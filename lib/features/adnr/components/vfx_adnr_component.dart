import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../bridge/services/bridge_service.dart';
import '../../wallet/models/wallet.dart';

import '../../../core/app_constants.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../encrypt/utils.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../providers/adnr_pending_provider.dart';
import '../services/adnr_service.dart';
import '../../../core/utils/tx_refresh.dart';
import 'create_adnr_dialog.dart';

class VfxAdnrCard extends BaseComponent {
  const VfxAdnrCard({
    super.key,
    required this.wallet,
  });

  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context);
      final adnrVerified = wallet.adnr != null;
      final adnrLabel = wallet.adnr == null ? l10n.adnrNoDomain : "@${wallet.adnr!}";
      final isPendingCreate = ref.watch(adnrPendingProvider).contains("${wallet.address}.create.${wallet.adnr ?? 'null'}");

      final isPendingBurn = ref.watch(adnrPendingProvider).contains("${wallet.address}.burn.${wallet.adnr ?? 'null'}");

      final isPendingTransfer = ref.watch(adnrPendingProvider).contains("${wallet.address}.transfer.${wallet.adnr ?? 'null'}");

      return AppCard(
        padding: 4,
        child: ListTile(
          leading: Icon(wallet.adnr != null ? Icons.link : Icons.link_off),
          title: SelectableText(wallet.address),
          subtitle: wallet.adnr != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AppBadge(
                        label: "@${wallet.adnr!}",
                        variant: AppColorVariant.Secondary,
                      ),
                    ),
                  ],
                )
              : Text(l10n.adnrNoDomain),
          isThreeLine: false,
          trailing: Builder(
            builder: (context) {
              if (isPendingBurn) {
                return AppBadge(
                  label: l10n.adnrDeletePending,
                  variant: AppColorVariant.Danger,
                );
              }

              if (isPendingTransfer) {
                return AppBadge(
                  label: l10n.adnrTransferPending,
                  variant: AppColorVariant.Dark,
                );
              }

              if (isPendingCreate) {
                return AppBadge(
                  label: l10n.adnrCreatePending,
                  variant: AppColorVariant.Warning,
                );
              }

              if (wallet.adnr == null) {
                return AppButton(
                  label: l10n.adnrCreateDomain,
                  // type: AppButtonType.Text,
                  variant: AppColorVariant.Success,
                  onPressed: () async {
                    if (!await passwordRequiredGuard(context, ref)) return;
                    if (!widgetGuardWalletIsSynced(ref)) return;

                    if (wallet.balance < (ADNR_COST + MIN_RBX_FOR_SC_ACTION)) {
                      fundWallet(context, wallet.address, ref);
                      // Toast.error("Not enough VFX in this wallet to create a VFX domain. $ADNR_COST RBX required (plus TX fee).");
                      return;
                    }

                    showDialog(
                        context: context,
                        builder: (context) {
                          return CreateAdnrDialog(
                            address: wallet.address,
                            adnr: wallet.adnr,
                          );
                        });
                  },
                );
              } else {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      label: l10n.adnrTransfer,
                      onPressed: !adnrVerified
                          ? null
                          : () async {
                              if (!await passwordRequiredGuard(context, ref)) return;
                              if (!widgetGuardWalletIsSynced(ref)) {
                                return;
                              }
                              if (wallet.balance < (ADNR_TRANSFER_COST + MIN_RBX_FOR_SC_ACTION)) {
                                Toast.error(l10n.adnrInsufficientFundsCreateInWallet(ADNR_COST.toString()));
                                return;
                              }

                              PromptModal.show(
                                  contextOverride: context,
                                  title: l10n.adnrTransferDomainTitle,
                                  body: l10n.adnrTransferDomainBody(ADNR_TRANSFER_COST.toString()),
                                  validator: (value) => formValidatorRbxAddress(value, false),
                                  labelText: l10n.adnrAddressFieldLabel,
                                  onValidSubmission: (toAddress) async {
                                    final result = await AdnrService().transferAdnr(wallet.address, toAddress);
                                    if (result.success) {
                                      Toast.message(l10n.adnrTransferTxBroadcastedToast);

                                      if (result.hash != null) {
                                        ref.read(logProvider.notifier).append(
                                              LogEntry(
                                                  message: l10n.adnrLogTransferEntry(result.hash!),
                                                  textToCopy: result.hash,
                                                  variant: AppColorVariant.Success),
                                            );

                                        ref.read(adnrPendingProvider.notifier).addId(wallet.address, "transfer", wallet.adnr ?? "null");
                                      }

                                      notifyTransactionSubmitted();
                                      return;
                                    }

                                    Toast.error(result.message);
                                  });
                            },
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    AppButton(
                      label: l10n.adnrDelete,
                      // type: AppButtonType.Text,
                      variant: AppColorVariant.Danger,
                      onPressed: () async {
                        if (!await passwordRequiredGuard(context, ref)) return;
                        if (!widgetGuardWalletIsSynced(ref)) {
                          return;
                        }

                        if (wallet.balance < (ADNR_DELETE_COST + MIN_RBX_FOR_SC_ACTION)) {
                          Toast.error(l10n.adnrInsufficientFundsDeleteInWallet);

                          return;
                        }

                        final confirmed = await ConfirmDialog.show(
                          title: l10n.adnrDeleteTitle,
                          body: l10n.svcAdnrDeleteConfirmBody(ADNR_DELETE_COST == 0
                              ? l10n.svcAdnrDeleteNoCost
                              : l10n.svcAdnrDeleteWithCost('$ADNR_DELETE_COST')),
                          destructive: true,
                          cancelText: l10n.actionCancel,
                          confirmText: l10n.adnrDelete,
                        );

                        if (confirmed == true) {
                          final result = await AdnrService().deleteAdnr(wallet.address);
                          if (result.success) {
                            Toast.message(l10n.adnrDeleteTxBroadcastedToast);

                            if (result.hash != null) {
                              ref.read(logProvider.notifier).append(
                                    LogEntry(
                                        message: l10n.adnrLogDeleteEntry(result.hash!),
                                        textToCopy: result.hash,
                                        variant: AppColorVariant.Success),
                                  );
                              ref.read(adnrPendingProvider.notifier).addId(wallet.address, "burn", wallet.adnr ?? "null");
                            }
                            notifyTransactionSubmitted();
                          }
                        }
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ),
      );
    });
  }

  Future<void> fundWallet(BuildContext context, String walletAddress, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final funders = ref.read(walletListProvider).where((w) => !w.isReserved && w.balance > (w.isValidating ? 50006 : 6)).toList();
    final fundingWallet = funders.isNotEmpty ? funders.first : null;
    if (fundingWallet != null) {
      final shouldSendFunds = await ConfirmDialog.show(
        title: l10n.adnrFundAccountTitle,
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.svcAdnrFundNeededBody),
              Text(""),
              SelectableText(l10n.txpPleaseSendFundsTo(walletAddress)),
              Text(""),
              Text(l10n.svcAdnrSufficientBalanceBody(
                  fundingWallet.address, '${fundingWallet.balance}')),
            ],
          ),
        ),
        confirmText: l10n.actionSend,
        cancelText: l10n.actionCancel,
      );

      if (shouldSendFunds == true) {
        const amount = 6.0;

        final confirmed = await ConfirmDialog.show(
          title: l10n.btcPleaseConfirmTitle,
          body: l10n.txpSendingConfirmBody('$amount', walletAddress, fundingWallet.address),
          confirmText: l10n.actionSend,
          cancelText: l10n.actionCancel,
        );

        if (confirmed != true) {
          return;
        }

        final message = await BridgeService().sendFunds(
          amount: amount,
          to: walletAddress.replaceAll("\n", ""),
          from: fundingWallet.address,
        );

        if (message != null) {
          final txHash = message.replaceAll("Success! TxId: ", "");
          ref.read(logProvider.notifier).append(
                LogEntry(message: message, textToCopy: txHash, variant: AppColorVariant.Success),
              );
          notifyTransactionSubmitted();
          await InfoDialog.show(
            contextOverride: context,
            title: l10n.adnrFundsSentTitle,
            body: l10n.adnrFundsSentBody(amount.toString(), walletAddress),
          );
        }
      }
    } else {
      InfoDialog.show(
          contextOverride: context,
          title: l10n.adnrFundAccountTitle,
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("You must now fund your Vault Account with a minimum of 5 VFX."),
                // Text(""),
                Text(l10n.txpPleaseSendFundsTo(walletAddress)),
                Divider(),
                AppButton(
                  label: l10n.adnrFundCopyAddress,
                  icon: Icons.copy,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: walletAddress));
                    Toast.message(l10n.adnrAddressCopiedToast);
                  },
                )
              ],
            ),
          ));
    }
  }
}
