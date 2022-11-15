/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';

class StatusCommand extends Command<void> {
  StatusCommand();

  @override
  String get description => '''
Displays the project's dart version and whether it has been pinned.
  ''';

  @override
  String get name => 'status';

  @override
  void run() {}

  static void printStatus(String channel) {
    final ch = Channel(channel);

    print(colour(channel, 'Status for channel $channel:'));
    print('Current Version: ${colour(channel, ch.currentVersion)}');
    print('Is Pinned: ${colourPinned(isPinned: ch.isPinned)}');
    print('Lastest cached Version: ${ch.latestVersion}');
    print('Available for download: ${ch.fetchLatestVersion()}');
  }

  static String colour(String channel, String message) {
    if (channel == 'stable') {
      return blue(message);
    } else if (channel == 'beta') {
      return cyan(message);
    } else if (channel == 'dev') {
      return magenta(message);
    }
    return green(message);
  }
}

String colourPinned({required bool isPinned}) =>
    isPinned ? orange('true') : green('false');
