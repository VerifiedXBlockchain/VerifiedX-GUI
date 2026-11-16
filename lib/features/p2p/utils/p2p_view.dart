import '../models/p2p_listing.dart';
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

/// A royalty as a percent of the price, or null when its amount cannot be
/// read as one.
///
/// Spyglass sends the contract's `RoyaltyAmount` without its type (flat or
/// percent). In a sale Core pays `price × RoyaltyAmount` to the royalty
/// address whichever the type is (`SmartContractService
/// .CompleteSaleSmartContractTX`), so an amount below 1 is the share of the
/// price a sale pays (0.02 → "2"). An amount of 1 or more cannot be a share
/// of a price: it is a flat royalty, shown as the contract states it and
/// never as a percent.
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
