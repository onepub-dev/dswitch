@Timeout(Duration(minutes: 2))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dswitch/src/channel.dart';

import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('switch To beta', () async {
    final runner = buildCommandRunner();

    await runner.run(['use', 'beta']);

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);

    await runner.run(['beta', 'install', '2.8.1']);

    await runner.run(['beta', 'pin', '2.8.1']);

    expect(Channel('beta').currentVersion, equals('2.8.1'));
  });
}
