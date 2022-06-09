/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dswitch/src/releases.dart';
import 'package:test/test.dart';

void main() {
  test('releases ...', () async {
    final releases = Release.fetchReleases('stable');

    for (final release in releases) {
      print(release.version);
    }
  });
}
