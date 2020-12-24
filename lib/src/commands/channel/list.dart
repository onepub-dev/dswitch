import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import '../../channel.dart';
import '../../releases.dart';

class ListCommand extends Command<void> {
  String channel;
  ListCommand(this.channel) {
    argParser.addFlag('archive',
        abbr: 'a',
        help: 'List all of the versions available in the Dart online archive');
  }

  @override
  String get description =>
      'List all of the locally cached version of Dart for the $channel channel.';

  @override
  String get name => 'list';

  @override
  void run() {
    final showARchives = argResults.wasParsed('archive');

    listForChannel(channel, showArchives: showARchives);
  }

  static void listForChannel(String channel, {bool showArchives}) {
    var ch = Channel(channel);

    if (showArchives) {
      var releases = Release.fetchReleases(channel);
      print(
          'The following versions for the $channel channel are available to download:');

      if (releases.isEmpty) {
        print(orange('None found.'));
      } else {
        for (var release in releases) {
          print(basename(release.version.toString()));
        }
      }
    } else {
      var versions = ch.cachedVersions();
      print(
          'The following versions for the $channel channel are cached locally:');
      if (versions.isEmpty) {
        print(orange('None found.'));
      } else {
        for (var version in versions) {
          print(basename(version));
        }
      }
    }
  }
}
