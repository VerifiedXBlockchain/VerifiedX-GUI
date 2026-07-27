import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../providers/beacon_form_provider.dart';
import '../providers/beacon_list_provider.dart';

class CreateBeaconModal extends BaseComponent {
  const CreateBeaconModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(beaconFormProvider.notifier);
    final model = ref.watch(beaconFormProvider);
    final l10n = AppLocalizations.of(context);
    return ModalContainer(
      withClose: true,
      withDecor: false,
      children: [
        Text(l10n.beaconCreateTitle),
        Text(
          l10n.beaconCreateBodyExplanation,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Form(
          key: provider.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: provider.nameController,
                      validator: provider.nameValidator,
                      decoration: InputDecoration(
                        label: Text(l10n.beaconNameLabel),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-Z0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 240,
                    child: TextFormField(
                      controller: provider.portController,
                      decoration: InputDecoration(
                          label: Text(l10n.beaconPortLabel)),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 240,
                    child: TextFormField(
                      controller: provider.periodController,
                      decoration: InputDecoration(
                          label: Text(l10n.beaconRetainDaysLabel)),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: model.isBeaconPrivate,
                onChanged: provider.setIsPrivate,
                title: Text(l10n.beaconMakePrivate),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: model.autoDeleteAfterDownload,
                onChanged: provider.setAutoDelete,
                title: Text(l10n.beaconAutoDelete),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              label: l10n.beaconCancel,
              type: AppButtonType.Text,
              variant: AppColorVariant.Light,
              onPressed: () {
                provider.clear();

                Navigator.of(context).pop();
              },
            ),
            AppButton(
              label: l10n.beaconCreate,
              variant: AppColorVariant.Success,
              onPressed: () async {
                final success = await provider.submit();

                if (success == null) {
                  return;
                }

                final confirmed = await ConfirmDialog.show(
                  title: l10n.beaconCreatedTitle,
                  body: l10n.beaconCreatedBody,
                  confirmText: l10n.beaconRestartNow,
                  cancelText: l10n.beaconLater,
                );

                if (confirmed == true) {
                  ref.read(globalLoadingProvider.notifier).start();
                  await ref.read(sessionProvider.notifier).restartCli();
                  ref.read(beaconListProvider.notifier).refresh();
                  ref.read(globalLoadingProvider.notifier).complete();
                }
                Navigator.of(context).pop();
              },
            )
          ],
        )
      ],
    );
  }
}
