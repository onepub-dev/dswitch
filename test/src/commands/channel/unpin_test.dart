import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('unpin beta <version>', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'unpin']);

    /// now switch to beta and check we got the right version.
    await runner.run(['beta', 'switch']);

    expect(Channel('beta').currentVersion, equals('2.8.0-20.11.beta'));
  });
}
