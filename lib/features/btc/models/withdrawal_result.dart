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

  const WithdrawalResult({
    required this.success,
    this.message,
    this.requestHash,
    this.vfxTransactionHash,
    this.btcTransactionHash,
    this.status,
    this.timedOut = false,
  });
}
