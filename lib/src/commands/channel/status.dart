/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';

class StatusCommand extends Command<void> {
  StatusCommand(this.channel);
  String channel;

  @override
  String get description => '''
Displays the status of the $channel channel.
  The active version of the channel.
  Whether a later version is available for downloading.
  Whether the channel is pinned and the pinned version no.''';

  @override
  String get name => 'status';

  @override
  void run() {
    printStatus(channel);
  }

  static void printStatus(String channel) {
    final ch = Channel(channel);

    print(green('Status for channel $channel:'));
    print('Current Version: ${ch.currentVersion}');
    print('Is Pinned: ${ch.isPinned}');
    print('Lastest cached Version: ${ch.latestVersion}');
    print('Available for download: ${ch.fetchLatestVersion()}');
  }
}
