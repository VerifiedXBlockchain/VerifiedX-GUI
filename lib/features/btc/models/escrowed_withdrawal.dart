import 'package:collection/collection.dart';

/// One open withdrawal request of a holder, as `GetVBTCBalance` reports it in
/// `EscrowedWithdrawals` (Core 6605b537+). The amount was debited into escrow
/// when the request was mined; it comes back only by completing or cancelling.
class EscrowedWithdrawal {
  final String requestHash;
  final double amount;
  final String? btcDestination;

  /// Past the 360-block window: it no longer blocks a new request and can no
  /// longer be completed. The escrow returns only through a cancellation.
  final bool expired;

  /// Too small to pay at its fee rate, so every completion attempt fails.
  final bool unpayable;

  /// A withdrawal-cancel transaction is awaiting the validators' vote.
  final bool cancellationPending;

  const EscrowedWithdrawal({
    required this.requestHash,
    required this.amount,
    this.btcDestination,
    this.expired = false,
    this.unpayable = false,
    this.cancellationPending = false,
  });

  factory EscrowedWithdrawal.fromJson(Map<String, dynamic> json) {
    return EscrowedWithdrawal(
      requestHash: (json['RequestHash'] ?? '').toString(),
      amount: (json['Amount'] as num?)?.toDouble() ?? 0,
      btcDestination: json['BTCDestination'] as String?,
      expired: json['Expired'] == true,
      unpayable: json['Unpayable'] == true,
      cancellationPending: json['CancellationPending'] == true,
    );
  }

  /// Parses the `EscrowedWithdrawals` array. Null when the field is absent
  /// (a node older than the escrow API), so callers can tell "no open
  /// requests" from "the node cannot say".
  static List<EscrowedWithdrawal>? listFromJson(dynamic raw) {
    if (raw is! List) return null;
    return raw
        .whereType<Map>()
        .map((e) => EscrowedWithdrawal.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// What the Withdraw button should do about a contract's active withdrawal.
enum PendingWithdrawalAction {
  /// Nothing pending: open the withdrawal form.
  openForm,

  /// A live request: offer to complete it (the existing prompt).
  offerComplete,

  /// This wallet's request expired unpaid: explain, then allow the form.
  expired,

  /// This wallet's request can never be paid: explain, then allow the form.
  unpayable,
}

/// Decides the pre-check for the V2 Withdraw button.
///
/// [activeRequestHash] is the contract's `ActiveWithdrawalRequestHash` (one
/// slot shared by every holder). [escrowed] is this wallet's open requests
/// from `GetVBTCBalance`, or null when they could not be read; then, and when
/// the active request is not among them, the existing prompt is kept.
PendingWithdrawalAction classifyPendingWithdrawal({
  required String? activeRequestHash,
  required List<EscrowedWithdrawal>? escrowed,
}) {
  if (activeRequestHash == null || activeRequestHash.isEmpty) {
    return PendingWithdrawalAction.openForm;
  }

  final entry = escrowed?.firstWhereOrNull((e) => e.requestHash == activeRequestHash);
  if (entry == null) return PendingWithdrawalAction.offerComplete;
  if (entry.expired) return PendingWithdrawalAction.expired;
  if (entry.unpayable) return PendingWithdrawalAction.unpayable;
  return PendingWithdrawalAction.offerComplete;
}
