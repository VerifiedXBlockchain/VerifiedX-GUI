import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/escrowed_withdrawal.dart';

void main() {
  group('EscrowedWithdrawal.listFromJson', () {
    test('parses the GetVBTCBalance EscrowedWithdrawals entries', () {
      final list = EscrowedWithdrawal.listFromJson([
        {
          'RequestHash': 'abc',
          'Amount': 0.0001,
          'BTCDestination': 'tb1qdest',
          'FeeRate': 30,
          'RequestBlockHeight': 100,
          'ExpiresAtHeight': 460,
          'Expired': true,
          'Unpayable': false,
          'CancellationPending': true,
        },
      ])!;

      expect(list, hasLength(1));
      expect(list.single.requestHash, 'abc');
      expect(list.single.amount, 0.0001);
      expect(list.single.btcDestination, 'tb1qdest');
      expect(list.single.expired, isTrue);
      expect(list.single.unpayable, isFalse);
      expect(list.single.cancellationPending, isTrue);
    });

    test('is null when the node does not report the field', () {
      expect(EscrowedWithdrawal.listFromJson(null), isNull);
    });

    test('an empty array means no open requests', () {
      expect(EscrowedWithdrawal.listFromJson([]), isEmpty);
    });
  });

  group('classifyPendingWithdrawal', () {
    const live = EscrowedWithdrawal(requestHash: 'h', amount: 1);
    const expired = EscrowedWithdrawal(requestHash: 'h', amount: 1, expired: true, unpayable: true);
    const unpayable = EscrowedWithdrawal(requestHash: 'h', amount: 1, unpayable: true);

    test('no active request opens the form', () {
      expect(classifyPendingWithdrawal(activeRequestHash: null, escrowed: null), PendingWithdrawalAction.openForm);
      expect(classifyPendingWithdrawal(activeRequestHash: '', escrowed: const [live]), PendingWithdrawalAction.openForm);
    });

    test('a live request of this wallet offers Complete', () {
      expect(classifyPendingWithdrawal(activeRequestHash: 'h', escrowed: const [live]), PendingWithdrawalAction.offerComplete);
    });

    test('an expired request is explained, not offered for completion', () {
      expect(classifyPendingWithdrawal(activeRequestHash: 'h', escrowed: const [expired]), PendingWithdrawalAction.expired);
    });

    test('an unpayable request is explained, not offered for completion', () {
      expect(classifyPendingWithdrawal(activeRequestHash: 'h', escrowed: const [unpayable]), PendingWithdrawalAction.unpayable);
    });

    test('expired escrow is explained after the active hash is cleared', () {
      for (final hash in [null, '']) {
        expect(classifyPendingWithdrawal(activeRequestHash: hash, escrowed: const [expired]), PendingWithdrawalAction.expired);
        expect(pendingEscrowedWithdrawal(activeRequestHash: hash, escrowed: const [expired]), expired);
      }
    });

    test('unpayable escrow is explained even without an active hash', () {
      expect(classifyPendingWithdrawal(activeRequestHash: null, escrowed: const [unpayable]), PendingWithdrawalAction.unpayable);
    });

    test('old escrow does not take over a live active request', () {
      const old = EscrowedWithdrawal(requestHash: 'old', amount: 2, expired: true);
      expect(classifyPendingWithdrawal(activeRequestHash: 'h', escrowed: const [old, live]), PendingWithdrawalAction.offerComplete);
      expect(pendingEscrowedWithdrawal(activeRequestHash: 'h', escrowed: const [old, live]), live);
    });

    test('unknown escrow state keeps the existing Complete prompt', () {
      expect(classifyPendingWithdrawal(activeRequestHash: 'h', escrowed: null), PendingWithdrawalAction.offerComplete);
      expect(classifyPendingWithdrawal(activeRequestHash: 'other', escrowed: const [expired]), PendingWithdrawalAction.offerComplete);
    });
  });
}
