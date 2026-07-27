import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/files.dart';
import '../../../utils/toast.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../models/mother_child.dart';
import '../services/mother_service.dart';
import 'mother_add_host_dialog.dart';
import 'mother_create_host_dialog.dart';

class MotherModal extends BaseComponent {
  final MotherData? motherData;
  final List<MotherChild> children;
  const MotherModal(this.motherData, this.children, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedToMother = ref.watch(walletInfoProvider)?.connectedToMother == true;
    final l10n = AppLocalizations.of(context);

    return ModalContainer(
      padding: 16.0,
      withDecor: false,
      withClose: false,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.motherTitle,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                  ),
                  Text(
                    l10n.motherDescription,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            AppButton(
              label: l10n.motherClose,
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: AppButtonType.Text,
              variant: AppColorVariant.Light,
            ),
          ],
        ),
        const Divider(),
        Text(
          l10n.motherStatusHeading,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        Text(l10n.motherIsHostRow(motherData != null ? l10n.motherYes : l10n.motherNo)),
        Text(l10n.motherIsRemoteRow(connectedToMother ? l10n.motherYes : l10n.motherNo)),
        if (motherData != null) Text(l10n.motherChildrenRow(children.length.toString())),
        const Divider(),
        if (motherData != null)
          ListTile(
            title: Text(l10n.motherLaunchHost),
            leading: const Icon(Icons.launch),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              AutoRouter.of(context).push(const MotherDashboardScreenRoute());
            },
          ),
        ListTile(
          title: Text(motherData == null ? l10n.motherSetWalletHost : l10n.motherUpdateHostInfo),
          leading: const Icon(Icons.cell_tower),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final data = await showDialog(
              context: context,
              builder: (context) => MotherCreateHostDialog(forUpdate: motherData != null),
            );

            if (data != null) {
              Navigator.of(context).pop();
            }
          },
        ),
        if (motherData != null)
          ListTile(
            title: Text(l10n.motherStopHost),
            leading: const Icon(
              Icons.stop,
              color: Colors.red,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                title: l10n.motherStopHostConfirmTitle,
                body: l10n.motherStopHostBody,
                confirmText: l10n.motherStop,
                cancelText: l10n.actionCancel,
              );

              if (confirmed == true) {
                final success = await MotherService().stopHost();
                if (success == true) {
                  final restart = await ConfirmDialog.show(
                    title: l10n.motherCliRestartTitle,
                    body: l10n.motherCliRestartBody,
                    confirmText: l10n.beaconRestartNow,
                    cancelText: l10n.beaconLater,
                  );

                  if (restart == true) {
                    ref.read(sessionProvider.notifier).restartCli();
                  }
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        if (!connectedToMother)
          ListTile(
            title: Text(l10n.motherSetWalletRemote),
            leading: const Icon(Icons.satellite_alt_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final data = await showDialog(
                context: context,
                builder: (context) => MotherAddHostDialog(),
              );

              if (data != null) {
                Navigator.of(context).pop();
              }
            },
          ),
        if (connectedToMother)
          ListTile(
            title: Text(l10n.motherStopRemote),
            leading: const Icon(
              Icons.stop,
              color: Colors.red,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                title: l10n.motherStopRemote,
                body: l10n.motherStopRemoteBody,
                confirmText: l10n.motherStopRemoteAction,
                cancelText: l10n.actionCancel,
              );
              if (confirmed == true) {
                final path = await configPath();
                final currentLines = await File(path).readAsLines();

                final List<String> updatedLines = [];
                for (final line in currentLines) {
                  if (!line.contains("MotherPassword=") && !line.contains("MotherAddress=")) {
                    updatedLines.add(line);
                  }
                }
                await File(path).writeAsString(updatedLines.join('\n'));
                await ref.read(sessionProvider.notifier).restartCli();
                Navigator.of(context).pop();
                Toast.message(l10n.motherRemoteRemoved);
              }
            },
          ),
        ListTile(
          title: Text(l10n.motherWhatIs),
          leading: const Icon(Icons.help),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            InfoDialog.show(
              title: l10n.motherTitle,
              body: l10n.motherInfoBody(Env.validatorPort.toString()),
            );
          },
        ),
      ],
    );
  }
}
