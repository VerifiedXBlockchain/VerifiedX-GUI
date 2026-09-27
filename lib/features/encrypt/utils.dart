import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_loader/global_loading_provider.dart';
import '../reserve/services/reserve_account_service.dart';

import '../../app.dart';
import '../../core/dialogs.dart';
import '../../core/providers/session_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_helper.dart';
import '../../utils/toast.dart';
import '../../utils/validation.dart';
import 'providers/password_required_provider.dart';
import 'providers/startup_password_required_provider.dart';

Future<bool> passwordRequiredGuard(
  BuildContext context,
  WidgetRef ref, [
  bool prompt = true,
  bool forValidating = false,
]) async {
  if (kIsWeb) {
    return true;
  }
  // Always ask the node: the cached state is only refreshed every 10 s, so
  // right after encrypting or after the node clears the password it can
  // still say "unlocked" (MTI#6). If the node can't be asked, fall back to
  // the cached state.
  bool required;
  try {
    required = await ref.read(passwordRequiredProvider.notifier).check();
  } catch (e) {
    print("Password check failed: $e");
    required = ref.read(passwordRequiredProvider);
  }
  if (!required) {
    return true;
  }

  if (prompt) {
    final success = await promptForPassword(context, ref, forValidating);
    if (success == null) {
      return false;
    }

    await ref.read(sessionProvider.notifier).loadWallets();

    if (success == false) {
      Toast.error(AppLocalizations.of(context).r3gIncorrectDecryptionPassword);
      return false;
    }
    return true;
  }
  return false;
}

Future<bool> passwordRequiredGuardV2(
  BuildContext context,
  WidgetRef ref,
  String address, [
  bool prompt = true,
  bool forValidating = false,
]) async {
  if (kIsWeb) {
    return true;
  }

  // The node refuses the reserve unlock route while the encrypted wallet
  // itself is locked, so that is unlocked first.
  if (!await passwordRequiredGuard(context, ref, prompt, forValidating)) {
    return false;
  }

  final alreadyUnlocked = await ReserveAccountService().isUnlockedV2(address);
  if (alreadyUnlocked) {
    return true;
  }

  final l10n = AppLocalizations.of(context);
  final password = await PromptModal.show(
    title: l10n.r3gUnlockAccount,
    contextOverride: context,
    validator: (value) => formValidatorNotEmpty(value, l10n.reservePasswordLabel),
    labelText: l10n.reservePasswordLabel,
    obscureText: true,
    revealObscure: true,
    lines: 1,
    tightPadding: true,
    fieldKey: const ValueKey('auth:password'),
    submitKey: const Key('auth:password_submit'),
  );
  if (password == null) {
    return false;
  }

  final unlocked = await ReserveAccountService().unlockV2(address, password);
  if (unlocked) {
    return true;
  }

  Toast.error(l10n.r3gIncorrectDecryptionPassword);

  return false;
}

Future<bool?> promptForPassword(BuildContext context, WidgetRef ref, [bool forValidating = false]) async {
  final l10n = AppLocalizations.of(context);
  final password = await PromptModal.show(
    title: l10n.r3gUnlockAccount,
    contextOverride: context,
    validator: (value) => formValidatorNotEmpty(value, l10n.reservePasswordLabel),
    labelText: l10n.reservePasswordLabel,
    obscureText: true,
    revealObscure: true,
    lines: 1,
    tightPadding: true,
    fieldKey: const ValueKey('auth:password'),
    submitKey: const Key('auth:password_submit'),
  );
  if (password == null) {
    return null;
  }

  if (password.isNotEmpty) {
    ref.read(globalLoadingProvider.notifier).start();
    final success = await ref.read(passwordRequiredProvider.notifier).unlock(password);
    ref.read(globalLoadingProvider.notifier).complete();
    if (success) {
      if (forValidating) {
        Toast.message(l10n.r3gAccountUnlocked);
      } else {
        Toast.message(l10n.r3gAccountUnlocked10Min);
      }
      return true;
    }
  }

  return false;
}

/// Unlock flow for a node call the node refused because the wallet is locked
/// (registered as [LockedWalletGate.unlocker] by the native app). Marks the
/// wallet as locked, asks for the password on the root navigator and returns
/// true once the node is unlocked.
Future<bool> unlockForLockedRequest(WidgetRef ref) async {
  if (kIsWeb) {
    return false;
  }
  ref.read(passwordRequiredProvider.notifier).markRequired();

  // The startup unlock screen is up (the router's navigator isn't mounted):
  // the user unlocks there.
  if (ref.read(startupPasswordRequiredProvider)) {
    return false;
  }

  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return false;
  }

  // The action that got refused may have raised the global loading overlay,
  // which sits above the navigator and would cover the prompt.
  final wasLoading = ref.read(globalLoadingProvider);
  if (wasLoading) {
    ref.read(globalLoadingProvider.notifier).complete();
  }

  try {
    final success = await promptForPassword(context, ref);
    if (success == null) {
      return false;
    }
    if (success == false) {
      Toast.error(globalL10n.r3gIncorrectDecryptionPassword);
      return false;
    }
    await ref.read(sessionProvider.notifier).loadWallets();
    return true;
  } finally {
    if (wasLoading) {
      ref.read(globalLoadingProvider.notifier).start();
    }
  }
}
