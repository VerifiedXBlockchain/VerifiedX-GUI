import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/services/bridge_service.dart';
import '../../encrypt/utils.dart';
import '../../../l10n/generated/app_localizations.dart';

class RestoreHdWalletButton extends BaseComponent {
  const RestoreHdWalletButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      key: const Key('hd:restore'),
      label: l10n.r3dRestoreHdAccount,
      icon: Icons.hd_outlined,
      onPressed: !ref.watch(sessionProvider.select((v) => v.cliStarted))
          ? null
          : () async {
              if (!await passwordRequiredGuard(context, ref)) return;
              final val = await PromptModal.show(
                title: l10n.r3dInputRecoverPhrase,
                validator: (value) => formValidatorNotEmpty(value, l10n.walletRecoveryPhrase),
                labelText: l10n.walletRecoveryPhrase,
                fieldKey: const ValueKey('hd:restore_phrase'),
                submitKey: const Key('hd:restore_submit'),
              );

              if (val != null) {
                final failure = await BridgeService().restoreHd(val);
                if (failure == null) {
                  Toast.message(l10n.r3dHdAccountRestored);
                } else {
                  Toast.error(failure.isEmpty ? null : failure);
                }
              }
            },
    );
  }
}
