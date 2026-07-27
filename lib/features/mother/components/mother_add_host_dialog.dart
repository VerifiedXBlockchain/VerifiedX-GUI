import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../core/utils/tx_refresh.dart';
import '../services/mother_service.dart';

class MotherAddHostDialog extends BaseComponent {
  MotherAddHostDialog({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ipAddressController = TextEditingController();
    final passwordController = TextEditingController();
    return AlertDialog(
      title: Text(l10n.motherAddHostTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.motherAddHostBody),
              TextFormField(
                controller: ipAddressController,
                decoration: InputDecoration(label: Text(l10n.motherIpHostLabel)),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return l10n.motherIpRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(label: Text(l10n.motherPasswordHostLabel)),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return l10n.motherPasswordRequired;
                  }
                  return null;
                },
              ),
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

            final success = await MotherService().joinHost(ipAddressController.text.trim(), passwordController.text);

            if (success != true) {
              Toast.error();
              return;
            }

            notifyTransactionSubmitted();

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
            l10n.beaconAdd,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
