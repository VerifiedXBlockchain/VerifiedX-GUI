import 'dart:math';

import 'p2p_amount.dart';

/// The rules the P2P registry (Spyglass `/api/p2p/`, `p2p/rules.py`) and Core
/// apply to messages a wallet signs for the shop. Pure: no network.

const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

/// [length] letters from the platform's secure random source.
String p2pRandomLetters(int length, [Random? random]) {
  final source = random ?? Random.secure();
  return String.fromCharCodes(
    Iterable.generate(length, (_) => _letters.codeUnitAt(source.nextInt(_letters.length))),
  );
}

/// A sign-in message: 16 letters, a dot and the Unix time in seconds
/// (Spyglass `api/auth/serializers.py` TIMED_MESSAGE). Spyglass accepts each
/// once, within 10 minutes of its time.
String p2pSignInMessage(int nowSeconds, [String Function(int length)? letters]) {
  return "${(letters ?? p2pRandomLetters)(16)}.$nowSeconds";
}

/// What a bidder signs, as Core rebuilds it at `Sale_Start()`
/// (`Models/DST/Bid.cs` VerifyBidSignature):
/// `{purchase key}_{amount × 1e8 as an integer}_{address}`.
String p2pBidMessage(String purchaseKey, P2pAmount amount, String address) {
  if (purchaseKey.isEmpty || purchaseKey.contains('_')) {
    throw ArgumentError.value(purchaseKey, 'purchaseKey', 'Must be non-empty and contain no "_"');
  }
  if (!amount.isPositive) {
    throw ArgumentError.value(amount, 'amount', 'A bid must be above zero');
  }
  if (address.isEmpty) {
    throw ArgumentError.value(address, 'address', 'Must be an address');
  }
  return "${purchaseKey}_${amount.units}_$address";
}

/// A vault (reserve) address: the registry and Core refuse bids, shops and
/// sales from one.
bool isP2pReserveAddress(String address) => address.startsWith('xRBX');

/// A VFX message signature as Core's `CreateSignature` returns one:
/// `base64(DER) + "." + base58(public key)`. A shape check only; Spyglass
/// verifies the signature itself.
final RegExp _signature = RegExp(r'^ME[A-Za-z0-9+/]{82,106}={0,2}\.[1-9A-HJ-NP-Za-km-z]{80,90}$');

bool isP2pSignatureFormat(String signature) => _signature.hasMatch(signature);

// Core's shop registry (Models/DecShop.cs and the DSTR branch of
// TransactionValidatorService), as the registry's dry runs check it.

/// Where every shop registration (DSTR) is sent.
const String p2pDecShopBase = 'DecShop_Base';

/// `DecShopCreate()` moves this much, `DecShopDelete()` and a
/// `DecShopUpdate()` within [p2pShopFreeUpdateAfter] of the last change this
/// much; a later update moves nothing.
const String p2pShopCreateCost = '10';
const String p2pShopUpdateCost = '1';
const String p2pShopDeleteCost = '1';
const Duration p2pShopFreeUpdateAfter = Duration(hours: 12);

/// Every shop in the registry is third-party hosted.
const int p2pShopHostingType = 2;

const int p2pShopNameMax = 64;
const int p2pShopDescriptionMaxChars = 1200;
const int p2pShopDescriptionMaxWords = 200;

final RegExp _shopUrl = RegExp(r'^[a-z][a-z0-9.-]{0,62}$');

/// A shop URL as Core and the registry compare it: lower case, trimmed,
/// `vfx://` and `rbx://` removed.
String normalizeP2pShopUrl(String input) {
  return input.trim().toLowerCase().replaceAll('rbx://', '').replaceAll('vfx://', '');
}

/// Whether Core's `DecShop.CheckURL` accepts the URL once normalised: a
/// letter, then up to 62 letters, digits, "-" or ".".
bool isValidP2pShopUrl(String input) => _shopUrl.hasMatch(normalizeP2pShopUrl(input));

/// Words as Core counts them: runs of characters between white space.
int countP2pWords(String text) => text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

enum P2pShopFieldError { required, tooLong, tooManyWords, invalid }

/// Core's limits on a shop's name, URL and description, by field (`name`,
/// `url`, `description`); empty when all pass. Lengths are UTF-16 code
/// units, which is how both C# and Dart count a string.
Map<String, P2pShopFieldError> checkP2pShopFields({required String name, required String url, required String description}) {
  final errors = <String, P2pShopFieldError>{};
  if (name.trim().isEmpty) {
    errors['name'] = P2pShopFieldError.required;
  } else if (name.length > p2pShopNameMax) {
    errors['name'] = P2pShopFieldError.tooLong;
  }
  if (normalizeP2pShopUrl(url).isEmpty) {
    errors['url'] = P2pShopFieldError.required;
  } else if (!isValidP2pShopUrl(url)) {
    errors['url'] = P2pShopFieldError.invalid;
  }
  if (description.length > p2pShopDescriptionMaxChars) {
    errors['description'] = P2pShopFieldError.tooLong;
  } else if (countP2pWords(description) > p2pShopDescriptionMaxWords) {
    errors['description'] = P2pShopFieldError.tooManyWords;
  }
  return errors;
}

/// A shop's `UniqueId` as Core's `DecShop.Build()` makes one: as many random
/// letters as the Unix time has digits, then the time.
String newP2pShopUniqueId(int nowSeconds, [String Function(int length)? letters]) {
  final time = nowSeconds.toString();
  return "${(letters ?? p2pRandomLetters)(time.length)}$time";
}

final RegExp _email = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");

/// Whether [text] has the shape of an email address. Spyglass decides in the
/// end; this keeps a slip of the keyboard from being sent.
bool isP2pEmail(String text) => text.length <= 254 && _email.hasMatch(text);
