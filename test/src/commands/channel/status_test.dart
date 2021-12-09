import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('beta status', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'status']);
  });
}
