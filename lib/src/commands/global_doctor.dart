/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../dswitch.dart';
import '../channel.dart';
import '../constants.dart';
import 'channel/status.dart';

class GlobalDoctorCommand extends Command<void> {
  GlobalDoctorCommand();

  @override
  String get description => '''
Prints details on how DSwitch is configured.
   ''';

  @override
  String get name => 'doctor';

  @override
  Future<void> run() async {
    print(green('DSwitch $packageVersion'));
    print('PATH: \n\t${PATH.join('\n\t')}');

    print('DSwitch Path: ${Platform.executable}');

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
        await StatusCommand.printStatus(channel);
        print('');
      } else {
        print(green('Channel $channel has not been installed.'));
      }
    }
  }
}
