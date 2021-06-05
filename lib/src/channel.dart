import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dswitch/src/constants.dart';
import 'package:dcli/dcli.dart' hide menu;
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'commands/commands.dart';
import 'download_version.dart';
import 'releases.dart';

/// Used to manage a channel
///

class Channel {
  String name;
  SettingsYaml? _settings;

  Channel(this.name) {
    createPaths();
  }

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
      print(orange(
          'Channel is already installed and the current version is: $currentVersion'));
    } else {
      var releases = Release.fetchReleases(name);
      var version = releases[0].version.toString();
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

  SettingsYaml get settings =>
      _settings ??= SettingsYaml.load(pathToSettings: pathToSettings);

  void createPaths() {
    createPath(dswitchPath);
    createPath(pathToVersions);
  }

  void validateChannel(ArgParser parser, String channel) {
    if (!channels.contains(channel)) {
      printerr(red('Invalid command. $channel'));
      showUsage(parser);
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

  String get pathToSettings => join(pathTo, '.channel.yaml');

  String _pathToVersion(String version) => join(pathToVersions, version);

  String _pathToVersionSdk(String version) =>
      join(_pathToVersion(version), 'dart-sdk');

  /// Channel Symlink - ~/.dswitch/<channel>
  String get _channelSymlink => channelSymlink(name);

  static String channelSymlink(String channel) => join(dswitchPath, channel);

  bool isDownloaded() => isVersionCached(currentVersion);

  void download(String version) {
    var downloader = DownloadVersion(name, version, _pathToVersion(version));
    downloader.download();

    if (Version.parse(version) > Version.parse(latestVersion)) {
      latestVersion = version;
    }
  }

  /// Downloads the list of versions available for this channel.
  String fetchLatestVersion() {
    final releases = Release.fetchReleases(name);
    return releases[0].version.toString();
  }

  /// The current active version.
  /// This will normally be the same as the [latestVersion] unless
  /// this channel is pinned.
  String get currentVersion {
    var _version = settings['currentVersion'] as String?;
    _version ??= latestVersion;
    return _version;
  }

  set currentVersion(String version) {
    settings['currentVersion'] = version;
    settings.save();
  }

  /// the most recent version we have downloaded.
  String get latestVersion => settings['latestVersion'] as String? ?? '0.0.1';

  set latestVersion(String version) {
    settings['latestVersion'] = version;
    settings.save();
  }

  /// If true then this channel is currently pinned.
  bool get pinned => settings['pinned'] as bool? ?? false;

  set pinned(bool pinned) {
    settings['pinned'] = pinned;
    settings.save();
  }

  static String channelPath(String channel) =>
      join(dswitchPath, 'channels', channel);

  /// returns a list of the version that are cached locally.
  List<String> cachedVersions() {
    return find('*',
            workingDirectory: pathToVersions,
            types: [Find.directory],
            recursive: false)
        .toList();
  }

  void delete(String version) {
    deleteDir(_pathToVersion(version), recursive: true);
  }

  /// Shows the user a menu with the 20 most recent version for the channel.
  ///
  /// Returns the version the user selected.
  String selectToInstall() {
    var releases = Release.fetchReleases(name);

    var release = menu<Release>(
        prompt: 'Select Version to install:',
        options: releases,
        limit: 20,
        format: (release) => release.version.toString());

    if (isVersionCached(release.version.toString())) {
      printerr(red('The selected version is already installed.'));
      exit(-1);
    }

    return release.version.toString();
  }

  String selectFromInstalled() {
    var version = menu<String>(
      prompt: 'Select Version:',
      options: cachedVersions(),
      format: (version) => basename(version),
      limit: 20,
    );
    return version;
  }

  bool isVersionCached(String version) {
    return cachedVersions().any((element) => basename(element) == version);
  }

  void upgrade() {
    if (isPinned) {
      printerr(
          red('The $name is pinned. Unpin the channel first and try again'));
    } else {
      var version = fetchLatestVersion();

      if (version == currentVersion) {
        print(
            'You are already on the latest version ($version) for the $name channel');
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
