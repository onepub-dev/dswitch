@Timeout(Duration(minutes: 30))
import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('beta install', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'install']);
  });

  test('beta install - select version', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'install', '--select']);

    /// can only be tested from the cmd line as requires user interaction.
  }, skip: true);

  test('beta install -  version', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'install', '2.8.1']);
  });
}
