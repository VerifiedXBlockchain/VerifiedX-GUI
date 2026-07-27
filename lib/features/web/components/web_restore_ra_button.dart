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

        final data = utf8.decode(base64.decode(restoreCode));

        final primaryPrivateKey = data.split("//")[0];

        final tempKeypair = await KeygenService.importReserveAccountPrivateKey(
            primaryPrivateKey);

        final recoveryPrivateKey = data.split("//")[1];

        final recoveryKeypair =
            await KeygenService.importPrivateKey(recoveryPrivateKey);

        final raKeypair = RaKeypair(
          private: tempKeypair.private,
          address: tempKeypair.address,
          public: tempKeypair.public,
          recoveryPrivate: recoveryKeypair.private,
          recoveryAddress: recoveryKeypair.address,
          recoveryPublic: recoveryKeypair.public,
          restoreCode: restoreCode,
        );

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
