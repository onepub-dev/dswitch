@Timeout(Duration(minutes: 5))
library;

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

    final beta = Channel('beta');
    final stable = Channel('stable');
    final originalVersion = stable.currentVersion;

    /// make certain we have viable versions of stable and beta.
    await stable.installLatestVersion();
    await beta.installLatestVersion();

    await runner.run(['use', 'stable']);

    final tuple = await selectVersions(beta);
    final latest = tuple.latest;
    final prior = tuple.prior;

    // download the prior version
    if (!beta.isVersionCached(prior.toString())) {
      await beta.download(prior.toString());
    }

    await beta.setCurrentVersion(prior.toString());

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);
    beta.reloadSettings;
    expect(beta.isActive, isTrue);
    expect(beta.currentVersion, equals(prior.toString()));
    if (beta.isVersionCached(latest.toString())) {
      beta.delete(latest.toString());
    }

    /// back to the stable channel so we can manipulate the beta channel
    /// without deleting dart from under ourself.
    stable.use();

    await runner.run(['beta', 'install', latest.toString()]);
    beta.reloadSettings;
    final postInstallVersion = beta.currentVersion;

    await runner.run(['beta', 'pin', prior.toString()]);
    beta.reloadSettings;
    expect(beta.currentVersion, equals(prior.toString()));

    await runner.run(['beta', 'unpin']);
    beta.reloadSettings;
    expect(beta.currentVersion, equals(postInstallVersion));

    await runner.run(['use', 'stable']);
    stable.reloadSettings;
    expect(stable.isActive, isTrue);
    expect(stable.currentVersion, equals(originalVersion));
  });
}
