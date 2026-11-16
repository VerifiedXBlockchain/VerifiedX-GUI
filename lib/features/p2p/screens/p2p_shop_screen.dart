import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_dry_run_banner.dart';

/// One shop, addressed by its URL: its collections and listings.
class P2pShopScreen extends BaseScreen {
  final String url;

  const P2pShopScreen({super.key, @PathParam('url') required this.url});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        onPressed: () => AutoRouter.of(context).pop(),
        icon: const Icon(Icons.chevron_left),
        tooltip: AppLocalizations.of(context).actionBack,
      ),
      title: Text("vfx://$url"),
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
