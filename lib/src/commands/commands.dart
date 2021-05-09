import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import '../version/version.g.dart';

import '../constants.dart';
import 'channel/channel.dart';
import 'global_list.dart';
import 'global_status.dart';
import 'global_use.dart';

CommandRunner buildCommandRunner() {
  var runner = CommandRunner<void>('dswitch',
      green('DSwitch $packageVersion manages Dart versions and channels'));

  runner.argParser.addFlag('verbose',
      abbr: 'v',
      help: 'Output debug information',
      negatable: false,
      callback: (verbose) => Settings().setVerbose(enabled: verbose));

  for (var channel in channels) {
    runner.addCommand(ChannelCommand(channel));
  }

  runner.addCommand(GlobalListCommand());
  runner.addCommand(GlobalStatusCommand());
  runner.addCommand(GlobalUseCommand());

  return runner;
}

void showUsage(ArgParser parser) {
  print('');
  print('Rapidly switches between dart channels.');
  print(orange(
      'Remember to restart your login session after you run dswitch for the first time'));
  print('');
  print('''
Examples:

/// switch to the latest 'local' beta channel. 
dswitch use beta

/// upgrade the beta channel without switching to it.
dswitch beta upgrade

/// install the latest beta channel without switching to it.
dswitch beta install

/// switch to the passed <version> of the beta channel, downloading it as necessary
dswitch beta pin <version>

/// revert to the latest beta channel version and switch to it.
dswitch beta unpin

/// list the set of versions available for the beta channel.
dswitch beta list



''');
  print(parser.usage);

  exit(1);
}
