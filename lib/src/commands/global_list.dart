import 'package:args/command_runner.dart';
import 'package:dswitch/src/commands/channel/list.dart';

import '../constants.dart';

class GlobalListCommand extends Command<void> {
  GlobalListCommand() {
    argParser.addFlag('archive',
        abbr: 'a',
        help: 'List all of the versions available in the Dart online archive');
  }

  @override
  String get description =>
      'List all of the locally cached version of Dart for all channels.';

  @override
  String get name => 'list';

  @override
  void run() {
    final showArchives = argResults!.wasParsed('archive');
    for (var channel in channels) {
      ListCommand.listForChannel(channel, showArchives: showArchives);
    }
  }
}
