import 'package:dswitch/src/releases.dart';
import 'package:test/test.dart';

void main() {
  test('releases ...', () async {
    final releases = Release.fetchReleases('stable');

    for (final release in releases) {
      print(release.version);
    }
  });
}
