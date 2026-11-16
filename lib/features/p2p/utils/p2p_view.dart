import '../models/p2p_listing.dart';
import '../models/p2p_me.dart';
import '../models/p2p_owned_nft.dart';
import '../models/p2p_shop.dart';
import 'p2p_amount.dart';
import 'p2p_rules.dart';

/// What the shop screens decide before they draw, kept pure so it is tested
/// apart from them. The server owns a listing's state; nothing here works a
/// state out from dates or bids. The clock only says how long the dates the
/// server gave are away.

/// "xJwSHB…NJksJ": an address short enough for a card or a row.
String shortP2pAddress(String address, [int head = 6, int tail = 5]) {
  if (address.length <= head + tail + 1) {
    return address;
  }
  return "${address.substring(0, head)}…${address.substring(address.length - tail)}";
}

/// The two largest units of a time left worth reading.
enum P2pCountdownUnit { daysHours, hoursMinutes, minutesSeconds, seconds }

class P2pCountdown {
  final P2pCountdownUnit unit;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const P2pCountdown(this.unit, this.days, this.hours, this.minutes, this.seconds);

  /// The time left, or null once it has run out.
  static P2pCountdown? of(Duration left) {
    if (left <= Duration.zero) {
      return null;
    }
    final total = (left.inMilliseconds / 1000).ceil();
    final days = total ~/ 86400;
    final hours = (total % 86400) ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    final unit = days > 0
        ? P2pCountdownUnit.daysHours
        : hours > 0
            ? P2pCountdownUnit.hoursMinutes
            : minutes > 0
                ? P2pCountdownUnit.minutesSeconds
                : P2pCountdownUnit.seconds;
    return P2pCountdown(unit, days, hours, minutes, seconds);
  }
}

/// Under this much time left a countdown is drawn as urgent.
const Duration p2pEndingSoon = Duration(hours: 1);

/// Where a listing's clock stands.
enum P2pClockKind {
  /// Live, before its start.
  upcoming,

  /// Live and inside its dates: taking bids.
  open,

  /// Live but past its end: the registry closes it on its next read.
  closing,

  /// A winner is chosen; the seller has until the deadline to start the sale.
  awaitingSeller,

  /// No clock to show.
  none,
}

class P2pListingClock {
  final P2pClockKind kind;

  /// What the clock counts down to; null for `closing` and `none`.
  final DateTime? until;

  const P2pListingClock(this.kind, [this.until]);

  factory P2pListingClock.of(P2pListing listing, DateTime now) {
    if (listing.state == P2pListingState.live) {
      final starts = listing.startsAt;
      final ends = listing.endsAt;
      if (starts != null && now.isBefore(starts)) {
        return P2pListingClock(P2pClockKind.upcoming, starts);
      }
      if (ends == null) {
        return const P2pListingClock(P2pClockKind.none);
      }
      if (now.isBefore(ends)) {
        return P2pListingClock(P2pClockKind.open, ends);
      }
      return const P2pListingClock(P2pClockKind.closing);
    }
    final deadline = listing.saleStartDeadline;
    if (listing.state == P2pListingState.awaitingSaleStart && deadline != null && now.isBefore(deadline)) {
      return P2pListingClock(P2pClockKind.awaitingSeller, deadline);
    }
    return const P2pListingClock(P2pClockKind.none);
  }
}

/// What the figure a listing leads with is.
enum P2pHeadlineKind { soldFor, winningBid, currentBid, startingBid, buyNow }

class P2pHeadline {
  final P2pHeadlineKind kind;

  /// A decimal string, as the API sent it.
  final String amount;

  const P2pHeadline(this.kind, this.amount);

  /// The figure [listing] leads with, or null when it has no price to show.
  static P2pHeadline? of(P2pListing listing) {
    final high = listing.highBid?.amount;
    if (listing.state == P2pListingState.sold) {
      final amount = listing.soldPrice ?? high ?? listing.buyNowPrice;
      return amount == null ? null : P2pHeadline(P2pHeadlineKind.soldFor, amount);
    }
    if (listing.winnerAddress != null && high != null) {
      return P2pHeadline(P2pHeadlineKind.winningBid, high);
    }
    if (high != null) {
      return P2pHeadline(P2pHeadlineKind.currentBid, high);
    }
    if (listing.floorPrice != null) {
      return P2pHeadline(P2pHeadlineKind.startingBid, listing.floorPrice!);
    }
    if (listing.buyNowPrice != null) {
      return P2pHeadline(P2pHeadlineKind.buyNow, listing.buyNowPrice!);
    }
    return null;
  }
}

