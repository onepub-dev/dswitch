import 'package:dswitch/src/channel.dart';
@Timeout(Duration(minutes: 2))
import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('switch To beta', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'switch']);

    /// now switch to beta and check we got the right version.
    await runner.run(['beta', 'switch', '2.81.']);

    expect(Channel('beta').currentVersion, equals('2.8.1'));
  });
}
