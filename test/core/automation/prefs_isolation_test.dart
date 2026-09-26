import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/automation/prefs_isolation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  group('preferencesPrefixFor', () {
    test('keeps the plugin default outside automation', () {
      expect(preferencesPrefixFor(isAutomation: false, isWeb: false), isNull);
      expect(preferencesPrefixFor(isAutomation: false, isWeb: true), isNull);
    });

    test('keeps the plugin default for web automation builds', () {
      expect(preferencesPrefixFor(isAutomation: true, isWeb: true), isNull);
    });

    test('isolates desktop automation builds under automation.', () {
      expect(
        preferencesPrefixFor(isAutomation: true, isWeb: false),
        'automation.',
      );
    });
  });

  group('SharedPreferences under the automation prefix', () {
    tearDown(SharedPreferences.resetStatic);

    test("neither reads nor overwrites the wallet's flutter. keys", () async {
      final store = InMemorySharedPreferencesStore.withData(
        {'flutter.password': 'wallet'},
      );
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences.resetStatic();
      SharedPreferences.setPrefix(automationPreferencesPrefix);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);

      await prefs.setString('password', 'automation');
      expect(prefs.getString('password'), 'automation');
      expect(await store.getAllWithPrefix(''), {
        'flutter.password': 'wallet',
        'automation.password': 'automation',
      });
    });
  });
}
