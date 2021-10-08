import 'package:dcli/dcli.dart';
import 'package:dswitch/dswitch.dart';
import 'package:settings_yaml/settings_yaml.dart';

var pathToSettings = join(HOME, '.dswitch', 'settings.yaml');

void updateVersionNo() {
  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );
  settings['version'] = packageVersion;
  verbose(() => 'updateVersionNo to $packageVersion');
  verbose(() => 'Path to settings file $pathToSettings');
  settings.save();
}

bool get isCurrentVersionInstalled {
  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  /// we need to find the latest version from pub cache
  /// as we are likely to be running in an old compiled version
  /// of the script.
  final primary = PubCache().findPrimaryVersion('dswitch');
  final installedVersion = (settings['version'] ?? '') as String;

  verbose(() =>
      'Settings version: $installedVersion, PackageVersion: $packageVersion PrimaryVersion: $primary');
  return primary == null ? false : installedVersion == primary.toString();
}

void createSettings() {
  if (!exists(dirname(pathToSettings))) {
    createDir(dirname(pathToSettings), recursive: true);
  }

  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  settings['version'] = packageVersion;
  settings.save();
}

bool get settingsExist => exists(pathToSettings);
