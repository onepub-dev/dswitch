/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
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
  settings.save();
  verbose(() =>
      'Settings now contains: ${read(pathToSettings).toList().join('\n')}');
}

bool get isCurrentVersionInstalled {
  final settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  /// we need to find the latest version from pub cache
  /// as we are likely to be running in an old compiled version
  /// of the script.
  final primary = PubCache().findPrimaryVersion('dswitch');
  final installedVersion = (settings['version'] ?? '') as String;

  verbose(() =>
      'Settings version: $installedVersion, PackageVersion: $packageVersion '
      'PrimaryVersion: $primary');
  return primary != null && installedVersion == primary.toString();
}

void createSettings() {
  if (!exists(dirname(pathToSettings))) {
    createDir(dirname(pathToSettings), recursive: true);
  }

  final settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  settings['version'] = packageVersion;
  settings.save();
}

bool get settingsExist => exists(pathToSettings);
