import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/utils/vbtc_multi_allocator.dart';
import 'package:rbx_wallet/features/btc_web/utils/vbtc_multi_withdrawal.dart';

void main() {
  group('share fee', () {
    test('is the smallest withdrawal transaction at the fee rate', () {
      expect(vbtcWithdrawalShareFeeSats(3), 462);
      expect(vbtcWithdrawalShareFeeSats(1), 154);
    });
  });

  group('vbtcMultiWithdrawalMax', () {
    test('sums every balance when there are 10 vaults or fewer', () {
      expect(vbtcMultiWithdrawalMax({'a:1': 0.00005, 'b:2': 0.00002}), 0.00007);
    });

    test('sums only the 10 largest', () {
      final balances = {
        for (var i = 1; i <= 12; i++) 'c:$i': i / 100000000,
      };
      // 3 + 4 + ... + 12 sats; the 1 and 2 sat vaults are left out.
      expect(vbtcMultiWithdrawalMax(balances), 75 / 100000000);
    });

    test('ignores empty vaults', () {
      expect(vbtcMultiWithdrawalMax({'a:1': 0, 'b:2': 0.0001}), 0.0001);
      expect(vbtcMultiWithdrawalMax({}), 0);
    });
  });

  group('planVbtcMultiWithdrawal', () {
    test('splits largest first and prices one fee per share', () {
      final plan = planVbtcMultiWithdrawal({'small:1': 0.00002, 'big:2': 0.00005}, 0.00007, 3);

      expect(plan.ok, isTrue);
      expect(plan.shares.map((s) => s.scIdentifier), ['big:2', 'small:1']);
      expect(plan.shares.map((s) => s.amount), [0.00005, 0.00002]);
      expect(plan.minPerShareFeeSats, 462);
      expect(plan.minTotalFeeSats, 924);
      expect(plan.maxNetAmount, 0.00006076);
    });

    test('one vault that covers the amount is one share', () {
      final plan = planVbtcMultiWithdrawal({'a:1': 0.001, 'b:2': 0.0005}, 0.0002, 2);

      expect(plan.ok, isTrue);
      expect(plan.shares, hasLength(1));
      expect(plan.minTotalFeeSats, 308);
    });

    test('names the part that would fall below the fee floor', () {
      // big covers 0.00005, the last 0.000004 (400 sats) lands on small: under 1008 at 3 sat/vB.
      final plan = planVbtcMultiWithdrawal({'small:1': 0.00002, 'big:2': 0.00005}, 0.000054, 3);

      expect(plan.failure, VbtcWithdrawalPlanFailure.shareBelowFeeFloor);
      expect(plan.belowFloorPart, 2);
      expect(plan.floorSats, 1008);
    });

    test('a share exactly at the floor is accepted', () {
      final plan = planVbtcMultiWithdrawal({'small:1': 0.00002, 'big:2': 0.00005}, 0.00006008, 3);

      expect(plan.ok, isTrue);
      expect(plan.shares.last.amount, 0.00001008);
      expect(planVbtcMultiWithdrawal({'small:1': 0.00002, 'big:2': 0.00005}, 0.00006007, 3).belowFloorPart, 2);
    });

    test('a lower fee rate lowers the floor', () {
      // The last share is 700 sats: the floor at 1 sat/vB, under it at 3.
      final balances = {'small:1': 0.00002, 'big:2': 0.00005};

      expect(planVbtcMultiWithdrawal(balances, 0.000057, 1).ok, isTrue);
      expect(planVbtcMultiWithdrawal(balances, 0.000057, 3).failure, VbtcWithdrawalPlanFailure.shareBelowFeeFloor);
    });

    test('refuses a total that needs more than 10 vaults', () {
      final balances = {for (var i = 0; i < 11; i++) 'c:${i.toString().padLeft(2, '0')}': 0.0001};

      expect(planVbtcMultiWithdrawal(balances, 0.001, 1).ok, isTrue);
      final plan = planVbtcMultiWithdrawal(balances, 0.0011, 1);
      expect(plan.failure, VbtcWithdrawalPlanFailure.tooManyVaults);
      expect(plan.shares, isEmpty);
    });

    test('refuses a zero, negative or sub-satoshi total with no shares', () {
      final balances = {'a:1': 0.0001};
      for (final total in [0.0, -0.00001, 0.000010001]) {
        final plan = planVbtcMultiWithdrawal(balances, total, 3);
        expect(plan.ok, isFalse, reason: '$total');
        expect(plan.failure, VbtcWithdrawalPlanFailure.invalidAmount, reason: '$total');
        expect(plan.shares, isEmpty);
        expect(plan.available, 0.0001);
      }
    });

    test('refuses a zero or negative fee rate', () {
      for (final feeRate in [0, -1]) {
        final plan = planVbtcMultiWithdrawal({'a:1': 0.0001}, 0.00005, feeRate);
        expect(plan.failure, VbtcWithdrawalPlanFailure.invalidFeeRate, reason: '$feeRate');
        expect(plan.shares, isEmpty);
      }
    });

    test('refuses more than the combined balance', () {
      final plan = planVbtcMultiWithdrawal({'a:1': 0.00002, 'b:2': 0.00003}, 0.00006, 1);

      expect(plan.failure, VbtcWithdrawalPlanFailure.insufficientBalance);
      expect(plan.available, 0.00005);
    });
  });

  group('vbtcWithdrawalPlanForShares', () {
    test("accepts Core's shares when each clears the 546-sat floor", () {
      final plan = vbtcWithdrawalPlanForShares(
        const [
          VbtcAllocationInput(scIdentifier: 'a:1', amount: 0.00005),
          VbtcAllocationInput(scIdentifier: 'b:2', amount: 0.00001008)
        ],
        3,
        0.0001,
      );
      expect(plan.ok, isTrue);
      expect(plan.minTotalFeeSats, 924);
    });

    test("refuses a share Core's 330-sat builder check lets through", () {
      // 792 sats at 3 sat/vB leaves 330: the builder accepts it, a watched vault refuses it at send.
      final plan = vbtcWithdrawalPlanForShares(
        const [
          VbtcAllocationInput(scIdentifier: 'a:1', amount: 0.00005),
          VbtcAllocationInput(scIdentifier: 'b:2', amount: 0.00000792)
        ],
        3,
        0.0001,
      );
      expect(plan.failure, VbtcWithdrawalPlanFailure.shareBelowFeeFloor);
      expect(plan.belowFloorPart, 2);
    });

    test('refuses more than 10 shares and a fee rate of zero', () {
      final eleven = [for (var i = 0; i < 11; i++) VbtcAllocationInput(scIdentifier: 'c:$i', amount: 0.0001)];
      expect(vbtcWithdrawalPlanForShares(eleven, 1, 0.0011).failure, VbtcWithdrawalPlanFailure.tooManyVaults);
      expect(vbtcWithdrawalPlanForShares(eleven.take(2).toList(), 0, 0.0002).failure,
          VbtcWithdrawalPlanFailure.invalidFeeRate);
    });
  });

  group('vbtcPreparedWithdrawalMatches', () {
    const shares = [
      VbtcAllocationInput(scIdentifier: 'big:2', amount: 0.00005),
      VbtcAllocationInput(scIdentifier: 'small:1', amount: 0.00002),
    ];
    Map<String, dynamic> prepared({String destination = 'tb1qdest', List<dynamic>? allocations}) => {
          'success': true,
          'Hash': 'abc',
          'Destination': destination,
          'Allocations': allocations ??
              [
                {'SCUID': 'big:2', 'Amount': 0.00005},
                {'SCUID': 'small:1', 'Amount': 2e-05},
              ],
        };

    test('accepts the confirmed shares and address', () {
      expect(vbtcPreparedWithdrawalMatches(prepared(), shares: shares, btcAddress: 'tb1qdest'), isTrue);
      expect(vbtcPreparedWithdrawalMatches(prepared(destination: 'TB1QDEST'), shares: shares, btcAddress: 'tb1qdest '), isTrue);
    });

    test('refuses another address, vault, amount or share count', () {
      expect(vbtcPreparedWithdrawalMatches(prepared(destination: 'tb1qother'), shares: shares, btcAddress: 'tb1qdest'), isFalse);
      expect(
        vbtcPreparedWithdrawalMatches(
          prepared(allocations: [
            {'SCUID': 'big:2', 'Amount': 0.00005},
            {'SCUID': 'other:3', 'Amount': 0.00002},
          ]),
          shares: shares,
          btcAddress: 'tb1qdest',
        ),
        isFalse,
      );
      expect(
        vbtcPreparedWithdrawalMatches(
          prepared(allocations: [
            {'SCUID': 'big:2', 'Amount': 0.00006},
            {'SCUID': 'small:1', 'Amount': 0.00001},
          ]),
          shares: shares,
          btcAddress: 'tb1qdest',
        ),
        isFalse,
      );
      expect(
        vbtcPreparedWithdrawalMatches(
          prepared(allocations: [
            {'SCUID': 'big:2', 'Amount': 0.00007},
          ]),
          shares: shares,
          btcAddress: 'tb1qdest',
        ),
        isFalse,
      );
      expect(vbtcPreparedWithdrawalMatches({'Destination': 'tb1qdest'}, shares: shares, btcAddress: 'tb1qdest'), isFalse);
    });
  });
}
