import '../../btc_web/models/watched_withdrawal.dart';

class WithdrawalResult {
  final bool success;
  final String? message;
  final String? requestHash;
  final String? vfxTransactionHash;
  final String? btcTransactionHash;
  final String? status;

  /// The request timed out client-side rather than being rejected. The CLI may
  /// still be signing and broadcasting, so this must not be treated as a
  /// failure until the contract state says otherwise — retrying blind can
  /// produce a second Bitcoin transaction.
  final bool timedOut;

  /// The node says this request can never be paid (`Unpayable` on
  /// CompleteWithdrawal), so retrying will keep failing.
  final bool unpayable;

  /// Set when the vault is one the chain watches: the chain pays the
  /// withdrawal, so [success] means only that it is paid or being paid.
  final WatchedWithdrawal? watched;

  const WithdrawalResult({
    required this.success,
    this.message,
    this.requestHash,
    this.vfxTransactionHash,
    this.btcTransactionHash,
    this.status,
    this.timedOut = false,
    this.unpayable = false,
    this.watched,
  });

  /// Whether the Bitcoin has been paid. On a watched vault that is only once
  /// Bitcoin confirms the payout, not when the request is accepted.
  bool get isPaid => watched != null ? watched!.paid : success;

  WithdrawalResult withWatched(WatchedWithdrawal? latest) => WithdrawalResult(
        success: success,
        message: message,
        requestHash: requestHash,
        vfxTransactionHash: vfxTransactionHash,
        btcTransactionHash: latest?.bitcoinTxHash ?? btcTransactionHash,
        status: latest?.status ?? status,
        timedOut: timedOut,
        unpayable: unpayable,
        watched: latest ?? watched,
      );
}
