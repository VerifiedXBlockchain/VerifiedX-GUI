import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_rules.dart';

void main() {
  group('p2pBidMessage', () {
    test('is {purchase key}_{amount × 1e8}_{address}, as Core rebuilds it', () {
      expect(
        p2pBidMessage('QLHYeWQCuH1794842796', P2pAmount.parse('5'), 'xBidder'),
        'QLHYeWQCuH1794842796_500000000_xBidder',
      );
      expect(p2pBidMessage('Key1', P2pAmount.parse('0.29'), 'xB'), 'Key1_29000000_xB');
      expect(p2pBidMessage('Key1', P2pAmount.parse('12.34567891'), 'xB'), 'Key1_1234567891_xB');
    });

    test('refuses a key with the separator in it, an empty key or address, and zero', () {
      final five = P2pAmount.parse('5');
      expect(() => p2pBidMessage('a_b', five, 'xB'), throwsArgumentError);
      expect(() => p2pBidMessage('', five, 'xB'), throwsArgumentError);
      expect(() => p2pBidMessage('Key1', five, ''), throwsArgumentError);
      expect(() => p2pBidMessage('Key1', P2pAmount.fromUnits(BigInt.zero), 'xB'), throwsArgumentError);
    });
  });

  group('p2pSignInMessage', () {
    test('is 16 letters, a dot and the Unix time: the shape Spyglass accepts', () {
      final message = p2pSignInMessage(1794846000);
      expect(RegExp(r'^[A-Za-z]{16}\.1794846000$').hasMatch(message), isTrue, reason: message);
    });

    test('is new each time', () {
      expect(p2pSignInMessage(1794846000), isNot(p2pSignInMessage(1794846000)));
    });

    test('takes its letters from the source it is given', () {
      expect(p2pSignInMessage(1794846000, (length) => 'a' * length), 'aaaaaaaaaaaaaaaa.1794846000');
    });

  });

  test('p2pRandomLetters gives letters only, of the length asked', () {
    final letters = p2pRandomLetters(200, Random(7));
    expect(letters, hasLength(200));
    expect(RegExp(r'^[A-Za-z]+$').hasMatch(letters), isTrue);
  });

  test('a vault address is told by its prefix', () {
    expect(isP2pReserveAddress('xRBXabc'), isTrue);
    expect(isP2pReserveAddress('xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ'), isFalse);
  });

  test('a signature is recognised by its shape', () {
    final der = 'ME${'A' * 90}==';
    final key = '2' * 88;
    expect(isP2pSignatureFormat('$der.$key'), isTrue);
    expect(isP2pSignatureFormat('ERROR - Account not associated with wallet.'), isFalse);
    expect(isP2pSignatureFormat(der), isFalse);
  });
}
