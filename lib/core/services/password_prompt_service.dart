import 'package:flutter/material.dart';

import '../../utils/toast.dart';
import '../../utils/validation.dart';
import '../../l10n/generated/app_localizations.dart';
import '../dialogs.dart';
import 'password_verification_service.dart';
import '../../core/app_constants.dart';

class PasswordPromptService {
  /// Prompts user for password and verifies it against stored hash
  static Future<String?> promptAndVerifyPassword(
    BuildContext context, {
    String? title,
    String? labelText,
    String? customMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final password = await PromptModal.show(
      contextOverride: context,
      title: title ?? l10n.authEnterPassword,
      labelText: labelText ?? l10n.tkbPassword,
      body: customMessage,
      validator: (value) => formValidatorNotEmpty(value, l10n.tkbPassword),
      obscureText: true,
      revealObscure: true,
      lines: 1, // Ensure single line for password
      initialValue: DEBUG_ENCRYPTION_PASSWORD,
    );

    if (password != null) {
      final isValid = PasswordVerificationService.verifyPassword(password);
      if (isValid) {
        return password;
      } else {
        Toast.error(l10n.r3eIncorrectPassword);
        return null;
      }
    }
    return null;
  }

  /// Prompts user for new password with confirmation
  static Future<String?> promptNewPassword(
    BuildContext context, {
    String? title,
    String? labelText,
    String? customMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final password = await PromptModal.show(
      contextOverride: context,
      title: title ?? l10n.r3eSetPassword,
      labelText: labelText ?? l10n.r3eNewPassword,
      body: customMessage ?? l10n.r3ePasswordEncryptKeys,
      validator: formValidatorPassword,
      obscureText: true,
      revealObscure: true,
      lines: 1, // Ensure single line for password
      initialValue: DEBUG_ENCRYPTION_PASSWORD,
    );

    
    if (password != null) {
      // Confirm password
      final confirmPassword = await PromptModal.show(
        contextOverride: context,
        title: l10n.txpConfirmPassword,
        labelText: l10n.txpConfirmPassword,
        validator: (value) {
          if (value != password) {
            return l10n.prvPasswordsDoNotMatch;
          }
          return null;
        },
        obscureText: true,
        lines: 1, // Ensure single line for password
        initialValue: DEBUG_ENCRYPTION_PASSWORD,
      );
      
      if (confirmPassword == password) {
        return password;
      } else {
        Toast.error(l10n.r3ePasswordConfirmFailed);
        return null;
      }
    }
    return null;
  }

  /// Wrapper for sensitive operations that require password verification
  static Future<void> requirePasswordFor(
    BuildContext context,
    Future<void> Function(String password) operation, {
    String? customMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final password = await promptAndVerifyPassword(
      context,
      title: l10n.txpConfirmPassword,
      customMessage:
          customMessage ?? l10n.r3eSensitiveOperationPassword,
    );

    if (password != null) {
      await operation(password);
    }
  }
}