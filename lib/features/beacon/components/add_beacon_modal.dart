import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../providers/add_beacon_form_provider.dart';
import '../providers/beacon_list_provider.dart';

class AddBeaconModal extends BaseComponent {
  const AddBeaconModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(addBeaconFormProvider.notifier);
    final l10n = AppLocalizations.of(context);
    return ModalContainer(
      withClose: true,
      withDecor: false,
      children: [
        Text(l10n.beaconAddTitle),
        Text(
          l10n.r3bAddBeaconDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Form(
          key: provider.formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: provider.nameController,
                  validator: provider.nameValidator,
                  decoration: InputDecoration(
                    label: Text(l10n.beaconNameLabel),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextFormField(
                  controller: provider.ipController,
                  validator: provider.ipAddressValidator,
                  decoration: InputDecoration(
                    label: Text(l10n.beaconIpLabel),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                width: 240,
                child: TextFormField(
                  controller: provider.portController,
                  decoration: InputDecoration(label: Text(l10n.beaconPortLabel)),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
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
              label: l10n.actionCancel,
              type: AppButtonType.Text,
              variant: AppColorVariant.Light,
              onPressed: () {
                provider.clear();
                Navigator.of(context).pop();
              },
            ),
            AppButton(
              label: l10n.beaconAdd,
              variant: AppColorVariant.Success,
              onPressed: () async {
                final success = await provider.submit();

                if (success == null) {
                  return;
                }

                ref.read(beaconListProvider.notifier).refresh();
                Navigator.of(context).pop();
              },
            )
          ],
        )
      ],
    );
  }
}
