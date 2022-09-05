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
  test('unpin stable <version>', () async {
    final runner = buildCommandRunner();

    final channel = Channel('beta');
    final tuple = selectVersions(channel);

    await runner.run(['use', 'stable']);

    expect(Channel('stable').isActive, isTrue);

    // put us onto the lates installed version of beta.
    await runner.run(['beta', 'unpin']);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(tuple.latest));
    expect(channel.isActive, isFalse);

    await runner.run(['beta', 'pin', tuple.prior]);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(tuple.prior));
    expect(channel.isActive, isTrue);

    await runner.run(['beta', 'unpin']);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(tuple.latest));
    expect(channel.isActive, isTrue);

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);
    channel.reloadSettings;
    expect(channel.isActive, isTrue);

    expect(Channel('beta').currentVersion, equals(tuple.latest));

    // reset the system
    await runner.run(['use', 'stable']);
  });
}

/// select a version that we can install that isn't
/// currently active
Tuple selectVersions(Channel channel) {
  final releases = Release.fetchReleases(channel.name);

  late final latest = releases[0].version.toString();
  late final v2 = releases[1].version.toString();
  return Tuple(latest, v2);
}

class Tuple {
  Tuple(this.latest, this.prior);

  String latest;
  String prior;
}
