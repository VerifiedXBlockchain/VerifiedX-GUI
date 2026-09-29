import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../keygen/models/ra_keypair.dart';
import 'package:rbx_wallet/features/keygen/services/keygen_service.dart'
    if (dart.library.io) 'package:rbx_wallet/features/keygen/services/keygen_service_mock.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:rbx_wallet/utils/toast.dart';

class WebRestoreRaButton extends BaseComponent {
  const WebRestoreRaButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.reserveRestoreVaultAccount,
      icon: Icons.refresh,
      type: AppButtonType.Text,
      variant: AppColorVariant.Light,
      onPressed: () async {
        final confirmed = await ConfirmDialog.show(
          title: l10n.reserveRestoreVaultAccount,
          body: l10n.r3fRestoreBody,
        );

        if (confirmed != true) {
          return;
        }

        final restoreCode = await PromptModal.show(
          contextOverride: context,
          title: l10n.walletRestoreCodeLabel,
          body: l10n.r3fRestoreCodePrompt,
          validator: (v) => null,
          labelText: l10n.walletRestoreCodeLabel,
        );

        if (restoreCode == null) {
          return;
        }

        final privateKeys = decodeVaultRestoreCode(restoreCode);
        if (privateKeys == null) {
          Toast.error(l10n.webVaultRestoreCodeInvalid);
          return;
        }

        final RaKeypair raKeypair;
        try {
          final tempKeypair = await KeygenService.importReserveAccountPrivateKey(privateKeys.primary);
          final recoveryKeypair = await KeygenService.importPrivateKey(privateKeys.recovery);

          raKeypair = RaKeypair(
            private: tempKeypair.private,
            address: tempKeypair.address,
            public: tempKeypair.public,
            recoveryPrivate: recoveryKeypair.private,
            recoveryAddress: recoveryKeypair.address,
            recoveryPublic: recoveryKeypair.public,
            restoreCode: restoreCode.trim(),
          );
        } catch (e) {
          print("Vault restore key import failed: $e");
          Toast.error(l10n.webVaultRestoreCodeInvalid);
          return;
        }

        ref.read(webSessionProvider.notifier).setRaKeypair(raKeypair);

        // Only save unencrypted keys if encryption is NOT enabled (legacy mode)
        final storage = singleton<Storage>();
        if (!storage.isEncryptionEnabled()) {
          storage.setMap(Storage.WEB_RA_KEYPAIR, raKeypair.toJson());
        }

        Toast.message(l10n.webVaultRestoredToast);
      },
    );
  }
}

/// The primary and recovery private keys packed in a Vault restore code
/// (base64 of "<primary>//<recovery>").
class VaultRestoreKeys {
  final String primary;
  final String recovery;

  const VaultRestoreKeys(this.primary, this.recovery);
}

/// Decodes a pasted restore code, or returns null when it is not valid base64,
/// not UTF-8, or does not hold two non-empty keys.
VaultRestoreKeys? decodeVaultRestoreCode(String restoreCode) {
  final String data;
  try {
    data = utf8.decode(base64.decode(restoreCode.trim()));
  } on FormatException {
    return null;
  }

  final parts = data.split("//");
  if (parts.length < 2 || parts[0].isEmpty || parts[1].isEmpty) {
    return null;
  }
  return VaultRestoreKeys(parts[0], parts[1]);
}
