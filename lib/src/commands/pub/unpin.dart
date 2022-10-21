/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';

import '../../first_run.dart';

class UnpinCommand extends Command<void> {
  UnpinCommand();

  @override
  String get description => '''
Unpins the current project's dart version.
  Changes the project to use the latest locally cached version for the current channel.
  ''';

  @override
  String get name => 'unpin';

  @override
  void run() {
    checkIsFullyInstalled();
  }
}
