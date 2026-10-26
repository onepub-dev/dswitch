import 'package:pub_semver/pub_semver.dart';

String validatedChannel(String channel) {
  if (!{'stable', 'beta', 'dev'}.contains(channel)) {
    throw ArgumentError.value(channel, 'channel', 'Unknown Dart channel');
  }
  return channel;
}

String validatedSdkVersion(String version) {
  if (!RegExp(r'^[0-9A-Za-z.+-]+$').hasMatch(version)) {
    throw FormatException('Invalid Dart SDK version', version);
  }
  final parsed = Version.parse(version);
  if (parsed.toString() != version) {
    throw FormatException('Noncanonical Dart SDK version', version);
  }
  return version;
}
