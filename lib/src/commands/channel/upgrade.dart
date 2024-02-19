/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';

import '../../channel.dart';
import '../../first_run.dart';

class UpgradeCommand extends Command<void> {
  UpgradeCommand(this.channel);
  String channel;

  @override
  String get description => '''
Upgrades the $channel channel to the latest version. 
  This command will not switch channels. 
  If the $channel channel is already active then dswitch will atomicly switch to the new version once it has been installed.
 If the $channel channel is pinned the upgrade action will have no affect, a warning will be displayed.''';

  @override
  String get name => 'upgrade';

  @override
  Future<void> run() async {
    checkIsFullyInstalled();
    await Channel(channel).upgrade();
  }
}
