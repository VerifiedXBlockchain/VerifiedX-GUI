import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app.dart';
import 'ra_auto_activate_provider.dart';
import '../../nft/providers/transferred_provider.dart';
import '../../wallet/providers/wallet_detail_provider.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../bridge/services/bridge_service.dart';
import 'pending_activation_provider.dart';
import '../services/reserve_account_service.dart';
import '../../wallet/components/wallet_selector.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../components/balance_indicator.dart';
import 'package:collection/collection.dart';
import '../../../l10n/generated/app_localizations.dart';

class ReserveAccountProvider extends StateNotifier<List<Wallet>> {
  final Ref ref;
  Timer? timer;

  ReserveAccountProvider(this.ref, [List<Wallet> model = const []]) : super(model);

  set(List<Wallet> wallets) {
    state = wallets.reversed.toList();
  }

  Future<void> newAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final password = await PromptModal.show(
      contextOverride: context,
      title: l10n.txpSetupVaultAccount,
      body: l10n.txpSetupVaultAccountBody,
      validator: (value) => formValidatorNotEmpty(value, l10n.reservePasswordLabel),
      labelText: l10n.reservePasswordLabel,
      obscureText: true,
      lines: 1,
      revealObscure: true,
    );

    if (password == null || password.isEmpty) {
      return;
    }

    final passwordConfirmation = await PromptModal.show(
      contextOverride: context,
      title: l10n.txpConfirmPassword,
      body: l10n.txpConfirmPasswordBody,
      validator: (value) => formValidatorNotEmpty(value, l10n.reservePasswordLabel),
      labelText: l10n.reservePasswordLabel,
      obscureText: true,
      lines: 1,
      revealObscure: true,
    );

    if (passwordConfirmation == null) {
      Toast.error(l10n.txpMustConfirmPassword);
      return;
    }

    if (password != passwordConfirmation) {
      Toast.error(l10n.txpPasswordsDoNotMatch);
      return;
    }

    final account = await ReserveAccountService().create(password);

