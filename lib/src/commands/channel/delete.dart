import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../first_run.dart';
import '../commands.dart';

class DeleteCommand extends Command<void> {
  String channel;
  DeleteCommand(this.channel) {
    argParser.addFlag('select',
        abbr: 's',
        help: 'Displays a list of available releases that you can select from');
  }

  @override
  String get description => '''
Deletes the given version for the $channel channel.
You cannot delete an active version.
If you pass the --select switch then a menu is displayed with the version available to delete.''';

  @override
  String get name => 'delete';

  @override
  void run() {
    checkIsCompiled();
    if (argResults!.wasParsed('select')) {
      if (argResults!.rest.isNotEmpty) {
        printerr(red('You may not pass any args with the --select switch.'));
        showUsage(argParser);
      }
      select();
    } else {
      if (argResults!.rest.isNotEmpty) {
        if (argResults!.rest.length != 1) {
          printerr(red(
              'You may only pass a single version no. Found ${argResults!.rest}'));
          showUsage(argParser);
        }

        var version = argResults!.rest[0];
        deleteVersion(version);
      } else {
        printerr(red('You must pass a version no. or the --select flag'));
        showUsage(argParser);
      }
    }
  }

  void deleteVersion(String version) {
    var ch = Channel(channel);

    if (ch.currentVersion == version) {
      printerr(red('You may not delete the active version.'));
      exit(-1);
    }

    if (!ch.isVersionCached(version)) {
      printerr(red(
          'Version $version has not been downloaded and so cannot be deleted.'));
      exit(-1);
    }
    ch.delete(version);
    print('Version $version has been deleted.');
  }

  void select() {
    var ch = Channel(channel);

    var version = ch.selectFromInstalled();
    deleteVersion(basename(version));
  }
}
