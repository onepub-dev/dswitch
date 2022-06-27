/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../channel.dart';
import '../constants.dart';
import '../first_run.dart';
import 'commands.dart';

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
  void run() {
    checkIsFullyInstalled();
    String channel;

    if (argResults!.rest.isEmpty || argResults!.rest.length != 1) {
      printerr(red('You may only pass a single channel name. '
          'Found ${argResults!.rest}'));
      showUsage(argParser);
    }

    channel = argResults!.rest[0];
    if (!channels.contains(channel)) {
      printerr(red(
          'Channel $channel does not exist. Available channels: $channels'));
      exit(1);
    }
    final ch = Channel(channel);

    if (ch.isActive) {
      print('You are already on the $channel channel.');
    } else {
      if (!ch.isDownloaded()) {
        final version = ch.fetchLatestVersion();
        print(orange('Downloading latest version ($version) for $channel'));

        ch
          ..download(version)
          ..currentVersion = version;
      }

      ch.use();
      print(green('Switched to $channel (${ch.currentVersion})'));

      print('');

      print(red('You may need to restart your terminal session.'));
    }
  }
}
