import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/core/services/butterfly_bridge_url_service.dart';
import 'package:rbx_wallet/core/services/password_prompt_service.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/features/global_loader/global_loading_provider.dart';
import 'package:rbx_wallet/features/wallet/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/web_router.gr.dart';
import '../../root/web_dashboard_container.dart';

import '../../../core/base_component.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../utils/toast.dart';
import 'root_container_side_nav_item.dart';

class RootContainerSideNavList extends BaseComponent {
  // final TabsRouter tabsRouter;
  final bool isExpanded;
  final bool inDrawer;

  const RootContainerSideNavList({
    super.key,
    // required this.tabsRouter,
    required this.isExpanded,
    this.inDrawer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsRouter = AutoTabsRouter.of(context);

    return Builder(builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RootContainerSideNavItem(
            title: "Dashboard",
            iconType: PrettyIconType.dashboard,
            onPressed: () {
              if (tabsRouter.activeIndex == 0) {
                tabsRouter
                    .stackRouterOfIndex(tabsRouter.activeIndex)!
                    .popUntilRoot();
              } else {
                tabsRouter.setActiveIndex(0);
              }
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive: tabsRouter.activeIndex == 0,
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Vault Account${kIsWeb ? '' : 's'}",
            iconType: PrettyIconType.lock,
            onPressed: () {
              tabsRouter.setActiveIndex(kIsWeb ? WebRouteIndex.reserve : 14);
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive:
                tabsRouter.activeIndex == (kIsWeb ? WebRouteIndex.reserve : 14),
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Domains",
            iconType: PrettyIconType.domain,
            onPressed: () {
              tabsRouter.setActiveIndex(kIsWeb ? WebRouteIndex.adnrs : 10);
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive:
                tabsRouter.activeIndex == (kIsWeb ? WebRouteIndex.adnrs : 10),
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Send",
            iconType: PrettyIconType.send,
            onPressed: () {
              tabsRouter.setActiveIndex(1);
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive: tabsRouter.activeIndex == 1,
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Receive",
            iconType: PrettyIconType.receive,
            onPressed: () {
              tabsRouter.setActiveIndex(2);
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive: tabsRouter.activeIndex == 2,
            isExpanded: isExpanded,
          ),
          if (BUTTERFLY_ENABLED)
            RootContainerSideNavItem(
              title: "Pay /w Butterfly",
              iconType: PrettyIconType.butterfly,
              onPressed: () async {
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }

                final result = await ButterflyOptionsDialog.show();
                if (result == "visit") {
                  launchUrlString(Env.butterflyWebBaseUrl,
                      mode: LaunchMode.externalApplication);
                } else if (result == "login") {
                  await _handleButterflyLogin(context, ref);
                }
              },
              isActive: false,
              isExpanded: isExpanded,
            ),
          RootContainerSideNavItem(
            title: "Crypto.com",
            isNew: true,
            iconType: PrettyIconType.custom,
            customIconWidget: Image.asset(
              "assets/images/crypto_dot_com_icon.png",
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            onPressed: () {
              AccountUtils.showCryptoDotComOnrampFlow(context, ref);

              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive: tabsRouter.activeIndex == 2,
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Transactions",
            iconType: PrettyIconType.transactions,
            onPressed: () {
              tabsRouter.setActiveIndex(3);
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive: tabsRouter.activeIndex == 3,
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Tokenize BTC",
            iconType: PrettyIconType.bitcoin,
            textColorOverrideIdle: AppColors.getBtc().withOpacity(0.8),
            textColorOverrideHover: AppColors.getBtc().withOpacity(1),
            textColorOverrideActive: AppColors.getBtc().withOpacity(1),
            onPressed: () {
              if (kIsWeb) {
                tabsRouter.setActiveIndex(WebRouteIndex.vbtc);
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
                return;
              }
              tabsRouter.setActiveIndex(15);
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
            },
            isActive:
                tabsRouter.activeIndex == (kIsWeb ? WebRouteIndex.vbtc : 15),
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Fungible Tokens",
            iconType: PrettyIconType.fungibleToken,
            onPressed: () {
              if (kIsWeb) {
                tabsRouter.setActiveIndex(WebRouteIndex.tokens);
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
                return;
              }
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
              if (tabsRouter.activeIndex == 13) {
                tabsRouter
                    .stackRouterOfIndex(tabsRouter.activeIndex)!
                    .popUntilRoot();
              } else {
                tabsRouter.setActiveIndex(13);
              }
            },
            isActive:
                tabsRouter.activeIndex == (kIsWeb ? WebRouteIndex.tokens : 13),
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Smart Contracts",
            iconType: PrettyIconType.smartContract,
            onPressed: () {
              if (kIsWeb) {
                tabsRouter.setActiveIndex(WebRouteIndex.smartContracts);
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
                return;
              }
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
              if (ref.read(sessionProvider).currentWallet == null) {
                Toast.error("An account is required to access this section.");
                return;
              }
              tabsRouter.setActiveIndex(8);
              tabsRouter.popTop();
            },
            isActive: tabsRouter.activeIndex ==
                (kIsWeb ? WebRouteIndex.smartContracts : 8),
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "Manage NFTs",
            iconType: PrettyIconType.nft,
            onPressed: () {
              if (kIsWeb) {
                tabsRouter.setActiveIndex(WebRouteIndex.nfts);
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
                return;
              }
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
              if (ref.read(sessionProvider).currentWallet == null) {
                Toast.error("An account is required to access this section.");
                return;
              }
              tabsRouter.setActiveIndex(7);
              tabsRouter.popTop();
            },
            isActive:
                tabsRouter.activeIndex == (kIsWeb ? WebRouteIndex.nfts : 7),
            isExpanded: isExpanded,
          ),
          RootContainerSideNavItem(
            title: "P2P Auctions",
            iconType: PrettyIconType.p2p,
            onPressed: () {
              if (kIsWeb) {
                tabsRouter.setActiveIndex(WebRouteIndex.shop);
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
                return;
              }
              if (inDrawer) {
                rootScaffoldKey.currentState!.closeDrawer();
              }
              if (tabsRouter.activeIndex == 9) {
                tabsRouter
                    .stackRouterOfIndex(tabsRouter.activeIndex)!
                    .popUntilRoot();
              } else {
                tabsRouter.setActiveIndex(9);
              }
            },
            isActive:
                tabsRouter.activeIndex == (kIsWeb ? WebRouteIndex.shop : 9),
            isExpanded: isExpanded,
          ),
          if (!kIsWeb)
            RootContainerSideNavItem(
              title: "Validator",
              iconType: PrettyIconType.validator,
              onPressed: () {
                tabsRouter.setActiveIndex(4);
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
              },
              isActive: tabsRouter.activeIndex == 4,
              isExpanded: isExpanded,
            ),
          if (!kIsWeb)
            RootContainerSideNavItem(
              title: "Operations",
              iconType: PrettyIconType.operations,
              onPressed: () {
                if (tabsRouter.activeIndex == 16) {
                  tabsRouter
                      .stackRouterOfIndex(tabsRouter.activeIndex)!
                      .popUntilRoot();
                } else {
                  tabsRouter.setActiveIndex(16);
                }
                if (inDrawer) {
                  rootScaffoldKey.currentState!.closeDrawer();
                }
              },
              isActive: tabsRouter.activeIndex == 16,
              isExpanded: isExpanded,
            ),
          if (kIsWeb)
            RootContainerSideNavItem(
              title: "Sign Out",
              iconType: PrettyIconType.custom,
              icon: Icons.logout,
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  title: "Sign Out",
                  body:
                      "Are you sure you want to logout of the VFX Web Wallet?",
                  destructive: true,
                  confirmText: "Logout",
                  cancelText: "Cancel",
                );
                if (confirmed == true) {
                  await ref.read(webSessionProvider.notifier).logout();

                  AutoRouter.of(context).replace(const WebAuthRouter());
                }
              },
              isActive: tabsRouter.activeIndex == 16,
              isExpanded: isExpanded,
            ),
        ],
      );
    });
  }
}

Future<void> _handleButterflyLogin(BuildContext context, WidgetRef ref) async {
  // Get wallet keys based on platform
  String? privateKey;
  String? publicKey;
  String? address;

  if (kIsWeb) {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No wallet selected. Please create or import a wallet first.");
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
  final password = await PasswordPromptService.promptNewPassword(
    rootNavigatorKey.currentContext!,
    title: "Create Butterfly Password",
    customMessage:
        "Create a password to securely transfer your credentials to Butterfly. You will need to enter this same password on the Butterfly website.",
  );

  if (password == null) return;

  // Confirmation dialog
  final confirmed = await ConfirmDialog.show(
    title: "Login to Butterfly",
    body: "You are about to open Butterfly and log in with:\n\n$address\n\nContinue?",
    confirmText: "Open Butterfly",
    cancelText: "Cancel",
  );

  if (confirmed != true) return;

  // Generate encrypted URL and launch
  try {
    ref.read(globalLoadingProvider.notifier).start();
    await Future.delayed(const Duration(milliseconds: 250));
    final url = ButterflyBridgeUrlService.createBridgeUrl(
      privateKey: privateKey,
      password: password,
      address: address,
      publicKey: publicKey,
      targetBaseUrl: Env.butterflyWebBaseUrl,
    );
    ref.read(globalLoadingProvider.notifier).complete();
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  } catch (e) {
    ref.read(globalLoadingProvider.notifier).complete();
    Toast.error("Failed to generate login URL: $e");
  }
}
