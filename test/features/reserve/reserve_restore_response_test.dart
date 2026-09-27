import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/features/reserve/services/reserve_account_service.dart';

void main() {
  // The fallback message reads through `globalL10n`; a detached root key makes
  // it fall back to English instead of resolving the router through get_it.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  const restored = {
    'PrivateKey': 'pk',
    'Address': 'xVault',
    'RecoveryAddress': 'xRecovery',
    'RecoveryPrivateKey': 'rpk',
    'RestoreCode': 'code',
  };

  group('restoredReserveAccountFromResponse', () {
    test('returns the account from a successful response', () {
      final account = restoredReserveAccountFromResponse({
        'Success': true,
        'ReserveAccount': {'Result': Map<String, dynamic>.from(restored)},
      });
      expect(account?.address, 'xVault');
    });

    test('returns null for the bare list an invalid code gets', () {
      expect(restoredReserveAccountFromResponse([]), isNull);
    });

    test('returns null for null, failures and missing results', () {
      expect(restoredReserveAccountFromResponse(null), isNull);
      expect(restoredReserveAccountFromResponse({'Success': false, 'Message': 'no'}), isNull);
      expect(restoredReserveAccountFromResponse({'Success': true}), isNull);
      expect(restoredReserveAccountFromResponse({'Success': true, 'ReserveAccount': []}), isNull);
      expect(restoredReserveAccountFromResponse({'Success': true, 'ReserveAccount': {'Result': null}}), isNull);
    });
  });

  group('reserveResponseErrorMessage', () {
    test('uses the CLI message when there is one', () {
      expect(reserveResponseErrorMessage({'Success': false, 'Message': 'Bad code'}), 'Bad code');
    });

    test('falls back to the generic error for lists, null and empty messages', () {
      expect(reserveResponseErrorMessage([]), 'A problem occurred');
      expect(reserveResponseErrorMessage(null), 'A problem occurred');
      expect(reserveResponseErrorMessage({'Success': false, 'Message': ' '}), 'A problem occurred');
      expect(reserveResponseErrorMessage({'Success': false}), 'A problem occurred');
    });
  });
}
