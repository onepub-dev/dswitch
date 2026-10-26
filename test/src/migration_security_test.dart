import 'dart:io';

import 'package:dswitch/src/channel.dart';
import 'package:dswitch/src/commands/channel/delete.dart';
import 'package:dswitch/src/commands/global_enable.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dswitch/src/exceptions/exit.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

class _OfflineChannel extends Channel {
  _OfflineChannel() : super('stable');

  @override
  Future<String> fetchLatestVersion() async => '3.0.0';

  @override
  Future<void> download(String version) async {
    final destination = join(pathToVersions, version);
    File(join(destination, 'dart-sdk', 'bin', 'dart'))
      ..createSync(recursive: true)
      ..writeAsStringSync('new');
    File(join(destination, '.dswitch-complete'))
        .writeAsStringSync('$version\n');
  }
}

void main() {
  late Directory temporary;
  late String originalDswitchPath;
  late String originalActiveLink;

  setUp(() {
    temporary = Directory.systemTemp.createTempSync('dswitch migration test ');
    originalDswitchPath = dswitchPath;
    originalActiveLink = activeSymlinkPath;
    dswitchPath = join(temporary.path, '.dswitch');
    activeSymlinkPath = join(dswitchPath, 'active');
  });

  tearDown(() {
    dswitchPath = originalDswitchPath;
    activeSymlinkPath = originalActiveLink;
    temporary.deleteSync(recursive: true);
  });

  String legacyBin(Channel channel) {
    final oldBin = join(channel.pathToVersions, '2.8.1', 'dart-sdk', 'bin');
    File(join(oldBin, 'dart'))
      ..createSync(recursive: true)
      ..writeAsStringSync('old');
    Link(activeSymlinkPath).createSync(oldBin);
    return oldBin;
  }

  test('unpin leaves a legacy-only active version unchanged', () async {
    final channel = Channel('stable');
    await channel.setCurrentVersion('2.8.1');
    await channel.setPinned(pinned: true);
    final oldBin = legacyBin(channel);

    await expectLater(channel.unpin(), throwsA(isA<ExitException>()));

    expect(channel.currentVersion, '2.8.1');
    expect(channel.isPinned, isTrue);
    expect(Link(activeSymlinkPath).targetSync(), oldBin);
  }, skip: Platform.isWindows);

  test(
    'install latest updates active link and protects its actual target',
    () async {
      final channel = _OfflineChannel();
      await channel.setCurrentVersion('2.8.1');
      final oldBin = legacyBin(channel);

      await channel.installLatestVersion();

      final newBin = join(channel.pathToVersions, '3.0.0', 'dart-sdk', 'bin');
      expect(channel.currentVersion, '3.0.0');
      expect(Link(activeSymlinkPath).targetSync(), newBin);
      expect(Link(Channel.channelSymlink('stable')).targetSync(), newBin);

      // Protect the binary actually serving `dart` even if links and settings
      // are later made inconsistent by an older installation.
      Link(activeSymlinkPath)
        ..deleteSync()
        ..createSync(oldBin);
      expect(
        () => DeleteCommand('stable').deleteVersion('2.8.1'),
        throwsA(isA<ExitException>()),
      );
      expect(Directory(dirname(oldBin)).existsSync(), isTrue);
    },
    skip: Platform.isWindows,
  );

  test('upgrade reinstalls an incomplete current SDK', () async {
    final channel = _OfflineChannel();
    await channel.setCurrentVersion('3.0.0');
    final oldBin = legacyBin(channel);

    await channel.upgrade();

    final newBin = join(channel.pathToVersions, '3.0.0', 'dart-sdk', 'bin');
    expect(channel.isVersionCached('3.0.0'), isTrue);
    expect(Link(activeSymlinkPath).targetSync(), newBin);
    expect(Link(activeSymlinkPath).targetSync(), isNot(oldBin));
  }, skip: Platform.isWindows);

  test('switch preparation preserves a pinned legacy version', () async {
    final channel = _OfflineChannel();
    await channel.setCurrentVersion('2.8.1');
    await channel.setPinned(pinned: true);
    legacyBin(channel);

    expect(channel.isVersionCached('2.8.1'), isFalse);
    await channel.prepareForUse();

    expect(channel.isVersionCached('2.8.1'), isTrue);
    expect(channel.currentVersion, '2.8.1');
    expect(channel.isPinned, isTrue);
    expect(channel.isVersionCached('3.0.0'), isFalse);
    channel.use();
    expect(
      Link(activeSymlinkPath).targetSync(),
      join(channel.pathToVersions, '2.8.1', 'dart-sdk', 'bin'),
    );
  }, skip: Platform.isWindows);

  test('install latest preserves an active pinned legacy version', () async {
    final channel = _OfflineChannel();
    await channel.setCurrentVersion('2.8.1');
    await channel.setPinned(pinned: true);
    final oldBin = legacyBin(channel);

    await channel.installLatestVersion();

    expect(channel.currentVersion, '2.8.1');
    expect(channel.isPinned, isTrue);
    expect(channel.isVersionCached('2.8.1'), isTrue);
    expect(channel.isVersionCached('3.0.0'), isFalse);
    expect(Link(activeSymlinkPath).targetSync(), oldBin);
    expect(Link(Channel.channelSymlink('stable')).targetSync(), oldBin);
  }, skip: Platform.isWindows);

  test(
    'enable replaces an unset legacy selection with a verified SDK',
    () async {
      final stable = _OfflineChannel();
      final oldBin = legacyBin(stable);
      expect(stable.currentVersion, '0.0.1');

      await GlobalEnableCommand(
        channelFactory: (name) => name == 'stable' ? stable : Channel(name),
      ).run();

      final newBin = join(stable.pathToVersions, '3.0.0', 'dart-sdk', 'bin');
      expect(stable.currentVersion, '3.0.0');
      expect(stable.isVersionCached('3.0.0'), isTrue);
      expect(Link(activeSymlinkPath).targetSync(), newBin);
      expect(Link(Channel.channelSymlink('stable')).targetSync(), newBin);
      expect(Link(activeSymlinkPath).targetSync(), isNot(oldBin));
      expect(Link(Channel.channelSymlink('beta')).existsSync(), isFalse);
      expect(Link(Channel.channelSymlink('dev')).existsSync(), isFalse);
    },
    skip: Platform.isWindows,
  );
}
