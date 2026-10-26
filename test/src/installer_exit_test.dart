import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('installer reports invalid options with a failing process status', () {
    final packageConfig = File('.dart_tool/package_config.json').absolute.path;
    final result = Process.runSync(Platform.resolvedExecutable, [
      '--packages=$packageConfig',
      'bin/dswitch_install.dart',
      '--invalid-option',
    ], workingDirectory: Directory.current.path);

    expect(result.exitCode, isNot(0));
    expect(result.stderr as String, contains('Invalid command line option'));
  });

  test('installer reports a missing stage-two home with a failing status', () {
    final packageConfig = File('.dart_tool/package_config.json').absolute.path;
    final result = Process.runSync(Platform.resolvedExecutable, [
      '--packages=$packageConfig',
      'bin/dswitch_install.dart',
      '--stage2=/tmp/dswitch',
    ], workingDirectory: Directory.current.path);

    expect(result.exitCode, isNot(0));
    expect(
      result.stderr as String,
      contains('requires both --stage2 and --home'),
    );
  });
}
