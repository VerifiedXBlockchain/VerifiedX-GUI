import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_dry_run_banner.dart';
import '../components/p2p_listing_card.dart';
import '../components/p2p_parts.dart';
import '../components/p2p_shop_header.dart';
import '../models/p2p_collection.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_browse_providers.dart';

/// One shop, addressed by its URL: its header, its collections as filter
/// chips and its public listings as a grid.
class P2pShopScreen extends BaseStatefulScreen {
  final String url;

  const P2pShopScreen({super.key, @PathParam('url') required this.url}) : super(horizontalPadding: 16, verticalPadding: 12);

  @override
  BaseScreenState<P2pShopScreen> createState() => _P2pShopScreenState();
}

class _P2pShopScreenState extends BaseScreenState<P2pShopScreen> {
  /// The collection the person picked to filter the grid by; null for all
  /// of them. Read through [_selectedIn]: the shop may hide it meanwhile.
  int? _collectionId;
  int _page = 1;

  /// The picked collection, while it is still one of the shop's [live]
  /// ones. Once the seller hides or deletes it the filter is off, so the
  /// grid never asks for a collection the visitor has no chip to leave.
  int? _selectedIn(List<P2pCollection> live) {
    return live.any((c) => c.id == _collectionId) ? _collectionId : null;
  }

  void _reload() {
    ref.invalidate(p2pShopProvider(widget.url));
    ref.invalidate(p2pShopListingsProvider);
  }

  @override
  AppBar? appBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shop = ref.watch(p2pShopProvider(widget.url)).valueOrNull;
    return AppBar(
      leading: IconButton(
        onPressed: () => AutoRouter.of(context).pop(),
        icon: const Icon(Icons.chevron_left),
        tooltip: l10n.actionBack,
      ),
      title: Text(shop?.name ?? "vfx://${widget.url}"),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        IconButton(
          key: const Key('p2p:shop_refresh'),
          tooltip: l10n.actionRefresh,
          icon: const Icon(Icons.refresh),
          onPressed: _reload,
        ),
        const WalletSelector(includeBtc: false, withOptions: false),
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shop = ref.watch(p2pShopProvider(widget.url));

    return shop.when(
      loading: () => const CenteredLoader(),
      error: (error, _) => P2pErrorView(error: error, onRetry: _reload),
      data: (shop) {
        if (shop == null) {
          return P2pEmptyState(icon: Icons.storefront_outlined, title: l10n.p2pShopNotFound, body: l10n.p2pShopNotFoundBody);
        }
        return _shop(context, shop);
      },
    );
  }

  Widget _shop(BuildContext context, P2pShop shop) {
    final l10n = AppLocalizations.of(context);
    final viewer = ref.watch(p2pViewerAddressProvider);
    final collections = shop.liveCollections;
    final selected = _selectedIn(collections);
    final listingsProvider = p2pShopListingsProvider(shop.url, collectionId: selected, page: _page);
    final listings = ref.watch(listingsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              P2pShopHeader(shop: shop, own: shop.isOwnedBy(viewer)),
              const SizedBox(height: 12),
              const P2pDryRunBanner(),
              // The chips stay while a filter is on, so it can be cleared.
              if (collections.length > 1 || selected != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  label: l10n.p2pShopCollections,
                  container: true,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CollectionChip(
                        key: const Key('p2p:collection:all'),
                        label: l10n.p2pShopAll,
                        count: collections.fold<int>(0, (sum, c) => sum + c.listingCount),
                        selected: selected == null,
                        onSelected: () => setState(() {
                          _collectionId = null;
                          _page = 1;
                        }),
                      ),
                      for (final collection in collections)
                        _CollectionChip(
                          key: Key('p2p:collection:${collection.id}'),
                          label: collection.name,
                          count: collection.listingCount,
                          selected: selected == collection.id,
                          onSelected: () => setState(() {
                            _collectionId = collection.id;
                            _page = 1;
                          }),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
            ],
          ),
        ),
        ...listings.when(
          loading: () => const [SliverFillRemaining(hasScrollBody: false, child: CenteredLoader())],
          error: (error, _) => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: P2pErrorView(error: error, onRetry: () => ref.invalidate(listingsProvider)),
            ),
          ],
          data: (page) {
            if (page.results.isEmpty) {
              return [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: P2pEmptyState(icon: Icons.inventory_2_outlined, title: l10n.p2pShopNoListings, body: l10n.p2pShopNoListingsBody),
                ),
              ];
            }
            return [
              SliverLayoutBuilder(
                builder: (context, constraints) => SliverGrid(
                  key: const Key('p2p:listing_grid'),
                  gridDelegate: p2pCardGridDelegate(constraints, maxCardWidth: 260, cardHeight: P2pListingCard.heightFor),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => P2pListingCard(listing: page.results[index]),
                    childCount: page.results.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: P2pPager(
                  page: _page,
                  hasNext: page.hasNext,
                  onPage: (next) => setState(() => _page = next),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}

class _CollectionChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _CollectionChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? p2pBrand() : Colors.white70;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? p2pBrand().withOpacity(0.12) : p2pSurface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: selected ? p2pBrand() : p2pBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 6),
              Text("$count", style: TextStyle(color: color.withOpacity(0.7), fontSize: 12, fontFamily: 'RobotoMono')),
            ],
          ),
        ),
      ),
    );
  }
}