    if (account == null) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ReserveAccountDetails(account: account);
      },
    );

    fundAccount(rootNavigatorKey.currentContext!, account.address);
  }

  Future<void> fundAccount(BuildContext context, String walletAddress) async {
    final l10n = AppLocalizations.of(context);
    final funders = ref.read(walletListProvider).where((w) => !w.isReserved && w.balance > (w.isValidating ? 1006 : 6)).toList();
    final fundingWallet = funders.isNotEmpty ? funders.first : null;

    if (fundingWallet != null) {
      final shouldSendFunds = await ConfirmDialog.show(
        title: l10n.txpFundAccount,
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.txpFundVaultBody),
              Text(""),
              SelectableText(l10n.txpPleaseSendFundsTo(walletAddress)),
              Text(""),
              Text(l10n.txpSufficientBalanceBody(
                  fundingWallet.address, "${fundingWallet.balance}")),
            ],
          ),
        ),
        confirmText: l10n.actionSend,
        cancelText: l10n.actionCancel,
      );

      if (shouldSendFunds == true) {
        const amount = 5.0;

        final confirmed = await ConfirmDialog.show(
          title: l10n.btcPleaseConfirmTitle,
          body: l10n.txpSendingConfirmBody(
              "$amount", walletAddress, fundingWallet.address),
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
          await InfoDialog.show(
            contextOverride: context,
            title: l10n.txpFundsSent,
            body: l10n.txpFundsSentBody("$amount", walletAddress),
          );
          // Navigator.of(context).pop();

          final confirmed = await ConfirmDialog.show(
            title: l10n.txpAutoActivate,
            body: l10n.txpAutoActivateBody,
            confirmText: l10n.actionYes,
            cancelText: l10n.actionNo,
          );

          if (confirmed == true) {
            final password = await PromptModal.show(
              contextOverride: context,
              title: l10n.reservePasswordLabel,
              validator: (v) => null,
              lines: 1,
              obscureText: true,
              labelText: l10n.reservePasswordLabel,
              revealObscure: true,
            );

            if (password != null) {
              ref.read(reserveAccountAutoActivateProvider.notifier).add(txHash, walletAddress, password);
              ref.read(pendingActivationProvider.notifier).addId(walletAddress);
              Toast.message(l10n.txpAutoActivateQueued);
            }
          }
        } else {
          Toast.error();
        }
      }
    } else {
      InfoDialog.show(
          contextOverride: context,
          title: l10n.txpFundAccount,
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.txpFundVaultBodyShort),
                Text(""),
                Text(l10n.txpPleaseSendFundsTo(walletAddress)),
                Divider(),
                AppButton(
                  label: l10n.txpCopyAddress,
                  icon: Icons.copy,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: walletAddress));
                    Toast.message(l10n.txpAddressCopiedClipboard);
                  },
                )
              ],
            ),
          ));
    }
  }

  Future<void> restoreAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final restoreCode = await PromptModal.show(
      contextOverride: context,
      title: l10n.walletRestoreCodeLabel,
      body: l10n.webRestoreCodeBody,
      validator: (v) => null,
      labelText: l10n.walletRestoreCodeLabel,
    );

    if (restoreCode == null) return;
    final password = await PromptModal.show(
      contextOverride: context,
      title: l10n.reservePasswordLabel,
      validator: (v) => null,
      lines: 1,
      obscureText: true,
      labelText: l10n.reservePasswordLabel,
      revealObscure: true,
    );
    if (password == null) return;

    final account = await ReserveAccountService().restore(restoreCode: restoreCode, password: password);

    if (account != null) {
      await ref.read(sessionProvider.notifier).loadWallets();

      showDialog(
        context: context,
        builder: (context) {
          return ReserveAccountDetails(account: account);
        },
      );
    }
  }

  Future<void> recoverAccount(BuildContext context, String address) async {
    final l10n = AppLocalizations.of(context);
    final recoveryPhrase = await PromptModal.show(
      contextOverride: context,
      title: l10n.walletRestoreCodeLabel,
      body: l10n.txpRestoreCodeRecoveryBody,
      validator: (v) => null,
      labelText: l10n.walletRestoreCodeLabel,
    );

    if (recoveryPhrase == null || recoveryPhrase.isEmpty) return;

    final password = await PromptModal.show(
      contextOverride: context,
      title: l10n.reservePasswordLabel,
      validator: (v) => null,
      lines: 1,
      obscureText: true,
      labelText: l10n.reservePasswordLabel,
      revealObscure: true,
    );
    if (password == null || password.isEmpty) return;

    final hash = await ReserveAccountService().recoverAccount(password: password, recoveryPhrase: recoveryPhrase, address: address);

    if (hash != null) {
      final w = ref.read(walletListProvider).firstWhereOrNull((e) => e.address == address);

      if (w != null) {
        ref.read(walletDetailProvider(w).notifier).delete();

        if (ref.read(sessionProvider).currentWallet?.address == address) {
          if (ref.read(walletListProvider).isNotEmpty) {
            ref.read(sessionProvider.notifier).setCurrentWallet(ref.read(walletListProvider).first);
          }
        }
      }

      await ref.read(sessionProvider.notifier).loadWallets();
      ref.read(transferredProvider.notifier).clear();

      RecoverDialog.show(hash: hash);
    }
  }

  void showBalanceInfo(BuildContext context, Wallet wallet) {
    final l10n = AppLocalizations.of(context);
    if (wallet.isReserved) {
      InfoDialog.show(
        contextOverride: context,
        title: l10n.reserveWebVaultBalanceTitle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BalanceIndicator(
              label: l10n.labelAvailable,
              value: wallet.availableBalance,
              bgColor: Colors.deepPurple.shade400,
              fgColor: Colors.white,
            ),
            BalanceIndicator(
              label: l10n.labelLocked,
              value: wallet.lockedBalance,
              bgColor: Colors.red.shade700,
              fgColor: Colors.white,
            ),
            BalanceIndicator(
              label: l10n.labelTotal,
              value: wallet.totalBalance,
              bgColor: Colors.green.shade700,
              fgColor: Colors.white,
            ),
          ],
        ),
      );
    } else {
      InfoDialog.show(
        contextOverride: context,
        title: l10n.txpAccountBalance,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BalanceIndicator(
              label: l10n.labelAvailable,
              value: wallet.balance,
              bgColor: Colors.white,
              fgColor: Colors.black,
            ),
            BalanceIndicator(
              label: l10n.labelLocked,
              value: wallet.lockedBalance,
              bgColor: Colors.red.shade700,
              fgColor: Colors.white,
            ),
            BalanceIndicator(
              label: l10n.labelTotal,
              value: wallet.balance + wallet.lockedBalance,
              bgColor: Colors.green.shade700,
              fgColor: Colors.white,
            ),
          ],
        ),
      );
    }
  }

  Future<void> activate(
    BuildContext context,
    Wallet wallet,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (!wallet.isReserved) {
      Toast.error(l10n.txpNotVaultAccount);
      return;
    }

    if (wallet.availableBalance < 5) {
      Toast.error(l10n.txpMinBalanceActivate);
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.txpActivateOnNetwork,
      body: l10n.txpActivateOnNetworkBody,
      confirmText: l10n.reserveActivateNow,
      cancelText: l10n.actionCancel,
    );

    if (confirmed == true) {
      final password = await PromptModal.show(
        contextOverride: context,
        title: l10n.reservePasswordLabel,
        validator: (v) => null,
        lines: 1,
        obscureText: true,
        labelText: l10n.reservePasswordLabel,
        revealObscure: true,
      );
      if (password == null) {
        return;
      }
      final success = await ReserveAccountService().publish(
        address: wallet.address,
        password: password,
      );

      if (success) {
        OverlayToast.message(message: l10n.txpVaultActivationSent);
        // Toast.message("Vault Account publish transaction sent.");
        ref.read(pendingActivationProvider.notifier).addId(wallet.address);
      }
    }
  }
}

final reserveAccountProvider = StateNotifierProvider<ReserveAccountProvider, List<Wallet>>((ref) {
  return ReserveAccountProvider(ref);
});
