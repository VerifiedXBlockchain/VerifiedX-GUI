import '../../btc_web/models/watched_withdrawal.dart';
import '../models/vbtc_withdrawal_part.dart';
import 'vbtc_v2_service.dart';

/// A multi-vault withdrawal's parts on the desktop node, which holds the
/// requester's key and signs each raise, release or cancel itself.
class DesktopVbtcWithdrawalPartActions implements VbtcWithdrawalPartActions {
  final String requestHash;
  final String requestorAddress;

  const DesktopVbtcWithdrawalPartActions({
    required this.requestHash,
    required this.requestorAddress,
  });

  @override
  Future<WatchedWithdrawal?> lookUp(String scIdentifier) {
    return VbtcV2Service().watchedWithdrawal(
      scUid: scIdentifier,
      withdrawalRequestHash: requestHash,
    );
  }

  @override
  Future<bool> changeFee(String scIdentifier, int feeRate, {required bool release}) async {
    final sentHash = await VbtcV2Service().changeWatchedWithdrawal(
      scUid: scIdentifier,
      requestorAddress: requestorAddress,
      withdrawalRequestHash: requestHash,
      feeRate: feeRate,
      release: release,
    );
    return sentHash != null;
  }

  @override
  Future<bool> cancel(String scIdentifier) {
    return VbtcV2Service().cancelWithdrawal(
      scUid: scIdentifier,
      ownerAddress: requestorAddress,
      withdrawalRequestHash: requestHash,
    );
  }
}
