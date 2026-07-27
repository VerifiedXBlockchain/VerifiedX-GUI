import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../models/beacon.dart';
import '../providers/beacon_list_provider.dart';
import '../services/beacon_service.dart';

class BeaconContextMenu extends BaseComponent {
  final Beacon beacon;
  const BeaconContextMenu(this.beacon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text(l10n.beaconRemove),
            onTap: () async {
              final isSelf = beacon.selfBeacon;

              final message = isSelf
                  ? l10n.beaconRemoveSelfBody
                  : l10n.beaconRemoveBody;

              final confirmText =
                  isSelf ? l10n.beaconRemoveAndRestart : l10n.beaconRemove;

              final confirmed = await ConfirmDialog.show(
                title: l10n.beaconRemoveTitle,
                body: message,
                confirmText: confirmText,
                cancelText: l10n.beaconCancel,
                destructive: true,
              );

              if (confirmed == true) {
                final success = await BeaconService().delete(beacon.id);
                if (success) {
                  if (isSelf) {
                    await ref.read(sessionProvider.notifier).restartCli();
                  }
                  ref.read(beaconListProvider.notifier).refresh();
                } else {
                  Toast.error();
                }
              }
            },
          ),
        ];
      },
    );
  }
}
