import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/web_router.gr.dart';
import '../../../core/utils.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../models/web_fungible_token.dart';
import '../providers/web_token_actions_manager.dart';
import '../providers/web_token_topic_list_provider.dart';
import '../screens/token_topic_detail_screen.dart';

class WebTokenManagementActions extends BaseComponent {
  const WebTokenManagementActions({
    super.key,
    required this.tokenDetail,
    required this.raIsOwner,
    required this.vfxIsOwner,
  });

  final WebFungibleTokenDetail tokenDetail;
  final bool raIsOwner;
  final bool vfxIsOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = tokenDetail.token;

    final isOwner = vfxIsOwner || raIsOwner;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).r3hManageToken,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 16,
        ),
        AppCard(
          fullWidth: true,
          child: Wrap(
            runSpacing: 8,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 16,
            children: [
              if (token.canMint) WebMintTokenButton(raIsOwner: raIsOwner, token: token),
              if (isOwner) WebChangeTokenOwnershipButton(token: token),
              if (isOwner) WebPauseTokenButton(token: token),
              if (isOwner) WebTokenBanAddressButton(token: token),
              if (isOwner && token.bannedAddresses.isNotEmpty) WebTokenListBannedAddressesButton(token: token),
              if (isOwner)
                AppButton(
                  label: AppLocalizations.of(context).tokenProveOwnership,
                  variant: AppColorVariant.Primary,
                  icon: Icons.verified_user,
                  onPressed: () async {
                    await proveSmartContractOwnership(context, ref, token.ownerAddress, token.smartContractId);
                  },
                ),
              if (isOwner)
                AppButton(
                  label: AppLocalizations.of(context).tokenVoting,
                  variant: AppColorVariant.Dark,
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return WebTokenTopicBottomSheet(tokenDetail: tokenDetail, isOwner: isOwner);
                        });
                  },
                ),
              //TODO: VOTE
            ],
          ),
        ),
      ],
    );
  }
}

class WebTokenTopicBottomSheet extends BaseComponent {
  final WebFungibleTokenDetail tokenDetail;
  final bool isOwner;

  const WebTokenTopicBottomSheet({
    super.key,
    required this.tokenDetail,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = tokenDetail.token;

    final data = ref.watch(webTokenTopicListProvider(token.smartContractId));
    final address = ref.read(webSessionProvider).keypair?.address;
    if (address == null) {
      return SizedBox();
    }

    final double balance = tokenDetail.holders.containsKey(address) ? tokenDetail.holders[address] : 0.0;

    if (data.topics.isEmpty && !isOwner) {
      return ModalContainer(
        children: [
          Center(
            child: Text(AppLocalizations.of(context).r3hNoVotingTopics),
          )
        ],
      );
    }

    return ModalContainer(
      withClose: true,
      children: [
        if (isOwner)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppCard(
                padding: 0,
                child: ListTile(
                  title: Text(AppLocalizations.of(context).tokenCreateNewVotingTopic),
                  subtitle: Text(AppLocalizations.of(context).tokenCreateNewVotingTopicBody),
                  trailing: Icon(Icons.add),
                  onTap: () {
                    AutoRouter.of(context).push(CreateTokenTopicScreenRoute(scId: token.smartContractId, address: address));
                  },
                )),
          ),
        ...data.topics.map((t) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppCard(
              padding: 0,
              child: ListTile(
                title: Text(t.topicName),
                subtitle: Text(
                  t.topicDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TokenTopicDetailScreen(t.toNative(), address, balance, isOwner),
                    ),
                  );
                },
              ),
            ),
          );
        })
      ],
    );
  }
}

class WebTokenListBannedAddressesButton extends StatelessWidget {
  const WebTokenListBannedAddressesButton({
    super.key,
    required this.token,
  });

  final WebFungibleToken token;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: AppLocalizations.of(context).tokenListBansWithCount(token.bannedAddresses.length.toString()),
      variant: AppColorVariant.Primary,
      onPressed: () {
        InfoDialog.show(
          title: AppLocalizations.of(context).tokenBannedAddressesTitle,
          body: token.bannedAddresses.join("\n"),
          closeText: AppLocalizations.of(context).actionClose,
        );
      },
    );
  }
}

