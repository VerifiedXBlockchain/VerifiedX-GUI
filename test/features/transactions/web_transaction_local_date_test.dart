import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';

void main() {
  test('localDate is the UTC date_crafted in local time', () {
    final tx = WebTransaction.fromJson({
      'hash': 'abc',
      'to_address': 'xTo',
      'from_address': 'xFrom',
      'type': 0,
      'total_amount': 1.0,
      'total_fee': 0.0,
      'date_crafted': '2026-09-27T04:38:52Z',
      'height': 1,
    });

    expect(tx.date.isUtc, isTrue);
    expect(tx.localDate.isUtc, isFalse);
    expect(tx.localDate, DateTime.utc(2026, 9, 27, 4, 38, 52).toLocal());
    // Same instant the list card shows.
    expect(tx.localDate, DateTime.fromMillisecondsSinceEpoch(tx.date.millisecondsSinceEpoch));
  });

  test('localUnlockTime is the UTC unlock_time in local time, like localDate', () {
    // TC-VAULT-018: a 25 h timelock sent 08:09 UTC.
    final tx = WebTransaction.fromJson({
      'hash': 'abc',
      'to_address': 'xTo',
      'from_address': 'xVault',
      'type': 0,
      'total_amount': 2.0,
      'total_fee': 0.0,
      'date_crafted': '2026-09-27T08:09:13Z',
      'unlock_time': '2026-09-28T09:09:13Z',
      'height': 1,
    });

    expect(tx.unlockTime!.isUtc, isTrue);
    expect(tx.localUnlockTime!.isUtc, isFalse);
    expect(tx.localUnlockTime, DateTime.utc(2026, 9, 28, 9, 9, 13).toLocal());
    // Both card dates are in the same zone, so their gap is the timelock.
    expect(tx.localUnlockTime!.difference(tx.localDate), const Duration(hours: 25));
  });

  test('localUnlockTime is null without an unlock_time', () {
    final tx = WebTransaction.fromJson({
      'hash': 'abc',
      'to_address': 'xTo',
      'from_address': 'xFrom',
      'type': 0,
      'total_amount': 1.0,
      'total_fee': 0.0,
      'date_crafted': '2026-09-27T04:38:52Z',
      'height': 1,
    });

    expect(tx.localUnlockTime, isNull);
  });
}
