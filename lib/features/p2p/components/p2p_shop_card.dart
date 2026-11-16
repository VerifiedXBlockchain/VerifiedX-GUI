import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_browse_providers.dart';
import '../utils/p2p_view.dart';
import 'p2p_parts.dart';

/// A shop on the shop list: a strip of what it sells, its name and vfx://
/// address, its owner and how many listings are live. Opens the shop.
class P2pShopCard extends ConsumerStatefulWidget {
  static const int stripLength = 4;

  /// The height of the text under the strip of pictures.
  static const double textHeight = 184;

  /// A card's height at [width]: the strip of square pictures, then the
  /// text, inside the card's 1px border.
  static double heightFor(double width) => (width - 2) / stripLength + textHeight + 2;

  final P2pShop shop;

  /// Whether the selected account owns the shop.
  final bool own;

  const P2pShopCard({super.key, required this.shop, required this.own});

  @override
  ConsumerState<P2pShopCard> createState() => _P2pShopCardState();
}

class _P2pShopCardState extends ConsumerState<P2pShopCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shop = widget.shop;
    final preview = ref.watch(p2pShopListingsProvider(shop.url, limit: P2pShopCard.stripLength));
    final thumbs = preview.valueOrNull?.results.take(P2pShopCard.stripLength).toList() ?? const [];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: Key('p2p:shop_card:${shop.url}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => AutoRouter.of(context).push(P2pShopScreenRoute(url: shop.url)),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: p2pCardDecoration(hovered: _hovered),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExcludeSemantics(
                  child: Row(
                    children: [
                      for (var i = 0; i < P2pShopCard.stripLength; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: i == 0 ? 0 : 1),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: i < thumbs.length ? P2pListingThumb(listing: thumbs[i]) : Container(color: p2pSurfaceRaised),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: P2pShopCard.textHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            P2pShopAvatar(name: shop.name, size: 40),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    shop.displayUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: p2pBrand(), fontSize: 12.5, fontFamily: 'RobotoMono'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            P2pTag(
                              label: l10n.p2pShopLiveCount(shop.liveListingCount),
                              color: AppColors.getSpringGreen(ColorShade.s50),
                            ),
                          ],
                        ),
                        if (shop.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            shop.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                          ),
                        ],
                        const Spacer(),
                        const Divider(height: 16, color: p2pBorder),
                        Row(
                          children: [
                            Text("${l10n.p2pShopOwner} ", style: const TextStyle(color: p2pMuted, fontSize: 12)),
                            Flexible(
                              child: Text(
                                shortP2pAddress(shop.ownerAddress),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'RobotoMono'),
                              ),
                            ),
                            const Spacer(),
                            if (widget.own) P2pTag(label: l10n.p2pShopYours, color: p2pBrand()),
                            if (shop.isDryRun) ...[
                              const SizedBox(width: 6),
                              P2pTag(label: l10n.p2pDryRunBadge, color: AppColors.gold[50]!),
                            ],
                          ],
                        ),
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
