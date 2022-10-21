/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';

class PinCommand extends Command<void> {
  PinCommand();

  @override
  String get description => '''
Selects the passed version for the current package
  If the version isn't in the cache then it is downloaded.
  If you don't pass a version then a menu will be displayed with the list of locally cached versions for the current channel to select from.
  Pinning allows you to switch between version within the dart project. 
  Use the unpin command to revert to the latest version for dart project.''';

  @override
  String get name => 'pin';

  @override
  void run() {}

  void installVersion(String version) {}
}
