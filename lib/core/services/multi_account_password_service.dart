import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/web/models/multi_account_instance.dart';
import '../../features/web/providers/multi_account_provider.dart';
import '../../utils/toast.dart';
import '../../utils/validation.dart';
import '../dialogs.dart';
import '../singletons.dart';
import '../storage.dart';
import 'multi_account_encryption_service.dart';
import 'password_prompt_service.dart';
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
      final storage = singleton<Storage>();
      final savedData = storage.getList(Storage.MULTIPLE_ACCOUNTS);

      bool hasEncryptedKeys = false;
      if (savedData != null) {
        // Find the stored JSON for this account
        final storedAccountJson = savedData.map((e) => jsonDecode(e) as Map<String, dynamic>).where((json) => json['id'] == account.id).firstOrNull;

        hasEncryptedKeys = storedAccountJson != null && MultiAccountEncryptionService.hasEncryptedPrivateKeys(storedAccountJson);
      }

      if (hasEncryptedKeys) {
        // Prompt for password without confirmation (since it's an existing password, not a new one)
        final password = await PromptModal.show(
          contextOverride: context,
          title: "Enter Account Password",
          labelText: "Account Password",
          body: "Enter the password for this account to decrypt its private keys.",
          validator: (value) => formValidatorNotEmpty(value, "Password"),
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
      Toast.error("Failed to decrypt account keys. Check your password.");
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
    return await PasswordPromptService.promptNewPassword(
      context,
      title: "Encrypt Account Keys",
      labelText: "Account Password",
      customMessage: "Enter a password to encrypt this account's private keys.",
    );
  }
}
