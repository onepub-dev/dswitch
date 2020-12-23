import 'package:dswitch/src/constants.dart';
import 'package:dcli/dcli.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'commands/commands.dart';
import 'download_version.dart';
import 'releases.dart';

/// Used to manage a channel
///

class Channel {
  String name;
  SettingsYaml _settings;
  Channel(this.name) {
    createPaths();
  }

  /// Returns true if this is the active channel
  bool get isActive =>
      exists(activePath) &&
      (resolveSymLink(activePath).startsWith(pathToVersions));

  void install() {
    if (isDownloaded()) {
      print(orange(
          'Channel is already installed and the current version is: ${currentVersion}'));
    } else {
      var releases = Release.fetchReleases(name);
      var version = releases[0].version.toString();
      print('Installing $name ($version) ...');
      download(version);
      currentVersion = version;
      _createChannelSymlink();
      print('install of $name channel complete');
    }
  }

  void _createChannelSymlink() {
    if (exists(_channelSymlink)) {
      deleteSymlink(_channelSymlink);
    }

    symlink(pathToCurrentVersion, _channelSymlink);
  }

  void switchTo({bool forceDownload}) {
    if (exists(activePath)) {
      deleteSymlink(activePath);
    }
    symlink(pathToCurrentVersion, activePath);

    /// they may never run install so we need to create this.
    _createChannelSymlink();
  }

  void pin(String version) {
    currentVersion = version;
    pinned = true;
    _createChannelSymlink();
  }

  void unpin() {
    currentVersion = latestVersion;
    pinned = false;
    _createChannelSymlink();
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
      printerr(red('Invalid command. ${channel}'));
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
  String get _channelSymlink => join(dswitchPath, name);

  bool isDownloaded() => currentVersion != null;

  void download(String version) {
    var downloader = DownloadVersion(name, version, _pathToVersion(version));
    downloader.download();

    if (Version.parse(version) > Version.parse(latestVersion)) {
      latestVersion = version;
    }
  }

  String fetchLatestVersion() {
    final releases = Release.fetchReleases(name);
    return releases[0].version.toString();
  }

  /// The current active version.
  /// This will normally be the same as the [latestVersion] unless
  /// this channel is pinned.
  String get currentVersion => settings['currentVersion'] as String;

  set currentVersion(String version) {
    settings['currentVersion'] = version;
    settings.save();
  }

  /// the most recent version we have downloaded.
  String get latestVersion => settings['latestVersion'] as String ?? '0.0.1';

  set latestVersion(String version) {
    settings['latestVersion'] = version;
    settings.save();
  }

  /// If true then this channel is currently pinned.
  bool get pinned => settings['pinned'] as bool;

  set pinned(bool pinned) {
    settings['pinned'] = pinned;
    settings.save();
  }

  static String channelPath(String channel) =>
      join(dswitchPath, 'channels', channel);

  /// returns a list of the version that are cached locally.
  List<String> cachedVersions() {
    return find('*',
            root: pathToVersions, types: [Find.directory], recursive: false)
        .toList();
  }

  /// Shows the user a menu with the 20 most recent version for the channel.
  ///
  /// Returns the version the user selected.
  String select() {
    var releases = Release.fetchReleases(name);

    var release = menu<Release>(
        prompt: 'Select Version to install:',
        options: releases,
        limit: 20,
        format: (release) => release.version.toString());

    return release.version.toString();
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

      print('Downloading $version...');
      download(version);

      currentVersion = version;

      if (isActive) {
        /// if we are the active channel then calling swithTo
        /// will update the symlinks to the new version
        switchTo();
      } else {
        _createChannelSymlink();
      }
      print('upgrade of $name channel to $version complete');
    }
  }
}
