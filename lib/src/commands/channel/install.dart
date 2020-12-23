import 'package:args/command_runner.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';

class InstallCommand extends Command<void> {
  String channel;
  InstallCommand(this.channel) {
    argParser.addFlag('select',
        abbr: 's',
        help: 'Displays a list of available releases that you can select from');
  }

  @override
  String get description => '''
Installs the given version for the $channel channel but does not switch to it.
If you don't provide a version then the latest version is installed.
If you pass the --select switch then a menu is displayed with the version available for download.''';

  @override
  String get name => 'install';

  @override
  void run() {
    if (argResults.wasParsed('select')) {
      select();
    }

    if (argResults.rest.isNotEmpty) {
      if (argResults.rest.length != 1) {
        printerr(red(
            'You may only pass a single version no. Found ${argResults.rest}'));
        showUsage(argParser);
      }

      var version = argResults.rest[0];
      installVersion(version);
    } else {
      installChannel(channel);
    }
  }

  void installChannel(String channel) {
    var ch = Channel(channel);
    ch.install();
  }

  void select() {
    var ch = Channel(channel);

    ch.download(ch.select());
  }

  void installVersion(String version) {
    print('Installing $channel version $version...');
    var ch = Channel(channel);
    ch.download(version);
  }
}
