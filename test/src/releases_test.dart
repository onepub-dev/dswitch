import 'package:dswitch/src/releases.dart';
import 'package:test/test.dart';

void main() {
  test('releases ...', () async {
    var releases = Release.fetchReleases('stable');

    for (var release in releases) {
      print(release.version);
    }
  });
}
