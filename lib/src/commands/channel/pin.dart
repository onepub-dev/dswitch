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

class PinCommand extends Command<void> {
  PinCommand(this.channel);
  String channel;

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
    checkIsFullyInstalled();
    String version;

    final ch = Channel(channel);

    if (argResults!.rest.isNotEmpty) {
      if (argResults!.rest.length != 1) {
        printerr(red('You may only pass a single version no. '
            'Found ${argResults!.rest}'));
        showUsage(argParser);
      }

      version = argResults!.rest[0];
    } else {
      version = ch.selectToInstall().version.toString();
    }

    if (!ch.isVersionCached(version)) {
      printerr(red("\nVersion $version isn't installed.\n"));
      if (confirm('Install $version')) {
        installVersion(version);
      } else {
        print(green(
            'To install $version Use: dswitch $channel install $version\n'));
        exit(0);
      }
    }

    ch.pin(version);
    print(green('Channel $channel is now pinned to $version'));

    if (!ch.isActive) {
      if (confirm(orange("The $channel isn't currently active. "
          'Do you want to activate it?'))) {
        ch.use();
      }
    }

    // if (ch.isActive) {
    //   print('\nPre-compiling dswitch against active dart version.');
    //   'pub global activate dswitch'.run;
    // }
  }

  void installVersion(String version) {
    print('Installing $channel version $version...');
    Channel(channel).download(version);
  }
}
