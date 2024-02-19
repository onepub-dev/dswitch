/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';

import '../constants.dart';
import 'channel/list.dart';

class GlobalListCommand extends Command<void> {
  GlobalListCommand() {
    argParser.addFlag('archive',
        abbr: 'a',
        help: 'List all of the versions available in the Dart online archive');
  }

  @override
  String get description =>
      'List all of the locally cached version of Dart for all channels.';

  @override
  String get name => 'list';

  @override
  Future<void> run() async {
    final showArchives = argResults!.wasParsed('archive');
    for (final channel in channels) {
      await ListCommand.listForChannel(channel, showArchives: showArchives);
    }
  }
}
