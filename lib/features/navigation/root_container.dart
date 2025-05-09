import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import '../../core/app_router.gr.dart';
import '../../core/base_component.dart';
import '../../core/components/buttons.dart';
import '../../core/providers/currency_segmented_button_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/colors.dart';
import '../bridge/providers/status_provider.dart';
import '../bridge/providers/wallet_info_provider.dart';
import '../btc/providers/electrum_connected_provider.dart';
import '../validator/providers/validating_status_provider.dart';
import '../wallet/components/manage_wallet_bottom_sheet.dart';
import '../wallet/utils.dart';

import '../../core/components/currency_segmented_button.dart';
import '../block/latest_block.dart';
import '../misc/providers/global_balances_expanded_provider.dart';
import '../validator/screens/validator_screen.dart';
import 'components/root_container_balance_row.dart';
import 'components/root_container_rotating_cube.dart';
import 'components/root_container_side_nav.dart';
import 'components/root_container_wallet_selector_list.dart';

const ROOT_CONTAINER_TRANSITION_DURATION = Duration(milliseconds: 250);
const ROOT_CONTAINER_TRANSITION_CURVE = Curves.ease;
const SIDE_NAV_WIDTH_EXPANDED = 180.0;
const SIDE_NAV_WIDTH_CONTRACTED = 60.0;

class RootContainer extends BaseComponent {
  const RootContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PageRouteInfo> routes = [
      const HomeTabRouter(),
      const SendTabRouter(),
      const ReceiveTabRouter(),
      const TransactionsTabRouter(),
      const ValidatorTabRouter(),
      const AdjudicatorTabRouter(),
      const NodesTabsRouter(),
      const NftTabRouter(),
      const SmartContractsTabRouter(),
      const DstsTabRouter(),
      const AdnrTabRouter(),
      const VotingTabRouter(),
      const BeaconTabRouter(),
      const TokenTabRouter(),
      const ReserveAccountsTabRouter(),
      const TokenizeBtcTabRouter(),
      const OperationsTabRouter(),
    ];

    return AutoTabsScaffold(
      backgroundColor: Color(0xff050505),
      scaffoldKey: rootScaffoldKey,
      routes: routes,
      builder: (context, child, animated) {
        return _Layout(
          child: child,
        );
      },
    );
  }
}

class _Layout extends StatefulWidget {
  final Widget child;

