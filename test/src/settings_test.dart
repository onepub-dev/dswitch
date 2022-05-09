@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart';
import 'package:di_zone2/di_zone2.dart';
import 'package:dswitch/src/settings.dart';
import 'package:dswitch/src/version/version.g.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'package:test/test.dart';

void main() {
  test('no directory', () {
    if (exists(dirname(pathToSettings))) {
      deleteDir(dirname(pathToSettings));
    }
    // no directory
    expect(settingsExist, isFalse);
    expect(isCurrentVersionInstalled, isFalse);
  }, skip: true);
  test('no file', () {
    createSettings();

    // No file
    delete(pathToSettings);
    expect(settingsExist, isFalse);
    expect(isCurrentVersionInstalled, isFalse);
  });
  test('no version', () {
    createSettings();

    // No version
    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );
    settings['version'] = null;
    settings.save();
    expect(settingsExist, isTrue);
    expect(isCurrentVersionInstalled, isFalse);
  });

  test('old version', () {
    createSettings();

    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );

    settings['version'] = '0.0.1';
    settings.save();

    expect(settingsExist, isTrue);
    expect(isCurrentVersionInstalled, isFalse);
  });

  test('current version', () {
    createSettings();
    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );

    settings['version'] = '0.0.1';
    settings.save();
    expect(settingsExist, isTrue);

    expect(isCurrentVersionInstalled, isFalse);
  });

  test('update version', () {
    if (exists(pathToSettings)) {
      delete(pathToSettings);
    }

    expect(settingsExist, isFalse);
    expect(isCurrentVersionInstalled, isFalse);

    final settings = SettingsYaml.load(
      pathToSettings: pathToSettings,
    );

    settings['version'] = '0.0.1';
    settings.save();

    expect(settingsExist, isTrue);

    expect(isCurrentVersionInstalled, isFalse);
    updateVersionNo(HOME);

    withTempDir((mockCache) {
      env[PubCache.envVarPubCache] = mockCache;

      withEnvironment(() {
        /// create a pub-cache using the test scope's HOME
        Scope()
          ..value(PubCache.scopeKey, PubCache.forScope())
          ..run(() {
            final pubCache = PubCache();
            createDir(join(pubCache.pathToDartLang, 'dswitch-3.3.0'),
                recursive: true);
            createDir(join(pubCache.pathToDartLang, 'dswitch-4.0.1'));
            createDir(join(pubCache.pathToDartLang, 'dswitch-4.0.3'));
            createDir(join(pubCache.pathToDartLang, 'dswitch-4.0.3-beta.1'));

            createDir(join(
                pubCache.pathToDartLang, 'dswitch-$packageVersion-beta.1'));
            expect(isCurrentVersionInstalled, isFalse);

            createDir(join(pubCache.pathToDartLang, 'dswitch-$packageVersion'));

            expect(isCurrentVersionInstalled, isTrue);
          });
      }, environment: {'PUB_CACHE': mockCache});
    });
  });
}
