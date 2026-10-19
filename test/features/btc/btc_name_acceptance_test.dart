import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/utils/btc_name_acceptance.dart';

void main() {
  const owner = 'xRDKbcK4P4DCiaRqvM9Wiy1nZg8wX6ecKx';
  const signature = '3045022100ab.02cdef';

  group('boundMessage', () {
    test('names the owner and the lowercased domain with .btc once', () {
      expect(BtcNameAcceptance.boundMessage(1760000000, owner, 'Satoshi'), '1760000000:$owner:satoshi.btc');
      expect(BtcNameAcceptance.boundMessage(1760000000, owner, 'satoshi.BTC'), '1760000000:$owner:satoshi.btc');
      expect(BtcNameAcceptance.boundMessage(1760000000, ' $owner ', ' satoshi '), '1760000000:$owner:satoshi.btc');
    });
  });

  group('build and parse', () {
    test('a built code parses back to its message and signature', () {
      final message = BtcNameAcceptance.boundMessage(1760000000, owner, 'satoshi');
      final code = BtcNameAcceptance.build(message, signature);
      expect(code, '$message|$signature');

      final parsed = BtcNameAcceptance.parse(code)!;
      expect(parsed.message, message);
      expect(parsed.signature, signature);
      expect(parsed.timestamp, 1760000000);
      expect(parsed.owner, owner);
      expect(parsed.name, 'satoshi.btc');
    });

    test('surrounding whitespace from copy and paste is ignored', () {
      final parsed = BtcNameAcceptance.parse('  1760000000:$owner:satoshi.btc|$signature \n');
      expect(parsed, isNotNull);
      expect(parsed!.signature, signature);
    });

    test('malformed codes are refused', () {
      expect(BtcNameAcceptance.parse(null), isNull);
      expect(BtcNameAcceptance.parse(''), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:satoshi.btc'), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:satoshi.btc|'), isNull);
      expect(BtcNameAcceptance.parse('|$signature'), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:satoshi.btc|nodot'), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:satoshi.btc|$signature|extra'), isNull);
      expect(BtcNameAcceptance.parse('1760000000|$signature'), isNull);
      expect(BtcNameAcceptance.parse('soon:$owner:satoshi.btc|$signature'), isNull);
      expect(BtcNameAcceptance.parse('1760000000::satoshi.btc|$signature'), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:|$signature'), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:satoshi.btc:x|$signature'), isNull);
    });
  });

  group('parse requires the full name', () {
    test('a code signed for the bare name is refused, as Core refuses it', () {
      // BtcNameSignatures.Check compares the signed name with "satoshi.btc".
      expect(BtcNameAcceptance.parse('1760000000:$owner:satoshi|$signature'), isNull);
      expect(BtcNameAcceptance.parse('1760000000:$owner:.btc|$signature'), isNull);
    });

    test('the suffix may be in any case, since Core ignores case', () {
      expect(BtcNameAcceptance.parse('1760000000:$owner:Satoshi.BTC|$signature'), isNotNull);
    });
  });

  group('matches', () {
    final acceptance = BtcNameAcceptance.parse('1760000000:$owner:satoshi.btc|$signature')!;

    test('the domain matches regardless of case or suffix', () {
      expect(acceptance.matches(owner: owner, name: 'satoshi.btc'), isTrue);
      expect(acceptance.matches(owner: owner, name: 'Satoshi'), isTrue);
      expect(acceptance.matches(owner: ' $owner ', name: 'SATOSHI.BTC'), isTrue);
    });

    test('another domain or owner does not match', () {
      expect(acceptance.matches(owner: owner, name: 'nakamoto'), isFalse);
      expect(acceptance.matches(owner: 'xOtherOwnerAddress', name: 'satoshi'), isFalse);
      expect(acceptance.matches(owner: owner.toLowerCase(), name: 'satoshi'), isFalse);
    });
  });
}
