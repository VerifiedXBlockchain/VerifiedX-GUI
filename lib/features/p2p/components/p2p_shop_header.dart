import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/p2p_shop.dart';
import '../utils/p2p_view.dart';
import 'p2p_parts.dart';

/// A shop's name, vfx:// address, description, owner and registration
/// state, with room for the actions of whoever is looking.
class P2pShopHeader extends StatelessWidget {
  final P2pShop shop;

  /// Whether the selected account owns the shop.
  final bool own;

  /// Buttons shown under the shop's details.
  final List<Widget> actions;

  const P2pShopHeader({super.key, required this.shop, required this.own, this.actions = const []});

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
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: actions),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
