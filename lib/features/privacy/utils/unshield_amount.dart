import '../../send/send_amount.dart';

/// Decimal places an unshield amount may carry. From `PrivateTxProofRulesHeight`
/// (live on testnet) Core refuses an unshield with more, since its proof binds
/// the amount scaled by 10^8 and anything finer would be truncated
/// (`PrivateTxProofRules.UnshieldAmountDecimalsReason`).
const int kUnshieldMaxDecimals = 8;

/// Whether [amount], as typed, is a plain decimal number with at most
/// [kUnshieldMaxDecimals] significant decimal places.
bool unshieldAmountFitsProof(String amount) {
  final places = amountDecimalPlaces(amount);
  return places != null && places <= kUnshieldMaxDecimals;
}
