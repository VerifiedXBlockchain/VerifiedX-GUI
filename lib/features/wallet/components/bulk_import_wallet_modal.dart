import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../providers/wallet_list_provider.dart';
import '../../../utils/toast.dart';

class BulkImportWalletModal extends BaseComponent {
  const BulkImportWalletModal({Key? key}) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    return ModalContainer(
      withDecor: false,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.walletBulkImportTitle,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.actionCancel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const Divider(),
        TextFormField(
          controller: controller,
          minLines: 6,
          maxLines: 10,
          decoration: InputDecoration(hintText: l10n.walletBulkImportHint),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: l10n.walletImportLabel,
            variant: AppColorVariant.Success,
            onPressed: () async {
              final value = controller.text;
              if (value.isEmpty) {
                return null;
              }

              final lines = value.split("\n");
              final List<String> linesToImport = [];
              for (final line in lines) {
                final l = line.trim();
                if (l.isNotEmpty) {
                  linesToImport.add(l);
                }
              }

              if (lines.isEmpty) {
                return null;
              }

              final label = l10n.walletKeypairsLabel(linesToImport.length);

              final confirmed = await ConfirmDialog.show(
                title: l10n.walletConfirmImportTitle,
                body: l10n.walletConfirmImportBody(label),
                confirmText: l10n.walletImportLabel,
                cancelText: l10n.actionCancel,
              );
              if (confirmed != true) {
                return null;
              }

              final resync = await ConfirmDialog.show(
                title: l10n.walletRescanBlocksTitle,
                body: l10n.walletRescanBlocksBodyKeys,
                confirmText: l10n.actionYes,
                cancelText: l10n.actionNo,
              );

              for (final privateKey in linesToImport) {
                await ref.read(walletListProvider.notifier).import(privateKey, false, resync == true);
              }

              Toast.message(l10n.walletImportedToast(label));

              ref.read(walletInfoProvider.notifier).infoLoop(false);
              ref.read(sessionProvider.notifier).mainLoop(false);
              ref.read(sessionProvider.notifier).smartContractLoop(false);

              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}