  const _Layout({
    required this.child,
  });

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> {
  bool sideNavExpanded = true;

  bool latestBlockIsHovering = false;
  bool latestBlockIsExpanded = false;
  bool walletSelectorIsHovering = false;
  bool walletSelectorIsExpanded = false;

  bool isHoveringTopBalance = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final tabsRouter = AutoTabsRouter.of(context);
      final globalBalancesExpanded = ref.watch(globalBalancesExpandedProvider);

      tabsRouter.addListener(() {
        Future.delayed(Duration(milliseconds: 100), () {
          if (tabsRouter.current.name == "HomeTabRouter") {
            if (!globalBalancesExpanded) {
              ref.read(globalBalancesExpandedProvider.notifier).expand();
            }
          } else {
            if (globalBalancesExpanded) {
              ref.read(globalBalancesExpandedProvider.notifier).detract();
            }
          }
        });
      });

      final isValidating = ref.watch(validatingStatusProvider);

      return Column(
        children: [
          if (isValidating)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.getSpringGreen(ColorShade.s200),
                border: Border(
                  top: BorderSide(
                    color: AppColors.getSpringGreen(),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: AppColors.getSpringGreen(ColorShade.s300),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotatingGear(
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "Validating...",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 56.0),
                    child: AnimatedContainer(
                      duration: ROOT_CONTAINER_TRANSITION_DURATION,
                      width: sideNavExpanded ? SIDE_NAV_WIDTH_EXPANDED : SIDE_NAV_WIDTH_CONTRACTED,
                      curve: ROOT_CONTAINER_TRANSITION_CURVE,
                      child: RootContainerSideNav(
                          isExpanded: sideNavExpanded,
                          onToggleExpanded: () {
                            setState(() {
                              sideNavExpanded = !sideNavExpanded;
                            });
                          }),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, top: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: RootContainerRotatingCube(),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 6,
                            ),
                            AnimatedOpacity(
                              duration: ROOT_CONTAINER_TRANSITION_DURATION,
                              opacity: sideNavExpanded ? 1 : 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Verified",
                                    style: TextStyle(
                                      color: AppColors.getWhite(ColorShade.s300),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Mukta',
                                      letterSpacing: 0.25,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 1,
                                  ),
                                  Consumer(builder: (context, ref, _) {
                                    return AnimatedDefaultTextStyle(
                                      duration: ROOT_CONTAINER_TRANSITION_DURATION,
                                      style: TextStyle(
                                        color: ref.watch(sessionProvider.select((v) => v.btcSelected))
                                            ? AppColors.getBtc()
                                            : AppColors.getBlue(ColorShade.s100),
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Mukta',
                                        letterSpacing: 0,
                                        height: 1,
                                      ),
                                      child: Text("X"),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              duration: ROOT_CONTAINER_TRANSITION_DURATION,
                              opacity: sideNavExpanded ? 1 : 0,
                              child: Transform.translate(
                                offset: Offset(0, -1),
                                child: Text(
                                  "Switchblade",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.getBlue(ColorShade.s50).withOpacity(0.7),
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedPadding(
                  duration: ROOT_CONTAINER_TRANSITION_DURATION,
                  curve: ROOT_CONTAINER_TRANSITION_CURVE,
                  padding: EdgeInsets.only(left: sideNavExpanded ? SIDE_NAV_WIDTH_EXPANDED : SIDE_NAV_WIDTH_CONTRACTED),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 57,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(),
                              clipBehavior: Clip.antiAlias,
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 6),
                          child: MouseRegion(
                              onHover: (_) {
                                setState(() {
                                  isHoveringTopBalance = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  isHoveringTopBalance = false;
                                });
                              },
                              child: RootContainerBalanceRow(isHovering: isHoveringTopBalance)),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    const expandedHeight = 300.0;
                    final btcSelected = ref.watch(sessionProvider.select((value) => value.btcSelected));
                    final vfxWallet = btcSelected ? null : ref.watch(sessionProvider.select((value) => value.currentWallet));
                    final btcWallet = btcSelected ? ref.watch(sessionProvider.select((value) => value.currentBtcAccount)) : null;

                    return AnimatedPositioned(
                      left: 0,
                      bottom: walletSelectorIsExpanded ? 0 : -expandedHeight,
                      duration: ROOT_CONTAINER_TRANSITION_DURATION,
                      curve: ROOT_CONTAINER_TRANSITION_CURVE,
                      child: MouseRegion(
                        onHover: (_) {
                          setState(() {
                            walletSelectorIsHovering = true;
                            walletSelectorIsExpanded = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            walletSelectorIsHovering = false;
                            walletSelectorIsExpanded = false;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: Offset(1, 2),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    walletSelectorIsExpanded = !walletSelectorIsExpanded;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.getGray(ColorShade.s300),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          duration: Duration(milliseconds: 105),
                                          style: TextStyle(
                                            color: walletSelectorIsHovering ? Colors.white : Colors.white.withOpacity(0.75),
                                            fontSize: 14,
                                          ),
                                          child: Builder(builder: (context) {
                                            if (vfxWallet != null) {
                                              return Tooltip(
                                                message: "Selected VFX Address",
                                                child: Row(
                                                  children: [
                                                    Text(vfxWallet.address),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      "[${vfxWallet.balanceLabel}]",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: vfxWallet.isReserved ? AppColors.getReserve() : AppColors.getBlue(),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 3,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }

                                            if (btcWallet != null) {
                                              return Tooltip(
                                                message: "Selected BTC Account",
                                                child: Row(
                                                  children: [
                                                    Text(btcWallet.address),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      "[${btcWallet.balance} BTC]",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.getBtc(),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 3,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return Text("Select Account");
                                          }),
                                        ),
                                        Transform.translate(
                                          offset: Offset(0, 1),
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            color: walletSelectorIsHovering ? Colors.white : Colors.white.withOpacity(0.75),
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: expandedHeight,
                              width: 600,
                              decoration: BoxDecoration(
                                color: AppColors.getGray(ColorShade.s300),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                              ),
                              child: AccountManagementContainer(),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Consumer(builder: (context, ref, _) {
                  final block = ref.watch(walletInfoProvider.select((v) => v?.lastestBlock));
                  if (block == null) {
                    return SizedBox();
                  }

                  return AnimatedPositioned(
                    right: 0,
                    bottom: latestBlockIsExpanded ? 0 : -360,
                    duration: ROOT_CONTAINER_TRANSITION_DURATION,
                    curve: ROOT_CONTAINER_TRANSITION_CURVE,
                    child: MouseRegion(
                      onHover: (_) {
                        setState(() {
                          latestBlockIsExpanded = true;
                          latestBlockIsHovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          latestBlockIsExpanded = false;
                          latestBlockIsHovering = false;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Transform.translate(
                            offset: Offset(1, 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.getGray(ColorShade.s300),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration: Duration(milliseconds: 105),
                                      style: TextStyle(
                                        color: latestBlockIsHovering ? Colors.white : Colors.white.withOpacity(0.75),
                                        fontSize: 14,
                                      ),
                                      child: Text(
                                        "Block ${block.height}",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Consumer(
                                      builder: (context, ref, _) {
                                        late final Color color;
                                        late final String message;
                                        if (!ref.watch(sessionProvider.select((v) => v.cliStarted))) {
                                          color = Theme.of(context).colorScheme.danger;
                                          message = "CLI Inactive";
                                        } else {
                                          final status = ref.watch(statusProvider);

                                          switch (status) {
                                            case BridgeStatus.Loading:
                                              color = Theme.of(context).colorScheme.warning;
                                              message = "VFX CLI Loading";
                                              break;
                                            case BridgeStatus.Online:
                                              color = Theme.of(context).colorScheme.success;
                                              message = "VFX Online";
                                              break;

                                            case BridgeStatus.Offline:
                                              color = Theme.of(context).colorScheme.danger;
                                              message = "VFX CLI Offline";
                                              break;
                                          }
                                        }

                                        return Tooltip(
                                          message: message,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),

                                    //btc status
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final sessionState = ref.watch(sessionProvider);

                                        late final Color color;
                                        late final String message;
                                        if (!sessionState.cliStarted) {
                                          color = Theme.of(context).colorScheme.danger;
                                          message = "BTC Inactive";
                                        } else {
                                          final electrumConnected = ref.watch(electrumConnectedProvider);

                                          switch (electrumConnected) {
                                            case null:
                                              color = Theme.of(context).colorScheme.warning;
                                              message = "BTC Loading";
                                              break;
                                            case true:
                                              color = Theme.of(context).colorScheme.success;
                                              message = "BTC Online";
                                              break;

                                            case false:
                                              color = Theme.of(context).colorScheme.danger;
                                              message = "BTC Offline";
                                              break;
                                          }
                                        }

                                        return Tooltip(
                                          message: message,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),

                                    //Sync Widget
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final walletInfo = ref.watch(walletInfoProvider);
                                        final session = ref.watch(sessionProvider);

                                        late final Color color;
                                        late final String message;
                                        bool isSynced = false;
                                        if (!session.cliStarted) {
                                          color = Theme.of(context).colorScheme.danger;
                                          message = "CLI Inactive";
                                        } else if (walletInfo == null) {
                                          color = Theme.of(context).colorScheme.danger;
                                          message = "Loading...";
                                        } else if (walletInfo.isResyncing) {
                                          color = Theme.of(context).colorScheme.danger;
                                          message = "Resyncing...";
                                        } else if (!walletInfo.isChainSynced) {
                                          color = AppColors.getGold();
                                          message = "Syncing...";
                                        } else {
                                          color = Theme.of(context).colorScheme.success;
                                          message = "Synced";
                                          isSynced = true;
                                        }

                                        if (isSynced) {
                                          return Tooltip(
                                            message: message,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          );
                                        }

                                        return Tooltip(
                                          message: message,
                                          child: SizedBox(
                                            width: 32,
                                            child: LinearProgressIndicator(
                                              value: isSynced ? 1 : null,
                                              color: color,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            height: 360,
                            child: LatestBlock(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class AccountManagementContainer extends BaseComponent {
  const AccountManagementContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(currencySegementedButtonProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CurrencySegementedButton(
                includeAny: true,
                shouldToggleGlobal: false,
              ),
              Builder(builder: (context) {
                switch (mode) {
                  case CurrencyType.vfx:
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: AppButton(
                            label: "[Restore Hidden]",
                            type: AppButtonType.Text,
                            variant: AppColorVariant.Light,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: ((context) {
                                    return WalletRestorer();
                                  }));
                            },
                          ),
                        ),
                        AppButton(
                          label: "Add Account",
                          onPressed: () {
                            AccountUtils.promptVfxNewOrImport(context, ref);
                          },
                          icon: Icons.add,
                          variant: AppColorVariant.Secondary,
                        ),
                      ],
                    );

                  case CurrencyType.btc:
                    return AppButton(
                      label: "Add Account",
                      onPressed: () {
                        AccountUtils.promptBtcNewOrImport(context, ref);
                      },
                      icon: Icons.add,
                      variant: AppColorVariant.Btc,
                    );

                  case CurrencyType.any:
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: AppButton(
                            label: "[Restore Hidden]",
                            type: AppButtonType.Text,
                            variant: AppColorVariant.Light,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: ((context) {
                                    return WalletRestorer();
                                  }));
                            },
                          ),
                        ),
                        AppButton(
                          label: "Add Account",
                          onPressed: () {
                            AccountUtils.promptVfxOrBtc(context, ref);
                          },
                          icon: Icons.add,
                          variant: AppColorVariant.Light,
                        ),
                      ],
                    );
                }
              }),
            ],
          ),
        ),
        Expanded(
          child: RootContainerWalletSelectorList(),
        ),
      ],
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
