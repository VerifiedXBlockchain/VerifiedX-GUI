import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/web/models/multi_account_instance.dart';
import '../../features/web/providers/multi_account_provider.dart';
import '../../utils/toast.dart';
import '../../utils/validation.dart';
import '../dialogs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../singletons.dart';
import '../storage.dart';
import 'multi_account_encryption_service.dart';
import 'password_prompt_service.dart';
import 'web_account_password_store.dart';
import 'package:collection/collection.dart';

class MultiAccountPasswordService {
  /// Switches to an account, prompting for password if needed
  static Future<bool> switchToAccount(
    BuildContext context,
    WidgetRef ref,
    MultiAccountInstance account,
  ) async {
    try {
      // Check if the stored version has encrypted keys by looking at storage
      final storedAccountJson = WebAccountPasswordStore(singleton<Storage>()).storedAccount(account.id);
      final hasEncryptedKeys = storedAccountJson != null && MultiAccountEncryptionService.hasEncryptedPrivateKeys(storedAccountJson);

      if (hasEncryptedKeys) {
        // Prompt for password without confirmation (since it's an existing password, not a new one)
        final l10n = AppLocalizations.of(context);
        final password = await PromptModal.show(
          contextOverride: context,
          title: l10n.hnavEnterAccountPasswordTitle,
          labelText: l10n.encryptPasswordHint,
          body: l10n.r3eDecryptAccountPasswordBody,
          validator: (value) => formValidatorNotEmpty(value, l10n.tkbPassword),
          obscureText: true,
          revealObscure: true,
          lines: 1,
        );

        if (password == null) {
          return false; // User cancelled
        }

        // Switch to account with password
        await ref.read(selectedMultiAccountProvider.notifier).set(account, password);
        return true;
      } else {
        // No encryption, switch normally
        await ref.read(selectedMultiAccountProvider.notifier).set(account);
        return true;
      }
    } catch (e) {
      print("Error switching to account: $e");
      Toast.error(
          AppLocalizations.of(context).r3eFailedDecryptKeys);
      return false;
    }
  }

  /// Switches to an account by ID, prompting for password if needed
  static Future<bool> switchToAccountById(
    BuildContext context,
    WidgetRef ref,
    int accountId,
  ) async {
    final accounts = ref.read(multiAccountProvider);
    final account = accounts.where((a) => a.id == accountId).firstOrNull;

    if (account == null) {
      return false;
    }

    return await switchToAccount(context, ref, account);
  }

  /// Prompts for password when adding a new account
  static Future<String?> promptForNewAccountPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await PasswordPromptService.promptNewPassword(
      context,
      title: l10n.r3eEncryptAccountKeys,
      labelText: l10n.encryptPasswordHint,
      customMessage: l10n.r3eEncryptAccountPasswordBody,
    );
  }
}
