import 'package:flutter/material.dart';
import '../../../../core/env.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/toast.dart';
import '../../../bridge/services/bridge_service.dart';
import '../../../remote_info/services/remote_info_service.dart';

class ImportSnapshotButton extends BaseComponent {
  const ImportSnapshotButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cliStarted = ref.watch(sessionProvider.select((v) => v.cliStarted));

    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.r3eImportSnapshot,
      icon: Icons.settings_backup_restore,
      onPressed: cliStarted
          ? () async {
              final data = await BridgeService().walletInfo();
              final int? blockHeight = int.tryParse(data['BlockHeight']);

              if (blockHeight == null) {
                Toast.error(l10n.r3eProblemLocalHeight);
                return;
              }

              final remoteInfo = await RemoteInfoService.fetchInfo();
              if (remoteInfo == null) {
                Toast.error(l10n.r3eProblemSnapshotHeight);
                return;
              }
              final snapshotHeight = remoteInfo.snapshot.height;

              if (blockHeight < snapshotHeight) {
                ref.read(sessionProvider.notifier).promptForSnapshotImport();
              } else {
                Toast.message(l10n.r3eLocalHeightAhead);
              }
            }
          : null,
    );
  }
}
