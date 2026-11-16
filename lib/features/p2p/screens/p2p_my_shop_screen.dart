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
import '../chain/p2p_tx_builders.dart';
import '../components/p2p_chain_step_dialog.dart';
import '../components/p2p_dry_run_banner.dart';
import '../components/p2p_parts.dart';
import '../components/p2p_shop_form.dart';
import '../components/p2p_shop_header.dart';
import '../models/p2p_shop.dart';
import '../providers/p2p_browse_providers.dart';
import '../providers/p2p_listing_providers.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_rules.dart';

/// The selected account's own shop. Without one: the form that opens it.
/// With one: its header, with edit and delete. Opening, changing and
/// deleting a shop are transactions on chain (DSTR), so each goes through the
/// chain-step confirmation: a dry run while the shop's steps are dry runs.
class P2pMyShopScreen extends BaseScreen {
  const P2pMyShopScreen({super.key}) : super(horizontalPadding: 16, verticalPadding: 12);

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
      title: Text(l10n.p2pMyShopTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        if (address != null)
          IconButton(
            key: const Key('p2p:my_shop_refresh'),
            tooltip: l10n.actionRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshP2pOwner(ref, address),
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
      return P2pEmptyState(icon: Icons.account_circle_outlined, title: l10n.p2pMyShopNoAccount);
    }
    if (isP2pReserveAddress(address)) {
      return P2pEmptyState(icon: Icons.lock_outline, title: l10n.p2pMyShopVault);
    }
    final provider = p2pOwnerShopProvider(address);
    final shop = ref.watch(provider);

    return shop.when(
      loading: () => const CenteredLoader(),
      error: (error, _) => P2pErrorView(error: error, onRetry: () => ref.invalidate(provider)),
      data: (shop) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const P2pDryRunBanner(),
            const SizedBox(height: 12),
            if (shop == null)
              // A new form for each account: what was typed for one is not
              // carried to the next.
              _RegisterShop(key: ValueKey(address), owner: address)
            else
              _OwnShop(key: ValueKey(shop.id), shop: shop, address: address),
          ],
        ),
      ),
    );
  }
}

/// Reads [address]'s shop again, and everything shown from it.
void refreshP2pOwner(WidgetRef ref, String address) {
  ref.invalidate(p2pOwnerShopProvider(address));
  ref.invalidate(p2pShopListProvider);
  ref.invalidate(p2pShopProvider);
}

class _RegisterShop extends ConsumerWidget {
  final String owner;

  const _RegisterShop({super.key, required this.owner});

  Future<void> _review(WidgetRef ref, AppLocalizations l10n, P2pShopValues values) async {
    final steps = ref.read(p2pChainStepsProvider);
    await P2pChainStepDialog.show(
      title: l10n.p2pShopRegisterTitle,
      rows: [
        P2pStepRow(l10n.p2pChainRowShop, values.name.trim()),
        P2pStepRow(l10n.p2pChainRowAddress, "vfx://${normalizeP2pShopUrl(values.url)}", mono: true),
      ],
      describe: () => steps.describeRegisterShop(owner, values),
      carryOut: (tx) async {
        await steps.sendShopStep(tx);
        refreshP2pOwner(ref, owner);
      },
      doneBody: values.name.trim(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final balance = ref.watch(p2pViewerBalanceProvider);
    final cost = P2pAmount.parse(p2pShopCreateCost);
    final short = balance != null && balance.isFinite && balance >= 0 && P2pAmount.fromDouble(balance) < cost;
    final dryRun = ref.watch(p2pChainStepsProvider).isDryRun;

    final form = Container(
      key: const Key('p2p:register_shop'),
      padding: const EdgeInsets.all(18),
      decoration: p2pCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.p2pShopRegisterTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l10n.p2pShopRegisterIntro, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          const SizedBox(height: 14),
          P2pShopForm(
            initial: const P2pShopValues(name: '', url: '', description: ''),
            note: short
                ? Text(
                    l10n.p2pShopRegisterShort(p2pVfxText(l10n, P2pAmount.fromDouble(balance).toDecimalString()), p2pVfxText(l10n, p2pShopCreateCost)),
                    key: const Key('p2p:register_short'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  )
                : null,
            onSubmit: (values) => _review(ref, l10n, values),
          ),
        ],
      ),
    );

    final costs = Container(
      key: const Key('p2p:register_cost'),
      padding: const EdgeInsets.all(18),
      decoration: p2pCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          P2pPrice(label: l10n.p2pShopRegisterCostLabel, amount: p2pShopCreateCost, large: true),
          const SizedBox(height: 10),
          for (final line in [
            l10n.p2pShopCostOnce,
            l10n.p2pShopCostUpdate(p2pVfxText(l10n, p2pShopUpdateCost)),
            l10n.p2pShopCostDelete(p2pVfxText(l10n, p2pShopDeleteCost)),
            l10n.p2pShopCostListing,
            if (dryRun) l10n.p2pShopCostDryRun,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("•  ", style: TextStyle(color: p2pMuted)),
                  Expanded(child: Text(line, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3))),
                ],
              ),
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 820) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [form, const SizedBox(height: 14), costs]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: form),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: costs),
          ],
        );
      },
    );
  }
}

