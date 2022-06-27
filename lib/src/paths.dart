/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli/dcli.dart';

import 'constants.dart';

/// Add the symlink 'active' paths for dart.
void updatePaths() {
  final dartPath = join(dswitchPath, 'active', 'dart');

  if (!Env().isOnPATH(dartPath)) {
    Env().prependToPATH(dartPath);
  }
}
