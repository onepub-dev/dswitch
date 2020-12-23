import 'package:dswitch/src/commands/commands.dart';
import 'package:test/test.dart';

void main() {
  test('beta status', () async {
    var runner = buildCommandRunner();

    await runner.run(['beta', 'status']);
  });
}
