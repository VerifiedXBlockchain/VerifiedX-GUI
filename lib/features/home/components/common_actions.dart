import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/app_router.gr.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/global_loader/global_loading_provider.dart';
import 'package:rbx_wallet/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app.dart';
import '../../../core/base_component.dart';
import '../../../core/components/open_explorer_modal.dart';
import '../../../core/env.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../btc/providers/tokenized_bitcoin_list_provider.dart';
import '../../faucet/screens/faucet_screen.dart';
import '../../misc/providers/global_balances_expanded_provider.dart';
import '../../navigation/utils.dart';
import '../../nft/providers/nft_list_provider.dart';
import '../../token/providers/token_list_provider.dart';
import '../../wallet/utils.dart';

import '../../../core/theme/pretty_icons.dart';

class CommonActions extends BaseComponent {
  const CommonActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: 6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // AppVerticalIconButton(
              //   label: "Add\nAddress",
              //   prettyIconType: PrettyIconType.custom,
              //   icon: Icons.add,
              //   onPressed: () async {
              //     await AccountUtils.promptVfxOrBtc(rootNavigatorKey.currentContext!, ref);
              //   },
              //   color: AppColors.getWhite(ColorShade.s200),
              // ),
              // AppVerticalIconButton(
              //   label: "Add\nVault",
              //   icon: Icons.security,
              //   prettyIconType: PrettyIconType.lock,
              //   onPressed: () {
              //     RootContainerUtils.navigateToTab(context, RootTab.reserve);
              //   },
              //   color: AppColors.getWhite(ColorShade.s200),
              // ),
              // AppVerticalIconButton(
              //   label: "Add\nDomain",
              //   icon: Icons.link,
              //   prettyIconType: PrettyIconType.domain,
              //   onPressed: () {
              //     RootContainerUtils.navigateToTab(context, RootTab.adnr);
              //   },
              //   color: AppColors.getWhite(ColorShade.s200),
              // ),
              AppVerticalIconButton(
                label: "Send\nCoin",
                prettyIconType: PrettyIconType.send,
                icon: Icons.arrow_upward,
                onPressed: () {
                  RootContainerUtils.navigateToTab(context, RootTab.send);
                },
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                label: "Receive\nCoin",
                icon: Icons.arrow_downward,
                prettyIconType: PrettyIconType.receive,
                onPressed: () {
                  RootContainerUtils.navigateToTab(context, RootTab.receive);
                },
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                label: "Transfer",
                icon: Icons.history,
                prettyIconType: PrettyIconType.transactions,
                onPressed: () {},
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                label: "Tokens",
                prettyIconType: PrettyIconType.fungibleToken,
                icon: Icons.toll,
                onPressed: () async {
                  if (ref.read(sessionProvider).currentWallet == null) {
                    Toast.error("No Account Selected");
                    return;
                  }

                  ref.read(globalLoadingProvider.notifier).start();
                  await ref.read(tokenizedBitcoinListProvider.notifier).load();
                  await ref.read(tokenListProvider.notifier).load(1);
                  await ref.read(nftListProvider.notifier).load(1);

                  ref.read(globalLoadingProvider.notifier).complete();
                  ref.read(globalBalancesExpandedProvider.notifier).detract();
                  AutoRouter.of(context).push(AllTokensScreenRoute());
                },
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                label: "Faucet",
                icon: FontAwesomeIcons.faucet,
                prettyIconType: PrettyIconType.custom,
                onPressed: () {
                  Navigator.of(rootNavigatorKey.currentContext!).push(MaterialPageRoute(
                    builder: (context) => FaucetScreen(),
                  ));
                },
              ),
              AppVerticalIconButton(
                label: "Tutorials",
                prettyIconType: PrettyIconType.custom,
                icon: FontAwesomeIcons.video,
                iconScale: 0.7,
                onPressed: () async {},
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                label: "Open\nExplorer",
                icon: Icons.open_in_browser,
                prettyIconType: PrettyIconType.custom,
                onPressed: () {
                  showModalBottomSheet(
                    context: rootNavigatorKey.currentContext!,
                    backgroundColor: Colors.black,
                    builder: (context) => OpenExplorerModal(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
