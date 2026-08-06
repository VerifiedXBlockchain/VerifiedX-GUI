import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/dialogs.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/toast.dart';
import '../../../../utils/validation.dart';
import '../../../bridge/services/bridge_service.dart';
import '../../../global_loader/global_loading_provider.dart';
import '../../../validator/providers/current_validator_provider.dart';
import '../../../wallet/providers/wallet_list_provider.dart';
import '../../../encrypt/providers/password_required_provider.dart';
import '../../../encrypt/providers/wallet_is_encrypted_provider.dart';

class EncryptWalletButton extends BaseComponent {
  const EncryptWalletButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // if (ref.watch(walletListProvider).isEmpty) {
    //   return SizedBox.shrink();
    // }

    final l10n = AppLocalizations.of(context);
    if (ref.watch(walletIsEncryptedProvider)) {
      if (ref.watch(passwordRequiredProvider)) {
        return AppButton(
          icon: Icons.lock_open_rounded,
          label: l10n.r3eUnlockWallet,
          onPressed: !ref.watch(sessionProvider.select((v) => v.cliStarted))
              ? null
              : () async {
                  final password = await PromptModal.show(
                    title: l10n.r3eUnlockWallet,
                    validator: (value) =>
                        formValidatorNotEmpty(value, l10n.tkbPassword),
                    labelText: l10n.tkbPassword,
                    obscureText: true,
                    revealObscure: true,
                    lines: 1,
                  );

                  if (password != null && password.isNotEmpty) {
                    final success = await ref.read(passwordRequiredProvider.notifier).unlock(password);
                    await ref.read(sessionProvider.notifier).loadWallets();

                    if (success) {
                      if (ref.watch(currentValidatorProvider)?.isValidating == true) {
                        Toast.message(l10n.r3eWalletUnlocked);
                      } else {
                        Toast.message(l10n.r3eWalletUnlocked10Min);
                      }
                    } else {
                      Toast.error(l10n.r3eIncorrectDecryptionPassword);
                    }
                  }
                },
        );
      }

      return AppButton(
        label: l10n.webLockWallet,
        icon: Icons.lock,
        onPressed: !ref.watch(sessionProvider.select((v) => v.cliStarted))
            ? null
            : () async {
                if (ref.read(currentValidatorProvider)?.isValidating == true) {
                  Toast.error(l10n.r3eCannotLockWhileValidating);
                  return;
                }
                final success = await ref.read(passwordRequiredProvider.notifier).lock();

                if (success) {
                  Toast.message(l10n.r3eWalletLocked);
                } else {
                  Toast.error();
                }
              },
      );
    }

    return AppButton(
      label: l10n.r3eEncryptWallet,
      icon: Icons.lock,
      onPressed: !ref.watch(sessionProvider.select((v) => v.cliStarted))
          ? null
          : () async {
              if (ref.read(walletListProvider).isEmpty) {
                Toast.error(l10n.r3eNoKeysToEncrypt);
                return;
              }

              final password = await PromptModal.show(
                title: l10n.r3eEncryptWallet,
                validator: (value) =>
                    formValidatorNotEmpty(value, l10n.tkbPassword),
                labelText: l10n.motherCreatePasswordLabel,
                obscureText: true,
                revealObscure: true,
                lines: 1,
                body: l10n.r3eEncryptWalletBody,
                confirmText: l10n.r3eAgree,
                cancelText: l10n.actionCancel,
              );

              if (password != null && password.isNotEmpty) {
                final confirmedPassword = await PromptModal.show(
                  title: l10n.txpConfirmPassword,
                  validator: (value) =>
                      formValidatorNotEmpty(value, l10n.tkbPassword),
                  labelText: l10n.tkbPassword,
                  obscureText: true,
                  revealObscure: true,
                  lines: 1,
                  body: l10n.r3eConfirmEncryptionPassword,
                );

                if (confirmedPassword != null && confirmedPassword.isNotEmpty) {
                  if (password != confirmedPassword) {
                    Toast.error(l10n.r3ePasswordsDoNotMatchRetry);
                    return;
                  }
                }

                ref.read(globalLoadingProvider.notifier).start();
                final error = await BridgeService().encryptWallet(password);
                ref.read(globalLoadingProvider.notifier).complete();

                if (error != null) {
                  Toast.error(error);
                } else {
                  Toast.message(l10n.r3eWalletEncrypted);
                  ref.read(walletIsEncryptedProvider.notifier).set(true);
                }
              }
            },
    );
  }
}
