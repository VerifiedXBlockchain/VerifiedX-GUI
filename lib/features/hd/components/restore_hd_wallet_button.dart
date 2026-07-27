import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/services/bridge_service.dart';
import '../../../l10n/generated/app_localizations.dart';

class RestoreHdWalletButton extends BaseComponent {
  const RestoreHdWalletButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.r3dRestoreHdAccount,
      icon: Icons.hd_outlined,
      onPressed: !ref.watch(sessionProvider.select((v) => v.cliStarted))
          ? null
          : () async {
              final val = await PromptModal.show(
                title: l10n.r3dInputRecoverPhrase,
                validator: (value) => formValidatorNotEmpty(value, l10n.walletRecoveryPhrase),
                labelText: l10n.walletRecoveryPhrase,
              );

              if (val != null) {
                final success = await BridgeService().restoreHd(val);
                if (success == true) {
                  Toast.message(l10n.r3dHdAccountRestored);
                } else {
                  Toast.error();
                }
              }
            },
    );
  }
}
