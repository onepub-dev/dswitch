import 'package:dcli/dcli.dart';
import 'package:dswitch/dswitch.dart';
import 'package:settings_yaml/settings_yaml.dart';

var pathToSettings = join(HOME, '.dswitch', 'settings.yaml');

void updateVersionNo() {
  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );
  settings['version'] = packageVersion;
  settings.save();
}

bool get isCurrentVersionInstalled {
  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  final installedVersion = (settings['version'] ?? '') as String;

  return packageVersion == installedVersion;

  // final primary = PubCache().findPrimaryVersion(DartProject.self.pubSpec.name!);

  // return primary == null ? false : settings['version'] == primary.toString();
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
