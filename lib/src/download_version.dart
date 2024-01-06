/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:system_info2/system_info2.dart';

import 'channel.dart';
import 'exceptions/exit.dart';

class DownloadVersion {
  DownloadVersion(this.channel, this.version, this.saveToPath);

  /// The path to the 'latest' version for a channel.
  static const String latest = 'latest';
  String channel;
  String version;
  String saveToPath;

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
        architecture: resolveArchitecture());
    expandSdk();
  }

  void fetchWindowsChannel() {
    downloadDart(
      channel: channel,
      platform: 'windows',
      version: version,
      architecture: resolveArchitecture(),
    );
    expandSdk();
  }

  void fetchLinuxChannel() {
    downloadDart(
        channel: channel,
        platform: 'linux',
        version: version,
        architecture: resolveArchitecture());

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
      deleteDir(targetPathTo);
      createDir(targetPathTo, recursive: true);
    }
    if (which('unzip').found) {
      'unzip $pathToZip'
          .start(workingDirectory: targetPathTo, progress: Progress.devNull());
    } else {
      dunzip(pathToZip, targetPathTo);
    }
    delete(pathToZip);

    /// recent dart archives don't seem to have the execute permission
    /// set.
    final pathToSdk = join(targetPathTo, 'dart-sdk', 'bin');
    if (!Platform.isWindows) {
      'chmod +x ${join(pathToSdk, 'dart')}'.run;
      'chmod +x ${join(pathToSdk, 'dartaotruntime')}'.run;
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
        createDir(join(targetPathTo, name), recursive: true);
      }
    }
  }

  void downloadDart(
      {required String channel,
      required String platform,
      required String version,
      required String architecture}) {
    final downloadPath = sdkDownloadPath(channel);

    if (!exists(dirname(downloadPath))) {
      createDir(dirname(downloadPath), recursive: true);
    }

    if (exists(downloadPath)) {
      delete(downloadPath);
    }
    var last = 0;

    try {
      fetch(
          url:
              'https://storage.googleapis.com/dart-archive/channels/$channel/release/$version/sdk/dartsdk-$platform-$architecture-release.zip',
          saveToPath: downloadPath,
          fetchProgress: (p) {
            final progress = (p.progress * 100).ceil();
            if (progress != last) {
              clearLine();
              echo('Fetching: $progress %');
              last = progress;
            }
          });
    } on FetchException catch (e) {
      if (e.errorCode == 404) {
        throw ExitException(
            1,
            '''

The Version $version does not exist.
Run 'dswitch $channel list -a' to see a list of versions.
''',
            showUsage: false);
      }
    }
    print('');
  }

  String sdkDownloadPath(String channel) =>
      join(Channel.channelPath(channel), '.downloads', '$version.zip');
}

void clearLine() {
  write('\r');
  write('${Ansi.esc}2K');
}

void write(String text) => stdout.write(text);

/// Converts the kernel architecture into one of the architecture names use
/// by:
/// https://dart.dev/tools/sdk/archive
String resolveArchitecture() {
  if (Platform.isMacOS) {
    return 'x64';
  } else if (Platform.isWindows) {
    if (SysInfo.kernelBitness == 32) {
      return 'ia32';
    } else {
      return 'x64';
    }
  } else // linux
  {
    final architecture = SysInfo.kernelArchitecture;
    if (architecture == ProcessorArchitecture.arm64) {
      return 'arm64';
    } else if (architecture == ProcessorArchitecture.arm) {
      return 'arm';
    } else if (architecture == ProcessorArchitecture.mips) {
      throw const OSError('Mips is not a supported architecture.');
    } else if (architecture == ProcessorArchitecture.x86) {
      return 'ia32';
    } else if (architecture == ProcessorArchitecture.ia64 ||
        architecture == ProcessorArchitecture.x86_64) {
      return 'x64';
    }
    throw OSError(
        '${SysInfo.rawKernelArchitecture} is not a supported architecture.');
  }
}
