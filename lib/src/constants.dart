import 'package:dcli/dcli.dart';

import 'channel.dart';

List<String> channels = ['stable', 'beta', 'dev'];
String dswitchPath = join(HOME, '.dswitch');
String activeSymlinkPath = join(dswitchPath, 'active');
String stableSymlinkPath = Channel.channelSymlink('stable');
String betaSymlinkPath = Channel.channelSymlink('beta');
String devSymlinkPath = Channel.channelSymlink('dev');
