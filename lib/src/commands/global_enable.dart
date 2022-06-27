/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import '../channel.dart';

import '../constants.dart';

class GlobalEnableCommand extends Command<void> {
  GlobalEnableCommand();

  @override
  String get description => '''
Enables DSwitch, the Stable channel will be activated.
   ''';

  @override
  String get name => 'enable';

  @override
  void run() {
    channels.forEach(enableChannel);

    Channel('stable').use();
    print('DSwitch has been enabled. The Stable channel is now active');
  }

  void enableChannel(String name) {
    Channel(name).use();
  }
}
