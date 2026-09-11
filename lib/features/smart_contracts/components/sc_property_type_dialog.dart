import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/buttons.dart';
import '../../sc_property/models/sc_property.dart';
import 'sc_creator/common/help_button.dart';
import '../../../core/base_component.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardPropertyTypeDialog extends BaseComponent {
  const ScWizardPropertyTypeDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(l10n.scwPropertyType), const HelpButton(HelpType.propertyTyes)],
      ),
      actionsAlignment: MainAxisAlignment.start,
      content: SizedBox(
        width: 300,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            AppButton(
              label: l10n.scwPropertyTypeText,
              onPressed: () {
                Navigator.of(context).pop(ScPropertyType.text);
              },
            ),
            AppButton(
              label: l10n.scwPropertyTypeNumber,
              onPressed: () {
                Navigator.of(context).pop(ScPropertyType.number);
              },
            ),
            AppButton(
              label: l10n.scwPropertyTypeColor,
              onPressed: () {
                Navigator.of(context).pop(ScPropertyType.color);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            l10n.actionCancel,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
        )
      ],
    );
  }
}
