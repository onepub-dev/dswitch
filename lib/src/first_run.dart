import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:path/path.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'constants.dart';

var pathToSettings = join(HOME, '.dswitch', 'settings.yaml');
void firstRun() {
  if (!exists(dirname(pathToSettings))) {
    createDir(dirname(pathToSettings), recursive: true);
  }

  if (!exists(pathToSettings)) {
    firstRunMessage();
  }

  var settings = SettingsYaml.load(
    pathToSettings: pathToSettings,
  );

  settings.save();
}

void checkIsCompiled() {
  final script = DartScript.self;
  if (!script.isCompiled) {
    print(red('Please run dswitch_install and then try again.'));
    exit(1);
  }
}

void firstRunMessage() {
  print('''

${green('Welcome to dswitch.')}

dswitch creates four symlinks (channels) that you can use from your IDE:
active: $activeSymlinkPath
stable: $stableSymlinkPath
beta: $betaSymlinkPath
dev: $devSymlinkPath
''');

  if (!Platform.isWindows) {
    print('''

The active symlink must be added to your path.
''');
  }

  print(blue('''

You can configure your IDE to use a different channel on a per project basis.
  '''));

  if (!exists(pathToSettings)) {
    if (Platform.isWindows) {
      windowsFirstRun();
    } else if (Platform.isLinux) {
      linuxFirstRun();
    } else if (Platform.isMacOS) {
      macosxFirstRun();
    }
  }
}

void macosxFirstRun() {}

void linuxFirstRun() {}

void windowsFirstRun() {
  var pre = Shell.current.checkInstallPreconditions();
  if (pre != null) {
    printerr(red(pre));
    exit(1);
  }

  if (!regIsOnUserPath(activeSymlinkPath)) {
    regPrependToPath(activeSymlinkPath);

    print(orange('Your PATH has been updated. Please restart your terminal.'));
  }
}
