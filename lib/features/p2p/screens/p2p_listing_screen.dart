import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_dry_run_banner.dart';

/// One listing, addressed by its id: the NFT, its prices, state and bids.
class P2pListingScreen extends BaseScreen {
  final int id;

  const P2pListingScreen({super.key, @PathParam('id') required this.id});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      leading: IconButton(
        onPressed: () => AutoRouter.of(context).pop(),
        icon: const Icon(Icons.chevron_left),
        tooltip: l10n.actionBack,
      ),
      title: Text(l10n.p2pListingTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: const [
        WalletSelector(includeBtc: false, withOptions: false),
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        P2pDryRunBanner(),
      ],
    );
  }
}
