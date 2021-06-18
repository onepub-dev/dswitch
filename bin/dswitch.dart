#! /usr/bin/env dcli

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/first_run.dart';

void main(List<String> args) {
  var parser = ArgParser()
    ..addFlag('verbose',
        abbr: 'v', defaultsTo: false, help: 'Output verbose logging.');

  var parsed = parser.parse(args);

  Settings().setVerbose(enabled: parsed['verbose'] as bool);

  firstRun();
  doit(args);
}

void doit(List<String> args) async {
  var runner = buildCommandRunner();

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
    printerr(red('You must run as an Administrator or enable Developer Mode'));
    exit(1);
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
    var dartPaths = which('dart').paths;
    if (dartPaths.length > 1) {
      if (!dartPaths[0].startsWith(activeSymlinkPath)) {
        printerr(
            red('dswitch found another version of Dart that is being used.'));
        print(
            'Please check that the dswitch path is before any other dart paths');
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
