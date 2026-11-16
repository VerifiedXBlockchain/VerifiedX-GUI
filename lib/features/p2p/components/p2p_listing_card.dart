import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/app_router.gr.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_listing.dart';
import '../utils/p2p_view.dart';
import 'p2p_parts.dart';

/// A listing in a shop's grid: its picture, name, the price it leads with,
/// its clock and its state. Opens the listing.
class P2pListingCard extends StatefulWidget {
  final P2pListing listing;

  const P2pListingCard({super.key, required this.listing});

  @override
  State<P2pListingCard> createState() => _P2pListingCardState();
}

class _P2pListingCardState extends State<P2pListingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listing = widget.listing;
    final headline = P2pHeadline.of(listing);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: Key('p2p:listing_card:${listing.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => AutoRouter.of(context).push(P2pListingScreenRoute(id: listing.id)),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: p2pCardDecoration(hovered: _hovered),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      P2pListingThumb(listing: listing),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(50)),
                          child: P2pStateBadge(state: listing.state),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          listing.isAuction ? "${l10n.p2pListingAuction} · ${p2pBidCountText(l10n, listing.bidCount)}" : l10n.p2pListingFixedPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: p2pMuted, fontSize: 12),
                        ),
                        const Spacer(),
                        if (headline != null) P2pPrice(label: p2pHeadlineLabel(l10n, headline.kind), amount: headline.amount),
                        const SizedBox(height: 4),
                        P2pClockLine(listing: listing),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
