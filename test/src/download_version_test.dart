@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart';
import 'package:dswitch/src/download_version.dart';
import 'package:test/test.dart';

void main() {
  test('download version ...', () async {
    withTempFile((file) {
      DownloadVersion('stable', '2.8.0', file).downloadDart(
          channel: 'stable',
          architecture: 'x64a',
          platform: 'windows',
          version: '2.8.0');
    }, create: false);
  });
}
