import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../components/p2p_dry_run_banner.dart';

/// Shops in the P2P registry: browse and search.
class P2pShopListScreen extends BaseScreen {
  const P2pShopListScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).p2pShopsTitle),
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
