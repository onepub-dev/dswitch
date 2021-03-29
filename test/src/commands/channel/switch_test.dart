@Timeout(Duration(minutes: 2))
import 'package:dswitch/src/channel.dart';

import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('switch To beta', () async {
    var runner = buildCommandRunner();

    await runner.run(['use', 'beta']);

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);

    await runner.run(['beta', 'install', '2.8.1']);

    await runner.run(['beta', 'pin', '2.8.1']);

    expect(Channel('beta').currentVersion, equals('2.8.1'));
  });
}
