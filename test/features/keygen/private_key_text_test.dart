import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/keygen/utils/private_key_text.dart';

// Keys chosen for each text-form case the node's export has produced.
const _highKey = 'a3f1c2d4e5b60718293a4b5c6d7e8f9011223344556677889900aabbccddeeff';
const _lowKey = '5b1e2d3c4f5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff0';
const _oneZeroNibbleKey = '0b1e2d3c4f5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff0';
const _twoZeroNibbleKey = '00c1e2d3c4f5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff';

/// The wallet's derivation before this change, kept verbatim so the tests
/// prove existing users' accounts are still produced.
String _legacyReserveSeed(String keyText, int attempt) {
  var input = keyText;
  if (input.startsWith("00")) {
    input = input.substring(2);
  }
  return "${input.substring(0, 32)}$attempt";
}

String _legacyPrivateCorrected(String keyText) => keyText.startsWith("00") ? keyText : "00$keyText";

String _legacyBtcEmail(String keyText) {
  var privateKey = _legacyPrivateCorrected(keyText);
  if (privateKey.startsWith("00")) {
    privateKey = privateKey.replaceFirst("00", "");
  }
  return "${privateKey.substring(0, 8)}@${privateKey.substring(privateKey.length - 8)}.com";
}

String _legacyBtcPassword(String keyText) {
  var privateKey = _legacyPrivateCorrected(keyText);
  if (privateKey.startsWith("00")) {
    privateKey = privateKey.replaceFirst("00", "");
  }
  return "${privateKey.substring(0, 12)}${privateKey.substring(privateKey.length - 12)}";
}

