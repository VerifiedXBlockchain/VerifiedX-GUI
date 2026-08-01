/// What a vBTC V2 withdrawal may safely do next when nothing local records it.
///
/// The wallet normally answers this from browser storage — a recorded Bitcoin
/// broadcast, or a stored FROST job id. Neither survives a different device or
/// a cleared profile, and on that path the only remaining account of what has
/// already happened is the explorer's withdrawal row.
enum FrostResumeAction {
  /// Nothing has been signed. A fresh signing ceremony is safe.
  ceremony,

  /// A signed Bitcoin transaction exists and the row names it, so the
  /// withdrawal can be settled with the completion transaction alone.
  completionOnly,

  /// Signing has already run and nothing here can finish it. Re-signing would
  /// risk a second payout, so the user has to be told rather than retried.
  refuse,
}

/// Decides what a resume with no local recovery record may do, given the
/// explorer's row for the withdrawal (null when it could not be read).
///
/// Treats a withdrawal as already signed if EITHER signal says so:
///
/// - `signed_at` is set — the explorer's direct record that FROST produced a
///   broadcastable Bitcoin transaction. `signed_btc_tx_hex` is deliberately
///   withheld from the payload, since anyone holding it can broadcast it, so
///   this timestamp is the only evidence available to a client.
/// - the status is `pending_btc` — what the explorer sets at that same moment.
///
/// Either alone is enough on purpose. Requiring both would fail open against an
/// explorer that carries the status but not yet the field, and a missing
/// `signed_at` is not evidence that nothing was signed. The cost of being
/// wrong is asymmetric: a needless manual step versus paying a withdrawal
/// twice.
FrostResumeAction frostResumeActionFor(Map<String, dynamic>? withdrawalRequest) {
  // An unreadable row teaches nothing. Every first-time withdrawal reaches
  // this code with no local record, so refusing here would block the ordinary
  // path on a transient explorer error.
  if (withdrawalRequest == null) return FrostResumeAction.ceremony;

  final status = withdrawalRequest['status'];
  final normalisedStatus = status is String ? status.trim().toLowerCase() : '';

  final signedAt = withdrawalRequest['signed_at'];
  final hasSignedAt = signedAt is String && signedAt.trim().isNotEmpty;

  if (!hasSignedAt && normalisedStatus != 'pending_btc') {
    return FrostResumeAction.ceremony;
  }

  // Only reachable once the Type 28 completion has landed, which also moves
  // the row to `completed` — but if a hash is there, settling beats refusing.
  final btcTxHash = withdrawalRequest['btc_transaction_hash'];
  if (btcTxHash is String && btcTxHash.trim().isNotEmpty) {
    return FrostResumeAction.completionOnly;
  }

  return FrostResumeAction.refuse;
}
