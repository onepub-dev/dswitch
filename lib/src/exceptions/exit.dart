import 'package:args/args.dart';

class ExitException implements Exception {
  int code;

  String message;

  bool showUsage;

  /// if showUsage is true then the caller may
  /// set an argParser to be used to show the usage from.
  ArgParser? argParser;

  ExitException(this.code, this.message,
      {required this.showUsage, this.argParser});

  @override
  String toString() => 'ExitException: $code $message';
}
