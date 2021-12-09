import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('commands ...', () async {
    final runner = buildCommandRunner();

    await runner.run([]);

    await runner.run(['help', 'beta']);

    await runner.run(['help', 'beta', 'status']);
  });
}
