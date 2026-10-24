import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/transactions/models/web_transaction.dart';
import 'package:rbx_wallet/features/transactions/providers/web_transaction_list_provider.dart';

WebTransaction _tx(String hash, {bool isPending = false}) => WebTransaction(
      hash: hash,
      toAddress: 'xB',
      fromAddress: 'xB',
      type: 44,
      amount: 0,
      fee: 0,
      date: DateTime(2026, 10, 23),
      height: 0,
      isPending: isPending,
    );

void main() {
  test('a send reported twice is listed once', () {
    final once = withPendingTx(const [], _tx('release'));
    final twice = withPendingTx(once, _tx('release'));

    expect(twice, hasLength(1));
    expect(twice.single.isPending, isTrue);
  });

  test('a transaction already confirmed in the list is not added again as pending', () {
    final list = withPendingTx([_tx('release')], _tx('release'));

    expect(list, hasLength(1));
    expect(list.single.isPending, isFalse);
  });

  test('a new send goes on top as pending', () {
    final list = withPendingTx([_tx('older')], _tx('newer'));

    expect(list.map((t) => t.hash), ['newer', 'older']);
    expect(list.first.isPending, isTrue);
  });
}
