import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../channel.dart';
import '../constants.dart';
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
    String channel;

    if (argResults.rest.isEmpty || argResults.rest.length != 1) {
      printerr(red(
          'You may only pass a single channel name. Found ${argResults.rest}'));
      showUsage(argParser);
    }

    channel = argResults.rest[0];
    if (!channels.contains(channel)) {
      printerr(red(
          'Channel $channel does not exist. Available channels: $channels'));
      exit(1);
    }
    var ch = Channel(channel);

    if (ch.isActive) {
      print('You are already on the $channel channel.');
    } else {
      if (!ch.isDownloaded()) {
        final version = ch.fetchLatestVersion();
        print(orange('Downloading latest version ($version) for $channel'));

        ch.download(version);
        ch.currentVersion = version;
      }

      ch.use();
      print(green('Switched to $channel (${ch.currentVersion})'));

      /// TODO: consider compiling dswitch

      print(green('precompiling dswitch against the new dart version'));

      'pub global activate dswitch'.run;

      print('');

      print(red('You may need to restart your terminal session.'));
    }
  }
}
