import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/features/btc/screens/web_tokenize_btc_onboarding_screen.dart';
import 'package:rbx_wallet/utils/toast.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_screen.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/back_to_home_button.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../models/tokenized_bitcoin.dart';
import '../providers/tokenized_btc_onboard_provider.dart';

import 'bulk_vbtc_transfer_screen.dart';
import 'tokenize_btc_screen.dart';
import 'tokenized_btc_detail_screen.dart';

import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import 'package:collection/collection.dart';

import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/components.dart';
import '../../btc_web/components/web_tokenized_btc_list_tile.dart';
import '../../btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import '../providers/btc_pending_tokenized_address_list_provider.dart';
import '../providers/tokenize_btc_form_provider.dart';
import '../providers/tokenized_bitcoin_list_provider.dart';
import 'tokenize_btc_onboarding_screen.dart';

class TokenizeBtcListScreen extends BaseScreen {
  const TokenizeBtcListScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);

    if (isMobile) {
      return AppBar(
        leading: WebMobileDrawerButton(),
        backgroundColor: Colors.black,
        title: Text(AppLocalizations.of(context).btcVbtcListTitle),
      );
    }

    return null;
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);

    return Column(
      children: [
        if (!isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).btcVbtcListTitle,
                    style: TextStyle(
                      fontFamily: "Mukta",
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      AppLocalizations.of(context).bw2OneVbtcEqualsBtc,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              if (BULK_VBTC_TRANSFER_ENABLED)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AppButton(
                    label: AppLocalizations.of(context).btcBulkTransferLabel,
                    onPressed: () {
                      final tokens = ref.read(tokenizedBitcoinListProvider).where((element) => element.balance > 0);
                      final webTokens = ref.read(btcWebVbtcTokenListProvider).where((element) => element.globalBalance > 0);

                      if (!kIsWeb && tokens.isEmpty) {
                        Toast.error(AppLocalizations.of(context).btcNoVbtcWithBalance);
                        return;
                      }
                      if (kIsWeb && webTokens.isEmpty) {
                        Toast.error(AppLocalizations.of(context).btcNoVbtcWithBalance);
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BulkVbtcTransferScreen(),
                        ),
                      );
                    },
                    variant: AppColorVariant.Btc,
                    type: AppButtonType.Elevated,
                  ),
                )
            ],
          ),
        AppCard(
          fullWidth: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VBtcButton(
                label: AppLocalizations.of(context).btcCreateVerifiedToken,
                icon: FontAwesomeIcons.bitcoin,
                onPressed: () async {
                  if (kIsWeb) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TokenizeBtcScreen(),
                      ),
                    );

                    return;
                  }
                  Wallet? wallet = ref.read(walletListProvider).firstWhereOrNull((a) => a.balance > MIN_RBX_FOR_SC_ACTION && !a.isReserved);

                  if (wallet == null) {
                    final confirmContinue = await ConfirmDialog.show(
                      title: AppLocalizations.of(context).btcVfxBalanceRequiredTitle,
                      body: AppLocalizations.of(context).bw2VfxBalanceRequiredSetupBody,
                      confirmText: AppLocalizations.of(context).actionYes,
                      cancelText: AppLocalizations.of(context).actionNo,
                    );
                    if (confirmContinue != true) {
                      return;
                    }

                    ref.read(vBtcOnboardProvider.notifier).reset();

                    final token = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TokenizeBtcOnboardingScreen()));
                    if (token == null) {
                      return;
                    }

                    if (token is TokenizedBitcoin) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TokenizedBtcDetailScreen(tokenKey: "${token.smartContractUid}|${token.rbxAddress}"),
                        ),
                      );
                      return;
                    }

                    wallet = ref.read(walletListProvider).firstWhereOrNull((a) => a.balance > MIN_RBX_FOR_SC_ACTION && !a.isReserved);

                    if (wallet == null) {
                      InfoDialog.show(
                        title: AppLocalizations.of(context).btcVfxBalanceRequiredTitle,
                        body: AppLocalizations.of(context).bw2VfxBalanceRequiredBody,
                      );
                      return;
                    }
                  }

                  ref.read(tokenizeBtcFormProvider.notifier).setAddress(wallet.address);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TokenizeBtcScreen(),
                    ),
                  );
                },
              ),
              if ((kIsWeb && ref.watch(btcWebVbtcTokenListProvider).isEmpty) || (!kIsWeb && ref.watch(tokenizedBitcoinListProvider).isEmpty))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppButton(
                    label: AppLocalizations.of(context).btcUseWizard,
                    type: AppButtonType.Text,
                    onPressed: () async {
                      ref.read(vBtcOnboardProvider.notifier).reset();

                      final token = await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => kIsWeb ? WebTokenizeBtcOnboardingScreen() : TokenizeBtcOnboardingScreen()));
                      if (token == null) {
                        return;
                      }

                      if (token is TokenizedBitcoin) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TokenizedBtcDetailScreen(tokenKey: "${token.smartContractUid}|${token.rbxAddress}"),
                          ),
                        );
                        return;
                      }
                    },
                    variant: AppColorVariant.Light,
                    underlined: true,
                  ),
                ),
              if (kIsWeb)
                SizedBox(
                  height: 8,
                ),
              TextButton.icon(
                onPressed: () {
                  SpecialDialog().show(
                    context,
                    content: VbtcInfo(),
                    title: AppLocalizations.of(context).btcVbtcLabel,
                    maxWidth: 800,
                  );
                },
                icon: Icon(
                  Icons.help,
                  size: 16,
                  color: AppColors.getWhite(),
                ),
                label: Text(
                  AppLocalizations.of(context).bw2WhatIsVbtc,
                  style: TextStyle(
                    color: AppColors.getWhite(),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Consumer(builder: (context, ref, _) {
          if (kIsWeb) {
            final tokens = ref.watch(btcWebVbtcTokenListProvider);

            return Expanded(
                child: ListView.builder(
              itemCount: tokens.length,
              itemBuilder: (context, index) {
                final token = tokens[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AppCard(
                    padding: 0,
                    child: WebTokenizedBtcListTile(token: token),
                  ),
                );
              },
            ));
          }

          final tokens = ref.watch(tokenizedBitcoinListProvider);

          final groupedTokens = groupTokens(tokens);

          return Expanded(
            child: groupedTokens.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context).btcNoTokenizedBtc),
                  )
                : ListView.builder(
                    itemCount: groupedTokens.length,
                    itemBuilder: (context, index) {
                      final entry = groupedTokens[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AppCard(
                          padding: 0,
                          child: GroupedTokenizedBtcListTile(entry: entry),
                        ),
                      );
                    },
                  ),
          );
        }),
      ],
    );
  }
}

