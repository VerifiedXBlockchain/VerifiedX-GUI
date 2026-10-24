import '../../../core/app_constants.dart';
import 'vbtc_multi_allocator.dart';

const int _satsPerVbtc = 100000000;

int _toSats(double amount) => (amount * _satsPerVbtc).round();
double _fromSats(int sats) => sats / _satsPerVbtc;

/// Size of the smallest Bitcoin withdrawal transaction Core builds: one
/// Taproot input, destination and change (VBTCService.MinWithdrawalTxVBytes).
const int vbtcWithdrawalMinTxVBytes = 154;

/// Smallest payout Bitcoin nodes relay (VBTCService.TaprootDustSats).
const int vbtcWithdrawalDustSats = 330;

/// The Bitcoin fee one share pays at [feeRate] sats/vB, out of its own
/// amount. A vault whose coins are small may need a bigger transaction, so
/// this is the least it costs.
int vbtcWithdrawalShareFeeSats(int feeRate) => feeRate * vbtcWithdrawalMinTxVBytes;

/// The smallest share Core accepts at [feeRate]: its fee plus a relayable
/// payout (VBTCService.GetWithdrawalFeeFloorError).
int vbtcWithdrawalShareFloorSats(int feeRate) => vbtcWithdrawalShareFeeSats(feeRate) + vbtcWithdrawalDustSats;

/// The most one request can withdraw from [balances]: the sum of the
/// [VBTC_MULTI_WITHDRAWAL_MAX_VAULTS] largest.
double vbtcMultiWithdrawalMax(Map<String, double> balances) {
  final sats = balances.values.map(_toSats).where((s) => s > 0).toList()..sort((a, b) => b.compareTo(a));
  return _fromSats(sats.take(VBTC_MULTI_WITHDRAWAL_MAX_VAULTS).fold<int>(0, (sum, s) => sum + s));
}

enum VbtcWithdrawalPlanFailure { insufficientBalance, tooManyVaults, shareBelowFeeFloor }

/// How one withdrawal request of a total would be split across vaults, with
/// what it costs in Bitcoin fees, or why Core would refuse it.
class VbtcWithdrawalPlan {
  final List<VbtcAllocationInput> shares;
  final int feeRate;
  final VbtcWithdrawalPlanFailure? failure;

  /// 1-based part that falls below the fee floor, for
  /// [VbtcWithdrawalPlanFailure.shareBelowFeeFloor].
  final int? belowFloorPart;

  /// Combined balance across every candidate vault.
  final double available;

  const VbtcWithdrawalPlan({
    required this.shares,
    required this.feeRate,
    required this.available,
    this.failure,
    this.belowFloorPart,
  });

  bool get ok => failure == null;

  int get perShareFeeSats => vbtcWithdrawalShareFeeSats(feeRate);

  int get totalFeeSats => perShareFeeSats * shares.length;

  int get floorSats => vbtcWithdrawalShareFloorSats(feeRate);

  /// What reaches the Bitcoin address: the total less one fee per share.
  double get netAmount => _fromSats(shares.fold<int>(0, (sum, s) => sum + _toSats(s.amount)) - totalFeeSats);
}

/// Splits [total] across [balances] (vault id to spendable vBTC) by Core's
/// rule, largest first and ties by id, then checks what Core checks before it
/// signs anything: at most [VBTC_MULTI_WITHDRAWAL_MAX_VAULTS] vaults, and
/// each share able to pay its own fee at [feeRate] and leave a relayable
/// payout. The last share is the one that runs small.
VbtcWithdrawalPlan planVbtcMultiWithdrawal(Map<String, double> balances, double total, int feeRate) {
  final allocation = allocateVbtcInputs(balances, total, maxInputs: VBTC_MULTI_WITHDRAWAL_MAX_VAULTS);
  if (!allocation.ok) {
    return VbtcWithdrawalPlan(
      shares: const [],
      feeRate: feeRate,
      available: allocation.available,
      failure: allocation.failure == VbtcAllocationFailure.tooManyInputs
          ? VbtcWithdrawalPlanFailure.tooManyVaults
          : VbtcWithdrawalPlanFailure.insufficientBalance,
    );
  }

  final floor = vbtcWithdrawalShareFloorSats(feeRate);
  for (var i = 0; i < allocation.inputs.length; i++) {
    if (_toSats(allocation.inputs[i].amount) < floor) {
      return VbtcWithdrawalPlan(
        shares: allocation.inputs,
        feeRate: feeRate,
        available: allocation.available,
        failure: VbtcWithdrawalPlanFailure.shareBelowFeeFloor,
        belowFloorPart: i + 1,
      );
    }
  }

  return VbtcWithdrawalPlan(shares: allocation.inputs, feeRate: feeRate, available: allocation.available);
}
