/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../channel.dart';
import '../constants.dart';
import '../exceptions/exit.dart';
import '../first_run.dart';

class GlobalUseCommand extends Command<void> {
  GlobalUseCommand();

  @override
  String get description => '''
Switches to the passed channel.
  If the channel is already downloaded then DSwitch will switch to the latest locally cached version for the  channel.
  If the channel is not already downloaded, then the latest version for the channel will be downloaded and then DSwitch will switch to the channel.
   ''';

  @override
  String get name => 'use';

  @override
  Future<void> run() async {
    checkIsFullyInstalled();
    String channel;

    if (argResults!.rest.isEmpty || argResults!.rest.length != 1) {
      throw ExitException(
          1,
          'You may only pass a single channel name. '
          'Found ${argResults!.rest}',
          showUsage: true,
          argParser: argParser);
    }

    channel = argResults!.rest[0];
    if (!channels.contains(channel)) {
      throw ExitException(
          1, 'Channel $channel does not exist. Available channels: $channels',
          showUsage: false);
    }
    final ch = Channel(channel);

    if (ch.isActive) {
      print('You are already on the $channel channel.');
    } else {
      if (!ch.isDownloaded()) {
        final version = await ch.fetchLatestVersion();
        print(orange('Downloading latest version ($version) for $channel'));

        await ch.download(version);
        await ch.setCurrentVersion(version);
      }

      ch.use();
      print(green('Switched to $channel (${ch.currentVersion})'));

      print('');

      print(red('You may need to restart your terminal session.'));
    }
  }
}
