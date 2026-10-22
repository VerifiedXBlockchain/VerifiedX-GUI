import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

void main() {
  // l10n.yaml does not set use-escaping, so gen_l10n copies an ICU-escaped
  // apostrophe ('') into the app as two apostrophes.
  for (final arb in ['lib/l10n/app_en.arb', 'lib/l10n/app_es.arb']) {
    test('$arb writes apostrophes as one character', () {
      final entries = jsonDecode(File(arb).readAsStringSync()) as Map<String, dynamic>;
      final doubled = entries.entries.where((e) => !e.key.startsWith('@') && e.value is String && (e.value as String).contains("''")).map((e) => e.key);
      expect(doubled, isEmpty);
    });
  }

  test('the strings that had doubled apostrophes read with one', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.tokenNoTopicsBody, "This token doesn't have any voting topics yet.");
    expect(l10n.paymentMessageHint, "What's this payment for?");
    expect(l10n.tokenWebInsufficient('xAddress', 'TKN'), "This address's (xAddress) TKN balance is insufficient.");
  });
}
