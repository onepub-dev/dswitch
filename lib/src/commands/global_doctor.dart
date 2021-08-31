import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dswitch/dswitch.dart';

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
  void run() {
    print(green('DSwitch $packageVersion'));
    print('PATH: \n\t${PATH.join('\n\t')}');

    print('DSwitch Path: ${Platform.executable}');

    for (var channel in channels) {
      var ch = Channel(channel);
      if (ch.isActive) {
        print(green('The active channel is $channel on ${ch.currentVersion}'));
        print('');
      }
    }

    for (var channel in channels) {
      var ch = Channel(channel);
      if (ch.isDownloaded()) {
        StatusCommand.printStatus(channel);
        print('');
      } else {
        print(green('Channel $channel has not been installed.'));
      }
    }
  }
}
