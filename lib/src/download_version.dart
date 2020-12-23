import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import 'channel.dart';

class DownloadVersion {
  /// The path to the 'latest' version for a channel.
  static const String latest = 'latest';
  String channel;
  String version;
  String saveToPath;

  DownloadVersion(this.channel, this.version, this.saveToPath);

  void download() {
    if (Platform.isLinux) {
      fetchLinuxChannel();
    }
    if (Platform.isWindows) {
      fetchWindowsChannel();
    }

    if (Platform.isMacOS) {
      fetchMacOSChannel();
    }
  }

  void fetchMacOSChannel() {
    downloadDart(
        channel: channel,
        platform: 'macos',
        version: version,
        architecture: 'x64');
  }

  void fetchWindowsChannel() {
    downloadDart(
        channel: channel,
        platform: 'windows',
        version: version,
        architecture: 'x64');
  }

  void fetchLinuxChannel() {
    downloadDart(
        channel: channel,
        platform: 'linux',
        version: version,
        architecture: 'x64');

    expandSdk();
  }

  void expandSdk() {
    if (!exists(saveToPath)) {
      createDir(saveToPath, recursive: true);
    }

    unzip(sdkDownloadPath(channel), saveToPath);
  }

  void unzip(String pathToZip, String targetPathTo) {
    print('Expanding release...');
    if (exists(targetPathTo)) {
      deleteDir(targetPathTo, recursive: true);
      createDir(targetPathTo, recursive: true);
    }
    if (which('unzip').found) {
      'unzip $pathToZip'
          .start(workingDirectory: targetPathTo, progress: Progress.devNull());
    } else {
      dunzip(pathToZip, targetPathTo);
    }
    print('Expansion complete.');
  }

  /// Unzip the file using the dart archive package.
  /// Problem is that it expands the entire archive in memory!
  void dunzip(String pathToZip, String targetPathTo) {
// Read the Zip file from disk.
    final bytes = File(pathToZip).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (final entity in archive) {
      final name = entity.name;
      if (entity.isFile) {
        final data = entity.content as List<int>;
        File(join(targetPathTo, name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(join(targetPathTo, name))..create(recursive: true);
      }
    }
  }

  void downloadDart(
      {String channel, String platform, String version, String architecture}) {
    var downloadPath = sdkDownloadPath(channel);

    if (!exists(dirname(downloadPath))) {
      createDir(dirname(downloadPath), recursive: true);
    }

    if (exists(downloadPath)) {
      delete(downloadPath);
    }
    var last = 0;
    fetch(
        url:
            'https://storage.googleapis.com/dart-archive/channels/$channel/release/$version/sdk/dartsdk-$platform-$architecture-release.zip',
        saveToPath: downloadPath,
        fetchProgress: (p) {
          var progress = (p.progress * 100).ceil();
          if (progress != last) {
            Terminal().clearLine();
            echo('$progress %');
            last = progress;
          }
        });
  }

  String sdkDownloadPath(String channel) =>
      join(Channel.channelPath(channel), '.downloads', '$version.zip');
}