class _OwnShop extends ConsumerWidget {
  final P2pShop shop;
  final String address;

  const _OwnShop({super.key, required this.shop, required this.address});

  Future<void> _edit(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final values = await showDialog<P2pShopValues>(
      context: context,
      builder: (_) => _EditShopDialog(shop: shop),
    );
    if (values == null) {
      return;
    }
    final steps = ref.read(p2pChainStepsProvider);
    await P2pChainStepDialog.show(
      title: l10n.p2pShopUpdateTitle,
      rows: [
        P2pStepRow(l10n.p2pChainRowShop, values.name.trim()),
        P2pStepRow(l10n.p2pChainRowAddress, "vfx://${normalizeP2pShopUrl(values.url)}", mono: true),
      ],
      describe: () => steps.describeUpdateShop(shop, values),
      carryOut: (tx) async {
        await steps.sendShopStep(tx);
        refreshP2pOwner(ref, address);
      },
      doneBody: values.name.trim(),
    );
  }

  Future<void> _delete(WidgetRef ref, AppLocalizations l10n) async {
    final steps = ref.read(p2pChainStepsProvider);
    final warning = [
      l10n.p2pShopDeleteWarning(p2pVfxText(l10n, p2pShopDeleteCost)),
      if (shop.liveListingCount > 0) l10n.p2pShopDeleteActive,
    ].join(' ');
    await P2pChainStepDialog.show(
      title: l10n.p2pShopDeleteTitle,
      rows: [
        P2pStepRow(l10n.p2pChainRowShop, shop.name),
        P2pStepRow(l10n.p2pChainRowAddress, shop.displayUrl, mono: true),
      ],
      warning: warning,
      describe: () => steps.describeDeleteShop(shop),
      carryOut: (tx) async {
        await steps.sendShopStep(tx);
        refreshP2pOwner(ref, address);
      },
      doneBody: shop.name,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        P2pShopHeader(
          shop: shop,
          own: true,
          actions: [
            AppButton(
              key: const Key('p2p:my_shop_view'),
              label: l10n.p2pMyShopView,
              icon: Icons.visibility_outlined,
              type: AppButtonType.Outlined,
              variant: AppColorVariant.Light,
              onPressed: () => AutoRouter.of(context).push(P2pShopScreenRoute(url: shop.url)),
            ),
            AppButton(
              key: const Key('p2p:my_shop_edit'),
              label: l10n.p2pMyShopEdit,
              icon: Icons.edit_outlined,
              type: AppButtonType.Outlined,
              variant: AppColorVariant.Light,
              onPressed: () => _edit(context, ref, l10n),
            ),
            IconButton(
              key: const Key('p2p:my_shop_delete'),
              tooltip: l10n.p2pShopDeleteTitle,
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.danger),
              onPressed: () => _delete(ref, l10n),
            ),
          ],
        ),
      ],
    );
  }
}

/// A shop's name, URL and description, to change. Resolves the new values
/// when Review is pressed with something changed; the transaction itself is
/// confirmed in the chain-step dialog that follows.
class _EditShopDialog extends ConsumerWidget {
  final P2pShop shop;

  const _EditShopDialog({required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cost = p2pShopUpdateAmount(shop, ref.watch(p2pClockProvider)());
    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Text(l10n.p2pShopEditTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: P2pShopForm(
            initial: P2pShopValues(name: shop.name, url: shop.url, description: shop.description),
            currentUrl: shop.url,
            note: Text(
              cost.isPositive ? l10n.p2pShopEditCost(p2pVfxText(l10n, cost.toDecimalString())) : l10n.p2pShopEditFree,
              key: const Key('p2p:shop_edit_cost'),
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
            ),
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: (values) => Navigator.of(context).pop(values),
          ),
        ),
      ),
    );
  }
}
