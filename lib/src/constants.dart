/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli/dcli.dart';

import 'channel.dart';

List<String> channels = ['stable', 'beta', 'dev'];
String dswitchPath = join(HOME, '.dswitch');
String activeSymlinkPath = join(dswitchPath, 'active');
String stableSymlinkPath = Channel.channelSymlink('stable');
String betaSymlinkPath = Channel.channelSymlink('beta');
String devSymlinkPath = Channel.channelSymlink('dev');
