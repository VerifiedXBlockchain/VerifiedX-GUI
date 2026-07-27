import 'package:flutter/material.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/dialogs.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';

class RestartCliButton extends BaseComponent {
  const RestartCliButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cliStarted = ref.watch(sessionProvider.select((v) => v.cliStarted));

    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.validatorRestartCliTitle,
      icon: Icons.restart_alt,
      onPressed: cliStarted
          ? () async {
              final confirmed = await ConfirmDialog.show(
                title: l10n.r3eRestart,
                body: l10n.r3eRestartCliConfirm,
                confirmText: l10n.r3eRestart,
                cancelText: l10n.actionCancel,
                destructive: true,
              );

              if (confirmed == true) {
                ref.read(sessionProvider.notifier).restartCli();
              }
            }
          : null,
    );
  }
}