/// Who is looking at a listing.
enum P2pViewerRole { seller, winner, visitor }

P2pViewerRole p2pViewerRole(P2pListing listing, String? address) {
  if (address != null && address == listing.sellerAddress) {
    return P2pViewerRole.seller;
  }
  if (address != null && address == listing.winnerAddress) {
    return P2pViewerRole.winner;
  }
  return P2pViewerRole.visitor;
}

/// Why the viewer cannot bid or buy right now.
enum P2pBuyBlock {
  /// The listing is not live.
  notLive,

  /// Live, but before its start.
  notOpenYet,

  /// Live, but past its end.
  closing,

  /// No VFX account is selected.
  noAccount,

  /// The selected account is a vault (xRBX) account.
  vault,

  /// The selected account is the seller.
  ownListing,
}

/// Null when [address] can bid on or buy [listing] at [now].
P2pBuyBlock? p2pBuyBlock(P2pListing listing, String? address, DateTime now) {
  if (listing.state != P2pListingState.live) {
    return P2pBuyBlock.notLive;
  }
  final clock = P2pListingClock.of(listing, now);
  if (clock.kind == P2pClockKind.upcoming) {
    return P2pBuyBlock.notOpenYet;
  }
  if (clock.kind != P2pClockKind.open) {
    return P2pBuyBlock.closing;
  }
  if (address == null) {
    return P2pBuyBlock.noAccount;
  }
  if (isP2pReserveAddress(address)) {
    return P2pBuyBlock.vault;
  }
  if (address == listing.sellerAddress) {
    return P2pBuyBlock.ownListing;
  }
  return null;
}

/// The share of the price a sale pays as royalty, as a percent, or null
/// when a sale cannot pay this royalty at all.
///
/// Spyglass sends the contract's `RoyaltyAmount` without its type (flat or
/// percent), so this does not say what the minter meant by the number: the
/// screen always shows the contract's own figure beside it. What it does say
/// is what a sale does with it. Core pays `price × RoyaltyAmount` to the
/// royalty address whichever the type is (`SmartContractService
/// .CompleteSaleSmartContractTX`), so an amount below 1 is the share of the
/// sale price that is paid (0.02 → "2"), and an amount of 1 or more leaves
/// the seller nothing and cannot be paid through a sale.
String? p2pRoyaltyPercent(P2pRoyalty royalty) {
  final amount = P2pAmount.tryParse(royalty.amount);
  if (amount == null || amount.units >= P2pAmount.unitsPerVfx) {
    return null;
  }
  return P2pAmount.fromUnits(amount.units * BigInt.from(100)).toDecimalString();
}

/// One step of a listing's life as the timeline draws it.
class P2pTimelineStep {
  final P2pListingState state;

  /// Reached and passed.
  final bool done;

  /// Where the listing is now.
  final bool current;

  /// The listing stopped here without a sale.
  final bool stopped;

  /// When the step was reached, where the listing says.
  final DateTime? at;

  const P2pTimelineStep({
    required this.state,
    this.done = false,
    this.current = false,
    this.stopped = false,
    this.at,
  });
}

const List<P2pListingState> _happyPath = [
  P2pListingState.live,
  P2pListingState.awaitingSaleStart,
  P2pListingState.salePending,
  P2pListingState.sold,
];

/// The seller has this long to send `Sale_Start()` after a win.
const Duration p2pSaleStartWindow = Duration(hours: 48);

