import 'package:flutter/material.dart';

import '../app.dart';
import 'generated/app_localizations.dart';

/// Localizations accessor for code that has no BuildContext (providers,
/// utils, toast helpers). Resolves through the root navigator so the
/// active app locale wins; falls back to English before the first frame
/// (e.g. toasts fired during startup).
AppLocalizations get globalL10n {
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    return AppLocalizations.of(context);
  }
  return lookupAppLocalizations(const Locale('en'));
}
