import 'package:bip39/bip39.dart' as bip39;

/// How the wallet reads a typed or pasted recovery phrase before checking it.
///
/// The BIP39 check splits on single ASCII spaces and compares against the
/// lowercase English word list, so a phrase that is right but typed in another
/// form is refused. A Japanese input method types full-width spaces and
/// letters, a paste from a list brings line breaks and double spaces, and
/// phones capitalize the first word. Every English word is plain lowercase
/// ASCII, so these forms are rewritten to it and the phrase reaches the check
/// as one space between each word. Words that are wrong stay wrong.

/// Full-width Latin letters, each 0xFEE0 above its ASCII form. Only letters
/// are mapped: full-width ？ or ＃ made ASCII would end the URL path the
/// desktop restore sends the phrase in.
const int _fullWidthUpperFirst = 0xFF21;
const int _fullWidthUpperLast = 0xFF3A;
const int _fullWidthLowerFirst = 0xFF41;
const int _fullWidthLowerLast = 0xFF5A;
const int _fullWidthOffset = 0xFEE0;

/// Any run of Unicode whitespace, including the full-width space (U+3000),
/// no-break space and line breaks.
final _whitespaceRun = RegExp(r'\s+');

bool _isFullWidthLetter(int rune) =>
    (rune >= _fullWidthUpperFirst && rune <= _fullWidthUpperLast) ||
    (rune >= _fullWidthLowerFirst && rune <= _fullWidthLowerLast);

String _fullWidthLettersToAscii(String text) => String.fromCharCodes(
      text.runes.map((rune) => _isFullWidthLetter(rune) ? rune - _fullWidthOffset : rune),
    );

/// [input] as the BIP39 check expects it: full-width letters made ASCII,
/// lowercase, and words separated by one space with none at either end.
String normalizeRecoveryPhrase(String input) {
  return _fullWidthLettersToAscii(input).toLowerCase().trim().split(_whitespaceRun).join(' ');
}

/// The normalized phrase when it is a valid English BIP39 phrase, otherwise
/// null. A valid phrase holds only lowercase letters and single spaces, so it
/// is safe to place in a URL path.
String? validRecoveryPhrase(String input) {
  final phrase = normalizeRecoveryPhrase(input);
  return bip39.validateMnemonic(phrase) ? phrase : null;
}
