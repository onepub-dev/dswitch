#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/first_run.dart';

void main(List<String> args) {
  firstRun();
  doit(args);
}

Future<void> doit(List<String> args) async {
  final runner = buildCommandRunner();

  ArgResults parsed;
  try {
    parsed = runner.parse(args);
  } on FormatException catch (e) {
    printerr(red(e.message));
    showUsage(runner.argParser);
    exit(1);
  }
  Settings().setVerbose(enabled: parsed['verbose'] as bool);

  if (parsed['verbose'] as bool) {
    print('verbose');
    showUsage(runner.argParser);
    exit(0);
  }

  checkConfig();

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    printerr(red(e.message));

    print(e.usage);
    exit(1);
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
