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
