import 'p2p_bid_summary.dart';
import 'p2p_listing.dart';
import 'p2p_shop.dart';

/// The winning bid as its seller needs it for `Sale_Start()`. Only the
/// seller's own `GET /p2p/me/` carries [signature]; it is never logged.
class P2pWinningBid {
  final String amount;
  final String address;
  final String signature;

  const P2pWinningBid({
    required this.amount,
    required this.address,
    required this.signature,
  });

  factory P2pWinningBid.fromJson(Map<String, dynamic> json) {
    return P2pWinningBid(
      amount: json['amount'] as String,
      address: json['address'] as String,
      signature: json['signature'] as String,
    );
  }

  @override
  String toString() => "P2pWinningBid(amount: $amount, address: $address)";
}

/// One of the signed-in address's own listings: the listing's fields with
/// [action] and [winningBid] beside them in the same JSON object.
class P2pSellingListing {
  static const String actionStartSale = 'start_sale';

  final P2pListing listing;

  /// `start_sale` while the listing awaits its `Sale_Start()`, else null.
  final String? action;

  /// From the win on (`awaiting_sale_start`, `sale_pending`, `sold`).
  final P2pWinningBid? winningBid;

  const P2pSellingListing({
    required this.listing,
    this.action,
    this.winningBid,
  });

  factory P2pSellingListing.fromJson(Map<String, dynamic> json) {
    final winning = json['winning_bid'];
    return P2pSellingListing(
      listing: P2pListing.fromJson(json),
      action: json['action'] as String?,
      winningBid: winning is Map<String, dynamic> ? P2pWinningBid.fromJson(winning) : null,
    );
  }

  bool get canStartSale => action == actionStartSale;
}

/// A listing the signed-in address has bid on.
class P2pBuyingEntry {
  static const String actionCompletePurchase = 'complete_purchase';

  final P2pListing listing;

  /// This address's highest bid on it.
  final P2pBidSummary? myHighBid;

  /// `complete_purchase` once the sale is started for this buyer, else null.
  final String? action;

  const P2pBuyingEntry({
    required this.listing,
    this.myHighBid,
    this.action,
  });

  factory P2pBuyingEntry.fromJson(Map<String, dynamic> json) {
    final mine = json['my_high_bid'];
    return P2pBuyingEntry(
      listing: P2pListing.fromJson(json['listing'] as Map<String, dynamic>),
      myHighBid: mine is Map<String, dynamic> ? P2pBidSummary.fromJson(mine) : null,
      action: json['action'] as String?,
    );
  }

  bool get canCompletePurchase => action == actionCompletePurchase;
}

/// `GET /p2p/me/`: the token's address's shop, what it sells and what it has
/// bid on. At most 100 of each: active, closed in the last 7 days, or just due.
class P2pMe {
  final P2pShop? shop;
  final List<P2pSellingListing> selling;
  final List<P2pBuyingEntry> buying;

  const P2pMe({
    this.shop,
    this.selling = const [],
    this.buying = const [],
  });

  factory P2pMe.fromJson(Map<String, dynamic> json) {
    final shop = json['shop'];
    final selling = json['selling'];
    final buying = json['buying'];
    return P2pMe(
      shop: shop is Map<String, dynamic> ? P2pShop.fromJson(shop) : null,
      selling: selling is List ? selling.whereType<Map<String, dynamic>>().map(P2pSellingListing.fromJson).toList() : const [],
      buying: buying is List ? buying.whereType<Map<String, dynamic>>().map(P2pBuyingEntry.fromJson).toList() : const [],
    );
  }
}
