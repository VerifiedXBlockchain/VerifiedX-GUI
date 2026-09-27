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
}
