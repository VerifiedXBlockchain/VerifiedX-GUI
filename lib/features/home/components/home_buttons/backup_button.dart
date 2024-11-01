import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/dialogs.dart';
import '../../../wallet/providers/wallet_list_provider.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/utils.dart';
import '../../../../utils/toast.dart';
import '../../../smart_contracts/components/sc_creator/common/modal_container.dart';

class BackupButton extends BaseComponent {
  const BackupButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cliStarted = ref.watch(sessionProvider.select((v) => v.cliStarted));
    print(!cliStarted || kIsWeb);

    return AppButton(
      label: "Backup",
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
                          title: const Text("Backup Keys"),
                          subtitle: Text("Export and save all your VFX${kIsWeb ? " Vault" : ""} and BTC  private keys & addresses to a text file."),
                          leading: const Icon(Icons.wallet),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            if (ref.read(walletListProvider).where((w) => w.isReserved).isNotEmpty && !kIsWeb) {
                              await InfoDialog.show(title: "Notice", body: "Please note that Reserve/Protected Accounts will not be exported.");
                            }
                            final success = kIsWeb ? await backupWebKeys(context, ref) : await backupKeys(context, ref);
                            if (success == true) {
                              Navigator.of(context).pop();
                              Toast.message("Keys backed up successfully.");
                            } else {
                              Toast.error();
                            }
                          },
                        ),
                        if (!kIsWeb)
                          ListTile(
                            title: const Text("Backup Media"),
                            subtitle: const Text("Zip and export your NFT media assets."),
                            leading: const Icon(Icons.file_present),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final success = await backupMedia(context, ref);

                              if (success == true) {
                                Navigator.of(context).pop();
                                Toast.message("Media backed up successfully.");
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
