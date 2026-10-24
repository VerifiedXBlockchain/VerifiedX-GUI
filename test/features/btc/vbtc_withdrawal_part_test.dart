import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_multi_withdrawal_result.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_withdrawal_part.dart';
import 'package:rbx_wallet/features/btc_web/models/watched_withdrawal.dart';

WatchedWithdrawal _part(String? state, {bool paid = false, bool notMinedYet = false, bool releasing = false}) {
  return WatchedWithdrawal(
    status: 'Unknown',
    paid: paid,
    notMinedYet: notMinedYet,
    state: state,
    releasing: releasing,
  );
}

void main() {
  final waiting = _part('Waiting');
  final pinned = _part('Pinned');
  final settled = _part('Settled', paid: true);
  final released = _part('Released');
  final notMined = _part(null, notMinedYet: true);

  group('vbtcWithdrawalPartState', () {
    test('reads each chain state', () {
      expect(vbtcWithdrawalPartState(null), VbtcWithdrawalPartState.checking);
      expect(vbtcWithdrawalPartState(notMined), VbtcWithdrawalPartState.notMinedYet);
      expect(vbtcWithdrawalPartState(waiting), VbtcWithdrawalPartState.waiting);
      expect(vbtcWithdrawalPartState(pinned), VbtcWithdrawalPartState.pinned);
      expect(vbtcWithdrawalPartState(_part('Pinned', releasing: true)), VbtcWithdrawalPartState.releasing);
      expect(vbtcWithdrawalPartState(settled), VbtcWithdrawalPartState.paid);
      expect(vbtcWithdrawalPartState(released), VbtcWithdrawalPartState.returned);
      expect(vbtcWithdrawalPartState(_part('Cancelled')), VbtcWithdrawalPartState.returned);
    });
  });

  group('vbtcMultiWithdrawalOverall', () {
    test('is not mined while no part is', () {
      expect(vbtcMultiWithdrawalOverall([null, null]), VbtcMultiWithdrawalOverall.notMinedYet);
      expect(vbtcMultiWithdrawalOverall([notMined, null]), VbtcMultiWithdrawalOverall.notMinedYet);
    });

    test('is in progress while any part is open or unread', () {
      expect(vbtcMultiWithdrawalOverall([settled, pinned]), VbtcMultiWithdrawalOverall.inProgress);
      expect(vbtcMultiWithdrawalOverall([waiting, waiting]), VbtcMultiWithdrawalOverall.inProgress);
      expect(vbtcMultiWithdrawalOverall([settled, null]), VbtcMultiWithdrawalOverall.inProgress);
    });

    test('says sent, partly sent or returned once every part is closed', () {
      expect(vbtcMultiWithdrawalOverall([settled, settled]), VbtcMultiWithdrawalOverall.sent);
      expect(vbtcMultiWithdrawalOverall([settled, released]), VbtcMultiWithdrawalOverall.partlySent);
      expect(vbtcMultiWithdrawalOverall([released, _part('Cancelled')]), VbtcMultiWithdrawalOverall.returned);
    });
  });

  group('VbtcMultiWithdrawalResult', () {
    test("parses Core's RequestWithdrawalMulti answer", () {
      final result = VbtcMultiWithdrawalResult.fromJson({
        'Success': true,
        'RequestHash': '2b391bf4',
        'Allocations': [
          {'SCUID': 'web1:1792760559', 'Amount': 0.00002},
          {'SCUID': 'm1:1792763038', 'Amount': 0.000015},
        ],
        'BitcoinTransactions': 2,
      });

      expect(result.requestHash, '2b391bf4');
      expect(result.allocations.map((a) => a.scIdentifier), ['web1:1792760559', 'm1:1792763038']);
      expect(result.allocations.map((a) => a.amount), [0.00002, 0.000015]);
    });

    test('skips malformed allocations', () {
      expect(
        vbtcWithdrawalSharesFromJson([
          {'SCUID': 'a:1', 'Amount': 1},
          {'SCUID': 'b:2'},
          'c:3',
        ]).map((a) => a.scIdentifier),
        ['a:1'],
      );
    });
  });

  group('vbtcMultiWithdrawalSharesOf', () {
    const multiData =
        '{"Function":"VBTCWithdrawalRequestMultiV2()","RequestorAddress":"xA","BTCAddress":"tb1q","TotalAmount":0.000035,"FeeRate":3,"Inputs":[{"SCUID":"web1:1","Amount":0.00002},{"SCUID":"m1:2","Amount":0.000015}],"UniqueId":null}';

    test("reads the parts from a multi request's Data", () {
      final shares = vbtcMultiWithdrawalSharesOf(multiData)!;

      expect(shares.map((s) => s.scIdentifier), ['web1:1', 'm1:2']);
      expect(shares.map((s) => s.amount), [0.00002, 0.000015]);
    });

    test('accepts Data wrapped in a list or already decoded', () {
      expect(vbtcMultiWithdrawalSharesOf('[$multiData]'), hasLength(2));
      expect(
        vbtcMultiWithdrawalSharesOf({
          'Function': 'VBTCWithdrawalRequestMultiV2()',
          'Inputs': [
            {'SCUID': 'a:1', 'Amount': 0.1}
          ],
        }),
        hasLength(1),
      );
    });

    test('is null for a single-vault request and for unreadable Data', () {
      expect(
        vbtcMultiWithdrawalSharesOf('{"Function":"VBTCWithdrawalRequest()","ContractUID":"a:1","Amount":0.1}'),
        isNull,
      );
      expect(vbtcMultiWithdrawalSharesOf('not json'), isNull);
      expect(vbtcMultiWithdrawalSharesOf(null), isNull);
      expect(vbtcMultiWithdrawalSharesOf(''), isNull);
    });
  });
}
