import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/components/buttons.dart';
import 'sc_creator/common/help_button.dart';
import '../features/evolve/evolve.dart';
import '../../../core/base_component.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardEvolveTypeDialog extends BaseComponent {
  const ScWizardEvolveTypeDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(l10n.scwEvolveType), const HelpButton(HelpType.evolveType)],
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
              label: l10n.scwEvolveTypeDateTime,
              onPressed: () {
                Navigator.of(context).pop(EvolveType.time);
              },
            ),
            AppButton(
              label: l10n.scwEvolveTypeBlockHeight,
              onPressed: () {
                Navigator.of(context).pop(EvolveType.blockHeight);
              },
            ),
            AppButton(
              label: l10n.scwEvolveTypeManualOnly,
              onPressed: () {
                Navigator.of(context).pop(EvolveType.manualOnly);
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
