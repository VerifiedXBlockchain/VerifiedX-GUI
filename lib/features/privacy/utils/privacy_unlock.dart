import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/dialogs.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../providers/shielded_address_provider.dart';

/// Ensures the privacy wallet is unlocked before running [action].
///
/// If already unlocked, runs [action] immediately. Otherwise, prompts the user
/// for their password and unlocks before proceeding.
Future<void> requirePrivacyUnlock(WidgetRef ref, [VoidCallback? action]) async {
  if (ref.read(privacyUnlockedProvider)) {
    action?.call();
    return;
  }

  final password = await PromptModal.show(
    contextOverride: rootNavigatorKey.currentContext!,
    title: "Unlock Privacy Wallet",
    labelText: "Password",
    body: "Enter your privacy wallet password to enable spending.",
    validator: (value) => formValidatorNotEmpty(value, "Password"),
    obscureText: true,
    revealObscure: true,
    lines: 1,
  );

  if (password != null) {
    ref.read(shieldedAddressProvider.notifier).setPassword(password);
    Toast.message("Privacy wallet unlocked");
    action?.call();
  }
}
