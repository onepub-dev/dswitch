#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:dswitch/dswitch.dart';
import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/exceptions/exit.dart';
import 'package:dswitch/src/settings.dart';
import 'package:path/path.dart';
import 'package:pubspec_manager/pubspec_manager.dart';

void main(List<String> args) async {
  final argParser = ArgParser()
    ..addFlag('verbose',
        abbr: 'v', negatable: false, help: 'Dump verbose logging information')
    ..addOption('stage2', help: 'Stage 2', hide: true)
    ..addOption('home', help: 'Users home directory.', hide: true);
  try {
    await run(args, argParser);
  } on ExitException catch (e) {
    String message;
    if (e.code == 0) {
      message = green(e.message);
    } else {
      message = red(e.message);
    }
    printerr(message);
    if (e.showUsage) {
      showUsage(e.argParser ?? argParser);
    }
  }
}

Future<void> run(List<String> args, ArgParser argParser) async {
  final ArgResults parsed;
  try {
    parsed = argParser.parse(args);
  } on FormatException catch (e) {
    throw ExitException(1, red('Invalid command line option: ${e.message}'),
        showUsage: true, argParser: argParser);
  }
  Settings().setVerbose(enabled: parsed['verbose'] as bool);

  if (!parsed.wasParsed('stage2')) {
    runStage1();
  } else {
    final pathToDSwitch = parsed['stage2'] as String;
    final pathToHome = parsed['home'] as String;
    await runStage2(pathToDSwitch, pathToHome: pathToHome);

    throw ExitException(0, 'Stage2 Completed successfully', showUsage: false);
  }

  print(orange('dswitch is ready to run'));
}

void runStage1() {
  if (!Shell.current.isPrivilegedUser) {
    if (io.Platform.isWindows) {
      throw ExitException(
          1, 'Please run dswitch_install with Administrative privileges.',
          showUsage: false);
    }
  }

  if (!exists(dirname(pathToSettings))) {
    createDir(dirname(pathToSettings));
  }
  // build the path to the copy of bin/dswitch.dart in the pub cache.
  late final String pathToDSwitch;

  if (DartScript.self.isPubGlobalActivated) {
    pathToDSwitch = join(
      DartProject.fromCache('dswitch', packageVersion).pathToProjectRoot,
    );
  } else {
    /// Used when we are testing from local source
    pathToDSwitch = dirname(dirname(DartScript.self.pathToScript));
    print('dswitch located in: ${DartScript.self.pathToScript}');
  }

  if (!exists(join(pathToDSwitch, 'bin', 'dswitch_install.dart'))) {
    throw ExitException(
        1,
        'Could not find dswitch_install in pub cache. Please run '
        "'dart pub global activate dswitch' and try again.",
        showUsage: false);
  }

  withTempDir((compileDir) {
    copyTree(pathToDSwitch, compileDir);

    hackPubspecForDev(pathToDSwitch, compileDir);
    final installScript =
        DartScript.fromFile(join(compileDir, 'bin', 'dswitch_install.dart'));
    print('');
    print(blue('Compiling dswitch_install from ${truepath(pathToDSwitch)}'));
    DartSdk().runPubGet(compileDir, progress: Progress.printStdErr());
    installScript.compile(workingDirectory: compileDir);

    print('');
    print(blue('Compiling dswitch'));
    final dswitchScript =
        DartScript.fromFile(join(compileDir, 'bin', 'dswitch.dart'))
          ..compile(workingDirectory: compileDir);

    // /// duplicate the script as we may not be able to copy ourselves
    // final duplicate =
    //     join(compileDir, '${script.basename}2${extension(script.basename)}');
    // copy(script.pathToExe, duplicate, overwrite: true);

    if (!io.Platform.isWindows) {
      print(green('Please provide your sudo password so we can install '
          'dswitch into your PATH'));
    }
    print('');
    var verboseSwitch = '';
    if (Settings().isVerbose) {
      verboseSwitch = '-v';
    }
    start(
        '${installScript.pathToExe} --stage2=${dswitchScript.pathToExe} '
        '$verboseSwitch --home="$HOME"',
        privileged: true);
  }, keep: true);
}

/// during development we often have a dependency_override
/// with  a relative path
/// to dcli. This hack changes the relative path to an absolute path
/// so the copied pubspec.yaml will still function.
void hackPubspecForDev(String pathToDSwitch, String compileDir) {
  final pathToPubspec = truepath(compileDir, 'pubspec.yaml');
  final pubspec = PubSpec.loadFromPath(pathToPubspec);

  if (pubspec.dependencyOverrides.exists('dcli')) {
    final overrides = pubspec.dependencyOverrides;

    final dcliDependenchy = overrides['dcli']! as DependencyPath;

    final absolutePathToDCli = truepath(pathToDSwitch, dcliDependenchy.path);
    (overrides['dcli']! as DependencyPath).path = absolutePathToDCli;

    pubspec.saveTo(pathToPubspec);
  }
}

/// In stage 2 we are running from a compiled exe as a privilged user.
Future<void> runStage2(String pathToDSwitch,
    {required String pathToHome}) async {
  final target = pathToInstallDir;

  if (!exists(pathToDSwitch)) {
    throw ExitException(
        1,
        'Could not find dswitch in pub cache. Please run '
        "'dart pub global activate dswitch' and try again.",
        showUsage: false);
  }

  print(blue('Installing dswitch into $target.'));
  // per 4.5 we installed to /usr/bin
  // so this is code to clean up old versions of dswitch if they exist.
  removeOldDSwitch();
  copy(pathToDSwitch, target, overwrite: true);
  // save the version no. that we just installed so
  // that dswtich can check its running the current
  // version each time it starts.
  Shell.current.releasePrivileges();
  await updateVersionNo(pathToHome);
  print('');
}

void removeOldDSwitch() {
  // per 4.5 we installed to /usr/bin
  // so this is code to clean up old versions of dswitch if they exist.
  if (exists(join(rootPath, 'usr', 'bin', 'dswitch'))) {
    try {
      delete(join(rootPath, 'usr', 'bin', 'dswitch'));
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      printerr('''
  Error trying to delete an old version of dswitch located at:
  /usr/bin/dswitch
  Please manually delete it as it may run instead of your newly installed
  version.
      ''');
    }
  }
}

String get pathToInstallDir {
  String target;
  if (io.Platform.isWindows) {
    target = join(
        env['USERPROFILE']!, 'AppData', 'Local', 'Microsoft', 'WindowsApps');
  } else {
    target = '/usr/local/bin';
  }
  return target;
}

Future<void> installDart() async {
  Channel? active;

  /// Check we have an installed and active version of dart.
  for (final channel in channels) {
    final ch = Channel(channel);
    if (ch.isActive) {
      active = ch;
    }
  }

  /// if we don't have an active version then install and make it active.
  if (active == null) {
    final channel = Channel('stable');
    await channel.installLatestVersion();
    channel.use();
  }
}
