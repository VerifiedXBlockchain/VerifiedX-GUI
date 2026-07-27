import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../singletons.dart';

const _kLocalePrefKey = 'locale_pref';

class LocaleProvider extends StateNotifier<Locale?> {
  LocaleProvider() : super(_readFromPrefs());

  static Locale? _readFromPrefs() {
    final prefs = singleton<SharedPreferences>();
    final raw = prefs.getString(_kLocalePrefKey);
    if (raw == null || raw.isEmpty) return null;
    return Locale(raw);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = singleton<SharedPreferences>();
    if (locale == null) {
      await prefs.remove(_kLocalePrefKey);
    } else {
      await prefs.setString(_kLocalePrefKey, locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleProvider, Locale?>(
  (ref) => LocaleProvider(),
);
