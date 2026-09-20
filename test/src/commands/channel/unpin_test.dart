/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:dswitch/src/releases.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('unpin beta <version>', () async {
    final runner = buildCommandRunner();

    final channel = Channel('beta');
    final tuple = await selectVersions(channel);
    final prior = tuple.prior.toString();

    await runner.run(['use', 'stable']);
    addTearDown(() => runner.run(['use', 'stable']));

    expect(Channel('stable').isActive, isTrue);

    // Prepare both releases so pinning never prompts for a download, and
    // derive the unpin target from all cached versions, including newer ones.
    for (final version in [tuple.latest.toString(), prior]) {
      if (!channel.isVersionCached(version)) {
        await channel.download(version);
      }
    }
    final latest = channel.latestVersion;

    // put us onto the latest installed version of beta.
    await runner.run(['beta', 'unpin']);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(latest));
    expect(channel.isActive, isFalse);

    await runner.run(['use', 'beta']);
    await runner.run(['beta', 'pin', prior]);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(prior));
    expect(channel.isPinned, isTrue);
    expect(channel.isActive, isTrue);

    await runner.run(['beta', 'unpin']);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(latest));
    expect(channel.isPinned, isFalse);
    expect(channel.isActive, isTrue);

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);
    channel.reloadSettings;
    expect(channel.isActive, isTrue);

    expect(Channel('beta').currentVersion, equals(latest));

    // reset the system
    await runner.run(['use', 'stable']);
  });
}

/// select a version that we can install that isn't
/// currently active
Future<Tuple> selectVersions(Channel channel) async {
  final releases = await Release.fetchReleases(channel.name);

  Version? latest;
  Version? prior;

  final active = Version.parse(channel.currentVersion);
  for (final release in releases) {
    // we are looking for a version which isn't currently active.
    if (release.version == active) {
      continue;
    }

    if (latest == null) {
      latest = release.version;
      continue;
    }
    prior = release.version;

    break;
  }

  /// If nothing is cached then lastest and prior will be null.
  latest ??= releases.first.version;
  prior ??= releases[2].version;

  return Tuple(latest, prior);
}

class Tuple {
  Version latest;

  Version prior;

  Tuple(this.latest, this.prior);
}
