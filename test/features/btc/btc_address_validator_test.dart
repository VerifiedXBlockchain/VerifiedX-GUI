import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/utils.dart';

/// The app defaults to mainnet in tests — `Env.btcIsTestNet` is driven by a
/// compile-time define that is absent here — so these cover the mainnet rules
/// the validator applies to a vBTC withdrawal destination.
void main() {
  group('formValidatorBtcAddress', () {
    test('accepts a P2PKH address', () {
      expect(
        formValidatorBtcAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'),
        isNull,
      );
    });

    test('accepts a P2SH address', () {
      expect(
        formValidatorBtcAddress('3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy'),
        isNull,
      );
    });

    test('accepts a bech32 SegWit v0 address', () {
      expect(
        formValidatorBtcAddress('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'),
        isNull,
      );
    });

    test('accepts a bech32m Taproot address', () {
      expect(
        formValidatorBtcAddress(
            'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0'),
        isNull,
      );
    });

    test('tolerates surrounding whitespace', () {
      expect(
        formValidatorBtcAddress(
            '  bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4  '),
        isNull,
      );
    });

    test('rejects an empty or missing address', () {
      expect(formValidatorBtcAddress(null), isNotNull);
      expect(formValidatorBtcAddress(''), isNotNull);
      expect(formValidatorBtcAddress('   '), isNotNull);
    });

    test('rejects a single mistyped character', () {
      // The checksum is the whole point: a withdrawal request is committed on
      // chain before any Bitcoin moves, so a typo can only be undone by a 75%
      // validator vote.
      expect(
        formValidatorBtcAddress('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5'),
        isNotNull,
      );
      expect(
        formValidatorBtcAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNb'),
        isNotNull,
      );
    });

    test('rejects a testnet address while pointed at mainnet', () {
      expect(
        formValidatorBtcAddress('tb1qw508d6qejxtdg4y5r3zarvaryvaxxpcs'),
        isNotNull,
      );
    });

    test('rejects a VFX address', () {
      expect(
        formValidatorBtcAddress('RNiQrW3aBUWZhfadqKxPuN46iGaR13ox7P'),
        isNotNull,
      );
    });
  });
}
