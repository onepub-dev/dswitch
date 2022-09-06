/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../channel.dart';
import '../constants.dart';
import 'channel/status.dart';

class GlobalStatusCommand extends Command<void> {
  @override
  String get description => 'Provides status information for every channel.';

  @override
  String get name => 'status';

  @override
  void run() {
    for (final channel in channels) {
      final ch = Channel(channel);
      if (ch.isActive) {
        print(orange('The active channel is $channel on ${ch.currentVersion}'));
        print('');
      }
    }

    for (final channel in channels) {
      final ch = Channel(channel);
      if (ch.isDownloaded()) {
        StatusCommand.printStatus(channel);
        print('');
      } else {
        print(green('Channel $channel has not been installed.'));
      }
    }
  }
}
