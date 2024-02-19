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

class PinCommand extends Command<void> {
  PinCommand(this.channel) {
    argParser.addFlag('force',
        help: 'If required, the pinned dart version is downloaded and '
            'installed without prompting the user.');
  }
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
  Future<void> run() async {
    checkIsFullyInstalled();
    String version;

    final ch = Channel(channel);

    if (argResults!.rest.isNotEmpty) {
      if (argResults!.rest.length != 1) {
        throw ExitException(
            1,
            'You may only pass a single version no. '
            'Found ${argResults!.rest}',
            showUsage: true,
            argParser: argParser);
      }

      version = argResults!.rest[0];
    } else {
      final release = await ch.selectToInstall();
      version = release.version.toString();
    }

    final force = argResults!['force'] as bool;

    if (!ch.isVersionCached(version)) {
      printerr(red("\nVersion $version isn't installed.\n"));
      if (force || confirm('Install $version')) {
        await installVersion(version);
      } else {
        throw ExitException(
            0, 'To install $version Use: dswitch $channel install $version\n',
            showUsage: false);
      }
    }

    await ch.pin(version);
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

  Future<void> installVersion(String version) async {
    print('Installing $channel version $version...');
    await Channel(channel).download(version);
  }
}
