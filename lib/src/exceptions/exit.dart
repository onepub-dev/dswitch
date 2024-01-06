import 'package:args/args.dart';

class ExitException implements Exception {
  ExitException(this.code, this.message,
      {required this.showUsage, this.argParser});

  int code;
  String message;
  bool showUsage;

  /// if showUsage is true then the caller may
  /// set an argParser to be used to show the usage from.
  ArgParser? argParser;

  @override
  String toString() => 'ExitException: $code $message';
}
