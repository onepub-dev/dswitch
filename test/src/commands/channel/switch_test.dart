@Timeout(Duration(minutes: 2))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dswitch/src/channel.dart';

import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

import 'unpin_test.dart';

void main() {
  test('switch To beta', () async {
    final runner = buildCommandRunner();

    await runner.run(['use', 'stable']);

    final channel = Channel('beta');

    final tuple = selectVersions(channel);
    final latest = tuple.latest;
    final prior = tuple.prior;

    if (channel.isVersionCached(latest)) {
      channel.delete(latest);
    }

    if (!channel.isVersionCached(prior)) {
      channel.download(prior);
    }

    channel
      ..currentVersion = prior
      ..latestVersion = latest;

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);
    channel.reloadSettings;
    expect(channel.isActive, isTrue);
    expect(channel.currentVersion, equals(prior));

    await runner.run(['beta', 'install', latest]);

    await runner.run(['beta', 'pin', prior]);
    channel.reloadSettings;
    expect(channel.currentVersion, equals(prior));

    await runner.run(['beta', 'unpin']);
    channel.reloadSettings;
    expect(channel.currentVersion, equals(latest));

    await runner.run(['use', 'stable']);
    final stable = Channel('stable')..reloadSettings;
    expect(stable.isActive, isTrue);
    expect(stable.currentVersion, equals(stable.latestVersion));
  });
}
