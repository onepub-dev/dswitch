import 'dart:io';

import 'package:dcli/dcli.dart';

void main() {
  final pathTo = which('dswitch');

  if (pathTo.notfound) {
    printerr(
        'Could not find dswitch on your path. Please check your PATH and try again');
    exit(1);
  }

  final script = DartScript.fromFile(pathTo.path!);
  print('Compiling dswitch so it will run independant of your dart version.');
  script.compile();

  /// replace the pub-cache script with a compiled version.
  copy(script.pathToExe, PubCache().pathToBin, overwrite: true);
  print(orange('DSwitch is ready to run'));
}