/// Live → Winner chosen → Sale started → Sold, with the listing's place on
/// it. A listing that left by a side exit shows the steps it reached and
/// then the exit as its last, stopped step.
List<P2pTimelineStep> p2pListingTimeline(P2pListing listing) {
  final times = <P2pListingState, DateTime?>{
    P2pListingState.live: listing.startsAt,
    P2pListingState.awaitingSaleStart: listing.saleStartDeadline?.subtract(p2pSaleStartWindow),
    P2pListingState.salePending: listing.sale?.start?.at,
    P2pListingState.sold: listing.sale?.complete?.at,
  };
  final index = _happyPath.indexOf(listing.state);
  if (index >= 0) {
    return [
      for (var i = 0; i < _happyPath.length; i++)
        P2pTimelineStep(
          state: _happyPath[i],
          done: i < index,
          current: i == index,
          at: i <= index ? times[_happyPath[i]] : null,
        ),
    ];
  }
  int reached;
  switch (listing.state) {
    case P2pListingState.unfulfilled:
      reached = 2;
      break;
    case P2pListingState.ended:
      // Ended after its sale started (Sale_Cancel) or before (the NFT moved).
      reached = listing.sale?.start != null ? 3 : (listing.winnerAddress != null ? 2 : 1);
      break;
    case P2pListingState.cancelled:
      reached = listing.winnerAddress != null ? 2 : 1;
      break;
    default:
      reached = 1;
  }
  return [
    for (var i = 0; i < reached; i++) P2pTimelineStep(state: _happyPath[i], done: true, at: times[_happyPath[i]]),
    P2pTimelineStep(state: listing.state, current: true, stopped: true),
  ];
}

/// Where a bidder stands on a listing they bid on.
enum P2pBuyingStatus {
  /// The sale has started for them: complete the purchase.
  pay,

  /// Won; the seller starts the sale next.
  wonWaiting,

  /// Holds the high bid, with the reserve met.
  winning,

  /// Holds the high bid, under the reserve.
  reserveNotMet,

  /// Someone bid higher.
  outbid,

  /// Bought it.
  purchased,

  /// It went to someone else.
  lost,

  /// It ended without a sale.
  closed,
}

P2pBuyingStatus p2pBuyingStatus(P2pBuyingEntry entry, String address) {
  final listing = entry.listing;
  final mine = listing.winnerAddress == address;
  if (entry.canCompletePurchase || (listing.state == P2pListingState.salePending && mine)) {
    return P2pBuyingStatus.pay;
  }
  switch (listing.state) {
    case P2pListingState.sold:
      return mine ? P2pBuyingStatus.purchased : P2pBuyingStatus.lost;
    case P2pListingState.awaitingSaleStart:
    case P2pListingState.salePending:
      return mine ? P2pBuyingStatus.wonWaiting : P2pBuyingStatus.lost;
    case P2pListingState.live:
      if (listing.highBid?.address != address) {
        return P2pBuyingStatus.outbid;
      }
      return listing.reserveMet ? P2pBuyingStatus.winning : P2pBuyingStatus.reserveNotMet;
    default:
      return P2pBuyingStatus.closed;
  }
}

/// The most [address] has bid on [listing], as far as the listing shows:
/// its high bid when that is theirs, else the largest of their bids among
/// the ones it carries. Null when it shows none of theirs.
P2pAmount? p2pOwnBid(P2pListing listing, String address) {
  P2pAmount? most;
  void consider(String? amount) {
    final parsed = P2pAmount.tryParse(amount);
    if (parsed != null && (most == null || parsed > most!)) {
      most = parsed;
    }
  }

  if (listing.highBid?.address == address) {
    consider(listing.highBid!.amount);
  }
  for (final bid in listing.bids ?? const []) {
    if (bid.address == address) {
      consider(bid.amount);
    }
  }
  return most;
}

/// Whether a sale was started for more than the buyer bid: [price] is what
/// the started sale asks, [bid] the most the buyer offered. The purchase is
/// not offered then. An unknown bid does not block: the registry only starts
/// a sale at the winning bid's amount.
bool p2pSaleAsksMoreThanBid(P2pAmount price, P2pAmount? bid) {
  return bid != null && price > bid;
}

/// Where a shop URL stands as it is typed.
enum P2pShopUrlStatus {
  empty,

  /// Core's URL rule refuses it, or the registry does.
  invalid,

  /// The shop's own URL, when editing.
  unchanged,

  /// Typing has not settled, or the registry's answer is not in.
  checking,
  free,
  taken,
}

