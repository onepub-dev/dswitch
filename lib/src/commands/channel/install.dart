import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../first_run.dart';

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
    checkIsFullyInstalled();
    if (argResults!.wasParsed('select')) {
      select();
    } else {
      if (argResults!.rest.isNotEmpty) {
        if (argResults!.rest.length != 1) {
          printerr(red(
              'You may only pass a single version no. Found ${argResults!.rest}'));
          showUsage(argParser);
        }

        var version = argResults!.rest[0];
        installVersion(version);
      } else {
        installLatestVersion(channel);
      }
    }
  }

  void installLatestVersion(String channel) {
    var ch = Channel(channel);
    ch.installLatestVersion();
  }

  void select() {
    var ch = Channel(channel);

    var selected = ch.selectToInstall();

    if (ch.isVersionCached(selected.version.toString())) {
      print(blue('The selected version is already installed.'));
    } else {
      ch.download(selected.version.toString());
    }
    print('Install of $channel channel complete.');
  }

  void installVersion(String version) {
    print('Installing $channel version $version...');
    var ch = Channel(channel);
    if (ch.isVersionCached(version)) {
      printerr(orange('The selected version is already installed.'));
      exit(0);
    }
    ch.download(version);
    print('Install of $channel channel complete. ');
  }
}
