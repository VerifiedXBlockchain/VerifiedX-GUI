import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/features/misc/providers/global_balances_expanded_provider.dart';
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/common/modal_container.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/components/open_explorer_modal.dart';
import '../../../core/providers/currency_segmented_button_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../core/utils.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../auth/screens/web_auth_screen.dart';
import '../../btc_web/services/btc_web_service.dart';
import '../../faucet/screens/faucet_screen.dart';
import '../../navigation/constants.dart';
import '../../navigation/root_container.dart';
import '../../price/components/coin_price_summary.dart';
import '../../price/components/price_chart.dart';
import '../../wallet/utils.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_wallet_mobile_account_info.dart';
import '../../web/components/web_wallet_type_switcher.dart';

import '../../../core/dialogs.dart';
import '../../web/components/web_wordmark.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/buttons.dart';
import '../../../core/env.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/web_router.gr.dart';
import '../../../generated/assets.gen.dart';
import '../../root/web_dashboard_container.dart';
import '../../web/components/web_latest_block.dart';
import '../../web/components/web_wallet_details.dart';
import '../../web/providers/account_info_visible_provider.dart';
import '../components/home_buttons/verify_nft_ownership_button.dart';
import 'all_tokens_screen.dart';

final smallPhoneHeight = 800;
final smallPhoneWidth = 390;

