/// Most decimal places a vBTC V2 amount may carry: one satoshi. The node
/// refuses a transfer, withdrawal or bridge-lock amount with more (VX-01).
const int kVbtcMaxDecimals = 8;

final _plainDecimal = RegExp(r'^\d*\.?\d*$');
final _trailingZeros = RegExp(r'0+$');

/// Whether the typed amount [text] has at most [kVbtcMaxDecimals] significant
/// decimal places. The node compares the value with its rounding to 8 places,
/// so trailing zeros do not count. Text that is not plain decimal notation
/// (for example "1e-9") is judged by its parsed value.
bool vbtcAmountWithinSatoshiPrecision(String text) {
  final trimmed = text.trim();
  if (_plainDecimal.hasMatch(trimmed)) {
    final parts = trimmed.split('.');
    if (parts.length < 2) {
      return true;
    }
    return parts[1].replaceFirst(_trailingZeros, '').length <= kVbtcMaxDecimals;
  }

  final value = double.tryParse(trimmed);
  if (value == null) {
    return false;
  }
  return double.parse(value.toStringAsFixed(kVbtcMaxDecimals)) == value;
}

/// Bitcoin's dust limit: the least a withdrawal may pay out once its fee is
/// taken (Core's `BtcCanonicalWithdrawal.DustSats`).
const int kBtcDustSats = 546;

/// Virtual size of the smallest withdrawal transaction, one input (Core's
/// `BtcCanonicalWithdrawal.VSize(1)`).
const int kVbtcWithdrawalMinVsize = 154;

/// The smallest withdrawal, in sats, the node accepts at [feeRate]: its
/// Bitcoin fee comes out of the amount, and what is left must be at least
/// [kBtcDustSats]. The node checks this only once the request is sent.
int vbtcWithdrawalMinimumSats(int feeRate) => kVbtcWithdrawalMinVsize * feeRate + kBtcDustSats;

/// Whether a withdrawal of [amountBtc] at [feeRate] would be refused for
/// leaving less than [kBtcDustSats] to pay.
bool vbtcWithdrawalLeavesDust(double amountBtc, int feeRate) {
  if (feeRate <= 0) return false;
  return (amountBtc * 100000000).round() < vbtcWithdrawalMinimumSats(feeRate);
}
