import 'package:dcli/dcli.dart';

import 'channel.dart';

var channels = ['stable', 'beta', 'dev'];
var dswitchPath = join(HOME, '.dswitch');
var activeSymlinkPath = join(dswitchPath, 'active');
var stableSymlinkPath = Channel.channelSymlink('stable');
var betaSymlinkPath = Channel.channelSymlink('beta');
var devSymlinkPath = Channel.channelSymlink('dev');
