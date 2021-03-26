import 'dart:convert';

import 'package:dcli/dcli.dart';
import 'package:pub_semver/pub_semver.dart';

class Release {
  Version? version;
  DateTime? released;
  late bool validRelease;

  Release(String jsonRelease) {
    validRelease = false;
    // later conside fetching the release details from:
    // https://storage.googleapis.com/dart-archive/channels/dev/release/latest/VERSION
    var parts = split(jsonRelease);
    try {
      /// ignore older version no.s
      if (jsonRelease.contains('.')) {
        version = Version.parse(parts[parts.length - 1]);
        validRelease = true;
      }
    } on FormatException catch (e) {
      /// early dart versions do not confirm to sematic versioning so we just ignore them.
      Settings().verbose(e.message);
    }
  }

  int compareTo(Release rhs) {
    return version!.compareTo(rhs.version!);
  }

  static List<Release> fetchReleases(String channel) {
    final releases = <Release>[];
    final saveToPath = FileSync.tempFile();
    fetch(url: buildURL(channel), saveToPath: saveToPath);

    var lines = read(saveToPath).toList();

    var json = jsonDecode(lines.join('\n')) as Map<String, dynamic>;

    var jsonReleases = json['prefixes'] as List<dynamic>;

    for (var jsonRelease in jsonReleases) {
      var release = Release(jsonRelease as String);
      if (release.validRelease) releases.add(release);
    }

    /// sort most recent first.
    releases.sort((lhs, rhs) => rhs.compareTo(lhs));
    releases.add(Release('1.0.0'));
    return releases;
  }

  static String buildURL(String channel) {
    return 'https://www.googleapis.com/storage/v1/b/dart-archive/o?delimiter=%2F&prefix=channels%2F$channel%2Frelease%2F&alt=json';
  }
}
