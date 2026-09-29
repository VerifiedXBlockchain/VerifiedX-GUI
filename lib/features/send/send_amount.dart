/// Amount rules and math for the VFX/BTC send form. Pure Dart so it can be
/// unit tested without Flutter or the network.
library send_amount;

/// Decimal places a VFX amount may carry. The Core CLI stores amounts as C#
/// `decimal` and does not cap a plain transfer's scale, but it treats VFX as
/// an 8-decimal currency everywhere it fixes one: fees are rounded to 8
/// places and privacy amounts are scaled by 10^8 ("matching VFX's 8 decimal
/// places"). Extra digits would also be lost to the client's `double`.
const int kVfxMaxDecimals = 8;

/// Decimal places a BTC amount may carry (1 satoshi = 0.00000001 BTC).
const int kBtcMaxDecimals = 8;

const int _unitsPerCoin = 100000000;

final _plainDecimal = RegExp(r'^\d*\.?\d*$');
final _trailingZeros = RegExp(r'0+$');

/// Significant decimal places in [amount] as typed: digits after the point,
/// ignoring trailing zeros. Returns null when [amount] is not a plain decimal
/// number (e.g. exponent notation or stray characters).
int? amountDecimalPlaces(String amount) {
  final trimmed = amount.trim();
  if (trimmed.isEmpty || trimmed == '.' || !_plainDecimal.hasMatch(trimmed)) {
    return null;
  }
  final point = trimmed.indexOf('.');
  if (point < 0) {
    return 0;
  }
  return trimmed.substring(point + 1).replaceFirst(_trailingZeros, '').length;
}

/// [value] in 10^-8 units, rounded to the nearest unit to absorb `double`
/// noise such as 0.1 + 0.2.
int _toUnits(double value) => (value * _unitsPerCoin).round();

double _fromUnits(int units) => units / _unitsPerCoin;

/// [value] as a plain decimal string with at most 8 decimals and no trailing
/// zeros. Unlike `double.toString()` it never uses exponent notation, which
/// the CLI's `decimal.Parse` refuses (0.0000001 would otherwise be sent as
/// "1e-7").
String formatSendAmount(double value) {
  final fixed = value.toStringAsFixed(8);
  if (!fixed.contains('.')) {
    return fixed;
  }
  final trimmed = fixed.replaceFirst(_trailingZeros, '');
  return trimmed.endsWith('.') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
}

/// Outcome of fitting a send and its network fee into the spendable balance.
class FeeAdjustedAmount {
  /// Amount to send.
  final double amount;

  /// Network fee quoted for [amount].
  final double fee;

  /// True when [amount] was lowered from what the user entered.
  final bool adjusted;

  const FeeAdjustedAmount({
    required this.amount,
    required this.fee,
    required this.adjusted,
  });

  /// True when nothing is left to send once the fee is reserved.
  bool get feeNotCovered => amount <= 0;
}

/// Fits [amount] plus its network fee into [spendable].
///
/// [feeFor] quotes the fee for a given amount. The fee depends on the
/// serialized transaction size, so it is quoted again for a lowered amount.
/// When [amount] plus its fee already fits, the amount is kept. Otherwise it
/// is lowered to `spendable - fee` (in whole 10^-8 units) and re-quoted until
/// the pair fits. [FeeAdjustedAmount.feeNotCovered] is true when the fee
/// alone takes the whole balance.
///
/// Returns null when [feeFor] cannot quote a fee, so the caller can fall back
/// to the node's own balance check.
Future<FeeAdjustedAmount?> fitAmountWithFee({
  required double amount,
  required double spendable,
  required Future<double?> Function(double amount) feeFor,
}) async {
  final spendableUnits = _toUnits(spendable);

  final firstFee = await feeFor(amount);
  if (firstFee == null) {
    return null;
  }
  var feeUnits = _toUnits(firstFee);

  if (_toUnits(amount) + feeUnits <= spendableUnits) {
    return FeeAdjustedAmount(amount: amount, fee: firstFee, adjusted: false);
  }

  // Each pass re-quotes the fee for the lowered amount. A smaller amount never
  // serializes longer, so this settles in one or two passes; the cap guards
  // against a misbehaving quote.
  for (var pass = 0; pass < 5; pass++) {
    final amountUnits = spendableUnits - feeUnits;
    if (amountUnits <= 0) {
      return FeeAdjustedAmount(amount: 0, fee: _fromUnits(feeUnits), adjusted: true);
    }
    final fee = await feeFor(_fromUnits(amountUnits));
    if (fee == null) {
      return null;
    }
    final quotedUnits = _toUnits(fee);
    if (amountUnits + quotedUnits <= spendableUnits) {
      return FeeAdjustedAmount(amount: _fromUnits(amountUnits), fee: fee, adjusted: true);
    }
    feeUnits = quotedUnits;
  }
  return null;
}

/// True when [destination] is one of [ownAddresses] (the user's own
/// addresses and domains). Base58 addresses are case sensitive; domains and
/// bech32 BTC addresses are compared case-insensitively.
bool isOwnSendAddress(String destination, Iterable<String?> ownAddresses) {
  final target = destination.trim();
  if (target.isEmpty) {
    return false;
  }
  final ignoreCase = _isCaseInsensitiveAddress(target);
  for (final own in ownAddresses) {
    final candidate = own?.trim() ?? '';
    if (candidate.isEmpty) {
      continue;
    }
    if (candidate == target) {
      return true;
    }
    if (ignoreCase && candidate.toLowerCase() == target.toLowerCase()) {
      return true;
    }
  }
  return false;
}

bool _isCaseInsensitiveAddress(String address) {
  final lower = address.toLowerCase();
  return address.contains('.') || lower.startsWith('bc1') || lower.startsWith('tb1');
}
