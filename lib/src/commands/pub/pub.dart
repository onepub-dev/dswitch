/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';

import 'pin.dart';
import 'status.dart';
import 'unpin.dart';

class PubCommand extends Command<void> {
  PubCommand() {
    addSubcommand(PinCommand());
    addSubcommand(StatusCommand());
    addSubcommand(UnpinCommand());
  }

  @override
  String get description => '''
Manages the current package.
  Sets the current packages SDK to the passed SDK version.
  Currently this is only suppported for vscode.
   ''';

  @override
  String get name => 'pub';

  @override
  void run() {}
}
