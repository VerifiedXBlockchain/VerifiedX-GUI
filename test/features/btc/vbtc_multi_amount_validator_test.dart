import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/btc/utils.dart';

void main() {
  // The validator reads its messages through `globalL10n`, which resolves the
  // root navigator key via get_it. Assigning a detached key before it is
  // first read skips that lookup, and with the test binding initialized its
  // currentContext is null, so `globalL10n` falls back to English.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  group('formValidatorVbtcMultiAmount', () {
    const available = 0.75;

    test('accepts a positive amount within the available balance', () {
      expect(formValidatorVbtcMultiAmount('0.5', available), isNull);
      expect(formValidatorVbtcMultiAmount('0.75', available), isNull);
      expect(formValidatorVbtcMultiAmount('0.00000001', available), isNull);
    });

    test('rejects an empty value', () {
      expect(formValidatorVbtcMultiAmount(null, available), isNotNull);
      expect(formValidatorVbtcMultiAmount('   ', available), isNotNull);
    });

    test('rejects non-numeric, zero and negative amounts', () {
      expect(formValidatorVbtcMultiAmount('abc', available), isNotNull);
      expect(formValidatorVbtcMultiAmount('0', available), isNotNull);
      expect(formValidatorVbtcMultiAmount('-0.1', available), isNotNull);
    });

    test('rejects more than 8 decimal places', () {
      expect(formValidatorVbtcMultiAmount('0.123456789', available), isNotNull);
      expect(formValidatorVbtcMultiAmount('0.12345678', available), isNull);
    });

    test('rejects amounts above the available balance', () {
      expect(formValidatorVbtcMultiAmount('0.750001', available), isNotNull);
    });
  });
}
