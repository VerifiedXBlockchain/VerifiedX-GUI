import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../services/mother_service.dart';

class MotherCreateHostDialog extends BaseComponent {
  final bool forUpdate;
  MotherCreateHostDialog({
    Key? key,
    required this.forUpdate,
  }) : super(key: key);

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    return AlertDialog(
      title: Text(forUpdate ? l10n.motherUpdateHostInfo : l10n.motherSetWalletHost),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(label: Text(l10n.motherHostNameLabel)),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return l10n.motherNameRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(label: Text(l10n.motherCreatePasswordLabel)),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return l10n.motherPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 6),
              Text(
                l10n.motherPortNote(Env.validatorPort.toString()),
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(
            l10n.actionCancel,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }

            final success = await MotherService().createHost(
              nameController.text,
              passwordController.text,
            );

            if (success != true) {
              Toast.error();
              return;
            }

            Toast.message(l10n.motherHostCreated);

            final restart = await ConfirmDialog.show(
              title: l10n.motherCliRestartTitle,
              body: l10n.motherCliRestartBody,
              confirmText: l10n.beaconRestartNow,
              cancelText: l10n.beaconLater,
            );

            if (restart == true) {
              ref.read(sessionProvider.notifier).restartCli();
            }

            Navigator.of(context).pop(true);
          },
          child: Text(
            l10n.beaconCreate,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
