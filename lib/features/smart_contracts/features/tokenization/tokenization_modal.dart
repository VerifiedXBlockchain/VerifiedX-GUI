import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_component.dart';
import '../../components/sc_creator/common/file_selector.dart';
import '../../components/sc_creator/common/form_group_header.dart';
import '../../components/sc_creator/common/help_button.dart';
import '../../components/sc_creator/common/manage_properties_list.dart';
import '../../components/sc_creator/common/modal_bottom_actions.dart';
import '../../components/sc_creator/common/modal_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'tokenization_provider.dart';

class TokenizationModal extends BaseComponent {
  const TokenizationModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.read(tokenizationFormProvider.notifier);
    final _model = ref.watch(tokenizationFormProvider);
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _provider.formKey,
      child: ModalContainer(children: [
        FormGroupHeader(
          l10n.scwTokenizationTitle,
        ),
        TextFormField(
          decoration: InputDecoration(label: Text(l10n.scwPhysicalDigitalGoodName)),
          validator: _provider.nameValidator,
          controller: _provider.nameController,
        ),
        Row(
          children: [
            Expanded(
              child: FileSelector(
                title: l10n.scwImages,
                transparentBackground: true,
                asset: _model.photo,
                onChange: (asset) {
                  if (asset != null) {
                    _provider.addPhoto(asset);
                  } else {
                    _provider.removePhoto();
                  }
                },
              ),
            ),
            const SizedBox(
              width: 8,
            ),
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
            )
          ],
        ),
        TextFormField(
          decoration: InputDecoration(label: Text(l10n.scwDescriptionOfPhysicalDigitalGood)),
          validator: _provider.descriptionValidator,
          controller: _provider.descriptionController,
          minLines: 3,
          maxLines: 6,
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
