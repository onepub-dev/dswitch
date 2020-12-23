import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:settings_yaml/settings_yaml.dart';

var pathToSettings = join(HOME, '.dswitch', 'settings.yaml');
void firstRun() {
  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  if (!exists(pathToSettings)) {
    if (Platform.isWindows) {
      var pre = Shell.current.checkInstallPreconditions();
      if (pre != null) {
        printerr(red(pre));
        exit(1);
      }
    }
  }
  settings.save();
}
