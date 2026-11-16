/// Why a shop step could not be described: Core would refuse the transaction,
/// or there was nothing to build it from. Nothing was built.
enum P2pChainFailure {
  /// The price is not above zero.
  priceZero,

  /// The listing has no winner (or no winning amount) to build the step for.
  noWinner,

  /// The contract's royalty amount is 1 or more: Core pays a royalty as
  /// `price × amount`, which would leave the seller nothing.
  royaltyTooHigh,

  /// At this price the royalty rounds to nothing, and Core refuses a sale
  /// payment that is not above zero.
  royaltyZero,

  /// Core could not quote the transaction's fee.
  feeUnavailable,

  /// The shop's name, URL or description is outside Core's limits.
  shopFields,
}

class P2pChainError implements Exception {
  final P2pChainFailure failure;

  const P2pChainError(this.failure);

  @override
  String toString() => "P2pChainError(${failure.name})";
}
