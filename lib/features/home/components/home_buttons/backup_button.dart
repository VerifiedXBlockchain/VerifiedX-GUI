import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/dialogs.dart';
import '../../../wallet/providers/wallet_list_provider.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/utils.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/toast.dart';
import '../../../smart_contracts/components/sc_creator/common/modal_container.dart';

class BackupButton extends BaseComponent {
  const BackupButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    final cliStarted = ref.watch(sessionProvider.select((v) => v.cliStarted));
    print(!cliStarted || kIsWeb);

    return AppButton(
      label: l10n.hnavBackupLabel,
      icon: Icons.backup_outlined,
      onPressed: !cliStarted && !kIsWeb
          ? null
          : () async {
              showModalBottomSheet(
                  backgroundColor: Colors.black87,
                  // isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return ModalContainer(
                      color: Colors.black26,
                      withDecor: false,
                      children: [
                        ListTile(
                          title: Text(l10n.authBackupKeys),
                          subtitle: Text(l10n.hnavBackupKeysSubtitle(kIsWeb ? l10n.hnavVaultSuffix : "")),
                          leading: const Icon(Icons.wallet),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            if (ref.read(walletListProvider).where((w) => w.isReserved).isNotEmpty && !kIsWeb) {
                              await InfoDialog.show(title: l10n.hnavNoticeTitle, body: l10n.hnavReserveAccountsNotExported);
                            }
                            final success = kIsWeb ? await backupWebKeys(context, ref) : await backupKeys(context, ref);
                            if (success == true) {
                              Navigator.of(context).pop();
                              Toast.message(l10n.hnavKeysBackedUpSuccess);
                            } else {
                              Toast.error();
                            }
                          },
                        ),
                        if (!kIsWeb)
                          ListTile(
                            title: Text(l10n.reserveBackupMediaTitle),
                            subtitle: Text(l10n.hnavBackupMediaSubtitle),
                            leading: const Icon(Icons.file_present),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final success = await backupMedia(context, ref);

                              if (success == true) {
                                Navigator.of(context).pop();
                                Toast.message(l10n.hnavMediaBackedUpSuccess);
                              } else {
                                Toast.error();
                              }
                            },
                          ),
                      ],
                    );
                  });
            },
    );
  }
}
