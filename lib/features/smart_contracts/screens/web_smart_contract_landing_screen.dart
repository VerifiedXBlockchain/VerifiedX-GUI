import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_wallet_type_switcher.dart';
import '../../../utils/toast.dart';
import '../../../core/components/big_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/base_screen.dart';
import '../../../core/breakpoints.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/web_router.gr.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../web/components/web_no_wallet.dart';

class WebSmartContractLandingScreen extends BaseScreen {
  const WebSmartContractLandingScreen({Key? key})
      : super(
          key: key,
          includeWebDrawer: true,
          // backgroundColor: Colors.black87,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);

    return AppBar(
      leading: isMobile ? WebMobileDrawerButton() : null,
      title: Text(AppLocalizations.of(context).scwCreateSmartContractTitle),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final keypair = ref.read(webSessionProvider).keypair;

    if (keypair == null) {
      return const WebNotWallet();
    }

    final isMobile = BreakPoints.useMobileLayout(context);
    final l10n = AppLocalizations.of(context);

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
            color: Colors.black,
            border: Border(
                // top: BorderSide(color: Colors.white30, width: 2),
                // bottom: BorderSide(color: Colors.white30, width: 2),
                ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  BigButton(
                    title: l10n.scwCreateAndMintTitle,
                    iconData: Icons.create,
                    body: l10n.scwCreateAndMintBody,
                    onPressed: () {
                      AutoRouter.of(context).push(const WebCreateSmartContractScreenRoute());
                    },
                  ),
                  BigButton(
                    title: l10n.scwMintNftCollectionTitle,
                    iconData: Icons.auto_awesome,
                    body: l10n.scwMintNftCollectionBody,
                    onPressed: () {
                      AutoRouter.of(context).push(const WebBulkCreateScreenRoute());

                      // AutoRouter.of(context).push(WebSmartContractWizardScreenRoute());
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(builder: (context) => const SmartContractWizardScreen()),
                      // );
                    },
                  ),
                  BigButton(
                    title: l10n.scwLaunchIdeTitle,
                    iconData: Icons.code,
                    body: l10n.scwLaunchIdeBody,
                    onPressed: () async {
                      if (isMobile) {
                        final confirmed = await ConfirmDialog.show(
                            title: l10n.scwLaunchIdeMobileTitle,
                            body: l10n.scwLaunchIdeMobileBody,
                            confirmText: l10n.scwLaunchIdeTitle);
                        if (confirmed != true) {
                          return;
                        }
                      }

                      launchUrl(Uri.parse("https://trillium.rbx.network/"));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
