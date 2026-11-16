import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_dry_run_banner.dart';
import '../components/p2p_parts.dart';
import '../components/p2p_shop_card.dart';
import '../providers/p2p_browse_providers.dart';

/// Shops in the P2P registry: browse and search.
class P2pShopListScreen extends BaseStatefulScreen {
  const P2pShopListScreen({super.key}) : super(horizontalPadding: 16, verticalPadding: 12);

  @override
  BaseScreenState<P2pShopListScreen> createState() => _P2pShopListScreenState();
}

class _P2pShopListScreenState extends BaseScreenState<P2pShopListScreen> {
  static const Duration _typingPause = Duration(milliseconds: 350);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  /// The search the list is loaded for: what was typed, once typing paused.
  String _search = '';
  int _page = 1;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onTyped(String value) {
    // The clear button follows the field at once; the list waits for a pause.
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(_typingPause, () => _applySearch(value));
  }

  void _applySearch(String value) {
    final search = value.trim();
    if (!mounted || search == _search) {
      return;
    }
    setState(() {
      _search = search;
      _page = 1;
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _applySearch('');
    setState(() {});
  }

  @override
  AppBar? appBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.p2pShopsTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        AppButton(
          key: const Key('p2p:my_bids'),
          label: l10n.p2pMyBidsTitle,
          icon: Icons.gavel,
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          onPressed: () => AutoRouter.of(context).push(const P2pMyBidsScreenRoute()),
        ),
        IconButton(
          key: const Key('p2p:shops_refresh'),
          tooltip: l10n.actionRefresh,
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(p2pShopListProvider),
        ),
        const WalletSelector(includeBtc: false, withOptions: false),
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const P2pDryRunBanner(),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Semantics(
              label: l10n.p2pSearchLabel,
              textField: true,
              child: TextField(
                key: const Key('p2p:shop_search'),
                controller: _searchController,
                onChanged: _onTyped,
                onSubmitted: (value) {
                  _debounce?.cancel();
                  _applySearch(value);
                },
                textInputAction: TextInputAction.search,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: l10n.p2pSearchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          key: const Key('p2p:shop_search_clear'),
                          tooltip: l10n.p2pClearSearch,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _clearSearch,
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: p2pSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: p2pBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: p2pBorder),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _shops(context)),
      ],
    );
  }

  Widget _shops(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = p2pShopListProvider(search: _search, page: _page);
    final shops = ref.watch(provider);
    final viewer = ref.watch(p2pViewerAddressProvider);

    return shops.when(
      loading: () => const CenteredLoader(),
      error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(provider)),
      data: (page) {
        if (page.results.isEmpty) {
          return _search.isEmpty
              ? P2pEmptyState(icon: Icons.storefront_outlined, title: l10n.p2pShopsEmpty, body: l10n.p2pShopsEmptyBody)
              : P2pEmptyState(icon: Icons.search_off, title: l10n.p2pShopsEmptySearch(_search), body: l10n.p2pShopsEmptySearchBody);
        }
        return CustomScrollView(
          key: const Key('p2p:shop_grid'),
          slivers: [
            SliverLayoutBuilder(
              builder: (context, constraints) => SliverGrid(
                gridDelegate: p2pCardGridDelegate(constraints, maxCardWidth: 420, cardHeight: P2pShopCard.heightFor),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shop = page.results[index];
                    return P2pShopCard(shop: shop, own: shop.isOwnedBy(viewer));
                  },
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
          ],
        );
      },
    );
  }
}
