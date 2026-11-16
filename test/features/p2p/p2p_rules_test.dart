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

  group('a shop\'s fields, by Core\'s limits', () {
    test('a URL is compared lower case, without vfx:// or rbx://', () {
      expect(normalizeP2pShopUrl('  vfx://CoolStuff '), 'coolstuff');
      expect(normalizeP2pShopUrl('rbx://Old-Shop'), 'old-shop');
      expect(normalizeP2pShopUrl('plain.shop'), 'plain.shop');
    });

    test('a URL starts with a letter and holds up to 63 letters, digits, dashes and dots', () {
      for (final url in ['a', 'my-shop', 'shop.one', 'vfx://MyShop', 'a${'b' * 62}']) {
        expect(isValidP2pShopUrl(url), isTrue, reason: url);
      }
      for (final url in ['', '1shop', '-shop', 'my shop', 'my_shop', 'shop!', 'a${'b' * 63}']) {
        expect(isValidP2pShopUrl(url), isFalse, reason: url);
      }
    });

    test('words are runs between white space', () {
      expect(countP2pWords(''), 0);
      expect(countP2pWords('  one   two\nthree\t four '), 4);
    });

    test('a name is required and at most 64 characters', () {
      Map<String, P2pShopFieldError> check(String name) => checkP2pShopFields(name: name, url: 'ok', description: '');
      expect(check('Shop'), isEmpty);
      expect(check('   ')['name'], P2pShopFieldError.required);
      expect(check('a' * 64), isEmpty);
      expect(check('a' * 65)['name'], P2pShopFieldError.tooLong);
    });

    test('a URL is required and must be one Core accepts', () {
      Map<String, P2pShopFieldError> check(String url) => checkP2pShopFields(name: 'Shop', url: url, description: '');
      expect(check('vfx://')['url'], P2pShopFieldError.required);
      expect(check('9lives')['url'], P2pShopFieldError.invalid);
      expect(check('vfx://NineLives'), isEmpty);
    });

    test('a description is at most 1200 characters and 200 words', () {
      Map<String, P2pShopFieldError> check(String description) => checkP2pShopFields(name: 'Shop', url: 'ok', description: description);
      expect(check(''), isEmpty);
      expect(check('a' * 1200), isEmpty);
      expect(check('a' * 1201)['description'], P2pShopFieldError.tooLong);
      expect(check(List.filled(200, 'w').join(' ')), isEmpty);
      expect(check(List.filled(201, 'w').join(' '))['description'], P2pShopFieldError.tooManyWords);
    });

    test('a UniqueId is as many letters as the time has digits, then the time, as Core builds one', () {
      final id = newP2pShopUniqueId(1794842795);
      expect(RegExp(r'^[A-Za-z]{10}1794842795$').hasMatch(id), isTrue, reason: id);
      expect(newP2pShopUniqueId(1794842795, (n) => 'q' * n), 'qqqqqqqqqq1794842795');
      expect(newP2pShopUniqueId(1794842795), isNot(newP2pShopUniqueId(1794842795)));
    });
  });
}
