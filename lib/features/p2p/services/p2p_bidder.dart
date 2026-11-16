import '../models/p2p_error.dart';
import '../models/p2p_listing.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_rules.dart';
import 'p2p_service.dart';
import 'p2p_session.dart';
import 'p2p_signer.dart';

/// Places a bid or a buy-now offer on a P2P listing (plan 4.3.3).
///
/// A bid is a message the bidder signs, `{purchase key}_{amount × 1e8}_
/// {address}`, posted to the registry with the address's sign-in token. It
/// is not a transaction: nothing here builds, signs or sends one, and no
/// VFX moves. Core checks the same signature again when the seller's
/// `Sale_Start()` names this bid.
class P2pBidder {
  final P2pService _service;
  final P2pSession _session;
  final P2pMessageSigner _signer;

  P2pBidder({
    required P2pService service,
    required P2pSession session,
    required P2pMessageSigner signer,
  })  : _service = service,
        _session = session,
        _signer = signer;

  /// Bids [amount] on listing [listingId] as [address], or with [isBuyNow]
  /// offers the buy-now price, which [amount] must be exactly.
  ///
  /// Reads the listing fresh, refuses locally what the registry would refuse
  /// (with the registry's own codes), has Core sign the bid message and posts
  /// it. [balance] is what [address] can spend, when known. Throws a
  /// [P2pError], a [P2pSigningError] or a [P2pSignInMismatch].
  Future<P2pBidResult> place({
    required int listingId,
    required String address,
    required P2pAmount amount,
    required bool isBuyNow,
    P2pAmount? balance,
  }) async {
    final listing = await _service.getListing(listingId);
    if (listing == null) {
      throw const P2pError(status: 404, code: 'not_found');
    }
    final refusal = checkP2pBid(listing, address: address, amount: amount, isBuyNow: isBuyNow, balance: balance);
    if (refusal != null) {
      throw P2pError(status: null, code: refusal);
    }

    final message = p2pBidMessage(listing.purchaseKey, amount, address);
    String? signature;
    return _session.withToken(address, (token) async {
      // Signed once: a second sign-in after a 401 posts the same signature.
      signature ??= await _signer.sign(message, address);
      return _service.placeBid(
        token: token,
        listingId: listingId,
        amount: amount.toDecimalString(),
        isBuyNow: isBuyNow,
        signature: signature!,
      );
    });
  }
}

/// The registry's code for why [address] cannot place this bid on [listing]
/// as it stands, or null when nothing known here stops it. The same checks
/// and codes as the registry's `place_bid`, so a refusal reads the same
/// whichever side makes it. The registry checks them all again, and its
/// dates and indexed balance decide.
String? checkP2pBid(
  P2pListing listing, {
  required String address,
  required P2pAmount amount,
  required bool isBuyNow,
  P2pAmount? balance,
}) {
  if (listing.state != P2pListingState.live) {
    return 'listing_not_live';
  }
  if (address == listing.sellerAddress) {
    return 'seller_cannot_bid';
  }
  if (isP2pReserveAddress(address)) {
    return 'reserve_address';
  }
  final buyNow = P2pAmount.tryParse(listing.buyNowPrice);
  if (isBuyNow) {
    if (buyNow == null) {
      return 'no_buy_now';
    }
    if (amount != buyNow) {
      return 'amount_mismatch';
    }
  } else {
    if (!listing.isAuction) {
      return 'not_an_auction';
    }
    final minimum = P2pAmount.tryParse(listing.nextMinBid) ?? P2pAmount.tryParse(listing.floorPrice);
    if (minimum != null && amount < minimum) {
      return 'bid_too_low';
    }
    if (buyNow != null && amount >= buyNow) {
      return 'use_buy_now';
    }
  }
  if (balance != null && balance < amount) {
    return 'insufficient_balance';
  }
  return null;
}
