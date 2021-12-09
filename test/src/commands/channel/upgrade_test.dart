@Timeout(Duration(minutes: 2))
import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('upgrade beta', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'upgrade']);
  });
}
