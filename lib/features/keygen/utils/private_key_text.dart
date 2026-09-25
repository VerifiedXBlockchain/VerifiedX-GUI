/// How the web wallet reads a pasted private key, and how it derives the Vault
/// and Bitcoin accounts that belong to it.
///
/// The VFX address comes from the key's value, but the Vault seed and the
/// Bitcoin email and password have always been cut from the key's TEXT. The
/// same key has been written in several texts over time: older nodes exported
/// it with a leading 0 when its top digit is 8 to f (65 characters) and with no
/// padding when it starts with zeros, the remediated node exports exactly 64
/// digits (VX-11), and the web wallet shows "00" plus the text. Each text
/// yields a different Vault and Bitcoin pair, so an import derives from the
/// canonical text and also from the historical ones, and keeps whichever pair
/// has history.

/// Order of the secp256k1 group. A private key is a number from 1 to n - 1.
final BigInt secp256k1Order = BigInt.parse(
  'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
  radix: 16,
);

final _whitespace = RegExp(r'\s');
final _hex = RegExp(r'^[0-9a-fA-F]+$');
final _leadingZeros = RegExp(r'^0+');

/// Shortest derivation text the Vault seed can be cut from.
const int _minDerivationTextLength = 32;

String _stripWhitespace(String text) => text.replaceAll(_whitespace, '');

/// The key as the remediated node's KeyParsing reads it: whitespace and an
/// optional "0x" removed, parsed as an unsigned hexadecimal number, required
/// to be a valid secp256k1 scalar, and written as exactly 64 lowercase hex
/// digits. Null when [input] is not a valid private key.
String? canonicalPrivateKeyHex(String input) {
  var text = _stripWhitespace(input);
  if (text.toLowerCase().startsWith('0x')) {
    text = text.substring(2);
  }
  if (text.isEmpty || !_hex.hasMatch(text)) {
    return null;
  }
  final value = BigInt.parse(text, radix: 16);
  if (value <= BigInt.zero || value >= secp256k1Order) {
    return null;
  }
  return value.toRadixString(16).padLeft(64, '0');
}

/// The text the wallet cuts the Vault seed and the Bitcoin email and password
/// from: the key text with one leading "00" removed, which undoes the "00"
/// the wallet adds when it shows or copies a key.
String derivationTextFromKeyText(String keyText) {
  return keyText.startsWith('00') ? keyText.substring(2) : keyText;
}

/// Seed for the [attempt]-th Vault candidate; the wallet counts up until the
/// derived account has a Vault (xRBX) address.
String reserveSeedFromDerivationText(String derivationText, int attempt) {
  return '${derivationText.substring(0, 32)}$attempt';
}

String btcEmailFromDerivationText(String derivationText) {
  return '${derivationText.substring(0, 8)}@${derivationText.substring(derivationText.length - 8)}.com';
}

String btcPasswordFromDerivationText(String derivationText) {
  return '${derivationText.substring(0, 12)}${derivationText.substring(derivationText.length - 12)}';
}

/// The distinct derivation texts an imported key may have been used with,
/// the canonical 64-digit form first. [canonicalHex] comes from
/// [canonicalPrivateKeyHex]. The others are the 65-character form an older
/// node exported for a key whose top digit is 8 to f, the unpadded form it
/// exported for a key with leading zeros, and [enteredText] exactly as pasted,
/// which is what earlier imports of that text derived from.
List<String> derivationTextCandidates(String canonicalHex, {String? enteredText}) {
  final forms = <String>[
    canonicalHex,
    if (int.parse(canonicalHex[0], radix: 16) >= 8) '0$canonicalHex',
    canonicalHex.replaceFirst(_leadingZeros, ''),
  ];
  if (enteredText != null) {
    final pasted = _stripWhitespace(enteredText);
    if (_hex.hasMatch(pasted) && canonicalPrivateKeyHex(pasted) == canonicalHex) {
      forms.add(pasted);
    }
  }

  final candidates = <String>[];
  for (final form in forms) {
    final text = derivationTextFromKeyText(form);
    if (text.length >= _minDerivationTextLength && !candidates.contains(text)) {
      candidates.add(text);
    }
  }
  return candidates;
}

/// Whether the explorers show activity for a derived Vault and Bitcoin pair.
enum DerivedAccountsHistory { found, none, unknown }

/// Combines the Vault and Bitcoin lookups for one pair: activity on either
/// counts, and a failed lookup leaves the pair unknown unless the other found
/// activity. A null argument means that lookup failed.
DerivedAccountsHistory combineAccountHistory({required bool? vaultHasHistory, required bool? btcHasHistory}) {
  if (vaultHasHistory == true || btcHasHistory == true) {
    return DerivedAccountsHistory.found;
  }
  if (vaultHasHistory == null || btcHasHistory == null) {
    return DerivedAccountsHistory.unknown;
  }
  return DerivedAccountsHistory.none;
}

/// Index of the pair to restore without asking, or null when the user has to
/// choose. [histories] follows [derivationTextCandidates], canonical first.
/// With every lookup answered, the only pair with activity wins, and with no
/// activity anywhere the canonical pair is used. Several pairs with activity,
/// or a lookup that failed, leave the choice to the user.
int? autoSelectDerivedAccounts(List<DerivedAccountsHistory> histories) {
  if (histories.length == 1) {
    return 0;
  }
  if (histories.contains(DerivedAccountsHistory.unknown)) {
    return null;
  }
  final withHistory = [
    for (var i = 0; i < histories.length; i++)
      if (histories[i] == DerivedAccountsHistory.found) i,
  ];
  if (withHistory.isEmpty) {
    return 0;
  }
  if (withHistory.length == 1) {
    return withHistory.single;
  }
  return null;
}
