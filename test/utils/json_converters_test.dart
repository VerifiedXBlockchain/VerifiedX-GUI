import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';
import 'package:rbx_wallet/features/web/models/web_address.dart';
import 'package:rbx_wallet/features/web/models/web_recovery_details.dart';
import 'package:rbx_wallet/utils/json_converters.dart';

void main() {
  group('parseJsonDouble', () {
    test('reads numbers and numeric strings', () {
      expect(parseJsonDouble(1), 1.0);
      expect(parseJsonDouble(2.5), 2.5);
      expect(parseJsonDouble("0.0000000000000000"), 0.0);
      expect(parseJsonDouble(" 10.99996105 "), 10.99996105);
      expect(parseJsonDouble("1E-8"), 0.00000001);
    });

    test('throws on anything else instead of guessing', () {
      expect(() => parseJsonDouble("abc"), throwsFormatException);
      expect(() => parseJsonDouble(null), throwsFormatException);
      expect(() => parseJsonDouble(true), throwsFormatException);
    });

    test('nullable variant passes null through', () {
      expect(parseJsonDoubleOrNull(null), isNull);
      expect(parseJsonDoubleOrNull("3"), 3.0);
    });
  });

  group('WebAddress.fromJson', () {
    test('parses a recovered Vault whose balances Spyglass sends as strings', () {
      // Spyglass payload for a Vault after Recover() (TC-VAULT-029).
      final address = WebAddress.fromJson({
        'address': 'xVault',
        'balance': '0.0000000000000000',
        'balance_total': '0.0000000000000000',
        'balance_locked': 0.0,
        'adnr': null,
        'activated': true,
        'deactivated': true,
      });

      expect(address.balance, 0.0);
      expect(address.balanceTotal, 0.0);
      expect(address.balanceLocked, 0.0);
      expect(address.activated, isTrue);
      expect(address.deactivated, isTrue);
    });

    test('still parses numeric balances and applies defaults', () {
      final address = WebAddress.fromJson({
        'address': 'xA',
        'balance': 12,
        'adnr': 'a.vfx',
      });

      expect(address.balance, 12.0);
      expect(address.balanceTotal, 0.0);
      expect(address.balanceLocked, 0.0);
      expect(address.deactivated, isFalse);
    });
  });

  test('WebTransaction and WebRecoveryDetails accept string amounts', () {
    final tx = WebTransaction.fromJson({
      'hash': 'abc',
      'to_address': 'xTo',
      'from_address': 'xFrom',
      'type': 0,
      'total_amount': '2.5000000000000000',
      'total_fee': null,
      'date_crafted': '2026-09-27T04:38:52Z',
      'height': 1,
    });
    expect(tx.amount, 2.5);
    expect(tx.fee, isNull);

    final recovery = WebRecoveryDetails.fromJson({
      'original_address': 'xA',
      'new_address': 'xB',
      'amount': '10.99996105',
    });
    expect(recovery.amount, 10.99996105);
  });
}
