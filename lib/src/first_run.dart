/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';

import 'constants.dart';
import 'exceptions/exit.dart';
import 'settings.dart';

Future<void> firstRun() async {
  if (!settingsExist) {
    await createSettings();
    firstRunMessage();
  }
}

void checkIsFullyInstalled() {
  if (!isLatestPubCacheVersionInstalled(
      isActivatedFromSource:
          PubCache().isGloballyActivatedFromSource('dswitch'))) {
    throw ExitException(
        1,
        'A new version of dswitch has been activated. '
        'Please run dswitch_install and then try again.',
        showUsage: false);
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
  final pre = Shell.current.checkInstallPreconditions();
  if (pre != null) {
    throw ExitException(1, pre, showUsage: false);
  }

  if (!regIsOnUserPath(activeSymlinkPath)) {
    regPrependToPath(activeSymlinkPath);

    print(orange('Your PATH has been updated. Please restart your terminal.'));
  }
}
