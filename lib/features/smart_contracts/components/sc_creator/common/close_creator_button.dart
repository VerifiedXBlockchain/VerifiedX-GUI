import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/dialogs.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../providers/create_smart_contract_provider.dart';

/// App bar close control for the smart contract creator on desktop and web.
/// Asks before discarding unsaved input, then clears the form and leaves.
class CloseSmartContractCreatorButton extends ConsumerWidget {
  /// Runs after the form is cleared when the creator has nothing to pop back
  /// to, such as a web deep link straight to the create route.
  final VoidCallback? onCannotPop;

  const CloseSmartContractCreatorButton({Key? key, this.onCannotPop}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      key: const Key('icon:closeScCreator'),
      onPressed: () async {
        final confirmed = await ConfirmDialog.show(
          title: l10n.r3aCloseScCreatorConfirm,
          body: l10n.configCloseDialogBody,
          cancelText: l10n.actionCancel,
          confirmText: l10n.actionContinue,
        );

        if (confirmed != true) {
          return;
        }

        ref.read(createSmartContractProvider.notifier).clearSmartContract();

        final router = AutoRouter.of(context);
        if (router.canPop() || onCannotPop == null) {
          router.pop();
        } else {
          onCannotPop!();
        }
      },
      icon: const Icon(Icons.close),
      tooltip: l10n.actionClose,
    );
  }
}