class WebHomeScreen extends BaseScreen {
  const WebHomeScreen({Key? key})
      : super(
          key: key,
          includeWebDrawer: true,
          backgroundColor: Colors.black,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final address = ref.watch(webSessionProvider.select((v) => v.currentWallet?.address));
    final isMobile = BreakPoints.useMobileLayout(context);

    return isMobile
        ? AppBar(
            title: const Text("Dashboard"),
            backgroundColor: Colors.black,
            shadowColor: Colors.transparent,
            actions: [WebWalletTypeSwitcher()],
            leading: const WebMobileDrawerButton(),
          )
        : null;
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final visibilityProvider = ref.read(webMobileAccountInfoVisibleProvider.notifier);
    final visibilityState = ref.watch(webMobileAccountInfoVisibleProvider);

    return Stack(
      children: [
        Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(0),
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: const [
            //       SizedBox(height: 4),
            //       WebWalletDetails(),
            //       SizedBox(height: 32),
            //     ],
            //   ),
            // ),
            const _Brand(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WebMobileAccountInfo(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Coin Prices",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 1,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(currencySegementedButtonProvider.notifier).set(CurrencyType.vfx);
                      Navigator.of(webDashboardScaffoldKey.currentContext!).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => WebPriceChartScreen(
                            isBtc: false,
                          ),
                        ),
                      );
                    },
                    child: CoinPriceSummary(
                      mini: true,
                      type: CoinPriceSummaryType.vfx,
                      actions: [
                        AppButton(
                          onPressed: () async {
                            AccountUtils.getCoin(context, ref, VfxOrBtcOption.vfx);
                          },
                          variant: AppColorVariant.Secondary,
                          type: AppButtonType.Outlined,
                          label: "Get VFX",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(currencySegementedButtonProvider.notifier).set(CurrencyType.btc);
                      Navigator.of(webDashboardScaffoldKey.currentContext!).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => WebPriceChartScreen(
                            isBtc: true,
                          ),
                        ),
                      );
                    },
                    child: CoinPriceSummary(
                      mini: true,
                      type: CoinPriceSummaryType.btc,
                      actions: [
                        AppButton(
                          onPressed: () {
                            AccountUtils.getCoin(context, ref, VfxOrBtcOption.btc);
                          },
                          label: "Get BTC",
                          variant: AppColorVariant.Btc,
                          type: AppButtonType.Outlined,
                        ),
                      ],
                    ),
                  ),
                  const _Actions(),
                ],
              ),
            ),
          ],
        ),
        if (visibilityState != null)
          GestureDetector(
            onTap: () {
              visibilityProvider.clear();
            },
            child: Container(
              color: Colors.black12,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        AnimatedPositioned(
          duration: ROOT_CONTAINER_TRANSITION_DURATION,
          curve: ROOT_CONTAINER_TRANSITION_CURVE,
          top: visibilityState == 0 ? 0 : -(ROOT_CONTAINER_BALANCE_ITEM_EXPANDED_HEIGHT + 64),
          left: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: WebAccountInfoVfx(),
          ),
        ),
        // AnimatedPositioned(
        //   duration: ROOT_CONTAINER_TRANSITION_DURATION,
        //   curve: ROOT_CONTAINER_TRANSITION_CURVE,
        //   top: visibilityState == 1 ? 0 : -(ROOT_CONTAINER_BALANCE_ITEM_EXPANDED_HEIGHT + 64),
        //   left: 0,
        //   child: SizedBox(
        //     width: MediaQuery.of(context).size.width,
        //     child: WebAccountInfoVbtc(),
        //   ),
        // ),
        AnimatedPositioned(
          duration: ROOT_CONTAINER_TRANSITION_DURATION,
          curve: ROOT_CONTAINER_TRANSITION_CURVE,
          top: visibilityState == 2 ? 0 : -(ROOT_CONTAINER_BALANCE_ITEM_EXPANDED_HEIGHT + 64),
          left: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: WebAccountInfoBtc(),
          ),
        ),
      ],
    );
  }

  @override
  Widget desktopBody(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: ROOT_CONTAINER_BALANCE_ITEM_EXPANDED_HEIGHT),
      child: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: CoinPriceSummary(
                      type: CoinPriceSummaryType.vfx,
                      actions: [
                        AppButton(
                          onPressed: () {
                            ref.read(currencySegementedButtonProvider.notifier).set(CurrencyType.vfx);
                            Navigator.of(webDashboardScaffoldKey.currentContext!).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) => WebPriceChartScreen(
                                  isBtc: false,
                                ),
                              ),
                            );
                          },
                          label: "View Chart",
                          variant: AppColorVariant.Light,
                          type: AppButtonType.Outlined,
                        ),
                        AppButton(
                          onPressed: () async {
                            AccountUtils.getCoin(context, ref, VfxOrBtcOption.vfx);
                          },
                          variant: AppColorVariant.Secondary,
                          type: AppButtonType.Outlined,
                          label: "Get VFX",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: CoinPriceSummary(
                      type: CoinPriceSummaryType.btc,
                      actions: [
                        AppButton(
                          onPressed: () {
                            ref.read(currencySegementedButtonProvider.notifier).set(CurrencyType.btc);
                            Navigator.of(webDashboardScaffoldKey.currentContext!).push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) => WebPriceChartScreen(
                                  isBtc: true,
                                ),
                              ),
                            );
                          },
                          label: "View Chart",
                          variant: AppColorVariant.Light,
                          type: AppButtonType.Outlined,
                        ),
                        AppButton(
                          onPressed: () {
                            AccountUtils.getCoin(context, ref, VfxOrBtcOption.btc);
                          },
                          label: "Get BTC",
                          variant: AppColorVariant.Btc,
                          type: AppButtonType.Outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _Actions(),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = BreakPoints.useMobileLayout(context);
    final smallPhone = MediaQuery.of(context).size.width <= smallPhoneWidth && MediaQuery.of(context).size.height <= smallPhoneHeight;

    return Center(
      child: Flex(
        direction: smallPhone ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isMobile
                ? smallPhone
                    ? 35
                    : 75
                : 150,
            child: Image.asset(
              Assets.images.animatedCube.path,
              scale: 1,
            ),
          ),
          SizedBox(
            width: 8,
            height: 8,
          ),
          WebWalletWordWordmark(
            withSubtitle: false,
          )
        ],
      ),
    );
  }
}

class _Actions extends BaseComponent {
  const _Actions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsRouter = AutoTabsRouter.of(context);

