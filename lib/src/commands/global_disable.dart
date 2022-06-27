/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart' as dcli;

import '../constants.dart';

class GlobalDisableCommand extends Command<void> {
  GlobalDisableCommand();

  @override
  String get description => '''
Disables DSwitch, reverting to the OS installed version of Dart.
The DSwitch symlinks are deleted.
   ''';

  @override
  String get name => 'disable';

  @override
  void run() {
    deleteSymlink(activeSymlinkPath);
    deleteSymlink(stableSymlinkPath);
    deleteSymlink(betaSymlinkPath);
    deleteSymlink(devSymlinkPath);

    print("DSwitch has been disabled. Use 'dswitch enable' to re-enable it.");
  }

  void deleteSymlink(String symlink) {
    if (dcli.exists(symlink)) {
      dcli.deleteSymlink(symlink);
    }
  }
}
