import 'package:args/command_runner.dart';

import '../../channel.dart';
import '../../first_run.dart';

class UpgradeCommand extends Command<void> {
  String channel;
  UpgradeCommand(this.channel);

  @override
  String get description => '''
Upgrades the $channel channel to the latest version. 
  This command will not switch channels. 
  If the $channel channel is already active then dswitch will atomicly switch to the new version once it has been installed.
 If the $channel channel is pinned the upgrade action will have no affect, a warning will be displayed.''';

  @override
  String get name => 'upgrade';

  @override
  void run() {
    checkIsCompiled();
    var ch = Channel(channel);

    ch.upgrade();
  }
}
