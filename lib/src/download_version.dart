/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

// darchive 3.1.x provides bounded ZIP preflight, extraction and CRC checks.
// ignore: implementation_imports
import 'package:darchive/src/safe_extractor.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:system_info2/system_info2.dart';

import 'channel.dart';
import 'exceptions/exit.dart';
import 'validation.dart';

class DownloadVersion {
  static const latest = 'latest';
  static const int maxSdkBytes = 2 * 1024 * 1024 * 1024;

  final String channel;
  final String version;
  final String saveToPath;

  DownloadVersion(String channel, String version, this.saveToPath)
    : channel = validatedChannel(channel),
      version = validatedSdkVersion(version);

  Future<void> download() async {
    if (Platform.isLinux) {
      await _downloadAndExpand('linux');
    } else if (Platform.isWindows) {
      await _downloadAndExpand('windows');
    } else if (Platform.isMacOS) {
      await _downloadAndExpand('macos');
    } else {
      throw UnsupportedError('Unsupported operating system');
    }
  }

  Future<void> _downloadAndExpand(String platform) async {
    final archivePath = await downloadDart(
      channel: channel,
      platform: platform,
      version: version,
      architecture: resolveArchitecture(),
    );
    try {
      await unzip(archivePath, saveToPath);
    } finally {
      final downloadDirectory = Directory(dirname(archivePath));
      if (downloadDirectory.existsSync()) {
        downloadDirectory.deleteSync(recursive: true);
      }
    }
  }

  /// Installs a validated SDK only after its ZIP has been fully extracted.
  Future<void> unzip(String pathToZip, String targetPathTo) async {
    final versionsRoot = normalize(
      absolute(join(Channel.channelPath(channel), 'versions')),
    );
    final target = normalize(absolute(targetPathTo));
    if (!isWithin(versionsRoot, target) || basename(target) != version) {
      throw ArgumentError.value(
        targetPathTo,
        'targetPathTo',
        'Unsafe SDK path',
      );
    }

    final parent = Directory(dirname(target))..createSync(recursive: true);
    final stageRoot = parent.createTempSync('.dswitch-stage-');
    Directory? backupRoot;
    try {
      final extracted = join(stageRoot.path, 'sdk');
      await extractSafely(
        archivePath: pathToZip,
        destination: extracted,
        overwrite: false,
        maxBytes: maxSdkBytes,
      );
      final dartBinary = join(
        extracted,
        'dart-sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      );
      if (FileSystemEntity.typeSync(dartBinary, followLinks: false) !=
          FileSystemEntityType.file) {
        throw const FormatException('ZIP does not contain a Dart SDK');
      }
      _ensureSdkExecutables(extracted);
      File(
        join(extracted, '.dswitch-complete'),
      ).writeAsStringSync('$version\n');

      final targetType = FileSystemEntity.typeSync(target, followLinks: false);
      if (targetType != FileSystemEntityType.notFound &&
          targetType != FileSystemEntityType.directory) {
        throw FileSystemException('SDK destination is not a directory', target);
      }
      if (targetType == FileSystemEntityType.directory) {
        backupRoot = parent.createTempSync('.dswitch-backup-');
        Directory(target).renameSync(join(backupRoot.path, 'previous'));
      }
      try {
        Directory(extracted).renameSync(target);
      } catch (_) {
        if (backupRoot != null) {
          Directory(join(backupRoot.path, 'previous')).renameSync(target);
        }
        rethrow;
      }
      if (backupRoot != null) {
        backupRoot.deleteSync(recursive: true);
        backupRoot = null;
      }
    } finally {
      if (stageRoot.existsSync()) {
        stageRoot.deleteSync(recursive: true);
      }
      if (backupRoot != null &&
          backupRoot.existsSync() &&
          !Directory(join(backupRoot.path, 'previous')).existsSync()) {
        backupRoot.deleteSync();
      }
    }
    print('Expansion complete.');
  }

  void _ensureSdkExecutables(String extracted) {
    if (Platform.isWindows) {
      return;
    }
    for (final relative in [
      ['bin', 'dart'],
      ['bin', 'dartaotruntime'],
      ['bin', 'utils', 'gen_snapshot'],
      ['bin', 'utils', 'wasm-opt'],
    ]) {
      final executable = joinAll([extracted, 'dart-sdk', ...relative]);
      if (FileSystemEntity.typeSync(executable, followLinks: false) ==
          FileSystemEntityType.file) {
        final result = Process.runSync('chmod', ['+x', executable]);
        if (result.exitCode != 0) {
          throw FileSystemException(
            'Could not make SDK executable',
            executable,
          );
        }
      }
    }
  }

  /// Downloads into a private temporary directory. The caller owns cleanup.
  Future<String> downloadDart({
    required String channel,
    required String platform,
    required String version,
    required String architecture,
  }) async {
    if (validatedChannel(channel) != this.channel ||
        validatedSdkVersion(version) != this.version) {
      throw ArgumentError('Download request does not match the SDK target');
    }
    final downloads = Directory(
      join(Channel.channelPath(channel), '.downloads'),
    )..createSync(recursive: true);
    final temporary = downloads.createTempSync('sdk-');
    final archivePath = join(temporary.path, 'dart-sdk.zip');
    var completed = false;
    var last = 0;
    try {
      await fetch(
        url:
            'https://storage.googleapis.com/dart-archive/channels/$channel/release/$version/sdk/dartsdk-$platform-$architecture-release.zip',
        saveToPath: archivePath,
        fetchProgress: (p) {
          final progress = (p.progress * 100).ceil();
          if (progress != last) {
            clearLine();
            echo('Fetching: $progress %');
            last = progress;
          }
        },
      );
      completed = true;
      return archivePath;
    } on FetchException catch (e) {
      if (e.errorCode == 404) {
        throw ExitException(
          1,
          'The version $version does not exist. Run '
          "'dswitch $channel list -a' to see available versions.",
          showUsage: false,
        );
      }
      rethrow;
    } finally {
      if (!completed && temporary.existsSync()) {
        temporary.deleteSync(recursive: true);
      }
      print('');
    }
  }
}

void clearLine() {
  write('\r');
  write('${Ansi.esc}2K');
}

void write(String text) => stdout.write(text);

/// Converts the kernel architecture into a Dart SDK archive name.
String resolveArchitecture() {
  if (Platform.isMacOS) {
    return 'x64';
  } else if (Platform.isWindows) {
    if (SysInfo.kernelBitness == 32) {
      return 'ia32';
    } else {
      return 'x64';
    }
  } else {
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
      '${SysInfo.rawKernelArchitecture} is not a supported architecture.',
    );
  }
}
