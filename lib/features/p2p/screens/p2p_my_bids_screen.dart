import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../chain/p2p_tx_builders.dart';
import '../components/p2p_dry_run_banner.dart';
import '../components/p2p_parts.dart';
import '../components/p2p_purchase.dart';
import '../models/p2p_me.dart';
import '../providers/p2p_browse_providers.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_rules.dart';
import '../utils/p2p_view.dart';

/// What the selected account has bid on and bought, from `GET /p2p/me/`:
/// where it stands on each listing, and "Complete purchase" where a sale has
/// started for it.
class P2pMyBidsScreen extends BaseScreen {
  const P2pMyBidsScreen({super.key}) : super(horizontalPadding: 16, verticalPadding: 12);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final address = ref.watch(p2pViewerAddressProvider);
    return AppBar(
      leading: IconButton(
        onPressed: () => AutoRouter.of(context).pop(),
        icon: const Icon(Icons.chevron_left),
        tooltip: l10n.actionBack,
      ),
      title: Text(l10n.p2pMyBidsTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        if (address != null)
          IconButton(
            key: const Key('p2p:my_bids_refresh'),
            tooltip: l10n.actionRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(p2pMeProvider(address)),
          ),
        const WalletSelector(includeBtc: false, withOptions: false),
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final address = ref.watch(p2pViewerAddressProvider);
    if (address == null) {
      return P2pEmptyState(icon: Icons.account_circle_outlined, title: l10n.p2pMyBidsNoAccount);
    }
    if (isP2pReserveAddress(address)) {
      return P2pEmptyState(icon: Icons.lock_outline, title: l10n.p2pMyBidsVault);
    }
    final provider = p2pMeProvider(address);
    final me = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const P2pDryRunBanner(),
        const SizedBox(height: 12),
        Expanded(
          child: me.when(
            loading: () => const CenteredLoader(),
            error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(provider)),
            data: (me) {
              if (me.buying.isEmpty) {
                return P2pEmptyState(icon: Icons.gavel, title: l10n.p2pMyBidsNone, body: l10n.p2pMyBidsNoneBody);
              }
              return ListView.separated(
                key: const Key('p2p:buying_list'),
                itemCount: me.buying.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _BuyingCard(entry: me.buying[index], address: address),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BuyingCard extends ConsumerWidget {
  final P2pBuyingEntry entry;
  final String address;

  const _BuyingCard({required this.entry, required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listing = entry.listing;
    final status = p2pBuyingStatus(entry, address);
    final headline = P2pHeadline.of(listing);
    final mine = entry.myHighBid;
    final price = p2pSalePrice(listing);
    final asksMore = price != null && p2pSaleAsksMoreThanBid(price, P2pAmount.tryParse(mine?.amount));
    final pay = status == P2pBuyingStatus.pay && price != null;

    return Container(
      key: Key('p2p:buying:${listing.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p2pSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pay ? p2pBrand().withOpacity(0.6) : p2pBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 84, height: 84, child: P2pListingThumb(listing: listing)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  key: Key('p2p:buying_open:${listing.id}'),
                  onTap: () => AutoRouter.of(context).push(P2pListingScreenRoute(id: listing.id)),
                  child: Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  "vfx://${listing.shopUrl}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p2pBrand(), fontFamily: 'RobotoMono', fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    P2pTag(key: Key('p2p:buying_status:${status.name}'), label: _statusLabel(l10n, status), color: _statusColor(status)),
                    Text(_statusNote(l10n, status), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 24,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    if (mine != null) P2pPrice(label: l10n.p2pMyBidsMine, amount: mine.amount),
                    if (headline != null && headline.amount != mine?.amount)
                      P2pPrice(label: p2pHeadlineLabel(l10n, headline.kind), amount: headline.amount),
                    P2pClockLine(listing: listing),
                  ],
                ),
                if (pay && asksMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.p2pPurchaseOverBid(p2pVfxText(l10n, price.toDecimalString()), p2pVfxText(l10n, mine?.amount)),
                      key: const Key('p2p:purchase_over_bid'),
                      style: TextStyle(color: AppColors.getSanguine(ColorShade.s50), fontSize: 13, height: 1.35),
                    ),
                  ),
              ],
            ),
          ),
          if (pay && !asksMore) ...[
            const SizedBox(width: 12),
            AppButton(
              key: Key('p2p:complete_purchase:${listing.id}'),
              label: l10n.p2pChainCompleteTitle,
              icon: Icons.check,
              // The listing as /me/ gave it carries the started sale and its price.
              onPressed: () => completeP2pPurchase(ref, l10n, listing),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, P2pBuyingStatus status) {
    switch (status) {
      case P2pBuyingStatus.pay:
        return l10n.p2pBuyingPay;
      case P2pBuyingStatus.wonWaiting:
        return l10n.p2pBuyingWonWaiting;
      case P2pBuyingStatus.winning:
        return l10n.p2pBuyingWinning;
      case P2pBuyingStatus.reserveNotMet:
        return l10n.p2pBuyingReserveNotMet;
      case P2pBuyingStatus.outbid:
        return l10n.p2pBuyingOutbid;
      case P2pBuyingStatus.purchased:
        return l10n.p2pBuyingPurchased;
      case P2pBuyingStatus.lost:
        return l10n.p2pBuyingLost;
      case P2pBuyingStatus.closed:
        return l10n.p2pBuyingClosed;
    }
  }

  String _statusNote(AppLocalizations l10n, P2pBuyingStatus status) {
    switch (status) {
      case P2pBuyingStatus.pay:
        return l10n.p2pBuyingNotePay;
      case P2pBuyingStatus.wonWaiting:
        return l10n.p2pBuyingNoteWonWaiting;
      case P2pBuyingStatus.winning:
        return l10n.p2pBuyingNoteWinning;
      case P2pBuyingStatus.reserveNotMet:
        return l10n.p2pBuyingNoteReserveNotMet;
      case P2pBuyingStatus.outbid:
        return l10n.p2pBuyingNoteOutbid;
      case P2pBuyingStatus.purchased:
        return l10n.p2pBuyingNotePurchased;
      case P2pBuyingStatus.lost:
        return l10n.p2pBuyingNoteLost;
      case P2pBuyingStatus.closed:
        return l10n.p2pBuyingNoteClosed;
    }
  }

  Color _statusColor(P2pBuyingStatus status) {
    switch (status) {
      case P2pBuyingStatus.pay:
        return p2pBrand();
      case P2pBuyingStatus.wonWaiting:
      case P2pBuyingStatus.winning:
      case P2pBuyingStatus.purchased:
        return AppColors.getSpringGreen(ColorShade.s50);
      case P2pBuyingStatus.reserveNotMet:
        return AppColors.gold[50]!;
      case P2pBuyingStatus.outbid:
      case P2pBuyingStatus.lost:
      case P2pBuyingStatus.closed:
        return Colors.white60;
    }
  }
}
