import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/features/reserve/screens/reserve_account_overview_screen.dart';
import 'package:rbx_wallet/features/root/web_dashboard_container.dart';
import '../../../core/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../core/web_router.gr.dart';
import '../../auth/auth_utils.dart';
import '../../btc_web/screens/web_tokenized_btc_detail_screen.dart';
import '../../nft/screens/nft_detail_screen.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../token/providers/web_token_detail_provider.dart';
import '../../token/screens/web_token_detail_screen.dart';
import '../../web/components/web_activate_ra_button.dart';
import '../../web/components/web_fund_ra_account_button.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_recover_ra_button.dart';
import '../../web/components/web_restore_ra_button.dart';
import '../../web/components/web_wallet_type_switcher.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../../web/providers/web_ra_pending_recovery_provider.dart';
import '../../../generated/assets.gen.dart';
import '../../../utils/toast.dart';

import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';

class WebReserveAccountOverviewScreen extends BaseScreen {
  const WebReserveAccountOverviewScreen({Key? key})
      : super(
          key: key,
          backgroundColor: Colors.black,
          includeWebDrawer: true,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);

    return AppBar(
      title: Text("Your Vault Account"),
      backgroundColor: Colors.black,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: VaultAccountInfoContent(),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(color: AppColors.getReserve()),
                        ),
                      )
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.help,
              size: 16,
              color: AppColors.getReserve(),
            ),
            label: Text(
              "What are Vault Accounts?",
              style: TextStyle(
                color: AppColors.getReserve(),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
      leading: isMobile ? WebMobileDrawerButton() : null,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final keypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));

    final balance = ref.watch(webSessionProvider.select((v) => v.raBalance)) ?? 0.0;
    if (keypair == null) {
      return Center(child: Text("No Vault Account Found"));
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "Address:",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      SelectableText(
                        keypair.address,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.reserve,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: keypair.address));
                          Toast.message("Address copied to clipboard");
                        },
                        child: Icon(
                          Icons.copy,
                          color: Theme.of(context).colorScheme.reserve,
                          size: 14,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Text(
                        "Available Balance:",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      SelectableText(
                        "$balance VFX",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final session = ref.read(webSessionProvider);
                          final body =
                              "Available: ${session.raBalance} VFX\nLocked: ${session.raBalanceLocked} VFX\nTotal: ${session.raBalanceTotal} VFX";
                          InfoDialog.show(title: "Vault Account Balance", body: body);
                        },
                        child: Icon(
                          Icons.help,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Text(
                        "Status:",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final hasRecovered = ref.watch(webRaPendingRecoveryProvider).contains(keypair.address);

                          if (hasRecovered) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Recovery In Progress",
                                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SelectableText(
                                  "Your Reserve (Protected) Account is being recovered to your recovery address.\nAll non-settled transactions for funds and NFTs will be transferred as well as your current available balance.\nIt is recommended you import your recovery private key into a new machine.",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                AppButton(
                                  label: "Reveal Keys",
                                  onPressed: () {
                                    showRaKeys(context, keypair);
                                  },
                                )
                              ],
                            );
                          }

                          if (ref.watch(webSessionProvider.select((v) => v.raActivated))) {
                            return AppBadge(
                              label: "Activated",
                              variant: AppColorVariant.Success,
                            );
                          }

                          if (balance < 5) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Awaiting Funds"),
                                SizedBox(
                                  width: 6,
                                ),
                                WebFundRaAccountButton(),
                              ],
                            );
                          }

                          return WebActivateRaButton();
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 12,
                      children: [
                        AppButton(
                          label: "Send Funds",
                          variant: AppColorVariant.Light,
                          icon: Icons.arrow_upward,
                          // variant: AppColorVariant.Light,
                          onPressed: () {
                            ref.read(webCurrencySegementedButtonProvider.notifier).set(WebCurrencyType.vault);
                            AutoTabsRouter.of(context).setActiveIndex(WebRouteIndex.send);
                          },
                        ),
                        AppButton(
                          label: "Manage Assets",
                          icon: Icons.toll,
                          variant: AppColorVariant.Light,
                          onPressed: () async {
                            final option = await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return ModalContainer(
                                    withDecor: false,
                                    children: [
                                      AppCard(
                                        padding: 0,
                                        child: ListTile(
                                          title: Text("NFTs"),
                                          leading: Icon(Icons.lightbulb_outline),
                                          trailing: Icon(Icons.chevron_right),
                                          onTap: () {
                                            Navigator.of(context).pop("nfts");
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      AppCard(
                                        padding: 0,
                                        child: ListTile(
                                          title: Text("Fungible Tokens"),
                                          leading: Icon(Icons.toll),
                                          trailing: Icon(Icons.chevron_right),
                                          onTap: () {
                                            Navigator.of(context).pop("tokens");
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      AppCard(
                                        padding: 0,
                                        child: ListTile(
                                          title: Text("Bitcoin (vBTC)"),
                                          leading: Icon(FontAwesomeIcons.bitcoin),
                                          trailing: Icon(Icons.chevron_right),
                                          onTap: () {
                                            Navigator.of(context).pop("btc");
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                });

                            if (option == null) {
                              return;
                            }

                            if (option == 'nfts') {
                              final nfts = await ExplorerService().listNfts(keypair.address);
                              // final nfts = await ExplorerService().listNfts("xMjrfrzkrNC2g3KJidbwF21gB7R3m46B9w");

                              if (nfts.isEmpty) {
                                Toast.error("Your Vault Account has no NFTS.");
                                return;
                              }

                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return ModalContainer(
                                      withClose: true,
                                      children: nfts.map((nft) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: AppCard(
                                            padding: 0,
                                            child: ListTile(
                                              title: Text(nft.name),
                                              subtitle: Text(
                                                nft.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: Icon(Icons.chevron_right),
                                              leading: Stack(
                                                children: [
                                                  Builder(
                                                    builder: (context) {
                                                      if (nft.currentEvolveAssetWeb != null && nft.currentEvolveAssetWeb!.isImage) {
                                                        return SizedBox(
                                                          width: 32,
                                                          height: 32,
                                                          child: AspectRatio(
                                                            aspectRatio: 1,
                                                            child: CachedNetworkImage(
                                                              imageUrl: nft.currentEvolveAssetWeb!.location,
                                                              width: double.infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      if (nft.primaryAssetWeb != null) {
                                                        return Icon(Icons.file_present_outlined);
                                                      }

                                                      return SizedBox(
                                                        width: 32,
                                                        height: 32,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: nft.id)));
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  });

                              return;
                            }

                            if (option == 'tokens') {
                              // final tokens = await ExplorerService().getTokenBalances("xMjrfrzkrNC2g3KJidbwF21gB7R3m46B9w");
                              final tokens = await ExplorerService().getTokenBalances(keypair.address);

                              if (tokens.isEmpty) {
                                Toast.error("Your Vault Account has no Fungible Tokens.");

                                return;
                              }

                              final balance = tokens
                                  .where((a) => a.address == keypair.address)
                                  .fold<double>(0, (currentValue, value) => currentValue + value.balance);

                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return ModalContainer(
                                      withClose: true,
                                      children: tokens.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: AppCard(
                                            padding: 0,
                                            child: ListTile(
                                              title: Text(item.token.name),
                                              subtitle: Text(
                                                "$balance ${item.token.ticker}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: Icon(Icons.chevron_right),
                                              leading: item.token.imageUrl != null && item.token.imageUrl!.isNotEmpty
                                                  ? Image.network(item.token.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                                                  : PrettyIcon(
                                                      type: PrettyIconType.fungibleToken,
                                                    ),
                                              onTap: () {
                                                Navigator.of(context).pop();

                                                ref.invalidate(webTokenDetailProvider(item.token.smartContractId));
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(builder: (_) => WebTokenDetailScreen(scId: item.token.smartContractId)));
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  });

                              return;
                            }

                            if (option == 'btc') {
                              final tokens = await ExplorerService().getWebVbtcTokens(keypair.address);

                              if (tokens.isEmpty) {
                                Toast.error("Your Vault Account has no vBTC Tokens.");

                                return;
                              }

                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return ModalContainer(
                                      withClose: true,
                                      children: tokens.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: AppCard(
                                            padding: 0,
                                            child: ListTile(
                                              title: Text(item.name),
                                              subtitle: Text(
                                                "${item.balanceForAddress(keypair.address)} vBTC",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: Icon(Icons.chevron_right),
                                              leading: CachedNetworkImage(
                                                imageUrl: item.imageUrl,
                                                height: 32,
                                                width: 32,
                                                errorWidget: (context, _, __) {
                                                  return Image.asset(
                                                    Assets.images.vbtcPng.path,
                                                    width: 32,
                                                    height: 32,
                                                  );
                                                },
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();

                                                Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (_) => WebTokenizedBtcDetailScreen(scIdentifier: item.scIdentifier)));
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  });
                            }
                          },
                        ),
                        AppButton(
                          label: "Receive Assets",
                          icon: Icons.arrow_downward,
                          variant: AppColorVariant.Light,
                          onPressed: () {
                            ref.read(webCurrencySegementedButtonProvider.notifier).set(WebCurrencyType.vault);
                            AutoTabsRouter.of(context).setActiveIndex(WebRouteIndex.recieve);
                          },
                        ),
                        WebRecoverRaButton(),
                      ],
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WebRestoreRaButton(),
            ),

            // AppCard(
            //   padding: 0,
            //   child: ListTile(
            //     title: Text(keypair.address),
            //     subtitle: Text("$balance VFX"),
            //     leading: IconButton(
            //       icon: Icon(Icons.copy),
            //       onPressed: () async {
            //         await Clipboard.setData(ClipboardData(text: keypair.address));
            //         Toast.message("Address copied to clipboard");
            //       },
            //     ),
            //     trailing: IconButton(
            //       icon: Icon(Icons.remove_red_eye),
            //       onPressed: () async {
            //         final confirmed = await ConfirmDialog.show(
            //           title: "Reveal Private Key?",
            //           body: "Are you sure you want to reveal your private key for your Vault Account?",
            //           confirmText: "Reveal",
            //           cancelText: "Cancel",
            //         );

            //         if (confirmed == true) {
            //           showRaKeys(context, keypair);
            //         }
            //       },
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: 16,
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Builder(
            //     builder: (context) {
            //       final hasRecovered = ref.watch(webRaPendingRecoveryProvider).contains(keypair.address);

            //       if (hasRecovered) {
            //         return Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Text(
            //               "Recovery In Progress",
            //               style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
            //             ),
            //             SizedBox(
            //               height: 8,
            //             ),
            //             SelectableText(
            //               "Your Reserve (Protected) Account is being recovered to your recovery address.\nAll non-settled transactions for funds and NFTs will be transferred as well as your current available balance.\nIt is recommended you import your recovery private key into a new machine.",
            //               textAlign: TextAlign.center,
            //             ),
            //             SizedBox(
            //               height: 12,
            //             ),
            //             AppButton(
            //               label: "Reveal Keys",
            //               onPressed: () {
            //                 showRaKeys(context, keypair);
            //               },
            //             )
            //           ],
            //         );
            //       }

            //       if (ref.watch(webSessionProvider.select((v) => v.raActivated))) {
            //         return Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             AppBadge(
            //               label: "Activated",
            //               variant: AppColorVariant.Success,
            //             ),
            //             SizedBox(
            //               height: 16,
            //             ),
            //             WebRecoverRaButton()
            //           ],
            //         );
            //       }

            //       final balance = ref.watch(webSessionProvider.select((v) => v.raBalance));

            //       if (balance == 0) {
            //         return Container(
            //           decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
            //           child: Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Text(
            //                   "Awaiting Funds",
            //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            //                 ),
            //                 SizedBox(
            //                   height: 8,
            //                 ),
            //                 Text("To activate, you must first transfer 5.0 VFX to this address."),
            //                 SizedBox(
            //                   height: 16,
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                   children: [
            //                     if ((ref.watch(webSessionProvider.select((v) => v.balance)) ?? 0) > 5 &&
            //                         ref.watch(webSessionProvider.select((v) => v.keypair)) != null &&
            //                         ref.read(webSessionProvider.select((v) => v.raKeypair)) != null)
            //                       WebFundRaAccountButton(),
            //                     AppButton(
            //                       label: "Copy Address",
            //                       icon: Icons.copy,
            //                       onPressed: () async {
            //                         await Clipboard.setData(ClipboardData(text: keypair.address));
            //                         Toast.message("Address copied to clipboard");
            //                       },
            //                     ),
            //                   ],
            //                 )
            //               ],
            //             ),
            //           ),
            //         );
            //       }

            //       return WebActivateRaButton();
            //     },
            //   ),
            // ),
            // SizedBox(height: 16),
            // WebRestoreRaButton(),
          ],
        ),
      ),
    );
  }
}

// class _Top extends BaseComponent {
//   const _Top({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Column(
//       children: [
//         SizedBox(
//           width: 120,
//           height: 120,
//           child: Image.asset(
//             Assets.images.animatedCube.path,
//             scale: 1,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: 800),
//               child: RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: "Vault Accounts [",
//                     ),
//                     TextSpan(
//                         text: "xRBX",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.secondary,
//                         )),
//                     TextSpan(
//                       text: "] is a Cold Storage and On-Chain Escrow Feature to keep your VFX Funds and your Digital Assets Safe.\n\n",
//                     ),
//                     TextSpan(
//                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
//                       text:
//                           "This feature is separate from your VFX instant settlement address and enables both recovery and call-back on-chain escrow features that allows you to be able to recover funds and assets back to your Vault Account in the event of theft, misplacement, or from a recipient that requires trustless escrow within 24 hours of occurrence or within a user pre-set defined time.\n\n",
//                     ),
//                     TextSpan(
//                       text: "These features are all on-chain and all peers are aware of their current state.\n",
//                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(
//                       text: "Note: Activating this feature requires a 5 VFX deposit, 4 of which will be burned upon activation.",
//                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
