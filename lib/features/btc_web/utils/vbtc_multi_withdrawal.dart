import '../../../core/app_constants.dart';
import 'vbtc_amount.dart';
import 'vbtc_multi_allocator.dart';

const int _satsPerVbtc = 100000000;

int _toSats(double amount) => (amount * _satsPerVbtc).round();
double _fromSats(int sats) => sats / _satsPerVbtc;

/// The Bitcoin fee one share pays at [feeRate] sats/vB, out of its own
/// amount. A vault whose coins are small may need a bigger transaction, so
/// this is the least it costs.
int vbtcWithdrawalShareFeeSats(int feeRate) => feeRate * kVbtcWithdrawalMinVsize;

/// The most one request can withdraw from [balances]: the sum of the
/// [VBTC_MULTI_WITHDRAWAL_MAX_VAULTS] largest.
double vbtcMultiWithdrawalMax(Map<String, double> balances) {
  final sats = balances.values.map(_toSats).where((s) => s > 0).toList()..sort((a, b) => b.compareTo(a));
  return _fromSats(sats.take(VBTC_MULTI_WITHDRAWAL_MAX_VAULTS).fold<int>(0, (sum, s) => sum + s));
}

enum VbtcWithdrawalPlanFailure {
  /// The total is zero, negative or more precise than a satoshi.
  invalidAmount,

  /// The fee rate is not a positive number of sats/vB.
  invalidFeeRate,
  insufficientBalance,
  tooManyVaults,
  shareBelowFeeFloor,
}

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

  /// The least Bitcoin fee one share pays: the smallest withdrawal
  /// transaction at [feeRate]. A vault whose coins are small may need a
  /// bigger transaction and pay more.
  int get minPerShareFeeSats => vbtcWithdrawalShareFeeSats(feeRate);

  /// The least the shares pay in Bitcoin fees together.
  int get minTotalFeeSats => minPerShareFeeSats * shares.length;

  int get floorSats => vbtcWithdrawalMinimumSats(feeRate);

  /// The most that reaches the Bitcoin address: the total less the least
  /// fee per share. Less arrives when a share needs a bigger transaction.
  double get maxNetAmount => _fromSats(shares.fold<int>(0, (sum, s) => sum + _toSats(s.amount)) - minTotalFeeSats);
}

double _available(Map<String, double> balances) =>
    _fromSats(balances.values.map(_toSats).where((s) => s > 0).fold<int>(0, (sum, s) => sum + s));

/// Splits [total] across [balances] (vault id to spendable vBTC) by Core's
/// rule, largest first and ties by id, then checks what Core checks before it
/// signs anything: at most [VBTC_MULTI_WITHDRAWAL_MAX_VAULTS] vaults, and
/// each share able to pay its own fee at [feeRate] and leave
/// [kBtcDustSats] to pay out. That is the watched vault's rule
/// (BtcWithdrawals in Core), stricter than the request builder's 330-sat
/// floor. The last share is the one that runs small.
VbtcWithdrawalPlan planVbtcMultiWithdrawal(Map<String, double> balances, double total, int feeRate) {
  if (feeRate <= 0) {
    return VbtcWithdrawalPlan(
      shares: const [],
      feeRate: feeRate,
      available: _available(balances),
      failure: VbtcWithdrawalPlanFailure.invalidFeeRate,
    );
  }
  if (!(total > 0) || _fromSats(_toSats(total)) != total) {
    return VbtcWithdrawalPlan(
      shares: const [],
      feeRate: feeRate,
      available: _available(balances),
      failure: VbtcWithdrawalPlanFailure.invalidAmount,
    );
  }

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

  final floor = vbtcWithdrawalMinimumSats(feeRate);
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

/// Whether Core's own allocation of [total] would draw on a vault outside
/// [watched]. Desktop sends only the total (`RequestWithdrawalMulti`), and
/// Core allocates across every vault it has not frozen, so a legacy vault
/// among the largest would get a share this flow cannot complete.
/// [balances] is every unfrozen vault with its spendable balance.
bool vbtcCoreAllocationTouchesUnwatched(Map<String, double> balances, Set<String> watched, double total) {
  final allocation = allocateVbtcInputs(balances, total, maxInputs: VBTC_MULTI_WITHDRAWAL_MAX_VAULTS);
  return allocation.inputs.any((input) => !watched.contains(input.scIdentifier));
}
