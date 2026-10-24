import 'package:flutter_test/flutter_test.dart';
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
}
