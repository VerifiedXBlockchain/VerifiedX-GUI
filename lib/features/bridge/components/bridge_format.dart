// Display helpers shared across the bridge UI.
//
// vBTC amounts have 8 decimal places of precision (sats). Plain
// [num.toString] can switch to scientific notation for small values
// (e.g. `0.00000005` → `5e-8`) — these helpers keep the format consistent.

/// Formats a vBTC amount with up to 8 decimal places, trimming trailing
/// zeros so common values like `0.5` don't render as `0.50000000`.
String formatVbtc(double amount) {
  if (amount == 0) return "0";
  final fixed = amount.toStringAsFixed(8);
  // Strip trailing zeros and an orphaned decimal point.
  return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
