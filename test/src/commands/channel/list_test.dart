import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('beta list', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'list']);
  });

  test('beta list --archive ', () async {
    final runner = buildCommandRunner();

    await runner.run(['beta', 'list', '--archive']);
  });
}
