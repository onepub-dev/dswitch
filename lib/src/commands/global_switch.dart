import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../channel.dart';
import 'commands.dart';

class GlobalSwitchCommand extends Command<void> {
  GlobalSwitchCommand();

  @override
  String get description => '''
Switches to the passed channel.
  If the channel is already downloaded then DSwitch will switch to the latest locally cached version for the  channel.
  If the channel is not already downloaded, then the latest version for the channel will be downloaded and then DSwitch will switch to the channel.
   ''';

  @override
  String get name => 'switch';

  @override
  void run() {
    String channel;

    if (argResults.rest.isEmpty || argResults.rest.length != 1) {
      printerr(red(
          'You may only pass a single channel name. Found ${argResults.rest}'));
      showUsage(argParser);
    }

    channel = argResults.rest[0];
    var ch = Channel(channel);

    if (!ch.isDownloaded()) {
      print(orange('Downloading latest version for $channel'));
      final version = ch.fetchLatestVersion();
      ch.download(version);
      ch.currentVersion = version;
    }

    ch.switchTo();
    print('Switched to $channel ${ch.currentVersion}');

    print('');

    print(
        'You may need to restart your terminal session if your shell hashes the location of exes.');
  }
}