void main() {
  group('canonicalPrivateKeyHex', () {
    test('keeps a 64-digit key', () {
      expect(canonicalPrivateKeyHex(_highKey), _highKey);
      expect(canonicalPrivateKeyHex(_lowKey), _lowKey);
    });

    test('drops the leading 0 of the 65-character form older nodes exported', () {
      expect(canonicalPrivateKeyHex('0$_highKey'), _highKey);
    });

    test('pads the unpadded form older nodes exported', () {
      expect(canonicalPrivateKeyHex(_oneZeroNibbleKey.substring(1)), _oneZeroNibbleKey);
      expect(canonicalPrivateKeyHex(_twoZeroNibbleKey.substring(2)), _twoZeroNibbleKey);
    });

    test('reads the web wallet display form with its "00" prefix', () {
      expect(canonicalPrivateKeyHex('00$_highKey'), _highKey);
    });

    test('accepts 0x, upper case and surrounding or inner whitespace', () {
      expect(canonicalPrivateKeyHex('0x$_highKey'), _highKey);
      expect(canonicalPrivateKeyHex(_highKey.toUpperCase()), _highKey);
      expect(canonicalPrivateKeyHex('  ${_highKey.substring(0, 20)} ${_highKey.substring(20)}\n'), _highKey);
    });

    test('refuses text that is not a valid secp256k1 key', () {
      expect(canonicalPrivateKeyHex(''), isNull);
      expect(canonicalPrivateKeyHex('0x'), isNull);
      expect(canonicalPrivateKeyHex('xyz'), isNull);
      expect(canonicalPrivateKeyHex('0' * 64), isNull);
      expect(canonicalPrivateKeyHex(secp256k1Order.toRadixString(16)), isNull);
      expect(canonicalPrivateKeyHex('f' * 64), isNull);
      expect(canonicalPrivateKeyHex('1${'0' * 64}'), isNull);
    });

    test('accepts the largest valid key', () {
      final largest = (secp256k1Order - BigInt.one).toRadixString(16);
      expect(canonicalPrivateKeyHex(largest), largest);
    });
  });

  group('derivationTextCandidates', () {
    test('a key with top digit 0 to 7 and no leading zero has one form', () {
      expect(derivationTextCandidates(_lowKey), [_lowKey]);
    });

    test('a key with top digit 8 to f adds the 65-character form', () {
      expect(derivationTextCandidates(_highKey), [_highKey, '0$_highKey']);
    });

    test('a key with one leading zero nibble adds the unpadded form', () {
      expect(derivationTextCandidates(_oneZeroNibbleKey), [_oneZeroNibbleKey, _oneZeroNibbleKey.substring(1)]);
    });

    test('a key with two leading zero nibbles derives once, as before', () {
      expect(derivationTextCandidates(_twoZeroNibbleKey), [_twoZeroNibbleKey.substring(2)]);
    });

    test('adds the text exactly as pasted when it differs', () {
      expect(
        derivationTextCandidates(_lowKey, enteredText: _lowKey.toUpperCase()),
        [_lowKey, _lowKey.toUpperCase()],
      );
      expect(
        derivationTextCandidates(_highKey, enteredText: ' $_highKey\n'),
        [_highKey, '0$_highKey'],
      );
    });

    test('ignores pasted text for another key or with a 0x prefix', () {
      expect(derivationTextCandidates(_lowKey, enteredText: _highKey), [_lowKey]);
      expect(derivationTextCandidates(_lowKey, enteredText: '0x$_lowKey'), [_lowKey]);
    });

    test('every text form an existing user imported is still derived', () {
      final cases = {
        _highKey: ['0$_highKey', _highKey, '00$_highKey', '000$_highKey'],
        _oneZeroNibbleKey: [_oneZeroNibbleKey.substring(1), _oneZeroNibbleKey, '00$_oneZeroNibbleKey'],
        _twoZeroNibbleKey: [_twoZeroNibbleKey.substring(2), _twoZeroNibbleKey, '00$_twoZeroNibbleKey'],
        _lowKey: [_lowKey, '00$_lowKey', _lowKey.toUpperCase()],
      };
      cases.forEach((key, pastedForms) {
        for (final pasted in pastedForms) {
          final canonical = canonicalPrivateKeyHex(pasted)!;
          expect(canonical, key);
          final candidates = derivationTextCandidates(canonical, enteredText: pasted);
          final legacyText = derivationTextFromKeyText(pasted);
          expect(candidates, contains(legacyText), reason: 'pasted form $pasted');
        }
      });
    });

    test('re-importing the new 64-digit export finds the pair from the old 65-character export', () {
      final oldImport = derivationTextFromKeyText('0$_highKey');
      expect(derivationTextCandidates(canonicalPrivateKeyHex(_highKey)!), contains(oldImport));
    });

    test('re-importing the new 64-digit export finds the pair from the old unpadded export', () {
      final oldImport = derivationTextFromKeyText(_oneZeroNibbleKey.substring(1));
      expect(derivationTextCandidates(canonicalPrivateKeyHex(_oneZeroNibbleKey)!), contains(oldImport));
    });
  });

  group('derivation from a key text matches the previous wallet code', () {
    const forms = [_highKey, '0$_highKey', '00$_highKey', _lowKey, _oneZeroNibbleKey, _twoZeroNibbleKey];

    test('Vault seed', () {
      for (final text in forms) {
        for (final attempt in [0, 1, 12]) {
          expect(reserveSeedFromDerivationText(derivationTextFromKeyText(text), attempt), _legacyReserveSeed(text, attempt));
        }
      }
    });

    test('Bitcoin email and password', () {
      for (final text in forms) {
        final derivationText = derivationTextFromKeyText(_legacyPrivateCorrected(text));
        expect(btcEmailFromDerivationText(derivationText), _legacyBtcEmail(text));
        expect(btcPasswordFromDerivationText(derivationText), _legacyBtcPassword(text));
      }
    });

    test('the Vault and Bitcoin accounts come from the same text', () {
      for (final text in forms) {
        expect(derivationTextFromKeyText(_legacyPrivateCorrected(text)), derivationTextFromKeyText(text));
      }
    });
  });

  group('combineAccountHistory', () {
    test('activity on either account counts', () {
      expect(combineAccountHistory(vaultHasHistory: true, btcHasHistory: false), DerivedAccountsHistory.found);
      expect(combineAccountHistory(vaultHasHistory: null, btcHasHistory: true), DerivedAccountsHistory.found);
    });

    test('a failed lookup without activity elsewhere is unknown', () {
      expect(combineAccountHistory(vaultHasHistory: null, btcHasHistory: false), DerivedAccountsHistory.unknown);
      expect(combineAccountHistory(vaultHasHistory: false, btcHasHistory: null), DerivedAccountsHistory.unknown);
    });

    test('no activity on both is none', () {
      expect(combineAccountHistory(vaultHasHistory: false, btcHasHistory: false), DerivedAccountsHistory.none);
    });
  });

  group('autoSelectDerivedAccounts', () {
    const found = DerivedAccountsHistory.found;
    const none = DerivedAccountsHistory.none;
    const unknown = DerivedAccountsHistory.unknown;

    test('a single form is used directly', () {
      expect(autoSelectDerivedAccounts([none]), 0);
      expect(autoSelectDerivedAccounts([unknown]), 0);
    });

    test('with no activity anywhere the canonical pair is used', () {
      expect(autoSelectDerivedAccounts([none, none]), 0);
    });

    test('the only pair with activity is used', () {
      expect(autoSelectDerivedAccounts([none, found]), 1);
      expect(autoSelectDerivedAccounts([found, none]), 0);
    });

    test('several pairs with activity, or a failed lookup, ask the user', () {
      expect(autoSelectDerivedAccounts([found, found]), isNull);
      expect(autoSelectDerivedAccounts([none, unknown]), isNull);
      expect(autoSelectDerivedAccounts([found, unknown]), isNull);
    });
  });
}
