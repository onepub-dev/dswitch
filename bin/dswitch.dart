#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/exceptions/exit.dart';
import 'package:dswitch/src/first_run.dart';
import 'package:path/path.dart';

late final CommandRunner<void> runner;
Future<void> main(List<String> args) async {
  firstRun();
  runner = buildCommandRunner();
  try {
    await doit(args);
  } on ExitException catch (e) {
    final String message;
    if (e.code == 0) {
      message = green(e.message);
    } else {
      message = red(e.message);
    }
    printerr(message);
    if (e.showUsage) {
      showUsage(e.argParser ?? runner.argParser);
    }
  }
}

Future<void> doit(List<String> args) async {
  ArgResults parsed;
  try {
    parsed = runner.parse(args);
  } on UsageException catch (e) {
    final message = '''
${e.message}

${e.usage}''';
    throw ExitException(1, message, showUsage: false);
  } on FormatException catch (e) {
    throw ExitException(1, e.message, showUsage: true);
  }
  Settings().setVerbose(enabled: parsed['verbose'] as bool);

  checkConfig();

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    printerr(red(e.message));
    print(e.usage);
  }
}

void checkConfig() {
  if (Platform.isWindows &&
      !(Shell.current.isPrivilegedUser ||
          (Shell.current as WindowsMixin).inDeveloperMode())) {
    throw ExitException(
        1, 'You must run as an Administrator or enable Developer Mode',
        showUsage: false);
  }

  /// are we on the path
  if (!Env().isOnPATH(activeSymlinkPath)) {
    var missing = true;
    if (Platform.isWindows) {
      final canonical = canonicalize(activeSymlinkPath);
      if (regGetUserPath().map(canonicalize).contains(canonical)) {
        print(red('''

You need to restart your terminal so it can see the DSwitch PATH changes.
  '''));
        missing = false;
      }
    }
    if (missing) {
      printerr(red('You need to add dswitch to your path.'));

      printPlatformPathMessage();
    }
  } else {
    // check for other instances of dart on the path.
    final dartPaths = which('dart').paths;
    if (dartPaths.length > 1) {
      if (!dartPaths[0].startsWith(activeSymlinkPath)) {
        printerr(
            red('dswitch found another version of Dart that is being used.'));
        print('Please check that the dswitch path is '
            'before any other dart paths');
        print('Prepend the following path to your PATH environment variable.');
        print(activeSymlinkPath);
        print('');
      }
    }
  }
}

void printPlatformPathMessage() {
  if (Platform.isLinux || Platform.isMacOS) {
    print('Add the following to your shell start up script');
    print('export PATH=$activeSymlinkPath:"\$PATH"');
  } else if (Platform.isWindows) {
    print('Prepend the following path to your PATH environment variable.');
    print(activeSymlinkPath);
  }
}
