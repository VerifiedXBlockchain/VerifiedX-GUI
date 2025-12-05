import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/core/app_router.gr.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/core/services/butterfly_bridge_url_service.dart';
import 'package:rbx_wallet/core/services/password_prompt_service.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/features/global_loader/global_loading_provider.dart';
import 'package:rbx_wallet/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../app.dart';
import '../../../core/base_component.dart';
import '../../../core/components/open_explorer_modal.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../../utils/validation.dart';
import '../../btc/providers/tokenized_bitcoin_list_provider.dart';
import '../../faucet/screens/faucet_screen.dart';
import '../../misc/providers/global_balances_expanded_provider.dart';
import '../../navigation/utils.dart';
import '../../nft/providers/nft_list_provider.dart';
import '../../nft/services/nft_service.dart';
import '../../token/providers/token_list_provider.dart';
import '../../wallet/utils.dart';

import '../../../core/theme/pretty_icons.dart';
import 'home_buttons/verify_nft_ownership_button.dart';

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
                label: "TXs",
                icon: Icons.history,
                prettyIconType: PrettyIconType.transactions,
                onPressed: () {
                  RootContainerUtils.navigateToTab(
                      context, RootTab.transactions);
                },
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
              // AppVerticalIconButton(
              //   label: "Faucet",
              //   icon: FontAwesomeIcons.faucet,
              //   prettyIconType: PrettyIconType.custom,
              //   onPressed: () {
              //     Navigator.of(rootNavigatorKey.currentContext!).push(MaterialPageRoute(
              //       builder: (context) => FaucetScreen(),
              //     ));
              //   },
              // ),
              AppVerticalIconButton(
                label: "Tutorials",
                prettyIconType: PrettyIconType.custom,
                icon: FontAwesomeIcons.video,
                iconScale: 0.7,
                onPressed: () async {
                  launchUrlString(
                      "https://docs.verifiedx.io/docs/tutorials/video-tutorials/");
                },
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                label: "Verify\nOwner",
                prettyIconType: PrettyIconType.validator,
                icon: Icons.check,
                onPressed: () async {
                  final sig = await PromptModal.show(
                    title: "Validate Ownership",
                    body:
                        "Paste in the signature provided by the owner to validate its ownership.",
                    validator: (val) => formValidatorNotEmpty(val, "Signature"),
                    labelText: "Signature",
                  );

                  if (sig != null && sig.isNotEmpty) {
                    final components = sig.split("<>");
                    if (components.length != 4) {
                      Toast.error("Invalid ownership verification signature");
                      return;
                    }

                    final address = components.first;
                    final scId = components.last;

                    final verified = await NftService().verifyOwnership(sig);

                    if (verified == null) {
                      return;
                    }
                    final color = verified
                        ? Theme.of(context).colorScheme.success
                        : Theme.of(context).colorScheme.danger;
                    final iconData = verified ? Icons.check : Icons.close;
                    final title = verified ? "Verified" : "Not Verified";
                    final subtitle = verified
                        ? "Ownership Verified"
                        : "Ownership NOT Verified";
                    final body = verified
                        ? "$address\nOWNS\n$scId"
                        : "$address\ndoes NOT own\n$scId";

                    InfoDialog.show(
                      title: title,
                      content: NftVerificationSuccessDialog(
                          iconData: iconData,
                          color: color,
                          subtitle: subtitle,
                          body: body),
                    );
                  }
                },
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
              if (BUTTERFLY_ENABLED)
                AppVerticalIconButton(
                  label: "Login to\nButterfly",
                  prettyIconType: PrettyIconType.butterfly,
                  icon: FontAwesomeIcons.wallet,
                  iconScale: 0.7,
                  onPressed: () async {
                    // Get wallet keys based on platform
                    String? privateKey;
                    String? publicKey;
                    String? address;

                    if (kIsWeb) {
                      final keypair = ref.read(webSessionProvider).keypair;
                      if (keypair == null) {
                        Toast.error(
                            "No wallet selected. Please create or import a wallet first.");
                        return;
                      }
                      privateKey = keypair.privateCorrected;
                      publicKey = keypair.public;
                      address = keypair.address;
                    } else {
                      final wallet = ref.read(sessionProvider).currentWallet;
                      if (wallet == null) {
                        Toast.error("No Account Selected");
                        return;
                      }
                      if (wallet.privateKey == null) {
                        Toast.error("Private key not available.");
                        return;
                      }
                      privateKey = wallet.privateKey!;
                      publicKey = wallet.publicKey;
                      address = wallet.address;
                    }

                    // Prompt for password
                    final password =
                        await PasswordPromptService.promptNewPassword(
                      rootNavigatorKey.currentContext!,
                      title: "Create Butterfly Password",
                      customMessage:
                          "Create a password to securely transfer your credentials to Butterfly. You will need to enter this same password on the Butterfly website.",
                    );

                    if (password == null) return;

                    // Confirmation dialog
                    final confirmed = await ConfirmDialog.show(
                      title: "Login to Butterfly",
                      body:
                          "You are about to open Butterfly and log in with:\n\n$address\n\nContinue?",
                      confirmText: "Open Butterfly",
                      cancelText: "Cancel",
                    );

                    if (confirmed != true) return;

                    // Generate encrypted URL and launch
                    try {
                      ref.read(globalLoadingProvider.notifier).start();
                      await Future.delayed(Duration(milliseconds: 250));
                      final url = ButterflyBridgeUrlService.createBridgeUrl(
                        privateKey: privateKey,
                        password: password,
                        address: address,
                        publicKey: publicKey,
                        targetBaseUrl: Env.butterflyWebBaseUrl,
                      );
                      ref.read(globalLoadingProvider.notifier).complete();
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      ref.read(globalLoadingProvider.notifier).complete();
                      Toast.error("Failed to generate login URL: $e");
                    }
                  },
                  color: AppColors.getWhite(ColorShade.s200),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
