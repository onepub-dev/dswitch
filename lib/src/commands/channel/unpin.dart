import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../first_run.dart';

class UnpinCommand extends Command<void> {
  UnpinCommand(this.channel);
  String channel;

  @override
  String get description => '''
Unpins the $channel channel.
  Changes the channel to the latest locally cached version for the $channel channel.
  Use 'dswitch $channel upgrade' to download the latest version for the $channel channel after unpinning it.''';

  @override
  String get name => 'unpin';

  @override
  void run() {
    checkIsFullyInstalled();
    final ch = Channel(channel)..unpin();
    print(green('Channel $channel is now on ${ch.currentVersion}'));

    // if (ch.isActive) {
    //   print('\nPre-compiling dswitch against active dart version.');
    //   'pub global activate dswitch'.run;
    // }
  }
}
