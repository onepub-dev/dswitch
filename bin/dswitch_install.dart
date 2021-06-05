import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dswitch/dswitch.dart';

void main() {
  // build the path to the copy of bin/dswitch.dart in the pub cache.
  final pathToDSwitch = join(
    DartProject.fromCache('dswitch', packageVersion).pathToProjectRoot,
  );

  if (!exists(pathToDSwitch)) {
    printerr(
        "Could not find dswitch in pub cache. Please run 'dart pub global activate dswitch' and try again.");
    exit(1);
  }

  var targetDir = PubCache().pathToBin;

  withTempDir((compileDir) {
    copyTree(pathToDSwitch, compileDir);

    final script = DartScript.fromFile(join(compileDir, 'bin', 'dswitch.dart'));
    print('Compiling dswitch so it will run independant of your dart version.');
    DartSdk().runPubGet(compileDir, progress: Progress.devNull());
    script.compile(workingDirectory: compileDir);

    /// replace the pub-cache script with a compiled version.
    copy(script.pathToExe, targetDir, overwrite: true);
  });
  print(orange('DSwitch is ready to run'));
}
