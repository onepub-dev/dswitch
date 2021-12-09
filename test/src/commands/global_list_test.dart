import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('global list ...', () async {
    final runner = buildCommandRunner();

    await runner.run(['list']);
  });

  test('global list - show archives', () async {
    final runner = buildCommandRunner();

    await runner.run(['list', '--archive']);
  });
}
