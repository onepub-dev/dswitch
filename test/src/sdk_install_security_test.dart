import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/download_version.dart';
import 'package:dswitch/src/validation.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  late Directory temporary;
  late String originalDswitchPath;

  setUp(() {
    temporary = Directory.systemTemp.createTempSync('dswitch sdk test ');
    originalDswitchPath = dswitchPath;
    dswitchPath = join(temporary.path, '.dswitch');
  });

  tearDown(() {
    dswitchPath = originalDswitchPath;
    temporary.deleteSync(recursive: true);
  });

  String destination(String version) =>
      join(Channel.channelPath('stable'), 'versions', version);

  File makeZip(String filename, List<int> bytes) {
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(filename, bytes)..mode = 0x1ed);
    return File(join(temporary.path, 'sdk.zip'))
      ..writeAsBytesSync(ZipEncoder().encode(archive));
  }

  test('rejects local version traversal before filesystem changes', () {
    final victim = File(join(temporary.path, 'victim.zip'))
      ..writeAsStringSync('preserve');

    expect(() => validatedSdkVersion('../../victim'), throwsFormatException);
    expect(
      () => DownloadVersion('stable', '../../victim', destination('3.0.0')),
      throwsFormatException,
    );
    expect(victim.readAsStringSync(), 'preserve');
    expect(Directory(dswitchPath).existsSync(), isFalse);
  });

  test('failed extraction preserves an existing SDK and cache state', () async {
    final target = destination('3.0.0');
    final existingDart = File(join(target, 'dart-sdk', 'bin', 'dart'))
      ..createSync(recursive: true)
      ..writeAsStringSync('old');
    File(join(target, '.dswitch-complete')).writeAsStringSync('3.0.0\n');
    final downloader = DownloadVersion('stable', '3.0.0', target);
    final maliciousZip = makeZip('../outside', [1, 2, 3]);

    await expectLater(
      downloader.unzip(maliciousZip.path, target),
      throwsException,
    );
    expect(existingDart.readAsStringSync(), 'old');
    expect(File(join(temporary.path, 'outside')).existsSync(), isFalse);
    expect(Channel('stable').isVersionCached('3.0.0'), isTrue);
  });

  test('only a complete staged SDK becomes cached', () async {
    final target = destination('3.0.0');
    File(join(target, 'dart-sdk', 'bin', 'dart'))
      ..createSync(recursive: true)
      ..writeAsStringSync('incomplete');
    expect(Channel('stable').isVersionCached('3.0.0'), isFalse);

    final zip = makeZip('dart-sdk/bin/dart', [1, 2, 3]);
    await DownloadVersion('stable', '3.0.0', target).unzip(zip.path, target);

    final dart = File(join(target, 'dart-sdk', 'bin', 'dart'));
    expect(dart.readAsBytesSync(), [1, 2, 3]);
    if (!Platform.isWindows) {
      expect(dart.statSync().mode & 0x49, isNot(0));
    }
    expect(
      File(join(target, '.dswitch-complete')).readAsStringSync().trim(),
      '3.0.0',
    );
    expect(Channel('stable').isVersionCached('3.0.0'), isTrue);
  });
}