/// [typed] is what the field holds, [settled] what it held when typing last
/// paused, [answer] the registry's availability for [settled] (null until it
/// is in), and [current] the shop's own URL when editing.
P2pShopUrlStatus p2pShopUrlStatus(String typed, String settled, P2pUrlAvailability? answer, [String? current]) {
  final url = normalizeP2pShopUrl(typed);
  if (url.isEmpty) {
    return P2pShopUrlStatus.empty;
  }
  if (!isValidP2pShopUrl(typed)) {
    return P2pShopUrlStatus.invalid;
  }
  if (current != null && url == normalizeP2pShopUrl(current)) {
    return P2pShopUrlStatus.unchanged;
  }
  if (normalizeP2pShopUrl(settled) != url || answer == null || answer.normalized != url) {
    return P2pShopUrlStatus.checking;
  }
  if (answer.reason == 'invalid') {
    return P2pShopUrlStatus.invalid;
  }
  return answer.available ? P2pShopUrlStatus.free : P2pShopUrlStatus.taken;
}

enum P2pListingFieldError { required, format, decimals, belowFloor, belowReserve, belowStart, past, beforeStart }

/// A new listing's prices and dates as typed, checked by the shop's rules: a
/// buy-now price or an auction (or both); starting bid ≤ reserve ≤ buy-now;
/// it closes after it opens and in the future.
class P2pListingFormCheck {
  /// By field: `buyNow`, `floor`, `reserve`, `endsAt`.
  final Map<String, P2pListingFieldError> errors;

  /// No price at all: neither a buy-now price nor an auction.
  final bool noPrice;

  /// The prices, once nothing is wrong with them.
  final String? buyNowPrice;
  final String? floorPrice;
  final String? reservePrice;

  /// Whether the listing can be posted.
  final bool ok;

  const P2pListingFormCheck({
    required this.errors,
    required this.noPrice,
    required this.ok,
    this.buyNowPrice,
    this.floorPrice,
    this.reservePrice,
  });

  factory P2pListingFormCheck.of({
    required String buyNow,
    required bool auction,
    required String floor,
    required String reserve,
    required DateTime? startsAt,
    required DateTime? endsAt,
    required DateTime now,
  }) {
    final errors = <String, P2pListingFieldError>{};
    P2pAmount? price(String key, String text) {
      if (text.trim().isEmpty) {
        return null;
      }
      final input = P2pAmountInput.read(text);
      if (input.amount != null) {
        return input.amount;
      }
      errors[key] = input.error == P2pAmountInputError.decimals ? P2pListingFieldError.decimals : P2pListingFieldError.format;
      return null;
    }

    final buyNowAmount = price('buyNow', buyNow);
    final floorAmount = auction ? price('floor', floor) : null;
    final reserveAmount = auction ? price('reserve', reserve) : null;
    if (auction && floorAmount == null && !errors.containsKey('floor')) {
      errors['floor'] = P2pListingFieldError.required;
    }
    final noPrice = !auction && buyNowAmount == null && !errors.containsKey('buyNow');

    if (floorAmount != null && reserveAmount != null && reserveAmount < floorAmount) {
      errors['reserve'] = P2pListingFieldError.belowFloor;
    }
    if (buyNowAmount != null && !errors.containsKey('reserve') && reserveAmount != null && buyNowAmount < reserveAmount) {
      errors['buyNow'] = P2pListingFieldError.belowReserve;
    } else if (buyNowAmount != null && floorAmount != null && buyNowAmount < floorAmount) {
      errors['buyNow'] = P2pListingFieldError.belowStart;
    }

    final starts = startsAt ?? now;
    if (endsAt == null) {
      errors['endsAt'] = P2pListingFieldError.required;
    } else if (!endsAt.isAfter(starts)) {
      errors['endsAt'] = P2pListingFieldError.beforeStart;
    } else if (!endsAt.isAfter(now)) {
      errors['endsAt'] = P2pListingFieldError.past;
    }

    final ok = errors.isEmpty && !noPrice;
    return P2pListingFormCheck(
      errors: errors,
      noPrice: noPrice,
      ok: ok,
      buyNowPrice: ok ? buyNowAmount?.toDecimalString() : null,
      floorPrice: ok ? floorAmount?.toDecimalString() : null,
      reservePrice: ok ? reserveAmount?.toDecimalString() : null,
    );
  }
}

