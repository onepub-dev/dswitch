@Timeout(Duration(minutes: 5))
library;

import 'package:dcli/dcli.dart';
import 'package:dswitch/src/download_version.dart';
import 'package:test/test.dart';

void main() {
  test('download version ...', () async {
    await withTempFileAsync((file) async {
      await DownloadVersion('stable', '2.8.1', file).downloadDart(
          channel: 'stable',
          architecture: 'x64',
          platform: 'windows',
          version: '2.8.1');
    }, create: false);
  });
}
