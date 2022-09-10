@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart';
import 'package:dswitch/src/download_version.dart';
import 'package:test/test.dart';

void main() async {
  test('download version ...', () {
    withTempFile((file) {
      DownloadVersion('stable', '2.8.1', file).downloadDart(
          channel: 'stable',
          architecture: 'x64',
          platform: 'windows',
          version: '2.8.1');
    }, create: false);
  });
}
