import 'package:flutter/material.dart';

import '../../utils/toast.dart';
import '../../utils/validation.dart';
import '../dialogs.dart';
import 'password_verification_service.dart';

class PasswordPromptService {
  /// Prompts user for password and verifies it against stored hash
  static Future<String?> promptAndVerifyPassword(
    BuildContext context, {
    String title = "Enter Password",
    String labelText = "Password",
    String? customMessage,
  }) async {
    final password = await PromptModal.show(
      contextOverride: context,
      title: title,
      labelText: labelText,
      body: customMessage,
      validator: (value) => formValidatorNotEmpty(value, "Password"),
      obscureText: true,
      revealObscure: true,
      lines: 1, // Ensure single line for password
    );

    if (password != null) {
      final isValid = PasswordVerificationService.verifyPassword(password);
      if (isValid) {
        return password;
      } else {
        Toast.error("Incorrect password");
        return null;
      }
    }
    return null;
  }

  /// Prompts user for new password with confirmation
  static Future<String?> promptNewPassword(
    BuildContext context, {
    String title = "Set Password",
    String labelText = "New Password",
    String? customMessage,
  }) async {
    final password = await PromptModal.show(
      contextOverride: context,
      title: title,
      labelText: labelText,
      body: customMessage ?? "This password will be used to encrypt your keys.",
      validator: formValidatorPassword,
      obscureText: true,
      revealObscure: true,
      lines: 1, // Ensure single line for password
    );

    
    if (password != null) {
      // Confirm password
      final confirmPassword = await PromptModal.show(
        contextOverride: context,
        title: "Confirm Password",
        labelText: "Confirm Password",
        validator: (value) {
          if (value != password) {
            return "Passwords do not match";
          }
          return null;
        },
        obscureText: true,
        lines: 1, // Ensure single line for password
      );
      
      if (confirmPassword == password) {
        return password;
      } else {
        Toast.error("Password confirmation failed");
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
    final password = await promptAndVerifyPassword(
      context,
      title: "Confirm Password",
      customMessage: customMessage ?? "Enter your password to continue with this sensitive operation.",
    );

    if (password != null) {
      await operation(password);
    }
  }
}