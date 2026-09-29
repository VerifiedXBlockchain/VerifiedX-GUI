import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';

/// Key prefix for the GUI's own preferences in a desktop automation build.
///
/// On macOS, `shared_preferences` stores everything in the NSUserDefaults
/// domain of the app's bundle id, which a `flutter run` build shares with the
/// installed wallet. The plugin namespaces its keys with a prefix (`flutter.`
/// by default) and only ever reads, writes and clears keys under that prefix,
/// so a different prefix gives an automation build its own preferences
/// (password hash, encryption flags, ...) in the same domain without touching
/// the wallet's.
const automationPreferencesPrefix = 'automation.';

/// The `SharedPreferences` key prefix a build should use, or null to keep the
/// plugin's default. Only desktop automation builds are isolated: on web the
/// preferences already live in the dev server origin's local storage.
String? preferencesPrefixFor({
  required bool isAutomation,
  required bool isWeb,
}) {
  if (isAutomation && !isWeb) {
    return automationPreferencesPrefix;
  }
  return null;
}

/// Applies [preferencesPrefixFor] to this process. Must run before the first
/// `SharedPreferences.getInstance` (the plugin throws otherwise), which is why
/// `main()` calls it ahead of `initSingletons()`.
void isolatePreferencesForAutomation() {
  final prefix = preferencesPrefixFor(
    isAutomation: Env.isAutomation,
    isWeb: kIsWeb,
  );
  if (prefix != null) {
    SharedPreferences.setPrefix(prefix);
  }
}
