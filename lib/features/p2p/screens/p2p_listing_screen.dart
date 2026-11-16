import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_bid_dialog.dart';
import '../components/p2p_dry_run_banner.dart';
import '../components/p2p_page_visibility.dart';
import '../components/p2p_parts.dart';
import '../models/p2p_bid_summary.dart';
import '../models/p2p_listing.dart';
import '../providers/p2p_browse_providers.dart';
import '../providers/p2p_listing_providers.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_view.dart';

/// One listing, addressed by its id: the NFT's picture, its prices, clock
/// and state, what the person looking can do (bid or buy now, each a signed
/// message), its progress, its bids and its details.
class P2pListingScreen extends BaseStatefulScreen {
  final int id;

  const P2pListingScreen({super.key, @PathParam('id') required this.id}) : super(horizontalPadding: 16, verticalPadding: 12);

  @override
  BaseScreenState<P2pListingScreen> createState() => _P2pListingScreenState();
}

class _P2pListingScreenState extends BaseScreenState<P2pListingScreen> {
  /// How often an open listing page reads its listing again: bids and the
  /// registry's own clock move it on without this wallet doing anything.
  static const Duration _pollEvery = Duration(seconds: 15);

  Timer? _poll;
  bool _showAllBids = false;

  /// Whether the page was in view when last looked at: it reads again when
  /// it comes back into view, and not while it is out of it.
  bool _inView = true;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(_pollEvery, (_) {
      // A page under another one, or in a tab the person has left, stays
      // built: it does not keep asking the registry.
      if (mounted && p2pPageIsVisible(context)) {
        _refresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inView = p2pPageIsVisible(context, watch: true);
    if (inView && !_inView) {
      // Back in view after a while under another page: read now, after
      // this build, not up to a whole interval later.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refresh();
        }
      });
    }
    _inView = inView;
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _refresh() {
    ref.read(p2pListingDetailProvider(widget.id).notifier).refresh();
    if (_showAllBids) {
      ref.invalidate(p2pAllBidsProvider(widget.id));
    }
  }

