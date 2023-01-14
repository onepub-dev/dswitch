@Timeout(Duration(minutes: 5))
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

    final channel = Channel('beta');
    final stable = Channel('stable');
    final originalVersion = stable.currentVersion;

    await runner.run(['use', 'stable']);

    final tuple = selectVersions(channel);
    final latest = tuple.selected;
    final prior = tuple.prior;

    if (channel.isVersionCached(latest.toString())) {
      channel.delete(latest.toString());
    }

    if (!channel.isVersionCached(prior.toString())) {
      channel.download(prior.toString());
    }

    channel.currentVersion = prior.toString();

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);
    channel.reloadSettings;
    expect(channel.isActive, isTrue);
    expect(channel.currentVersion, equals(prior.toString()));

    await runner.run(['beta', 'install', latest.toString()]);
    channel.reloadSettings;
    final postInstallVersion = channel.currentVersion;

    await runner.run(['beta', 'pin', prior.toString()]);
    channel.reloadSettings;
    expect(channel.currentVersion, equals(prior.toString()));

    await runner.run(['beta', 'unpin']);
    channel.reloadSettings;
    expect(channel.currentVersion, equals(postInstallVersion.toString()));

    await runner.run(['use', 'stable']);
    stable.reloadSettings;
    expect(stable.isActive, isTrue);
    expect(stable.currentVersion, equals(originalVersion));
  });
}