/// What a seller can do with a listing of theirs.
class P2pSellerActions {
  /// `Sale_Start()` for the winner.
  final bool startSale;

  /// Withdraw the listing, before its sale starts.
  final bool cancelListing;

  /// Change its prices and dates: only while live with no bids.
  final bool editListing;

  /// `Sale_Cancel()`, once the sale has started.
  final bool cancelSale;

  /// List the NFT again, after a sale that was never started.
  final bool listAgain;

  const P2pSellerActions({
    this.startSale = false,
    this.cancelListing = false,
    this.editListing = false,
    this.cancelSale = false,
    this.listAgain = false,
  });

  factory P2pSellerActions.of(P2pListing listing) {
    switch (listing.state) {
      case P2pListingState.live:
        return P2pSellerActions(cancelListing: true, editListing: listing.bidCount == 0);
      case P2pListingState.awaitingSaleStart:
        return const P2pSellerActions(startSale: true, cancelListing: true);
      case P2pListingState.salePending:
        return const P2pSellerActions(cancelSale: true);
      case P2pListingState.unfulfilled:
        return const P2pSellerActions(listAgain: true);
      default:
        return const P2pSellerActions();
    }
  }

  bool get any => startSale || cancelListing || editListing || cancelSale || listAgain;
}

/// How a seller's listings are grouped, by what they need.
enum P2pSellingGroup { needsYou, live, waitingForBuyer, sold, closed }

P2pSellingGroup p2pSellingGroupOf(P2pListingState state) {
  switch (state) {
    case P2pListingState.awaitingSaleStart:
      return P2pSellingGroup.needsYou;
    case P2pListingState.live:
      return P2pSellingGroup.live;
    case P2pListingState.salePending:
      return P2pSellingGroup.waitingForBuyer;
    case P2pListingState.sold:
      return P2pSellingGroup.sold;
    default:
      return P2pSellingGroup.closed;
  }
}

/// The seller's listings by group, a sale to start first; empty groups are
/// left out.
Map<P2pSellingGroup, List<P2pSellingListing>> p2pGroupSelling(List<P2pSellingListing> selling) {
  final groups = <P2pSellingGroup, List<P2pSellingListing>>{};
  for (final group in P2pSellingGroup.values) {
    final items = selling.where((s) => p2pSellingGroupOf(s.listing.state) == group).toList();
    if (items.isNotEmpty) {
      groups[group] = items;
    }
  }
  return groups;
}

/// Why an NFT of this wallet cannot be listed by an address.
enum P2pNftBlock {
  /// Another account of the wallet owns it.
  notYours,

  /// A token or a vBTC vault.
  unsellable,

  /// Its mint is not on chain yet.
  notMinted,

  /// It is in an active listing already.
  listed,
}

/// Why [address] cannot list [nft], or null when it can. [listed] is the
/// registry's set of this wallet's NFTs in active listings. The registry
/// decides in the end (`nft_not_listable`, `nft_already_listed`,
/// `not_nft_owner`); this keeps what it would refuse from being offered.
P2pNftBlock? p2pNftBlock(P2pOwnedNft nft, {required String address, required Set<String> listed}) {
  if (nft.owner != address) {
    return P2pNftBlock.notYours;
  }
  if (!nft.isSellable) {
    return P2pNftBlock.unsellable;
  }
  if (!nft.isMinted) {
    return P2pNftBlock.notMinted;
  }
  if (listed.contains(nft.id)) {
    return P2pNftBlock.listed;
  }
  return null;
}

/// Where a date-and-time picker opens for [initial], at [now]: on this
/// computer's clock, and not before today. A picker reads a `DateTime`'s own
/// date and hour, so a UTC time (a listing's are) must be made local first,
/// or accepting it unchanged would move it by the zone's offset.
DateTime p2pPickerStart(DateTime initial, DateTime now) {
  final localNow = now.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final start = initial.toLocal();
  return start.isBefore(today) ? today : start;
}
