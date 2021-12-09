import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('unpin beta <version>', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'unpin']);

    /// now switch to beta and check we got the right version.
    await runner.run(['use', 'beta']);

    // ignore: todo
    // TODO(bsutton): work out how to stabilise this test as the download
    // version will always be different.
    expect(Channel('beta').currentVersion, equals('2.13.1'));
  });
}