    final isMobile = BreakPoints.useMobileLayout(context);
    final smallPhone = MediaQuery.of(context).size.width <= smallPhoneWidth && MediaQuery.of(context).size.height <= smallPhoneHeight;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: isMobile ? 0 : 16),
      child: AppCard(
        padding: smallPhone ? 6 : 20,
        fullWidth: true,
        child: Center(
          child: Wrap(
            runSpacing: isMobile ? 6 : 16,
            spacing: isMobile ? 4 : 16,
            alignment: WrapAlignment.center,
            children: [
              // AppButton(
              //   label: "Test",
              //   onPressed: () {
              //     runTests();
              //   },
              // ),
              // AppButton(
              //   label: "Other Test",
              //   onPressed: () {
              //     otherTest();
              //   },
              // ),

              AppVerticalIconButton(
                label: "Send\nCoin",
                icon: Icons.outbox,
                prettyIconType: PrettyIconType.send,
                onPressed: () {
                  tabsRouter.setActiveIndex(WebRouteIndex.send);
                },
              ),
              AppVerticalIconButton(
                label: "Receive\nCoin",
                icon: Icons.move_to_inbox,
                prettyIconType: PrettyIconType.receive,
                onPressed: () {
                  tabsRouter.setActiveIndex(WebRouteIndex.recieve);
                },
              ),
              AppVerticalIconButton(
                label: "TXs",
                icon: Icons.history,
                prettyIconType: PrettyIconType.transactions,
                onPressed: () {
                  tabsRouter.setActiveIndex(WebRouteIndex.transactions);
                },
                color: AppColors.getWhite(ColorShade.s200),
              ),
              Builder(builder: (context) {
                return AppVerticalIconButton(
                  label: "Tokens",
                  prettyIconType: PrettyIconType.fungibleToken,
                  icon: Icons.toll,
                  onPressed: () {
                    ref.read(globalBalancesExpandedProvider.notifier).detract();
                    AutoRouter.of(context).push(AllTokensScreenRoute());
                  },
                  color: AppColors.getWhite(ColorShade.s200),
                );
              }),
              AppVerticalIconButton(
                label: "Tutorials",
                prettyIconType: PrettyIconType.custom,
                icon: FontAwesomeIcons.video,
                iconScale: 0.7,
                onPressed: () {
                  launchUrlString("https://docs.verifiedx.io/docs/tutorials/video-tutorials/");
                },
                color: AppColors.getWhite(ColorShade.s200),
              ),
              AppVerticalIconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ModalContainer(
                          title: "Get Help",
                          withClose: true,
                          children: [
                            AppCard(
                              padding: 0,
                              child: ListTile(
                                  title: Text("Join Discord"),
                                  leading: Icon(
                                    FontAwesomeIcons.discord,
                                    size: 18,
                                  ),
                                  onTap: () {
                                    launchUrlString("https://discord.gg/7cd5ebDQCj");
                                  },
                                  trailing: Icon(Icons.open_in_new, size: 16)),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            AppCard(
                              padding: 0,
                              child: ListTile(
                                  title: Text("Visit Website"),
                                  leading: Icon(
                                    Icons.link,
                                  ),
                                  onTap: () {
                                    launchUrlString("https://verifiedx.io");
                                  },
                                  trailing: Icon(Icons.open_in_new, size: 16)),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            AppCard(
                              padding: 0,
                              child: ListTile(
                                  title: Text("Read Docs"),
                                  leading: Icon(
                                    Icons.read_more,
                                  ),
                                  onTap: () {
                                    launchUrlString("https://docs.verifiedx.io");
                                  },
                                  trailing: Icon(Icons.open_in_new, size: 16)),
                            )
                          ],
                        );
                      });
                },
                icon: Icons.help,
                label: "Get\nHelp",
                prettyIconType: PrettyIconType.custom,
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
              AppVerticalIconButton(
                  label: "Verify\nOwner",
                  prettyIconType: PrettyIconType.validator,
                  icon: Icons.check,
                  onPressed: () async {
                    final sig = await PromptModal.show(
                      title: "Validate Ownership",
                      body: "Paste in the signature provided by the owner to validate its ownership.",
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

                      var verified = await ExplorerService().verifyNftOwnership(sig);
                      if (verified == null) {
                        return;
                      }

                      final color = verified ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.danger;
                      final iconData = verified ? Icons.check : Icons.close;
                      final title = verified ? "Verified" : "Not Verified";
                      final subtitle = verified ? "Ownership Verified" : "Ownership NOT Verified";
                      final body = verified ? "$address\nOWNS\n$scId" : "$address\ndoes NOT own\n$scId";

                      InfoDialog.show(
                        title: title,
                        content: NftVerificationSuccessDialog(
                          iconData: iconData,
                          color: color,
                          subtitle: subtitle,
                          body: body,
                        ),
                      );
                    }
                  }),
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

              if (ref.read(webSessionProvider).keypair != null && !isMobile)
                AppVerticalIconButton(
                  label: "Sign\nOut",
                  icon: Icons.logout,
                  prettyIconType: PrettyIconType.custom,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      title: "Sign Out",
                      body: "Are you sure you want to logout of the VFX Web Wallet?",
                      destructive: true,
                      confirmText: "Logout",
                      cancelText: "Cancel",
                    );
                    if (confirmed == true) {
                      await ref.read(webSessionProvider.notifier).logout();

                      AutoRouter.of(context).replace(const WebAuthRouter());
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
