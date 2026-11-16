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
