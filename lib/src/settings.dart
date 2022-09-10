/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:settings_yaml/settings_yaml.dart';

import '../dswitch.dart';

final relPathToSettings = join('.dswitch', 'settings.yaml');
final pathToSettings = join(HOME, relPathToSettings);

/// This method is called from stage2 of the install.
/// When run on linux stage2 is run under sudo so the
/// HOME directory is /root.
/// So we can update the user's settings.yaml in their
/// home directory we must pass the home dir in.
void updateVersionNo(String pathToHome) {
  final pathToSettings = join(pathToHome, relPathToSettings);
  final settings = SettingsYaml.load(pathToSettings: pathToSettings);
  settings['version'] = packageVersion;
  verbose(() => 'updateVersionNo to $packageVersion');
  verbose(() => 'Path to settings file $pathToSettings');
  // ignore: discarded_futures
  waitForEx(settings.save());
  verbose(() =>
      'Settings now contains: ${read(pathToSettings).toList().join('\n')}');
}

///
/// Returns true if the running version is the last version found in pub cache.
/// You pass in [isActivatedFromSource] then the source version
/// may be greater than the pub-cache version and this test will still pass.
bool isLatestPubCacheVersionInstalled({bool isActivatedFromSource = false}) {
  final settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  /// we need to find the latest version from pub cache
  /// as we are likely to be running in an old compiled version
  /// of the script.
  final lastestInPubCache =
      PubCache().findPrimaryVersion('dswitch') ?? Version.parse('0.0.1-fake.1');
  final installedVersion =
      Version.parse((settings['version'] ?? '0.0.1-fake.2') as String);

  verbose(() =>
      'Settings version: $installedVersion, PackageVersion: $packageVersion '
      'PubCacheVersion: $lastestInPubCache');

  // we allow an installed version greater than the pub-cache version
  // in case we are running a dev version from source.
  if (isActivatedFromSource) {
    return installedVersion.compareTo(lastestInPubCache) >= 0;
  } else {
    return installedVersion == lastestInPubCache;
  }
}

void createSettings() {
  if (!exists(dirname(pathToSettings))) {
    createDir(dirname(pathToSettings), recursive: true);
  }

  final settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  settings['version'] = packageVersion;
  // ignore: discarded_futures
  waitForEx(settings.save());
}

bool get settingsExist => exists(pathToSettings);
