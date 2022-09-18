/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'constants.dart';
import 'download_version.dart';
import 'exceptions/exit.dart';
import 'releases.dart';

/// Used to manage a channel
///

class Channel {
  Channel(this.name) {
    createPaths();
  }

  String name;

  /// Returns true if this is the active channel
  bool get isActive {
    try {
      return exists(activeSymlinkPath) &&
          (resolveSymLink(activeSymlinkPath).startsWith(pathToVersions));
    } on FileSystemException catch (e) {
      // the link target doesn't exist.
      if (e.osError != null && e.osError!.errorCode == 3) {
        return false;
      } else {
        rethrow;
      }
    }
  }

  void installLatestVersion() {
    if (isDownloaded()) {
      print(orange('Channel is already installed and the current version is: '
          '$currentVersion'));
    } else {
      final releases = Release.fetchReleases(name);
      final version = releases[0].version.toString();
      print('Installing $name ($version) ...');
      download(version);
      currentVersion = version;
      _createChannelSymlink();
      print('Install of $name channel complete.');
    }
  }

  void use() {
    _createActiveSymLink();

    /// they may never run install so we need to create this.
    _createChannelSymlink();
  }

  void pin(String version) {
    currentVersion = version;
    pinned = true;

    /// If we are the active channel then we need to update the active link.
    if (isActive) {
      _createActiveSymLink();
    }
    _createChannelSymlink();
  }

  void unpin() {
    currentVersion = latestVersion;
    pinned = false;

    /// If we are the active channel then we need to update the active link.
    if (isActive) {
      _createActiveSymLink();
    }
    _createChannelSymlink();
  }

  void _createChannelSymlink() {
    if (exists(_channelSymlink, followLinks: false)) {
      deleteSymlink(_channelSymlink);
    }

    symlink(pathToCurrentVersion, _channelSymlink);
  }

  void _createActiveSymLink() {
    if (exists(activeSymlinkPath, followLinks: false)) {
      deleteSymlink(activeSymlinkPath);
    }
    symlink(pathToCurrentVersion, activeSymlinkPath);
  }

  bool get isPinned => pinned == true;

  late SettingsYaml _settings =
      SettingsYaml.load(pathToSettings: _pathToSettings);

  /// Used by unit tests to force a reload of the settings when
  /// a spawned version of dswitch has updated it.
  @visibleForTesting
  void get reloadSettings =>
      _settings = SettingsYaml.load(pathToSettings: _pathToSettings);

  void createPaths() {
    createPath(dswitchPath);
    createPath(pathToVersions);
  }

  void validateChannel(ArgParser parser, String channel) {
    if (!channels.contains(channel)) {
      throw ExitException(1, 'Invalid command. $channel',
          showUsage: true, argParser: parser);
    }
  }

  void createPath(String pathTo) {
    if (!exists(pathTo)) {
      createDir(pathTo, recursive: true);
    }
  }

  /// Returns the path to this channel
  String get pathTo => channelPath(name);

  String get pathToVersions => join(pathTo, 'versions');

  String get pathToCurrentVersion =>
      join(_pathToVersionSdk(currentVersion), 'bin');

  String get _pathToSettings => join(pathTo, '.channel.yaml');

  String _pathToVersion(String version) => join(pathToVersions, version);

  String _pathToVersionSdk(String version) =>
      join(_pathToVersion(version), 'dart-sdk');

  /// Channel Symlink - ~/.dswitch/<channel>
  String get _channelSymlink => channelSymlink(name);

  static String channelSymlink(String channel) => join(dswitchPath, channel);

  /// Checks if the current version for the channel has
  /// been downloaded.
  bool isDownloaded() => isVersionCached(currentVersion);

  void download(String version) {
    DownloadVersion(name, version, _pathToVersion(version)).download();
  }

  /// Downloads the list of versions available for this channel
  /// and returns the must recent version.
  String fetchLatestVersion() {
    final releases = Release.fetchReleases(name);
    return releases[0].version.toString();
  }

  /// The current active version.
  /// This will normally be the same as the [latestVersion] unless
  /// this channel is pinned.
  String get currentVersion {
    var _version = _settings['currentVersion'] as String?;
    return _version ??= latestVersion;
  }

  set currentVersion(String version) {
    _settings['currentVersion'] = version;
    // ignore: discarded_futures
    waitForEx(_settings.save());
  }

  /// the most recent version we have downloaded.
  String get latestVersion {
    String? latest;
    if (cachedVersions().isNotEmpty) {
      latest = basename(cachedVersions().first);
    }
    return latest ?? '0.0.1';
  }

  /// If true then this channel is currently pinned.
  bool get pinned => _settings['pinned'] as bool? ?? false;

  set pinned(bool pinned) {
    _settings['pinned'] = pinned;
    // ignore: discarded_futures
    waitForEx(_settings.save());
  }

  static String channelPath(String channel) =>
      join(dswitchPath, 'channels', channel);

  /// returns a list of the version that are cached locally.
  List<String> cachedVersions() => find('*',
          workingDirectory: pathToVersions,
          types: [Find.directory],
          recursive: false)
      .toList()
    ..sort((a, b) =>
        Version.parse(basename(b)).compareTo(Version.parse(basename(a))));

  void delete(String version) {
    deleteDir(_pathToVersion(version));
  }

  /// Shows the user a menu with the 20 most recent version for the channel.
  ///
  /// Returns the version the user selected.
  Release selectToInstall() {
    final releases = Release.fetchReleases(name);

    final release = menu<Release>(
        prompt: 'Select Version to install:',
        options: releases,
        limit: 20,
        format: (release) => release.version.toString());
    return release;
  }

  /// Displays a menu of the currently cached version
  /// and asks the user to select one to install.
  String selectFromInstalled() {
    final version = menu<String>(
      prompt: 'Select Version:',
      options: cachedVersions(),
      format: basename,
      limit: 20,
    );
    return version;
  }

  bool isVersionCached(String version) =>
      cachedVersions().any((element) => basename(element) == version);

  void upgrade() {
    if (isPinned) {
      printerr(
          red('The $name is pinned. Unpin the channel first and try again'));
    } else {
      final version = fetchLatestVersion();

      if (version == currentVersion) {
        print('You are already on the latest version ($version) for the '
            '$name channel');
      } else {
        print('Downloading $version...');
        download(version);

        currentVersion = version;

        if (isActive) {
          /// if we are the active channel then calling swithTo
          /// will update the symlinks to the new version
          use();
        } else {
          _createChannelSymlink();
        }
        print('upgrade of $name channel to $version complete');
      }
    }
  }
}
