import 'package:dcli/dcli.dart';

import 'constants.dart';

/// Add the symlink 'active' paths for dart.
void updatePaths() {
  final dartPath = join(dswitchPath, 'active', 'dart');

  if (!Env().isOnPATH(dartPath)) {
    Env().prependToPATH(dartPath);
  }
}
