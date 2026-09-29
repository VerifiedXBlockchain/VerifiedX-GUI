import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/btc_address_validator.dart';

/// Vectors come from BIP173 and BIP350 (SegWit) and from the genesis block's
/// hash160 62e907b15cbf27d5425399ebf6f0fb50ebb88f18 encoded with each
/// network's Base58Check version byte.
void main() {
  group('Base58Check addresses', () {
    test('mainnet P2PKH and P2SH', () {
      expect(btcAddressType('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa', testnet: false), BtcAddressType.p2pkh);
      expect(btcAddressType('1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2', testnet: false), BtcAddressType.p2pkh);
      expect(btcAddressType('3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy', testnet: false), BtcAddressType.p2sh);
      expect(btcAddressType('3Ai1JZ8pdJb2ksieUV8FsxSNVJCpoPi8W6', testnet: false), BtcAddressType.p2sh);
    });

    test('testnet P2PKH (m/n) and P2SH (2)', () {
      expect(btcAddressType('mpXwg4jMtRhuSpVq4xS3HFHmCmWp9NyGKt', testnet: true), BtcAddressType.p2pkh);
      expect(btcAddressType('2N2GDNJ4rEm6NxfMC9ck8VuRdheQzXWaNZv', testnet: true), BtcAddressType.p2sh);
    });

    test('rejects a wrong checksum', () {
      expect(isValidBtcAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNb', testnet: false), isFalse);
      expect(isValidBtcAddress('3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLz', testnet: false), isFalse);
      expect(isValidBtcAddress('mpXwg4jMtRhuSpVq4xS3HFHmCmWp9NyGKu', testnet: true), isFalse);
    });

    test('rejects the other network', () {
      expect(isValidBtcAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa', testnet: true), isFalse);
      expect(isValidBtcAddress('3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy', testnet: true), isFalse);
      expect(isValidBtcAddress('mpXwg4jMtRhuSpVq4xS3HFHmCmWp9NyGKt', testnet: false), isFalse);
      expect(isValidBtcAddress('2N2GDNJ4rEm6NxfMC9ck8VuRdheQzXWaNZv', testnet: false), isFalse);
    });

    test('rejects an unknown version byte with a valid checksum', () {
      // Same hash160 under the VFX version byte (0x3c).
      expect(isValidBtcAddress('RJJBTXXfgE5DjiPQpZSnYrQe73NhrBZ3ao', testnet: false), isFalse);
      expect(isValidBtcAddress('RJJBTXXfgE5DjiPQpZSnYrQe73NhrBZ3ao', testnet: true), isFalse);
    });

    test('rejects non-base58 characters and truncation', () {
      expect(isValidBtcAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf0a', testnet: false), isFalse);
      expect(isValidBtcAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf', testnet: false), isFalse);
    });
  });

  group('bech32 SegWit v0 (BIP173)', () {
    test('mainnet P2WPKH, in either case', () {
      expect(btcAddressType('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4', testnet: false), BtcAddressType.p2wpkh);
      expect(btcAddressType('BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4', testnet: false), BtcAddressType.p2wpkh);
    });

    test('testnet P2WSH', () {
      expect(
        btcAddressType('tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7', testnet: true),
        BtcAddressType.p2wsh,
      );
      expect(
        btcAddressType('tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy', testnet: true),
        BtcAddressType.p2wsh,
      );
    });

    test('rejects a wrong checksum', () {
      expect(isValidBtcAddress('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5', testnet: false), isFalse);
    });

    test('rejects the bech32m checksum on witness v0 (BIP350)', () {
      expect(isValidBtcAddress('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kemeawh', testnet: false), isFalse);
      expect(isValidBtcAddress('tb1q0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq24jc47', testnet: true), isFalse);
    });

    test('rejects a v0 program that is neither 20 nor 32 bytes', () {
      expect(isValidBtcAddress('BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P', testnet: false), isFalse);
    });
  });

  group('bech32m SegWit v1+ (BIP350)', () {
    test('mainnet and testnet Taproot', () {
      expect(
        btcAddressType('bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0', testnet: false),
        BtcAddressType.p2tr,
      );
      expect(
        btcAddressType('tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c', testnet: true),
        BtcAddressType.p2tr,
      );
    });

    test('future witness versions are valid but untyped', () {
      expect(btcAddressType('BC1SW50QGDZ25J', testnet: false), BtcAddressType.witnessUnknown);
      expect(btcAddressType('bc1zw508d6qejxtdg4y5r3zarvaryvaxxpcs', testnet: false), BtcAddressType.witnessUnknown);
      expect(
        btcAddressType('bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y', testnet: false),
        BtcAddressType.witnessUnknown,
      );
    });

    test('rejects the bech32 checksum on witness v1+', () {
      expect(isValidBtcAddress('bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqh2y7hd', testnet: false), isFalse);
      expect(isValidBtcAddress('tb1z0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqglt7rf', testnet: true), isFalse);
      expect(isValidBtcAddress('BC1S0XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ54WELL', testnet: false), isFalse);
    });

    test('rejects the invalid vectors from BIP350', () {
      const invalid = [
        // Unknown HRP.
        'tc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq5zuyut',
        // Invalid character 'o'.
        'bc1p38j9r5y49hruaue7wxjce0updqjuyyx0kh56v8s25huc6995vvpql3jow4',
        // Witness version 17.
        'BC130XLXVLHEMJA6C4DQV22UAPCTQUPFHLXM9H8Z3K2E72Q4K9HCZ7VQ7ZWS8R',
        // Program of 1 byte.
        'bc1pw5dgrnzv',
        // Program of 41 bytes.
        'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v8n0nx0muaewav253zgeav',
        // Zero padding of more than 4 bits.
        'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7v07qwwzcrf',
        // Empty data section.
        'bc1gmk9yu',
      ];
      for (final address in invalid) {
        expect(isValidBtcAddress(address, testnet: false), isFalse, reason: address);
        expect(isValidBtcAddress(address, testnet: true), isFalse, reason: address);
      }
    });

    test('rejects the invalid testnet vectors from BIP350', () {
      const invalid = [
        // Mixed case.
        'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vq47Zagq',
        // Non-zero padding in 8-to-5 conversion.
        'tb1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vpggkg4j',
      ];
      for (final address in invalid) {
        expect(isValidBtcAddress(address, testnet: true), isFalse, reason: address);
      }
    });

    test('rejects the other network', () {
      expect(
        isValidBtcAddress('bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0', testnet: true),
        isFalse,
      );
      expect(
        isValidBtcAddress('tb1pqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesf3hn0c', testnet: false),
        isFalse,
      );
    });
  });

  group('btcAddressIssue', () {
    test('is null for a valid address on the current network', () {
      expect(btcAddressIssue('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4', testnet: false), isNull);
      expect(btcAddressIssue('  mpXwg4jMtRhuSpVq4xS3HFHmCmWp9NyGKt  ', testnet: true), isNull);
    });

    test('reports an address from the other network', () {
      expect(btcAddressIssue('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa', testnet: true), BtcAddressIssue.wrongNetwork);
      expect(
        btcAddressIssue('tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7', testnet: false),
        BtcAddressIssue.wrongNetwork,
      );
    });

    test('reports garbage and VFX addresses as invalid', () {
      expect(btcAddressIssue('', testnet: false), BtcAddressIssue.invalid);
      expect(btcAddressIssue('not an address', testnet: false), BtcAddressIssue.invalid);
      expect(btcAddressIssue('RJJBTXXfgE5DjiPQpZSnYrQe73NhrBZ3ao', testnet: true), BtcAddressIssue.invalid);
      expect(btcAddressIssue('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5', testnet: false), BtcAddressIssue.invalid);
    });
  });
}
