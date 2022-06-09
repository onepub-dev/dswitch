/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:convert';

import 'package:dcli/dcli.dart';
import 'package:pub_semver/pub_semver.dart';

Version unknown = Version(0, 0, 0);

class Release {
  Release(String jsonRelease) {
    validRelease = false;
    // later conside fetching the release details from:
    // https://storage.googleapis.com/dart-archive/channels/dev/release/latest/VERSION
    final parts = split(jsonRelease);
    try {
      /// ignore older version no.s
      if (jsonRelease.contains('.')) {
        version = Version.parse(parts[parts.length - 1]);
        validRelease = true;
      }
    } on FormatException catch (e) {
      version = unknown;

      /// early dart versions do not confirm to sematic versioning so we
      /// just ignore them.
      Settings().verbose(e.message);
    }
  }

  late final Version version;
  DateTime? released;
  late bool validRelease;
  int compareTo(Release rhs) => version.compareTo(rhs.version);

  static List<Release> fetchReleases(String channel) {
    final releases = <Release>[];
    withTempFile((saveToPath) {
      fetch(url: buildURL(channel), saveToPath: saveToPath);

      final lines = read(saveToPath).toList();

      final json = jsonDecode(lines.join('\n')) as Map<String, dynamic>;

      final jsonReleases = json['prefixes'] as List<dynamic>;

      for (final jsonRelease in jsonReleases) {
        final release = Release(jsonRelease as String);
        if (release.validRelease) {
          releases.add(release);
        }
      }
    }, create: false);

    /// sort most recent first.
    releases
      ..sort((lhs, rhs) => rhs.compareTo(lhs))
      ..add(Release('1.0.0'));
    return releases;
  }

  static String buildURL(String channel) =>
      'https://www.googleapis.com/storage/v1/b/dart-archive/o?delimiter=%2F&prefix=channels%2F$channel%2Frelease%2F&alt=json';
}
