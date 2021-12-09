import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../releases.dart';

class ListCommand extends Command<void> {
  ListCommand(this.channel) {
    argParser.addFlag('archive',
        abbr: 'a',
        help: 'List all of the versions available in the Dart online archive');
  }
  String channel;

  @override
  String get description => 'List all of the locally cached version of '
      'Dart for the $channel channel.';

  @override
  String get name => 'list';

  @override
  void run() {
    final showArchives = argResults!.wasParsed('archive');

    listForChannel(channel, showArchives: showArchives);
  }

  static void listForChannel(String channel, {required bool showArchives}) {
    final ch = Channel(channel);

    print('');
    print(green('Channel $channel'));
    if (showArchives) {
      final releases = Release.fetchReleases(channel);

      print('Available to download:');

      if (releases.isEmpty) {
        print(orange('None found.'));
      } else {
        for (final release in releases) {
          print(basename(release.version.toString()));
        }
      }
    } else {
      final versions = ch.cachedVersions();
      print('Cached Locally:');
      if (versions.isEmpty) {
        print(orange('None found.'));
      } else {
        for (final version in versions) {
          print(basename(version));
        }
      }
    }
  }
}
