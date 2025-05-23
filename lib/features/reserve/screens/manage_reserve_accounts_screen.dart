import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../btc/providers/tokenized_bitcoin_list_provider.dart';
import '../../btc/screens/tokenized_btc_list_screen.dart';
import '../../nft/components/nft_list_tile.dart';
import '../../nft/models/nft.dart';
import '../../nft/providers/nft_list_provider.dart';
import '../../nft/screens/nft_detail_screen.dart';
import '../../nft/services/nft_service.dart';
import '../../nft/utils.dart';
import '../providers/pending_activation_provider.dart';
import '../providers/reserve_account_provider.dart';
import 'reserve_account_overview_screen.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../token/models/token_account.dart';
import '../../token/models/token_sc_feature.dart';
import '../../token/screens/token_management_screen.dart';
import '../../wallet/models/wallet.dart';
import '../../../utils/toast.dart';

class ManageReserveAccountsScreen extends BaseScreen {
  const ManageReserveAccountsScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
      title: Text(
        "Manage Vault Accounts",
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(reserveAccountProvider.notifier);
    final accounts = ref.watch(reserveAccountProvider);

    final tabsRouter = AutoTabsRouter.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: "Setup New Account",
                icon: Icons.add,
                variant: AppColorVariant.Success,
                onPressed: () {
                  provider.newAccount(context);
                },
              ),
              SizedBox(
                height: 6,
              ),
              AppButton(
                label: "Restore Vault Account",
                icon: Icons.refresh,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                onPressed: () async {
                  provider.restoreAccount(context);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: accounts.isEmpty
              ? Center(
                  child: Text("No Vault Accounts"),
                )
              : ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final ra = accounts[index];

                    return ReserveAccountManageCard(ra);
                  },
                ),
        ),
      ],
    );
  }
}

class ReserveAccountManageCard extends BaseComponent {
  final Wallet ra;

  const ReserveAccountManageCard(this.ra, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showActivateButton = !ref.watch(pendingActivationProvider).contains(ra.address) && ra.balance >= 5;

    final provider = ref.read(reserveAccountProvider.notifier);
    final tabsRouter = AutoTabsRouter.of(context);

    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: AppCard(
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
                    ra.address,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.reserve,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: ra.address));
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
                    "${ra.availableBalance} VFX",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      provider.showBalanceInfo(context, ra);
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
                  ReserveAccountStatusBadge(wallet: ra, withRecoverButton: false)
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   "Actions",
                    //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    //         decoration: TextDecoration.underline,
                    //       ),
                    // ),
                    // SizedBox(
                    //   height: 8,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppButton(
                          label: "Send Funds",
                          variant: AppColorVariant.Light,
                          icon: Icons.arrow_upward,
                          // variant: AppColorVariant.Light,
                          onPressed: () {
                            ref.read(sessionProvider.notifier).setCurrentWallet(ra);
                            tabsRouter.setActiveIndex(1);
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

                            if (option == 'nfts' || option == 'tokens') {
                              final List<Nft> ownedNfts = [];

                              if (option == 'nfts') {
                                final nfts = ref.read(nftListProvider).data.results;

                                for (final nft in nfts) {
                                  final n = await NftService().retrieve(nft.id);
                                  if (n != null && n.currentOwner == ra.address) {
                                    ownedNfts.add(n);
                                  }
                                }
                              } else if (option == 'tokens') {
                                final accounts =
                                    ref.watch(sessionProvider).balances.where((b) => b.tokens.isNotEmpty && b.address == ra.address).toList();
                                for (final a in accounts) {
                                  for (final t in a.tokens) {
                                    final n = await NftService().retrieve(t.smartContractId);
                                    if (n != null) {
                                      ownedNfts.add(n);
                                    }
                                  }
                                }
                              }

                              if (ownedNfts.isEmpty) {
                                Toast.message("This account has no assets/NFTS.");
                                return;
                              }

                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ModalContainer(
                                      withDecor: false,
                                      children: [
                                        Text("Manage Assets"),
                                        ...ownedNfts
                                            .map(
                                              (nft) => NftListTile(
                                                nft,
                                                onPressedOverride: () async {
                                                  if (option == 'nfts') {
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: nft.id)));
                                                  } else {
                                                    final n = await NftService().getNftData(nft.id);

                                                    // if (!ref.read(transferredProvider).contains(tokenAccount.smartContractId)) {
                                                    if (n != null && nft.isToken) {
                                                      // if (n.currentOwner == address) {
                                                      final tokenAccount = TokenAccount.fromNft(n, ref);
                                                      final tokenFeature = TokenScFeature.fromNft(n);
                                                      if (tokenAccount != null && tokenFeature != null) {
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (_) => TokenManagementScreenContainer(
                                                                  address: ra.address,
                                                                  nftId: nft.id,
                                                                  tokenAccount: tokenAccount,
                                                                  tokenFeature: tokenFeature,
                                                                  ref: ref,
                                                                  nft: nft,
                                                                )));
                                                        return;
                                                      }
                                                      // }
                                                      // }
                                                    }
                                                  }
                                                },
                                                trailingOverride: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (option == 'nfts') ...[
                                                      AppButton(
                                                        label: "Transfer",
                                                        variant: AppColorVariant.Secondary,
                                                        onPressed: () {
                                                          initTransferNftProcess(context, ref, nft);
                                                        },
                                                      ),
                                                    ],
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    AppButton(
                                                      label: "View Details",
                                                      onPressed: () async {
                                                        print(option);
                                                        if (option == 'nfts') {
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => NftDetailScreen(id: nft.id)));
                                                        } else {
                                                          final n = await NftService().getNftData(nft.id);

                                                          // if (!ref.read(transferredProvider).contains(tokenAccount.smartContractId)) {
                                                          if (n != null && n.isToken) {
                                                            // if (n.currentOwner == address) {
                                                            final tokenAccount = TokenAccount.fromNft(n, ref);
                                                            final tokenFeature = TokenScFeature.fromNft(n);
                                                            if (tokenAccount != null && tokenFeature != null) {
                                                              Navigator.of(context).push(MaterialPageRoute(
                                                                  builder: (_) => TokenManagementScreenContainer(
                                                                        address: ra.address,
                                                                        nftId: n.id,
                                                                        tokenAccount: tokenAccount,
                                                                        tokenFeature: tokenFeature,
                                                                        ref: ref,
                                                                        nft: n,
                                                                      )));
                                                              return;
                                                            }
                                                            // }
                                                            // }
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList()
                                      ],
                                    );
                                  });
                            } else if (option == 'btc') {
                              final btcTokens = ref.read(tokenizedBitcoinListProvider).where((t) => t.rbxAddress == ra.address).toList();
                              if (btcTokens.isEmpty) {
                                Toast.message("This account has no vBTC Tokens");
                                return;
                              }
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ModalContainer(
                                      withClose: true,
                                      withDecor: false,
                                      children: btcTokens.map((token) => TokenizedBtcListTile(token: token)).toList(),
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
                            ref.read(sessionProvider.notifier).setCurrentWallet(ra);
                            tabsRouter.setActiveIndex(2);
                          },
                        ),
                        if (showActivateButton)
                          AppVerticalIconButton(
                            label: "Activate\nAccount",
                            icon: Icons.upload,
                            color: AppColors.getReserve(),
                            onPressed: () {
                              provider.activate(context, ra);
                            },
                          ),
                        if (ra.isNetworkProtected) ReserveAccountRecoverButton(wallet: ra),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
