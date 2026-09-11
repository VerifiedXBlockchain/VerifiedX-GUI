import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../sc_property/models/sc_property.dart';
import '../providers/property_wizard_form_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardPropertyDialog extends BaseComponent {
  ScWizardPropertyDialog({
    Key? key,
    required this.propertyIndex,
    required this.type,
  }) : super(key: key);

  final int propertyIndex;
  final ScPropertyType type;

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(propertyWizardFormProvider(propertyIndex).notifier);
    final model = ref.read(propertyWizardFormProvider(propertyIndex));
    final l10n = AppLocalizations.of(context);

    return StatefulBuilder(builder: (context, setState) {
      return Form(
        key: formKey,
        child: AlertDialog(
          title: Text(_getTitle(l10n)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: provider.nameValidator,
                        controller: provider.nameController,
                        decoration: InputDecoration(
                          label: Text(l10n.scwPropertyName),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: provider.valueController,
                        validator: provider.valueValidator,
                        decoration: InputDecoration(
                          label: Text(l10n.scwPropertyValue),
                        ),
                        inputFormatters: [
                          if (type == ScPropertyType.number)
                            FilteringTextInputFormatter.allow(
                              RegExp("[0-9.]"),
                            ),
                        ],
                      ),
                    ),
                    if (type == ScPropertyType.color)
                      IconButton(
                        icon: Icon(
                          Icons.color_lens,
                        ),
                        onPressed: () async {
                          final color = await showDialog(
                            context: context,
                            builder: (context) {
                              Color color = colorFromHex(provider.valueController.value.text) ?? Color.fromARGB(255, 255, 0, 0);

                              return StatefulBuilder(builder: (context, setState) {
                                return AlertDialog(
                                  content: ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 300),
                                    child: ColorPicker(
                                      pickerColor: color,
                                      enableAlpha: false,
                                      onColorChanged: (val) {
                                        setState(() {
                                          color = val;
                                        });
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        l10n.actionCancel,
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(color);
                                      },
                                      child: Text(
                                        l10n.scwChoose,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                );
                              });
                            },
                          );

                          if (color != null) {
                            final v = colorToHex(color, enableAlpha: false);
                            provider.valueController.text = "#$v";
                          }
                        },
                      )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(
                l10n.actionCancel,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final e = provider.generateProperty(type);
                if (e != null) {
                  Navigator.of(context).pop(e);
                }
              },
              child: Text(
                l10n.scwAddProperty,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    });
  }

  String _getTitle(AppLocalizations l10n) {
    switch (type) {
      case ScPropertyType.text:
        return l10n.scwTextProperty;
      case ScPropertyType.number:
        return l10n.scwNumericalProperty;
      case ScPropertyType.color:
        return l10n.scwColorProperty;
      default:
        return l10n.scwTextProperty;
    }
  }
}
