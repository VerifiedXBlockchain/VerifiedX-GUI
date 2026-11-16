import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_dry_run_banner.dart';
import '../components/p2p_listing_card.dart';
import '../components/p2p_parts.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_browse_providers.dart';
import '../utils/p2p_view.dart';

/// One shop, addressed by its URL: its header, its collections as filter
/// chips and its public listings as a grid.
class P2pShopScreen extends BaseStatefulScreen {
  final String url;

  const P2pShopScreen({super.key, @PathParam('url') required this.url}) : super(horizontalPadding: 16, verticalPadding: 12);

  @override
  BaseScreenState<P2pShopScreen> createState() => _P2pShopScreenState();
}

class _P2pShopScreenState extends BaseScreenState<P2pShopScreen> {
  /// The collection the grid is filtered to; null for all of them.
  int? _collectionId;
  int _page = 1;

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
    final listingsProvider = p2pShopListingsProvider(shop.url, collectionId: _collectionId, page: _page);
    final listings = ref.watch(listingsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShopHeader(shop: shop, own: shop.isOwnedBy(viewer)),
              const SizedBox(height: 12),
              const P2pDryRunBanner(),
              if (collections.length > 1) ...[
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
                        selected: _collectionId == null,
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
                          selected: _collectionId == collection.id,
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
              SliverGrid(
                key: const Key('p2p:listing_grid'),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  // The square picture, then the name, price and clock.
                  childAspectRatio: 0.66,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => P2pListingCard(listing: page.results[index]),
                  childCount: page.results.length,
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

class _ShopHeader extends StatelessWidget {
  final P2pShop shop;
  final bool own;

  const _ShopHeader({required this.shop, required this.own});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final registeredAt = shop.registeredAt;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      key: const Key('p2p:shop_header'),
      padding: const EdgeInsets.all(16),
      decoration: p2pCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          P2pShopAvatar(name: shop.name, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(shop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    if (own) P2pTag(label: l10n.p2pShopYours, color: p2pBrand()),
                    if (shop.chainState == P2pShopChainState.dryRun)
                      P2pTag(label: l10n.p2pDryRunBadge, color: AppColors.gold[50]!)
                    else if (shop.chainState == P2pShopChainState.registered)
                      P2pTag(label: l10n.p2pShopRegistered, color: AppColors.getSpringGreen(ColorShade.s50), icon: Icons.verified_outlined),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        shop.displayUrl,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p2pBrand(), fontFamily: 'RobotoMono', fontSize: 13.5),
                      ),
                    ),
                    P2pCopyButton(value: shop.displayUrl, tooltip: l10n.p2pCopyShopAddress),
                  ],
                ),
                if (shop.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(shop.description, style: const TextStyle(color: Colors.white70, height: 1.35)),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 18,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${l10n.p2pShopOwner} ", style: const TextStyle(color: p2pMuted, fontSize: 12.5)),
                        Text(
                          shortP2pAddress(shop.ownerAddress),
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontFamily: 'RobotoMono'),
                        ),
                        P2pCopyButton(value: shop.ownerAddress, tooltip: l10n.p2pCopyOwnerAddress),
                      ],
                    ),
                    Text(
                      "${l10n.p2pShopLiveListings} ${shop.liveListingCount}",
                      style: const TextStyle(color: p2pMuted, fontSize: 12.5),
                    ),
                    if (registeredAt != null)
                      Text(
                        l10n.p2pShopRegisteredOn(DateFormat.yMMMd(locale).format(registeredAt.toLocal())),
                        style: const TextStyle(color: p2pMuted, fontSize: 12.5),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