class WebTokenBanAddressButton extends BaseComponent {
  const WebTokenBanAddressButton({
    super.key,
    required this.token,
  });

  final WebFungibleToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: AppLocalizations.of(context).tokenBanAddress,
      variant: AppColorVariant.Danger,
      onPressed: () async {
        final manager = ref.read(webTokenActionsManager);
        if (!manager.guardIsTokenOwnerAndNotVault(token)) {
          return;
        }
        if (!manager.verifyBalance()) {
          return;
        }
        final address = await manager.promptForAddress(title: AppLocalizations.of(context).r3hAddressToBan);
        if (address == null) {
          return;
        }

        final success = await manager.banAddress(token, token.ownerAddress, address);
      },
    );
  }
}

class WebPauseTokenButton extends BaseComponent {
  const WebPauseTokenButton({
    super.key,
    required this.token,
  });

  final WebFungibleToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: token.isPaused ? l10n.r3hResumeTxs : l10n.r3hPauseTxs,
      variant: AppColorVariant.Light,
      onPressed: () async {
        final manager = ref.read(webTokenActionsManager);

        if (!manager.guardIsTokenOwnerAndNotVault(token)) {
          return;
        }
        if (!manager.verifyBalance()) {
          return;
        }

        final confirmed = await ConfirmDialog.show(
          title: token.isPaused ? l10n.r3hResumeTransactions : l10n.r3hPauseTransactions,
          body: token.isPaused
              ? l10n.r3hResumeTxConfirmBody
              : l10n.r3hPauseTxConfirmBody,
          confirmText: l10n.actionYes,
          cancelText: l10n.actionNo,
        );
        if (confirmed == true) {
          final success = await manager.pause(token, token.ownerAddress, !token.isPaused);
        }
      },
    );
  }
}

class WebChangeTokenOwnershipButton extends BaseComponent {
  const WebChangeTokenOwnershipButton({
    super.key,
    required this.token,
  });

  final WebFungibleToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.tokenChangeOwnership,
      variant: AppColorVariant.Secondary,
      onPressed: () async {
        final manager = ref.read(webTokenActionsManager);

        if (!manager.guardIsTokenOwner(token)) {
          return;
        }

        if (!manager.verifyBalance(isRa: token.ownerAddress.startsWith('xRBX'))) {
          return;
        }
        final address = await manager.promptForAddress(title: l10n.r3hNewOwnerAddress);
        if (address == null) {
          return;
        }

        if (token.ownerAddress.startsWith("xRBX")) {
          final raKeypair = ref.read(webSessionProvider).raKeypair;

          if (raKeypair == null || raKeypair.address != token.ownerAddress) {
            Toast.error(l10n.r3hVaultKeypairNotFound(token.ownerAddress));
            return;
          }

          final hoursString = await PromptModal.show(
            title: l10n.svcTimelockDuration,
            validator: (_) => null,
            labelText: l10n.r3hHours24Minimum,
            initialValue: "24",
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          );

          int unlockHours = (hoursString != null ? int.tryParse(hoursString) : 24) ?? 24;
          if (unlockHours < 24) {
            unlockHours = 24;
          }
          final success = await manager.transferOwnershipFromVault(
            token,
            address,
            token.ownerAddress,
            raKeypair,
            unlockHours,
          );
          return;
        }
        final success = await manager.transferOwnership(
          token,
          address,
          token.ownerAddress,
        );
      },
    );
  }
}

class WebMintTokenButton extends BaseComponent {
  const WebMintTokenButton({
    super.key,
    required this.raIsOwner,
    required this.token,
  });

  final bool raIsOwner;
  final WebFungibleToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.tokenMintTokens,
      variant: AppColorVariant.Success,
      onPressed: () async {
        final manager = ref.read(webTokenActionsManager);

        if (!manager.guardIsTokenOwnerAndNotVault(token)) {
          return;
        }

        if (!manager.verifyBalance()) {
          return;
        }

        final amount = await manager.promptForAmount(title: l10n.tokenAmountToMintTitle);

        if (amount == null) {
          return;
        }

        final success = await manager.mintTokens(token, token.ownerAddress, amount);
      },
    );
  }
}
