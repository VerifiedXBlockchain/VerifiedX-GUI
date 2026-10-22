import 'package:base58check/base58check.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/utils/validation.dart';

/// A well-formed Base58Check address with [version] as its network byte.
String _address(int version) => Base58CheckCodec.bitcoin().encode(Base58CheckPayload(version, List<int>.generate(20, (i) => i * 7 + 3)));

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  group('isOtherNetworksVfxAddress', () {
    const mainnet = 0x3C;
    const testnet = 0x89;

    test("accepts this network's address", () {
      expect(_address(mainnet), startsWith('R'));
      expect(_address(testnet), startsWith('x'));
      expect(isOtherNetworksVfxAddress(_address(mainnet), versionByte: mainnet), isFalse);
      expect(isOtherNetworksVfxAddress(_address(testnet), versionByte: testnet), isFalse);
    });

    test("refuses the other network's address, either way", () {
      expect(isOtherNetworksVfxAddress(_address(testnet), versionByte: mainnet), isTrue);
      expect(isOtherNetworksVfxAddress(_address(mainnet), versionByte: testnet), isTrue);
    });

    test('refuses a Bitcoin-style version-0 address', () {
      expect(isOtherNetworksVfxAddress(_address(0x00), versionByte: mainnet), isTrue);
    });

    test('refuses a version byte that still encodes to the network letter', () {
      // 0x3D also encodes to an "R..." address, so the first letter alone
      // (isValidRbxAddress) lets it through.
      final lookalike = _address(0x3D);
      expect(lookalike, startsWith('R'));
      expect(isOtherNetworksVfxAddress(lookalike, versionByte: mainnet), isTrue);
    });

    test('leaves vault, shielded, names and undecodable input to the other rules', () {
      expect(isOtherNetworksVfxAddress('xRBXabcdefghijkmnopqrstuvwxyz12345', versionByte: mainnet), isFalse);
      expect(isOtherNetworksVfxAddress('zfx_abc', versionByte: mainnet), isFalse);
      expect(isOtherNetworksVfxAddress('alice.vfx', versionByte: mainnet), isFalse);
      expect(isOtherNetworksVfxAddress('', versionByte: mainnet), isFalse);
      // A broken checksum does not decode.
      final good = _address(testnet);
      final broken = good.substring(0, good.length - 1) + (good.endsWith('1') ? '2' : '1');
      expect(isOtherNetworksVfxAddress(broken, versionByte: mainnet), isFalse);
    });
  });

  group('formValidatorRbxAddress', () {
    test("refuses the other network's address with its own message", () {
      final other = _address(vfxAddressVersionByte == 0x3C ? 0x89 : 0x3C);
      final ours = _address(vfxAddressVersionByte);
      // A real address from the other network starts with that network's
      // letter, and still gets the network message rather than "invalid".
      expect(other[0], isNot(ours[0]));
      expect(formValidatorRbxAddress(other), contains('another network'));
      expect(formValidatorRbxAddress(ours), isNull);

      final lookalike = _address(vfxAddressVersionByte + 1);
      expect(lookalike[0], ours[0]);
      expect(formValidatorRbxAddress(lookalike), contains('another network'));
    });
  });

  group('formValidatorRbxAddress with names allowed', () {
    test('passes any name the send resolves, whatever its case', () {
      expect(formValidatorRbxAddress('legacy.rbx', true), isNull);
      expect(formValidatorRbxAddress('Alice.VFX', true), isNull);
      expect(formValidatorRbxAddress('alice.vfx', true), isNull);
    });

    test('still checks a plain address', () {
      expect(formValidatorRbxAddress(_address(vfxAddressVersionByte), true), isNull);
      expect(formValidatorRbxAddress('notanaddress', true), contains('Invalid'));
      expect(formValidatorRbxAddress(_address(vfxAddressVersionByte + 1), true), contains('another network'));
    });

    test('a name is not an address where names are not allowed', () {
      expect(formValidatorRbxAddress('Alice.VFX'), isNotNull);
    });
  });

  group('formValidatorVbtcRecipient', () {
    test("refuses the other network's address, as it refuses a vault", () {
      expect(formValidatorVbtcRecipient(_address(vfxAddressVersionByte)), isNull);
      expect(formValidatorVbtcRecipient(_address(vfxAddressVersionByte + 1)), contains('another network'));
      expect(formValidatorVbtcRecipient(_address(vfxAddressVersionByte == 0x3C ? 0x89 : 0x3C)), contains('another network'));
    });
  });

  group('looksLikeVfxName', () {
    test('a name is resolved before sending, whatever its case', () {
      expect(looksLikeVfxName('alice.vfx'), isTrue);
      expect(looksLikeVfxName(' Alice.VFX '), isTrue);
      expect(looksLikeVfxName('legacy.rbx'), isTrue);
    });

    test('an address is not a name', () {
      expect(looksLikeVfxName(_address(0x3C)), isFalse);
      expect(looksLikeVfxName('xRBXabcdefghijkmnopqrstuvwxyz12345'), isFalse);
    });
  });
}
