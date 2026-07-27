import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../global_loader/global_loading_provider.dart';
import '../models/keypair.dart';
import '../services/keygen_service.dart' if (dart.library.io) '../services/keygen_service_mock.dart';

class KeygenCta extends BaseComponent {
  const KeygenCta({Key? key}) : super(key: key);

  Future<void> handleImport(BuildContext context, WidgetRef ref, String email) async {
    final l10n = AppLocalizations.of(context);
    PromptModal.show(
      title: l10n.keygenImportWalletTitle,
      validator: (String? value) => formValidatorNotEmpty(value, l10n.keygenPrivateKeyLabel),
      labelText: l10n.keygenPrivateKeyLabel,
      onValidSubmission: (value) async {
        final keypair = await KeygenService.importPrivateKey(value, email);

        showKeys(context, keypair);
      },
    );
  }

  Future<void> handleCreate(BuildContext context, WidgetRef ref) async {
    ref.read(globalLoadingProvider.notifier).start();
    final l10n = AppLocalizations.of(context);

    final email = await PromptModal.show(
      contextOverride: context,
      title: l10n.keygenEmailAddressTitle,
      labelText: l10n.keygenEmailLabel,
      validator: formValidatorEmail,
    );

    if (email == null || email.isEmpty) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final keypair = await KeygenService.generate();
    if (keypair == null) {
      ref.read(globalLoadingProvider.notifier).complete();
      Toast.error();

      return;
    }
    ref.read(globalLoadingProvider.notifier).complete();

    showKeys(context, keypair);
  }

  Future<void> handleRecover(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final email = await PromptModal.show(
      contextOverride: context,
      title: l10n.keygenEmailAddressTitle,
      labelText: l10n.keygenEmailLabel,
      validator: formValidatorEmail,
    );

    if (email == null || email.isEmpty) {
      return;
    }

    await PromptModal.show(
      title: l10n.keygenRecoveryMnemonicTitle,
      validator: (value) => formValidatorNotEmpty(value, l10n.keygenRecoveryMnemonicLabel),
      labelText: l10n.keygenRecoveryMnemonicLabel,
      lines: 3,
      onValidSubmission: (value) async {
        ref.read(globalLoadingProvider.notifier).start();

        await Future.delayed(const Duration(milliseconds: 300));

        final keypair = await KeygenService.recover(value.trim());

        if (keypair == null) {
          Toast.error();
          ref.read(globalLoadingProvider.notifier).complete();

          return;
        }
        ref.read(globalLoadingProvider.notifier).complete();

        showKeys(context, keypair);
      },
    );
  }

  Future<void> showKeys(
    BuildContext context,
    Keypair keypair,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.keygenKeyGeneratedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.keygenKeyGeneratedBody),
              ),
              if (keypair.mneumonic != null)
                ListTile(
                  leading: const Icon(FontAwesomeIcons.paragraph),
                  title: TextFormField(
                    initialValue: keypair.mneumonic!,
                    decoration: InputDecoration(
                      label: Text(l10n.keygenRecoveryMnemonicLabel),
                    ),
                    style: const TextStyle(fontSize: 16),
                    readOnly: true,
                    minLines: 3,
                    maxLines: 3,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: keypair.mneumonic));
                      Toast.message(l10n.keygenMnemonicCopiedToast);
                    },
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: TextFormField(
                  initialValue: keypair.address,
                  decoration: InputDecoration(label: Text(l10n.keygenAddressLabel)),
                  readOnly: true,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: keypair.address));
                    Toast.message(l10n.keygenPublicKeyCopiedToast);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: TextFormField(
                  initialValue: keypair.privateCorrected,
                  decoration: InputDecoration(
                    label: Text(l10n.keygenPrivateKeyLabel),
                  ),
                  style: const TextStyle(fontSize: 13),
                  readOnly: true,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: keypair.privateCorrected));
                    Toast.message(l10n.keygenPrivateKeyCopiedToast);
                  },
                ),
              ),
              // if (keypair.mneumonic != null) Text(keypair.mneumonic!),

              const Divider(),
              AppButton(
                label: l10n.keygenDone,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        AppButton(
          label: l10n.keygenImportPrivateKey,
          onPressed: () async {
            final email = await PromptModal.show(
              title: l10n.keygenEmailAddressTitle,
              validator: (value) => formValidatorEmail(value),
              labelText: l10n.keygenEmailLabel,
            );
            if (email != null) {
              handleImport(context, ref, email);
            }
          },
        ),
        const SizedBox(
          width: 8,
        ),
        AppButton(
          label: l10n.keygenGenerateKeypair,
          onPressed: () {
            handleCreate(
              context,
              ref,
            );
          },
        ),
        const SizedBox(
          width: 8,
        ),
        AppButton(
          label: l10n.keygenRecoverAccount,
          onPressed: () {
            handleRecover(context, ref);
          },
        )
      ],
    );
  }
}
