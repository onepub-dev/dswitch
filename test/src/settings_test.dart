@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dswitch/src/settings.dart';
import 'package:dswitch/src/version/version.g.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:scope/scope.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'package:test/test.dart';

void main() {
  test('no directory', () {
    if (exists(dirname(pathToSettings))) {
      deleteDir(dirname(pathToSettings));
    }
    // no directory
    expect(settingsExist, isFalse);
    expect(isLatestPubCacheVersionInstalled(), isFalse);
  }, skip: true);
  test('no file', () async {
    await createSettings();

    // No file
    delete(pathToSettings);
    expect(settingsExist, isFalse);
    expect(isLatestPubCacheVersionInstalled(), isFalse);
  });
  test('no version', () async {
    await createSettings();

    // No version
    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );
    settings['version'] = null;
    await settings.save();
    expect(settingsExist, isTrue);
    expect(isLatestPubCacheVersionInstalled(), isFalse);
  });

  test('old version', () async {
    await createSettings();

    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );

    settings['version'] = '0.0.1';
    await settings.save();

    expect(settingsExist, isTrue);
    expect(isLatestPubCacheVersionInstalled(), isFalse);
  });

  test('current version', () async {
    await createSettings();
    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );

    settings['version'] = '0.0.1';
    await settings.save();
    expect(settingsExist, isTrue);

    expect(isLatestPubCacheVersionInstalled(), isFalse);
  });

  test('update version', () async {
    if (exists(pathToSettings)) {
      delete(pathToSettings);
    }

    expect(settingsExist, isFalse);
    expect(isLatestPubCacheVersionInstalled(), isFalse);

    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );

    settings['version'] = '0.0.1';
    await settings.save();

    expect(settingsExist, isTrue);

    expect(isLatestPubCacheVersionInstalled(), isFalse);
    await updateVersionNo(HOME);

    await core.withTempDirAsync((mockCache) async {
      env[PubCache.envVarPubCache] = mockCache;

      await withEnvironmentAsync(() async {
        /// create a pub-cache using the test scope's HOME
        Scope()
          ..value(PubCache.scopeKey, PubCache.forScope())
          ..runSync(() {
            final pubCache = PubCache();

            final sourceVersion = Version.parse(packageVersion);

            createDir(join(pubCache.pathToHosted, 'dswitch-4.0.1'),
                recursive: true);
            createDir(join(pubCache.pathToHosted, 'dswitch-4.0.3'));
            createDir(join(pubCache.pathToHosted, 'dswitch-4.0.3-beta.1'));

            expect(isLatestPubCacheVersionInstalled(), isFalse);

            createDir(join(pubCache.pathToHosted, 'dswitch-$packageVersion'));
            expect(isLatestPubCacheVersionInstalled(), isTrue);

            createDir(join(
                pubCache.pathToHosted, 'dswitch-${sourceVersion.nextMinor}'));

            expect(isLatestPubCacheVersionInstalled(), isFalse);
          });
      }, environment: {'PUB_CACHE': mockCache});
    });
  });
}
