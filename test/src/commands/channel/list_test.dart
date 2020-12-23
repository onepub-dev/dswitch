import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('beta list', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'list']);
  });

  test('beta list --archive ', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'list', '--archive']);
  });
}