class VbtcInfo extends StatelessWidget {
  const VbtcInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).bw2VbtcInfoBody,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            AppLocalizations.of(context).bw2VbtcInfoWelcome,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TokenizedBtcListTile extends StatelessWidget {
  const TokenizedBtcListTile({
    super.key,
    required this.token,
  });

  final TokenizedBitcoin token;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
            clipBehavior: Clip.antiAlias,
            child: BtcTokenImage(
              nftId: token.smartContractUid,
              size: 100,
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text(
              token.tokenName,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            // subtitle: Text("${token.myBalance} vBTC"),
            subtitle: Text(
              token.rbxAddress,
              style: TextStyle(
                color: token.rbxAddress.startsWith("xRBX") ? Colors.deepPurple.shade200 : null,
                fontSize: 16,
              ),
            ),

            trailing: Text(
              AppLocalizations.of(context).bw2VbtcAmount(token.myBalance.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TokenizedBtcDetailScreen(tokenKey: "${token.smartContractUid}|${token.rbxAddress}"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GroupedTokenizedBtcListTile extends StatelessWidget {
  final CombinedVbtcToken entry;

  const GroupedTokenizedBtcListTile({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final token = entry.token;

    return InkWell(
      onTap: entry.addresses.length == 1
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TokenizedBtcDetailScreen(tokenKey: "${token.smartContractUid}|${token.rbxAddress}"),
                ),
              );
            }
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
              clipBehavior: Clip.antiAlias,
              child: BtcTokenImage(
                nftId: token.smartContractUid,
                size: 100,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            token.tokenName,
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          if (entry.addresses.length == 1)
                            Text(
                              token.rbxAddress,
                              style: TextStyle(
                                color: token.rbxAddress.startsWith("xRBX") ? Colors.deepPurple.shade200 : Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (entry.addresses.length > 1)
                            Text(
                              "${AppLocalizations.of(context).bw2MyTotalBalance}  ",
                              style: TextStyle(color: Colors.white70),
                            ),
                          Text(
                            AppLocalizations.of(context).bw2VbtcAmount(entry.addresses.fold<double>(0.0, (previousValue, element) => previousValue + element.balance).toString()),
                            style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (entry.addresses.length > 1) ...[
                    Divider(),
                    ...entry.addresses.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TokenizedBtcDetailScreen(tokenKey: "${item.token.smartContractUid}|${item.token.rbxAddress}"),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context).bw2VbtcAmount(item.balance.toString())}  ",
                                        style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
                                      ),
                                      Text(
                                        item.address,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  AppButton(
                                    label: AppLocalizations.of(context).btcDetailsLabel,
                                    variant: AppColorVariant.Btc,
                                    icon: Icons.chevron_right,
                                    type: AppButtonType.Text,
                                    underlined: true,
                                    iconTrails: true,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => TokenizedBtcDetailScreen(tokenKey: "${item.token.smartContractUid}|${item.token.rbxAddress}"),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CombinedVbtcTokenAddress {
  final String address;
  final double balance;
  final TokenizedBitcoin token;
  CombinedVbtcTokenAddress({
    required this.address,
    required this.balance,
    required this.token,
  });
}

class CombinedVbtcToken {
  final TokenizedBitcoin token;
  final List<CombinedVbtcTokenAddress> addresses;

  CombinedVbtcToken({required this.token, required this.addresses});
}

List<CombinedVbtcToken> groupTokens(List<TokenizedBitcoin> input) {
  final Map<String, CombinedVbtcToken> grouped = {};

  for (final item in input) {
    final scId = item.smartContractUid;

    final itemToAdd = CombinedVbtcTokenAddress(address: item.rbxAddress, balance: item.myBalance, token: item);
    if (grouped.containsKey(scId)) {
      grouped[scId]!.addresses.add(itemToAdd);
    } else {
      grouped[scId] = CombinedVbtcToken(
        token: item,
        addresses: [itemToAdd],
      );
    }
  }

  return grouped.values.toList();
}
