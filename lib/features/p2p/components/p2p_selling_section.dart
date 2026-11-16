import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_me.dart';
import '../providers/p2p_browse_providers.dart';
import '../utils/p2p_view.dart';
import 'p2p_listing_manage.dart';
import 'p2p_parts.dart';

/// The owner's listings in My shop (`GET /p2p/me/`), grouped by what they
/// need, a sale to start first. Each row opens the listing and carries what
/// its seller can do with it.
class P2pSellingSection extends ConsumerWidget {
  final String address;

  /// Opens "List an NFT"; with an id, for that NFT.
  final void Function([String? nftId]) onList;

  const P2pSellingSection({super.key, required this.address, required this.onList});

  String _groupTitle(AppLocalizations l10n, P2pSellingGroup group) {
    switch (group) {
      case P2pSellingGroup.needsYou:
        return l10n.p2pGroupNeedsYou;
      case P2pSellingGroup.live:
        return l10n.p2pGroupLive;
      case P2pSellingGroup.waitingForBuyer:
        return l10n.p2pGroupWaitingForBuyer;
      case P2pSellingGroup.sold:
        return l10n.p2pGroupSold;
      case P2pSellingGroup.closed:
        return l10n.p2pGroupClosed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = p2pMeProvider(address);
    final me = ref.watch(provider);

    return Container(
      key: const Key('p2p:selling'),
      padding: const EdgeInsets.all(16),
      decoration: p2pCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.p2pSellingTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
              AppButton(
                key: const Key('p2p:list_open'),
                label: l10n.p2pListOpen,
                icon: Icons.add,
                size: AppSizeVariant.Sm,
                onPressed: () => onList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          me.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: CenteredLoader()),
            error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(provider)),
            data: (me) {
              final groups = p2pGroupSelling(me.selling);
              if (groups.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.p2pSellingNone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text(l10n.p2pSellingNoneBody, style: const TextStyle(color: p2pMuted, fontSize: 13)),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final group in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Text(
                        "${_groupTitle(l10n, group.key)} · ${group.value.length}",
                        key: Key('p2p:selling_group:${group.key.name}'),
                        style: TextStyle(
                          color: group.key == P2pSellingGroup.needsYou ? p2pBrand() : p2pMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final selling in group.value) _SellingRow(selling: selling, address: address, onList: onList),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SellingRow extends ConsumerWidget {
  /// Room for a row's two buttons side by side; longer labels wrap.
  static const double actionsWidth = 300;

  final P2pSellingListing selling;
  final String address;
  final void Function([String? nftId]) onList;

  const _SellingRow({required this.selling, required this.address, required this.onList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listing = selling.listing;
    final headline = P2pHeadline.of(listing);

    return InkWell(
      key: Key('p2p:selling_row:${listing.id}'),
      onTap: () => AutoRouter.of(context).push(P2pListingScreenRoute(id: listing.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: p2pBorder))),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: 48, height: 48, child: P2pListingThumb(listing: listing))),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(
                    listing.isAuction ? "${l10n.p2pListingAuction} · ${p2pBidCountText(l10n, listing.bidCount)}" : l10n.p2pListingFixedPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: p2pMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  P2pClockLine(listing: listing, fontSize: 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  P2pStateBadge(state: listing.state),
                  if (headline != null) ...[
                    const SizedBox(height: 4),
                    P2pPrice(label: p2pHeadlineLabel(l10n, headline.kind), amount: headline.amount),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // A fixed width whatever a row offers (nothing, one button or
            // two), so the columns before it line up from row to row.
            SizedBox(
              width: _SellingRow.actionsWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: P2pSellerButtons(listing: listing, address: address, onListAgain: onList, compact: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
