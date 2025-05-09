import 'package:flutter/material.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/base_component.dart';
import '../../../models/stat.dart';
import '../../../providers/stat_form_provider.dart';
import '../common/form_group_header.dart';
import '../common/help_button.dart';
import '../common/modal_bottom_actions.dart';
import '../common/modal_container.dart';

class StatModal extends BaseComponent {
  final int index;
  const StatModal(
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.read(statFormProvider(index).notifier);
    final _model = ref.watch(statFormProvider(index));
    final GlobalKey<FormState> _formKey = GlobalKey();

    return Form(
      key: _formKey,
      child: ModalContainer(
        children: [
          const FormGroupHeader("Stat"),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _provider.labelController,
                      decoration: const InputDecoration(
                          label: Text(
                            "Label",
                            style: TextStyle(color: Colors.white),
                          ),
                          suffixIcon: HelpButton(HelpType.unknown)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SmartSelect<StatType>.single(
                      title: "Stat Type",
                      modalType: S2ModalType.bottomSheet,
                      selectedValue: _model.type,
                      onChange: (option) {},
                      choiceItems: Stat.allTypes()
                          .map(
                            (s) => S2Choice<StatType>(
                              value: s,
                              title: Stat.typeToString(s),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _provider.valueController,
                      decoration: const InputDecoration(
                          label: Text(
                            "Value",
                            style: TextStyle(color: Colors.white),
                          ),
                          suffixIcon: HelpButton(HelpType.unknown)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _provider.descriptionController,
                      decoration: const InputDecoration(
                          label: Text(
                            "Description",
                            style: TextStyle(color: Colors.white),
                          ),
                          suffixIcon: HelpButton(HelpType.unknown)),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
              ModalBottomActions(
                confirmText: "Save",
                onConfirm: () {
                  _provider.save();

                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
