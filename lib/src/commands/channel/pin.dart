import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../commands.dart';

class PinCommand extends Command<void> {
  String channel;
  PinCommand(this.channel);

  @override
  String get description => '''
Selects the given version for the $channel channel and makes it the active version. 
  If the version isn't in the cache then it is downloaded.
  If you don't pass a version then a menu will be displayed with the list of locally cached versions for the $channel channel to select from.
  Pinning allows you to switch between version within the $channel channel. 
  Use the unpin command to revert to the latest version for the $channel channel.''';

  @override
  String get name => 'pin';

  @override
  void run() {
    String version;

    var ch = Channel(channel);

    if (argResults.rest.isNotEmpty) {
      if (argResults.rest.length != 1) {
        printerr(red(
            'You may only pass a single version no. Found ${argResults.rest}'));
        showUsage(argParser);
      }

      version = argResults.rest[0];
    } else {
      version = ch.select();
    }

    if (!ch.isVersionCached(version)) {
      printerr(red(
          "The selected version isn't installed. Use: dswitch install $channel $version"));
      exit(0);
    }

    ch.pin(version);
  }

  void installVersion(String version) {
    print('Installing $channel version $version...');
    var ch = Channel(channel);
    ch.download(version);
  }
}
