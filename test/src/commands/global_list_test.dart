import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('global list ...', () async {
    var runner = buildCommandRunner();

    await runner.run(['list']);
  });

  test('global list - show archives', () async {
    var runner = buildCommandRunner();

    await runner.run(['list', '--archive']);
  });
}
