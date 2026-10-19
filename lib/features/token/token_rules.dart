/// Consensus rules for fungible tokens that the wallet checks before building
/// a transaction, so a refusal is explained in the form instead of arriving as
/// a node error.

/// Whether a token transfer names its own sender as the recipient. The node
/// refuses a TokenTransfer() to the sender's own address (NEW-04, NEW-09), and
/// the address field accepts mixed case, so the comparison ignores case and
/// surrounding whitespace.
bool isTokenTransferToSelf(String fromAddress, String toAddress) {
  return fromAddress.trim().toLowerCase() == toAddress.trim().toLowerCase();
}

/// Largest supply the node accepts in TokenDeploy() (VX-02).
const int kTokenMaxSupply = 2147483647;

final _wholeNumber = RegExp(r'^\d+(\.0*)?$');

/// Whether [text] is a token supply the node accepts: a whole number from 0 to
/// [kTokenMaxSupply]. A trailing ".0" is allowed because the form shows a
/// stored supply in its double form, for example "1000.0".
bool isValidTokenSupply(String text) {
  final trimmed = text.trim();
  if (!_wholeNumber.hasMatch(trimmed)) {
    return false;
  }
  final whole = BigInt.parse(trimmed.split('.').first);
  return whole <= BigInt.from(kTokenMaxSupply);
}

/// C#'s `decimal.MaxValue`, the largest supply or balance Core can hold.
const double kTokenMaxAmount = 79228162514264337593543950335.0;

/// Why Core refuses a TokenMint(), from `TokenMintRulesHeight`
/// (`LedgerIntegrityRules.TokenMintRefusal`).
enum TokenMintProblem {
  /// The contract is paused.
  paused,

  /// The amount has more decimal places than the token's `DecimalPlaces`; the
  /// remainder could never be transferred.
  tooManyDecimals,

  /// The current supply or the minter's balance would pass [kTokenMaxAmount].
  overflow,
}

/// Why a mint of [amount] would be refused, or null when it passes. Each
/// check is skipped when its state is unknown (null), and the node judges it
/// instead.
TokenMintProblem? tokenMintProblem({
  required double amount,
  required int? decimalPlaces,
  bool? isPaused,
  double? currentSupply,
  double? holderBalance,
}) {
  if (isPaused == true) return TokenMintProblem.paused;
  if (decimalPlaces != null && (decimalPlaces < 0 || decimalPlacesOf(amount) > decimalPlaces)) {
    return TokenMintProblem.tooManyDecimals;
  }
  if (currentSupply != null && amount > kTokenMaxAmount - currentSupply) return TokenMintProblem.overflow;
  if (holderBalance != null && amount > kTokenMaxAmount - holderBalance) return TokenMintProblem.overflow;
  return null;
}

/// Significant decimal places of [value] as Dart prints it (the shortest
/// form that reads back the same), including exponent forms like 1e-7.
int decimalPlacesOf(double value) {
  final plain = plainDecimalString(value);
  final point = plain.indexOf('.');
  return point < 0 ? 0 : plain.length - point - 1;
}

/// [value] as a plain decimal with no exponent and no trailing zeros, so the
/// node's `decimal` binding reads it. `double.toString()` gives "1e-7" for
/// 0.0000001, which a C# decimal route parameter refuses.
String plainDecimalString(double value) {
  var text = value.toString();
  final negative = text.startsWith('-');
  if (negative) text = text.substring(1);

  final e = text.indexOf('e');
  var mantissa = e < 0 ? text : text.substring(0, e);
  final exponent = e < 0 ? 0 : int.parse(text.substring(e + 1));

  final point = mantissa.indexOf('.');
  var digits = point < 0 ? mantissa : mantissa.replaceFirst('.', '');
  var intLength = (point < 0 ? mantissa.length : point) + exponent;

  if (intLength <= 0) {
    digits = '0' * (1 - intLength) + digits;
    intLength = 1;
  } else if (intLength > digits.length) {
    digits = digits + '0' * (intLength - digits.length);
  }

  var whole = digits.substring(0, intLength).replaceFirst(RegExp(r'^0+(?=\d)'), '');
  var fraction = digits.substring(intLength).replaceFirst(RegExp(r'0+$'), '');
  mantissa = fraction.isEmpty ? whole : '$whole.$fraction';
  return negative ? '-$mantissa' : mantissa;
}
