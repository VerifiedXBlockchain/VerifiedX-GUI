import '../../btc/models/vbtc_withdrawal_part.dart';
import '../../token/providers/web_token_actions_manager.dart';
import '../models/watched_withdrawal.dart';

/// A multi-vault withdrawal's parts in the web wallet: states from Spyglass,
/// and each raise, release (Type 44) or cancel built, signed and sent by the
/// wallet's own key, as for a single-vault withdrawal.
class WebVbtcWithdrawalPartActions implements VbtcWithdrawalPartActions {
  final WebTokenActionsManager manager;
  final String requestHash;
  final String requestorAddress;

  const WebVbtcWithdrawalPartActions({
    required this.manager,
    required this.requestHash,
    required this.requestorAddress,
  });

  @override
  Future<WatchedWithdrawal?> lookUp(String scIdentifier) {
    return manager.watchedV2Withdrawal(scIdentifier: scIdentifier, requestHash: requestHash);
  }

  @override
  Future<bool> changeFee(String scIdentifier, int feeRate, {required bool release}) async {
    final sent = await manager.raiseWatchedWithdrawalFee(
      scIdentifier: scIdentifier,
      requestHash: requestHash,
      feeRate: feeRate,
      release: release,
    );
    return sent == true;
  }

  @override
  Future<bool> cancel(String scIdentifier) {
    return manager.cancelV2Withdrawal(
      scIdentifier: scIdentifier,
      requestorAddress: requestorAddress,
      requestHash: requestHash,
    );
  }
}
