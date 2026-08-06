import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/big_button.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/components/back_to_home_button.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_screen.dart';
import '../../../core/web_router.gr.dart';
import '../../../utils/guards.dart';
import '../../nft/providers/nft_detail_provider.dart';
import '../providers/create_smart_contract_provider.dart';

class SmartContractsScreen extends BaseScreen {
  const SmartContractsScreen({Key? key})
      : super(
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).scTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      // leading: BackToHomeButton(),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Image.asset(
        //   Assets.images.gridBg.path,
        //   width: double.infinity,
        //   height: double.infinity,
        //   fit: BoxFit.cover,
        // ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black38,
            border: Border(
                // top: BorderSide(color: Colors.white30, width: 2),
                // bottom: BorderSide(color: Colors.white30, width: 2),
                ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // BigButton(
                //   title: "Templated Smart Contract",
                //   iconData: FontAwesomeIcons.magic,
                //   body: "Start with a predefined smart contract template",
                //   onPressed: () {
                //     AutoRouter.of(context).push(TemplateChooserScreenRoute());
                //   },
                // ),
                BigButton(
                  title: AppLocalizations.of(context).scCreateAndMintTitle,
                  iconData: Icons.receipt_long,
                  body: AppLocalizations.of(context).scCreateAndMintBody,
                  onPressed: () async {
                    if (!kDebugMode) {
                      if (!widgetGuardWalletIsSynced(ref)) {
                        return;
                      }
                    }

                    if (ref.read(sessionProvider).btcSelected) {
                      Toast.error(AppLocalizations.of(context).scChooseVfxToast);
                      return;
                    }

                    if (ref.read(sessionProvider).currentWallet?.isReserved == true) {
                      Toast.error(AppLocalizations.of(context).scVaultCannotMintToast);
                      return;
                    }

                    ref.read(createSmartContractProvider.notifier).clearSmartContract();
                    final id = await AutoRouter.of(context).push(const SmartContractCreatorContainerScreenRoute());

                    if (id != null) {
                      ref.read(nftDetailProvider("$id").notifier).init();
                      ref.read(createSmartContractProvider.notifier).clearSmartContract();

                      // AutoRouter.of(context).push(NftDetailScreenRoute(id: "$id"));
                    }
                  },
                ),
                // if (kDebugMode)
                BigButton(
                  title: AppLocalizations.of(context).scMintCollectionTitle,
                  iconData: Icons.auto_awesome,
                  body: AppLocalizations.of(context).scMintCollectionBody,
                  onPressed: () {
                    AutoRouter.of(context).push(const BulkCreateScreenRoute());
                  },
                ),
                BigButton(
                  title: AppLocalizations.of(context).scLaunchIdeTitle,
                  iconData: Icons.code,
                  body: AppLocalizations.of(context).scLaunchIdeBody,
                  onPressed: () {
                    launchUrl(Uri.parse("https://trillium.rbx.network/"));
                  },
                ),
                // BigButton(
                //   title: "My Smart Contracts",
                //   iconData: Icons.folder,
                //   body:
                //       "View existing smart contracts that you have compiled or continue where you left off with a saved draft",
                //   onPressed: () {
                //     AutoRouter.of(context).push(MySmartContractsScreenRoute());
                //   },
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
