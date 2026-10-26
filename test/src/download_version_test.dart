@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/download_version.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('download version ...', () async {
    final temporary = Directory.systemTemp.createTempSync('dswitch-download-');
    final originalPath = dswitchPath;
    try {
      dswitchPath = join(temporary.path, '.dswitch');
      final target = join(Channel.channelPath('stable'), 'versions', '2.8.1');
      final downloaded = await DownloadVersion('stable', '2.8.1', target)
          .downloadDart(
            channel: 'stable',
            architecture: 'x64',
            platform: 'windows',
            version: '2.8.1',
          );
      expect(File(downloaded).existsSync(), isTrue);
    } finally {
      dswitchPath = originalPath;
      temporary.deleteSync(recursive: true);
    }
  }, skip: Platform.environment['DSWITCH_NETWORK_TESTS'] != '1');
}
