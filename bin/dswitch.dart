#! /usr/bin/env dcli

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/constants.dart';

void main(List<String> args) {
  if (Platform.isWindows && !Shell.current.isPrivilegedUser) {
    print(run('You must run dswitch as an Administrator'));
    exit(1);
  }
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
  /// are we on the path
  if (!Env().isOnPATH(activePath)) {
    printerr(red('You need to add dswitch to your path.'));
    print('Prepend the following path to your PATH environment variable.');
    print(activePath);
  } else {
    // check for other instances of dart on the path.
    var dartPaths = which('dart').paths;
    if (dartPaths.length > 1) {
      if (!dartPaths[0].startsWith(activePath)) {
        printerr(
            red('dswitch found another version of Dart that is being used.'));
        print(
            'Please check that the dswitch path is before any other dart paths');
        print('Prepend the following path to your PATH environment variable.');
        print(activePath);
        print('');
      }
    }
  }
}
