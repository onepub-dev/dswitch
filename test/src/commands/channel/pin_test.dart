import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

import 'unpin_test.dart';

void main() {
  test('pin beta <version>', () async {
    final runner = buildCommandRunner();
    await runner.run(['use', 'stable']);

    final channel = Channel('beta');

    final tuple = await selectVersions(channel);

    final pinTo = tuple.prior.toString();

    await runner.run(['beta', 'pin', pinTo]);

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);
    channel.reloadSettings;

    expect(channel.currentVersion, equals(pinTo));

    // reset our environment.
    await runner.run(['use', 'stable']);
  });
}
