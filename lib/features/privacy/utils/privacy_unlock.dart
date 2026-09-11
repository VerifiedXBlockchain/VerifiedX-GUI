import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/dialogs.dart';
import '../../../l10n/l10n_helper.dart';
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

  final l10n = globalL10n;
  final password = await PromptModal.show(
    contextOverride: rootNavigatorKey.currentContext!,
    title: l10n.prvUnlockWalletTitle,
    labelText: l10n.prvPasswordLabel,
    body: l10n.prvUnlockWalletBody,
    validator: (value) => formValidatorNotEmpty(value, l10n.prvPasswordLabel),
    obscureText: true,
    revealObscure: true,
    lines: 1,
  );

  if (password != null) {
    ref.read(shieldedAddressProvider.notifier).setPassword(password);
    Toast.message(l10n.prvWalletUnlocked);
    action?.call();
  }
}
