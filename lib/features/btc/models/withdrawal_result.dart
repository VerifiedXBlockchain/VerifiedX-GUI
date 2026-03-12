class WithdrawalResult {
  final bool success;
  final String? message;
  final String? requestHash;
  final String? vfxTransactionHash;
  final String? btcTransactionHash;
  final String? status;

  const WithdrawalResult({
    required this.success,
    this.message,
    this.requestHash,
    this.vfxTransactionHash,
    this.btcTransactionHash,
    this.status,
  });
}
