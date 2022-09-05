/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../exceptions/exit.dart';
import '../../first_run.dart';

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
        throw ExitException(
            1, 'You may not pass any args with the --select switch.',
            showUsage: true, argParser: argParser);
      }
      select();
    } else {
      if (argResults!.rest.isNotEmpty) {
        if (argResults!.rest.length != 1) {
          throw ExitException(
              1,
              'You may only pass a single version no. '
              'Found ${argResults!.rest}',
              showUsage: true,
              argParser: argParser);
        }

        final version = argResults!.rest[0];
        deleteVersion(version);
      } else {
        throw ExitException(
            1, 'You must pass a version no. or the --select flag',
            showUsage: true, argParser: argParser);
      }
    }
  }

  void deleteVersion(String version) {
    final ch = Channel(channel);

    if (ch.currentVersion == version) {
      throw ExitException(2, 'You may not delete the active version.',
          showUsage: false);
    }

    if (!ch.isVersionCached(version)) {
      throw ExitException(
          2,
          'Version $version has not been downloaded and so cannot be '
          'deleted.',
          showUsage: false);
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