  @override
  AppBar? appBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listing = ref.watch(p2pListingDetailProvider(widget.id)).valueOrNull;
    return AppBar(
      leading: IconButton(
        onPressed: () => AutoRouter.of(context).pop(),
        icon: const Icon(Icons.chevron_left),
        tooltip: l10n.actionBack,
      ),
      title: Text(listing?.title ?? l10n.p2pListingTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        IconButton(
          key: const Key('p2p:listing_refresh'),
          tooltip: l10n.actionRefresh,
          icon: const Icon(Icons.refresh),
          onPressed: _refresh,
        ),
        const WalletSelector(includeBtc: false, withOptions: false),
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = p2pListingDetailProvider(widget.id);
    final listing = ref.watch(provider);

    return listing.when(
      loading: () => const CenteredLoader(),
      error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(provider)),
      data: (listing) {
        if (listing == null) {
          return P2pEmptyState(icon: Icons.inventory_2_outlined, title: l10n.p2pListingNotFound, body: l10n.p2pListingNotFoundBody);
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final media = _Media(listing: listing);
            final details = _details(context, listing);
            if (constraints.maxWidth < 860) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: media)),
                    const SizedBox(height: 16),
                    details,
                  ],
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 5,
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: media),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: SingleChildScrollView(child: details)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _details(BuildContext context, P2pListing listing) {
    final l10n = AppLocalizations.of(context);
    final viewer = ref.watch(p2pViewerAddressProvider);
    final role = p2pViewerRole(listing, viewer);
    final nft = listing.nft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            P2pStateBadge(state: listing.state),
            P2pTag(
              label: listing.isAuction ? l10n.p2pListingAuction : l10n.p2pListingFixedPrice,
              color: Colors.white70,
              icon: listing.isAuction ? Icons.gavel : Icons.sell_outlined,
            ),
            if (role == P2pViewerRole.seller) P2pTag(label: l10n.p2pListingYours, color: p2pBrand()),
            if (role == P2pViewerRole.winner) P2pTag(label: l10n.p2pListingYouWon, color: p2pBrand()),
            if (listing.isDryRun) P2pTag(label: l10n.p2pDryRunBadge, color: AppColors.gold[50]!),
          ],
        ),
        const SizedBox(height: 10),
        Text(listing.title, key: const Key('p2p:listing_title'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.15)),
        if (nft != null && nft.minterName.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(l10n.p2pListingBy(nft.minterName), style: const TextStyle(color: p2pMuted)),
        ],
        if (nft != null && nft.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(nft.description, style: const TextStyle(color: Colors.white, height: 1.4)),
        ],
        const SizedBox(height: 14),
        _PricePanel(listing: listing, viewer: viewer),
        const SizedBox(height: 12),
        const P2pDryRunBanner(),
        _SectionTitle(l10n.p2pListingProgress),
        _Timeline(listing: listing),
        _SectionTitle(listing.isAuction ? l10n.p2pListingBids : l10n.p2pListingOffers, count: listing.bidCount),
        _bids(context, listing, viewer),
        _SectionTitle(l10n.p2pListingDetails),
        _DetailsTable(listing: listing),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _bids(BuildContext context, P2pListing listing, String? viewer) {
    final l10n = AppLocalizations.of(context);
    final shown = listing.bids ?? const <P2pBidSummary>[];
    final hasMore = listing.bidCount > shown.length;
    final all = _showAllBids && hasMore ? ref.watch(p2pAllBidsProvider(listing.id)) : null;
    final bids = all?.valueOrNull ?? shown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BidList(bids: bids, viewer: viewer, auction: listing.isAuction),
        if (hasMore && all?.valueOrNull == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.p2pListingBidsShown(shown.length, listing.bidCount),
                    style: const TextStyle(color: p2pMuted, fontSize: 12.5),
                  ),
                ),
                AppButton(
                  key: const Key('p2p:all_bids'),
                  label: l10n.p2pListingAllBids,
                  type: AppButtonType.Text,
                  variant: AppColorVariant.Light,
                  processing: all?.isLoading ?? false,
                  onPressed: () => setState(() => _showAllBids = true),
                ),
              ],
            ),
          ),
        if (all != null && all.hasError)
          P2pErrorView(error: all.error!, onRetry: () => ref.invalidate(p2pAllBidsProvider(listing.id))),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionTitle(this.title, {this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 8),
            Text("$count", style: const TextStyle(color: p2pMuted, fontFamily: 'RobotoMono', fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

/// The NFT's picture, with a way to open the file itself.
class _Media extends StatelessWidget {
  final P2pListing listing;

  const _Media({required this.listing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assetUrl = listing.nft?.assetUrl;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        key: const Key('p2p:listing_media'),
        clipBehavior: Clip.antiAlias,
        decoration: p2pCardDecoration(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              image: true,
              label: listing.title,
              child: P2pListingThumb(listing: listing, fit: BoxFit.contain),
            ),
            if (assetUrl != null && assetUrl.isNotEmpty)
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: l10n.actionViewAsset,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    onPressed: () => launchUrlString(assetUrl, mode: LaunchMode.externalApplication),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The figure the listing leads with, its bids and reserve, its clock, and
/// what the person looking can do.
class _PricePanel extends StatelessWidget {
  final P2pListing listing;
  final String? viewer;

  const _PricePanel({required this.listing, required this.viewer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headline = P2pHeadline.of(listing);
    final showsBuyNowBeside = listing.buyNowPrice != null && headline?.kind != P2pHeadlineKind.buyNow;

    return Container(
      key: const Key('p2p:price_panel'),
      padding: const EdgeInsets.all(16),
      decoration: p2pCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headline != null)
                Expanded(
                  child: P2pPrice(
                    key: const Key('p2p:headline_price'),
                    label: p2pHeadlineLabel(l10n, headline.kind),
                    amount: headline.amount,
                    large: true,
                  ),
                )
              else
                const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (listing.isAuction)
                    Text(p2pBidCountText(l10n, listing.bidCount), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  if (listing.reservePrice != null) ...[
                    const SizedBox(height: 6),
                    P2pTag(
                      key: const Key('p2p:reserve'),
                      label: listing.reserveMet ? l10n.p2pListingReserveMet : l10n.p2pListingReserveNotMet,
                      color: listing.reserveMet ? AppColors.getSpringGreen(ColorShade.s50) : AppColors.gold[50]!,
                      icon: listing.reserveMet ? Icons.verified_user_outlined : Icons.shield_outlined,
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (listing.isLive && (listing.nextMinBid != null || showsBuyNowBeside)) ...[
            const Divider(height: 24, color: p2pBorder),
            Row(
              children: [
                if (listing.nextMinBid != null)
                  Expanded(
                    child: P2pPrice(key: const Key('p2p:next_min_bid'), label: l10n.p2pListingNextMinBid, amount: listing.nextMinBid!),
                  ),
                if (showsBuyNowBeside)
                  Expanded(
                    child: P2pPrice(key: const Key('p2p:buy_now_price'), label: l10n.p2pPriceBuyNow, amount: listing.buyNowPrice!),
                  ),
              ],
            ),
          ],
          P2pNowBuilder(
            builder: (context, now) {
              final clock = P2pListingClock.of(listing, now);
              if (clock.kind == P2pClockKind.none) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(color: p2pSurfaceRaised, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(child: P2pClockLine(listing: listing, fontSize: 14)),
                    if (clock.until != null)
                      Text(p2pDateTimeText(context, clock.until!), style: const TextStyle(color: p2pMuted, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _Actions(listing: listing, viewer: viewer),
        ],
      ),
    );
  }
}

/// Bid and Buy now for someone who can, or why not for someone who cannot.
class _Actions extends StatelessWidget {
  final P2pListing listing;
  final String? viewer;

  const _Actions({required this.listing, required this.viewer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = p2pViewerRole(listing, viewer);
    if (role == P2pViewerRole.winner) {
      return _note(_winnerNote(l10n), success: listing.state != P2pListingState.salePending);
    }
    return P2pNowBuilder(
      builder: (context, now) {
        final block = p2pBuyBlock(listing, viewer, now);
        if (block != null) {
          return _note(_blockNote(l10n, block));
        }
        final address = viewer!;
        final leading = listing.highBid?.address == address;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 16, color: AppColors.getSpringGreen(ColorShade.s50)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        listing.reserveMet ? l10n.p2pListingLeading : l10n.p2pListingLeadingReserve,
                        key: const Key('p2p:leading_note'),
                        style: TextStyle(color: AppColors.getSpringGreen(ColorShade.s50), fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (listing.isAuction)
                  AppButton(
                    key: const Key('p2p:bid_open'),
                    label: l10n.p2pBidOpen,
                    icon: Icons.gavel,
                    onPressed: () => P2pBidDialog.show(listingId: listing.id, address: address, mode: P2pBidMode.bid),
                  ),
                if (listing.hasBuyNow)
                  AppButton(
                    key: const Key('p2p:buy_open'),
                    label: l10n.p2pBuyOpen(p2pVfxText(l10n, listing.buyNowPrice)),
                    icon: Icons.sell_outlined,
                    type: listing.isAuction ? AppButtonType.Outlined : AppButtonType.Elevated,
                    variant: listing.isAuction ? AppColorVariant.Light : AppColorVariant.Primary,
                    onPressed: () => P2pBidDialog.show(listingId: listing.id, address: address, mode: P2pBidMode.buyNow),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _winnerNote(AppLocalizations l10n) {
    final price = listing.highBid?.amount;
    switch (listing.state) {
      case P2pListingState.awaitingSaleStart:
        return l10n.p2pListingWonWaiting(p2pVfxText(l10n, price));
      case P2pListingState.salePending:
        return l10n.p2pListingSaleStartedNote;
      case P2pListingState.sold:
        return l10n.p2pListingPurchased(p2pVfxText(l10n, listing.soldPrice ?? price));
      default:
        return l10n.p2pListingOver;
    }
  }

  String _blockNote(AppLocalizations l10n, P2pBuyBlock block) {
    switch (block) {
      case P2pBuyBlock.notOpenYet:
        return l10n.p2pListingNotOpenYet;
      case P2pBuyBlock.closing:
        return l10n.p2pListingClosing;
      case P2pBuyBlock.noAccount:
        return l10n.p2pListingNoAccount;
      case P2pBuyBlock.vault:
        return l10n.p2pListingVault;
      case P2pBuyBlock.ownListing:
        return l10n.p2pListingOwn;
      case P2pBuyBlock.notLive:
        switch (listing.state) {
          case P2pListingState.sold:
            final price = P2pHeadline.of(listing)?.amount;
            return l10n.p2pListingSoldNote(p2pVfxText(l10n, price));
          case P2pListingState.awaitingSaleStart:
          case P2pListingState.salePending:
            return l10n.p2pListingWonByOther;
          default:
            return l10n.p2pListingOver;
        }
    }
  }

  Widget _note(String text, {bool success = false}) {
    return Text(
      text,
      key: const Key('p2p:action_note'),
      style: TextStyle(
        color: success ? AppColors.getSpringGreen(ColorShade.s50) : Colors.white70,
        fontSize: 13.5,
        height: 1.35,
      ),
    );
  }
}

/// Live → Winner chosen → Sale started → Sold, with the listing's place on it.
class _Timeline extends StatelessWidget {
  final P2pListing listing;

  const _Timeline({required this.listing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = p2pListingTimeline(listing);
    final success = AppColors.getSpringGreen(ColorShade.s50);

    return Column(
      key: const Key('p2p:timeline'),
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: steps[i].stopped
                              ? Colors.white38
                              : steps[i].done
                                  ? success
                                  : steps[i].current
                                      ? p2pBrand()
                                      : Colors.white24,
                        ),
                      ),
                      child: steps[i].stopped
                          ? const Icon(Icons.close, size: 12, color: Colors.white54)
                          : steps[i].done
                              ? Icon(Icons.check, size: 12, color: success)
                              : steps[i].current
                                  ? Icon(Icons.circle, size: 8, color: p2pBrand())
                                  : null,
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(width: 2, color: steps[i].done ? success : Colors.white24),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 14 : 0, top: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p2pStateText(l10n, steps[i].state),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: steps[i].done || steps[i].current ? FontWeight.w600 : FontWeight.w400,
                              color: steps[i].done || steps[i].current ? Colors.white : p2pMuted,
                            ),
                          ),
                        ),
                        if (steps[i].at != null)
                          Text(p2pDateTimeText(context, steps[i].at!), style: const TextStyle(color: p2pMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BidList extends StatelessWidget {
  final List<P2pBidSummary> bids;
  final String? viewer;
  final bool auction;

  const _BidList({required this.bids, required this.viewer, required this.auction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (bids.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p2pBorder),
        ),
        child: Text(auction ? l10n.p2pListingNoBids : l10n.p2pListingNoOffers, style: const TextStyle(color: p2pMuted)),
      );
    }
    return Container(
      key: const Key('p2p:bid_list'),
      decoration: p2pCardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < bids.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: p2pBorder),
            Padding(
              key: Key('p2p:bid:${bids[i].id}'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(shortP2pAddress(bids[i].address), style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 13)),
                            if (bids[i].address == viewer) P2pTag(label: l10n.p2pListingYou, color: p2pBrand()),
                            ..._statusTag(l10n, bids[i]),
                          ],
                        ),
                        if (bids[i].at != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(p2pDateTimeText(context, bids[i].at!), style: const TextStyle(color: p2pMuted, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  P2pPrice(amount: bids[i].amount, alignment: CrossAxisAlignment.end),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _statusTag(AppLocalizations l10n, P2pBidSummary bid) {
    final success = AppColors.getSpringGreen(ColorShade.s50);
    if (bid.isBuyNow) {
      return [P2pTag(label: l10n.p2pPriceBuyNow, color: success)];
    }
    switch (bid.status) {
      case P2pBidStatus.winning:
        return [P2pTag(label: l10n.p2pBidStatusWinning, color: success)];
      case P2pBidStatus.won:
        return [P2pTag(label: l10n.p2pBidStatusWon, color: success)];
      case P2pBidStatus.accepted:
        return [P2pTag(label: l10n.p2pBidStatusAccepted, color: AppColors.gold[50]!)];
      case P2pBidStatus.outbid:
        return [P2pTag(label: l10n.p2pBidStatusOutbid, color: Colors.white60)];
      case P2pBidStatus.lost:
        return [P2pTag(label: l10n.p2pBidStatusLost, color: Colors.white60)];
      case P2pBidStatus.unknown:
        return const [];
    }
  }
}

class _DetailsTable extends StatelessWidget {
  final P2pListing listing;

  const _DetailsTable({required this.listing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nft = listing.nft;
    final royalty = nft?.royalty;
    final percent = royalty == null ? null : p2pRoyaltyPercent(royalty);
    const mono = TextStyle(fontFamily: 'RobotoMono', fontSize: 13);

    final rows = <Widget>[
      _row(
        l10n.p2pListingShop,
        InkWell(
          key: const Key('p2p:listing_shop_link'),
          onTap: () => AutoRouter.of(context).push(P2pShopScreenRoute(url: listing.shopUrl)),
          child: Text("vfx://${listing.shopUrl}", style: mono.copyWith(color: p2pBrand())),
        ),
      ),
      if (nft != null && nft.minterName.isNotEmpty) _row(l10n.p2pListingMinter, Text(nft.minterName)),
      _row(
        l10n.p2pListingRoyalty,
        royalty == null
            ? Text(l10n.p2pListingNoRoyalty)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    percent == null ? l10n.p2pListingRoyaltyAmount(formatP2pAmount(royalty.amount)) : l10n.p2pListingRoyaltyPercent(percent),
                    key: const Key('p2p:royalty'),
                  ),
                  Text(shortP2pAddress(royalty.payTo), style: mono.copyWith(color: p2pMuted, fontSize: 12)),
                ],
              ),
      ),
      _row(
        l10n.p2pListingSeller,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(shortP2pAddress(listing.sellerAddress), style: mono),
            P2pCopyButton(value: listing.sellerAddress, tooltip: l10n.p2pCopySellerAddress),
          ],
        ),
      ),
      if (listing.winnerAddress != null)
        _row(
          listing.state == P2pListingState.sold ? l10n.p2pListingBuyer : l10n.p2pListingWinner,
          Text(shortP2pAddress(listing.winnerAddress!), style: mono),
        ),
      if (listing.startsAt != null) _row(l10n.p2pListingStarts, Text(p2pDateTimeText(context, listing.startsAt!))),
      if (listing.endsAt != null) _row(l10n.p2pListingEnds, Text(p2pDateTimeText(context, listing.endsAt!))),
      if (listing.state == P2pListingState.awaitingSaleStart && listing.saleStartDeadline != null)
        _row(l10n.p2pListingSaleStartBy, Text(p2pDateTimeText(context, listing.saleStartDeadline!))),
      if (listing.endReason != null) _row(l10n.p2pListingEndReason, Text(_endReason(l10n, listing.endReason!), key: const Key('p2p:end_reason'))),
      _row(
        l10n.p2pListingContract,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(shortP2pAddress(listing.smartContractUid, 8, 8), style: mono),
            P2pCopyButton(value: listing.smartContractUid, tooltip: l10n.p2pCopyContract),
          ],
        ),
      ),
    ];

    return Container(
      key: const Key('p2p:details'),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: p2pCardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: p2pBorder),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _row(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: p2pMuted, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: DefaultTextStyle.merge(style: const TextStyle(fontSize: 13), textAlign: TextAlign.right, child: value),
            ),
          ),
        ],
      ),
    );
  }

  /// An open set: a reason this build does not know is shown as it came.
  String _endReason(AppLocalizations l10n, String reason) {
    switch (reason) {
      case 'nft_moved':
        return l10n.p2pEndReasonNftMoved;
      case 'nft_burned':
        return l10n.p2pEndReasonNftBurned;
      case 'shop_deleted':
        return l10n.p2pEndReasonShopDeleted;
      case 'shop_owner_changed':
        return l10n.p2pEndReasonShopOwnerChanged;
      case 'sale_cancelled':
        return l10n.p2pEndReasonSaleCancelled;
      case 'sale_started_elsewhere':
        return l10n.p2pEndReasonSaleStartedElsewhere;
      case 'shop_registered_on_chain':
        return l10n.p2pEndReasonShopRegisteredOnChain;
    }
    return reason;
  }
}
