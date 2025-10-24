/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';

import 'delete.dart';
import 'install.dart';
import 'list.dart';
import 'pin.dart';
import 'status.dart';
import 'unpin.dart';
import 'upgrade.dart';

class ChannelCommand extends Command<void> {
  String channel;

  ChannelCommand(this.channel) {
    // addSubcommand(DefaultCommand(channel));
    addSubcommand(InstallCommand(channel));
    addSubcommand(ListCommand(channel));
    addSubcommand(PinCommand(channel));
    addSubcommand(StatusCommand(channel));
    addSubcommand(UnpinCommand(channel));
    addSubcommand(UpgradeCommand(channel));
    addSubcommand(DeleteCommand(channel));
  }

  @override
  String get description => 'Manages the $channel channel.';

  @override
  String get name => channel;

  @override
  void run() {}
}

class DefaultCommand extends Command<void> {
  String channel;

  DefaultCommand(this.channel);

  @override
  String get description => '''
Manages the $channel channel.
  If the channel is already downloaded then DSwitch will switch to the latest locally cached version for the $channel channel.
  If the channel is not already downloaded, then the latest version for the $channel channel will be downloaded and then DSwitch will switch to the channel.
   ''';

  @override
  String get name => '';
}
