import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/dropdowns.dart';
import '../../components/sc_creator/common/file_selector.dart';
import '../../components/sc_creator/common/form_group_header.dart';
import '../../components/sc_creator/common/help_button.dart';
import '../../components/sc_creator/common/manage_properties_list.dart';
import '../../components/sc_creator/common/modal_bottom_actions.dart';
import '../../components/sc_creator/common/modal_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'pair_provider.dart';

class PairModal extends BaseComponent {
  const PairModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.read(pairFormProvider.notifier);
    final _model = ref.watch(pairFormProvider);
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _provider.formKey,
      child: ModalContainer(children: [
        FormGroupHeader(
          l10n.scwPairWrapTitle,
        ),
        Row(
          children: [
            AppDropdown<String>(
                label: l10n.scwNetwork,
                selectedValue: _model.network,
                selectedLabel: _model.network,
                options: _provider.networkOptions.map((o) => AppDropdownOption<String>(label: o, value: o)).toList(),
                onChange: (val) {
                  _provider.setNetwork(val);
                }),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(label: Text(l10n.scwNetworkContractAddress(_model.network))),
                validator: _provider.nftAddressValidator,
                controller: _provider.nftAddressController,
              ),
            ),
            if (_model.network != "VFX") ...[
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(label: Text(l10n.scwTokenIdOptional)),
                  // validator: _provider.descriptionValidator,
                  // controller: _provider.descriptionController,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(label: Text(l10n.scwTokenStandardOptional)),
                  // validator: _provider.descriptionValidator,
                  // controller: _provider.descriptionController,
                ),
              ),
            ]
          ],
        ),
        TextFormField(
          decoration: InputDecoration(label: Text(l10n.scwFullDescription)),
          validator: _provider.descriptionValidator,
          controller: _provider.descriptionController,
          minLines: 3,
          maxLines: 6,
        ),
        TextFormField(
          decoration: InputDecoration(label: Text(l10n.scwReasonForPairingWrapping)),
          validator: _provider.reasonValidator,
          controller: _provider.reasonController,
          minLines: 3,
          maxLines: 6,
        ),
        Row(
          children: [
            Expanded(
              child: FileSelector(
                title: l10n.scwProvenanceFilesOptional,
                transparentBackground: true,
                asset: _model.provenance,
                onChange: (asset) {
                  if (asset != null) {
                    _provider.addProvenance(asset);
                  } else {
                    _provider.removeProvenance();
                  }
                },
              ),
            ),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(label: Text(l10n.scwMetadataUrl)),
                controller: _provider.metadataUrlController,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                l10n.scwPropertiesOptional,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const HelpButton(HelpType.manageProperties)
            ],
          ),
        ),
        ManagePropertiesList(
          properties: _model.properties,
          onCreate: (property) {
            _provider.addProperty(property);
          },
          onRemove: (index) {
            _provider.removeProperty(index);
          },
        ),
        ModalBottomActions(
          onConfirm: () {
            _provider.complete(context);
          },
        )
      ]),
    );
  }
}
