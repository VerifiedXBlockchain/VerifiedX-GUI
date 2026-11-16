/// Why a typed amount could not be read.
enum P2pAmountInputError { empty, format, decimals, zero }

/// A VFX amount as the P2P API writes it: a decimal string with up to 8
/// places, held exactly in units of 1e-8 VFX. Never a double: a bid signs
/// `amount × 1e8` as an integer, and a double can be one unit off.
class P2pAmount implements Comparable<P2pAmount> {
  static const int maxPlaces = 8;
  static final BigInt unitsPerVfx = BigInt.from(100000000);
  static final RegExp _decimal = RegExp(r'^(\d+)(?:\.(\d{1,8}))?$');
  static final RegExp _typed = RegExp(r'^(\d*)(?:\.(\d*))?$');

  /// The amount in units of 1e-8 VFX.
  final BigInt units;

  const P2pAmount._(this.units);

  static final P2pAmount zero = P2pAmount._(BigInt.zero);

  factory P2pAmount.fromUnits(BigInt units) => P2pAmount._(units);

  /// The amount [text] names, or null when it is not a non-negative decimal
  /// with at most 8 places and no exponent ("10", "0.5", "12.34567891").
  static P2pAmount? tryParse(String? text) {
    if (text == null) {
      return null;
    }
    final match = _decimal.firstMatch(text);
    if (match == null) {
      return null;
    }
    final whole = BigInt.parse(match.group(1)!);
    final fraction = BigInt.parse((match.group(2) ?? '').padRight(maxPlaces, '0'));
    return P2pAmount._(whole * unitsPerVfx + fraction);
  }

  /// As [tryParse], throwing a [FormatException] for anything else.
  factory P2pAmount.parse(String text) {
    final amount = tryParse(text);
    if (amount == null) {
      throw FormatException('Not a decimal amount with at most 8 places', text);
    }
    return amount;
  }

  /// A balance or fee Core reports as a double, to the nearest unit. For
  /// comparing and display only: never the source of a signed amount.
  factory P2pAmount.fromDouble(double value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(value, 'value', 'Not a non-negative finite amount');
    }
    return P2pAmount._(BigInt.from((value * 1e8).round()));
  }

  /// The shortest decimal string, as the API writes one: 150000000 → "1.5".
  String toDecimalString() {
    final negative = units.isNegative;
    final abs = units.abs();
    final whole = abs ~/ unitsPerVfx;
    final fraction = (abs % unitsPerVfx).toString().padLeft(maxPlaces, '0').replaceFirst(RegExp(r'0+$'), '');
    return "${negative ? '-' : ''}$whole${fraction.isEmpty ? '' : '.$fraction'}";
  }

  bool get isPositive => units > BigInt.zero;

  P2pAmount operator +(P2pAmount other) => P2pAmount._(units + other.units);

  /// May be negative: for comparing and display, not for [parse].
  P2pAmount operator -(P2pAmount other) => P2pAmount._(units - other.units);

  bool operator <(P2pAmount other) => units < other.units;
  bool operator <=(P2pAmount other) => units <= other.units;
  bool operator >(P2pAmount other) => units > other.units;
  bool operator >=(P2pAmount other) => units >= other.units;

  @override
  int compareTo(P2pAmount other) => units.compareTo(other.units);

  @override
  bool operator ==(Object other) => other is P2pAmount && other.units == units;

  @override
  int get hashCode => units.hashCode;

  @override
  String toString() => toDecimalString();
}

/// What a person typed into an amount field: [amount] when it reads as one
/// above zero, else [error].
class P2pAmountInput {
  final P2pAmount? amount;
  final P2pAmountInputError? error;

  const P2pAmountInput._(this.amount, this.error);

  /// Reads "12", "12.5", ".5" and "12." (surrounding spaces ignored). More
  /// than 8 places, zero, an exponent, a sign or a thousands separator are
  /// refused rather than guessed at.
  factory P2pAmountInput.read(String typed) {
    final text = typed.trim();
    if (text.isEmpty) {
      return const P2pAmountInput._(null, P2pAmountInputError.empty);
    }
    final match = P2pAmount._typed.firstMatch(text);
    if (match == null) {
      return const P2pAmountInput._(null, P2pAmountInputError.format);
    }
    final whole = match.group(1) ?? '';
    final fraction = match.group(2) ?? '';
    if (whole.isEmpty && fraction.isEmpty) {
      return const P2pAmountInput._(null, P2pAmountInputError.format);
    }
    if (fraction.length > P2pAmount.maxPlaces) {
      return const P2pAmountInput._(null, P2pAmountInputError.decimals);
    }
    final amount = P2pAmount.parse("${whole.isEmpty ? '0' : whole}${fraction.isEmpty ? '' : '.$fraction'}");
    if (!amount.isPositive) {
      return const P2pAmountInput._(null, P2pAmountInputError.zero);
    }
    return P2pAmountInput._(amount, null);
  }
}

/// An API amount for display: the decimal string with thousands separators
/// in its whole part ("12,345.5"). Anything that is not an amount is shown
/// as it came.
String formatP2pAmount(String? amount) {
  final parsed = P2pAmount.tryParse(amount);
  if (parsed == null) {
    return amount ?? '';
  }
  final text = parsed.toDecimalString();
  final dot = text.indexOf('.');
  final whole = dot < 0 ? text : text.substring(0, dot);
  final fraction = dot < 0 ? '' : text.substring(dot);
  final grouped = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');
  return "$grouped$fraction";
}
