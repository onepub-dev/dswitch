/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../first_run.dart';
import '../commands.dart';

class DeleteCommand extends Command<void> {
  DeleteCommand(this.channel) {
    argParser.addFlag('select',
        abbr: 's',
        help: 'Displays a list of available releases that you can select from');
  }
  String channel;

  @override
  String get description => '''
Deletes the given version for the $channel channel.
You cannot delete an active version.
If you pass the --select switch then a menu is displayed with the version available to delete.''';

  @override
  String get name => 'delete';

  @override
  void run() {
    checkIsFullyInstalled();
    if (argResults!.wasParsed('select')) {
      if (argResults!.rest.isNotEmpty) {
        printerr(red('You may not pass any args with the --select switch.'));
        showUsage(argParser);
      }
      select();
    } else {
      if (argResults!.rest.isNotEmpty) {
        if (argResults!.rest.length != 1) {
          printerr(red('You may only pass a single version no. '
              'Found ${argResults!.rest}'));
          showUsage(argParser);
        }

        final version = argResults!.rest[0];
        deleteVersion(version);
      } else {
        printerr(red('You must pass a version no. or the --select flag'));
        showUsage(argParser);
      }
    }
  }

  void deleteVersion(String version) {
    final ch = Channel(channel);

    if (ch.currentVersion == version) {
      printerr(red('You may not delete the active version.'));
      exit(-1);
    }

    if (!ch.isVersionCached(version)) {
      printerr(red('Version $version has not been downloaded and so cannot be '
          'deleted.'));
      exit(-1);
    }
    ch.delete(version);
    print('Version $version has been deleted.');
  }

  void select() {
    final ch = Channel(channel);

    final version = ch.selectFromInstalled();
    deleteVersion(basename(version));
  }
}
