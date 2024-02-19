@Timeout(Duration(minutes: 30))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/releases.dart';
import 'package:test/test.dart';

void main() {
  test('beta install', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'install']);
  });

  test('beta install - select version', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'install', '--select']);

    /// can only be tested from the cmd line as requires user interaction.
  }, skip: true);

  test('stable install -  version', () async {
    final channel = Channel('stable');

    //find a version that isn't installed
    final version = await selectVersion(channel);

    final runner = buildCommandRunner();

    await runner.run(['stable', 'install', version]);
  });
}

/// select a version that we can install that isn't
/// currently active
Future<String> selectVersion(Channel channel) async {
  late String selected;
  final releases = await Release.fetchReleases(channel.name);

  final active = channel.currentVersion;
  for (final release in releases.reversed) {
    if (release.version.toString() != active) {
      selected = release.version.toString();
      if (channel.isVersionCached(selected)) {
        channel.delete(selected);
      }
    }
  }
  return selected;
}
