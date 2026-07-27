import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sc_creator/common/help_button.dart';
import '../features/evolve/evolve.dart';
import '../features/evolve/evolve_phase_wizard_form_provider.dart';
import '../providers/sc_wizard_provider.dart';

import '../../../core/base_component.dart';
import '../../asset/asset.dart';
import 'sc_creator/common/file_selector.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardEvolvesDialog extends BaseComponent {
  ScWizardEvolvesDialog({Key? key, required this.entryIndex, required this.phaseIndex}) : super(key: key);

  final int phaseIndex;
  final int entryIndex;

  final stageNameController = TextEditingController();
  final stageDescriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(evolvePhaseWizardFormProvider(phaseIndex).notifier);
    final model = ref.read(evolvePhaseWizardFormProvider(phaseIndex));
    final type = ref.read(scWizardProvider.notifier).getEvolveType(entryIndex);
    final l10n = AppLocalizations.of(context);
    return StatefulBuilder(builder: (context, setState) {
      return Form(
        key: formKey,
        child: AlertDialog(
          title: Text(l10n.scwEvolvingPhase),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: TextFormField(
                        validator: provider.nameValidator,
                        controller: provider.nameController,
                        decoration: InputDecoration(
                          suffix: const HelpButton(HelpType.evolveStageName),
                          label: Text(l10n.scwEvolveStageName),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                  ],
                ),
                FileSelector(
                  title: l10n.scwEvolveStageAsset,
                  asset: ref.watch(evolvePhaseWizardFormProvider(phaseIndex)).asset,
                  transparentBackground: true,
                  allowReplace: false,
                  onChange: (Asset? asset) {
                    provider.setAsset(asset);
                  },
                ),
                TextFormField(
                  controller: provider.descriptionController,
                  validator: provider.descriptionValidator,
                  maxLines: 3,
                  decoration: InputDecoration(
                    suffix: const HelpButton(HelpType.evolveStageDescription),
                    label: Text(l10n.scwEvolveStageDescription),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                if (type == EvolveType.time)
                  Column(
                    children: [
                      buildDate(l10n, provider, () => _showDatePicker(context, ref), type),
                      const SizedBox(
                        height: 6,
                      ),
                      buildTime(
                        l10n,
                        provider,
                        () => _showTimePicker(context, ref),
                        type,
                      ),
                    ],
                  ),
                if (type == EvolveType.blockHeight) buildBlockHeight(l10n, provider, type),
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

                final e = provider.generateEvolvePhase();
                if (e != null) {
                  Navigator.of(context).pop(e);
                }
              },
              child: Text(
                l10n.scwAddEvolvingPhase,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    });
  }

  Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
    final _provider = ref.read(evolvePhaseWizardFormProvider(phaseIndex).notifier);
    final _d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 100),
      ),
    );

    if (_d != null) {
      final now = DateTime.now();
      final d = DateTime(_d.year, _d.month, _d.day, now.hour + 1, now.minute, now.second);
      _provider.updateDate(d);
    }
  }

  Future<void> _showTimePicker(BuildContext context, WidgetRef ref) async {
    final _provider = ref.read(evolvePhaseWizardFormProvider(phaseIndex).notifier);
    final t = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (t != null) {
      _provider.updateTime(t);
    }
  }

  TextFormField buildTime(AppLocalizations l10n, EvolvePhaseWizardFormProvider _provider, Future<void> Function() _showTimePicker, EvolveType type) {
    return TextFormField(
      controller: _provider.timeController,
      validator: (val) {
        return _provider.dateTimeValidator(val, type);
      },
      onTap: () {
        _showTimePicker();
      },
      decoration: InputDecoration(
        prefixIcon: const HelpButton(
          HelpType.evolveDatetime,
          subtle: true,
        ),
        label: Text(
          l10n.scwEvolutionTime(DateTime.now().timeZoneName.toString()),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.watch),
          onPressed: () {
            _showTimePicker();
          },
        ),
      ),
    );
  }

  TextFormField buildBlockHeight(AppLocalizations l10n, EvolvePhaseWizardFormProvider _provider, EvolveType type) {
    return TextFormField(
      controller: _provider.blockHeightController,
      validator: (val) => _provider.blockHeightValidator(val, type),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp("[0-9]"),
        )
      ],
      decoration: InputDecoration(
        suffix: const HelpButton(
          HelpType.evolveBlockHeight,
        ),
        label: Text(
          l10n.scwBlockHeightValue,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  TextFormField buildDate(AppLocalizations l10n, EvolvePhaseWizardFormProvider _provider, Future<void> Function() _showDatePicker, EvolveType type) {
    return TextFormField(
      controller: _provider.dateController,
      validator: (value) => _provider.dateTimeValidator(value, type),
      onTap: () {
        _showDatePicker();
      },
      decoration: InputDecoration(
        prefixIcon: const HelpButton(
          HelpType.evolveDatetime,
          subtle: true,
        ),
        label: Text(
          l10n.scwEvolutionDate,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            _showDatePicker();
          },
        ),
      ),
    );
  }
}
