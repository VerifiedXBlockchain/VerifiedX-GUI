import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/keygen/utils/recovery_phrase.dart';

// BIP39 test vector: valid 12-word English phrase.
const _phrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

const _ideographicSpace = '　';
const _noBreakSpace = ' ';

/// [text] as a Japanese input method in full-width mode types it.
String _fullWidth(String text) => String.fromCharCodes(
      text.runes.map((rune) => rune == 0x20 ? 0x3000 : (rune >= 0x21 && rune <= 0x7E ? rune + 0xFEE0 : rune)),
    );

void main() {
  group('normalizeRecoveryPhrase', () {
    test('a phrase already in canonical form is unchanged', () {
      expect(normalizeRecoveryPhrase(_phrase), _phrase);
    });

    test('full-width spaces from a Japanese input method become single spaces', () {
      final typed = _phrase.replaceAll(' ', _ideographicSpace);
      expect(bip39.validateMnemonic(typed), isFalse);
      expect(normalizeRecoveryPhrase(typed), _phrase);
    });

    test('full-width letters become ASCII', () {
      final typed = _fullWidth(_phrase);
      expect(bip39.validateMnemonic(typed), isFalse);
      expect(normalizeRecoveryPhrase(typed), _phrase);
    });

    test('full-width punctuation is left as typed', () {
      expect(normalizeRecoveryPhrase('abandon？ about＃'), 'abandon？ about＃');
    });

    test('line breaks, tabs, repeated and no-break spaces collapse to one space', () {
      final words = _phrase.split(' ');
      final pasted = '  ${words.take(4).join('\n')}\r\n${words.skip(4).take(4).join('\t')}  ${words.skip(8).join('$_noBreakSpace ')}\n';
      expect(bip39.validateMnemonic(pasted), isFalse);
      expect(normalizeRecoveryPhrase(pasted), _phrase);
    });

    test('capitalized words become lowercase', () {
      final typed = 'Abandon ${_phrase.substring('abandon '.length).toUpperCase()}';
      expect(bip39.validateMnemonic(typed), isFalse);
      expect(normalizeRecoveryPhrase(typed), _phrase);
    });

    test('spelling and word order are not changed', () {
      final words = _phrase.replaceFirst('about', 'abuot').split(' ');
      final reordered = [words.last, ...words.take(words.length - 1)].join(' ');
      expect(normalizeRecoveryPhrase(reordered.replaceAll(' ', _ideographicSpace)), reordered);
    });
  });

  group('validRecoveryPhrase', () {
    test('a phrase typed in another form derives the same seed as the canonical one', () {
      final typed = '${_fullWidth('Abandon')}$_ideographicSpace${_phrase.substring('abandon '.length).replaceAll(' ', '  ')}\n';
      final phrase = validRecoveryPhrase(typed);
      expect(phrase, _phrase);
      expect(bip39.mnemonicToSeedHex(phrase!), bip39.mnemonicToSeedHex(_phrase));
    });

    test('a misspelled word is refused', () {
      expect(validRecoveryPhrase(_phrase.replaceFirst('about', 'abuot')), isNull);
    });

    test('punctuation that would end a URL path is refused, full-width or not', () {
      for (final mark in ['?', '#', '/', '%', '？', '＃', '／', '％']) {
        expect(validRecoveryPhrase('$_phrase $mark abandon abandon abandon'), isNull, reason: mark);
        expect(validRecoveryPhrase('$_phrase$mark'), isNull, reason: mark);
      }
    });

    test('empty and whitespace-only input is refused', () {
      expect(validRecoveryPhrase(''), isNull);
      expect(validRecoveryPhrase(' \n$_ideographicSpace'), isNull);
    });
  });
}
