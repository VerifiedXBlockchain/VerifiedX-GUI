import '../../btc_web/models/watched_withdrawal.dart';

/// One vault's share ("part") of a multi-vault withdrawal request. Each part
/// is paid by its own Bitcoin transaction and settles on its own.
class VbtcWithdrawalPart {
  final String scIdentifier;

  /// The vault's token name, or its contract id when the wallet does not
  /// know it by name.
  final String name;
  final double amount;

  const VbtcWithdrawalPart({
    required this.scIdentifier,
    required this.name,
    required this.amount,
  });
}

/// Where one part stands, from the chain's answer for its vault.
enum VbtcWithdrawalPartState { checking, notMinedYet, waiting, pinned, releasing, paid, returned }

VbtcWithdrawalPartState vbtcWithdrawalPartState(WatchedWithdrawal? watched) {
  if (watched == null) return VbtcWithdrawalPartState.checking;
  if (watched.paid) return VbtcWithdrawalPartState.paid;
  if (watched.notMinedYet) return VbtcWithdrawalPartState.notMinedYet;
  if (watched.releasing) return VbtcWithdrawalPartState.releasing;
  if (watched.isPinned) return VbtcWithdrawalPartState.pinned;
  if (watched.isWaiting) return VbtcWithdrawalPartState.waiting;
  return VbtcWithdrawalPartState.returned;
}

/// The heading for a whole request, as Butterfly words it: still being paid,
/// all sent, some sent and the rest returned, or all returned.
enum VbtcMultiWithdrawalOverall { notMinedYet, inProgress, sent, partlySent, returned }

VbtcMultiWithdrawalOverall vbtcMultiWithdrawalOverall(List<WatchedWithdrawal?> parts) {
  if (parts.isEmpty || parts.every((p) => p == null || p.notMinedYet)) {
    return VbtcMultiWithdrawalOverall.notMinedYet;
  }
  if (parts.any((p) => p == null || !p.isClosed)) {
    return VbtcMultiWithdrawalOverall.inProgress;
  }
  final paid = parts.where((p) => p!.paid).length;
  if (paid == parts.length) return VbtcMultiWithdrawalOverall.sent;
  if (paid == 0) return VbtcMultiWithdrawalOverall.returned;
  return VbtcMultiWithdrawalOverall.partlySent;
}

/// What the status dialog asks of the platform for one request: the desktop
/// node, or Spyglass and the web wallet's own signing.
abstract class VbtcWithdrawalPartActions {
  /// Where [scIdentifier]'s part stands, or null when it could not be read.
  Future<WatchedWithdrawal?> lookUp(String scIdentifier);

  /// Sends a fee raise or, with [release], a release of one part. True when
  /// sent; a refusal has already been shown.
  Future<bool> changeFee(String scIdentifier, int feeRate, {required bool release});

  /// Cancels one part still waiting for its Bitcoin transaction. True when
  /// sent; a refusal has already been shown.
  Future<bool> cancel(String scIdentifier);
}
