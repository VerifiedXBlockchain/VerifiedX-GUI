import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sc_property/models/sc_property.dart';

import '../../../../utils/toast.dart';
import '../../../../utils/validation.dart';
import '../../../../l10n/l10n_helper.dart';
import '../../../asset/asset.dart';
import '../../../bridge/providers/wallet_info_provider.dart';
import 'evolve.dart';
import 'evolve_form_provider.dart';
import 'evolve_phase.dart';

class EvolvePhaseFormProvider extends StateNotifier<EvolvePhase> {
  final Ref ref;
  final int index;
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController blockHeightController;
  late final TextEditingController dateController;
  late final TextEditingController timeController;

  EvolvePhaseFormProvider(
    this.ref,
    this.index, [
    EvolvePhase model = const EvolvePhase(),
  ]) : super(model) {
    nameController = TextEditingController(text: model.name);
    descriptionController = TextEditingController(text: model.description);

    blockHeightController = TextEditingController(text: "${model.blockHeight ?? '0'}");
    dateController = TextEditingController(text: model.dateLabel);
    timeController = TextEditingController(text: model.timeLabel);
  }

  String? nameValidator(String? val) => formValidatorNotEmpty(val, globalL10n.walletNameLabel);
  String? descriptionValidator(String? val) => formValidatorNotEmpty(val, globalL10n.btcDetailDescriptionLabel);

  String? dateTimeValidator(String? val) {
    if (ref.read(evolveFormProvider).type != EvolveType.time) {
      return null;
    }

    if (val == null || val.isEmpty) {
      return globalL10n.r3aRequiredForDateTimeEvolution;
    }

    return null;
  }

  String? blockHeightValidator(String? val) {
    if (ref.read(evolveFormProvider).type != EvolveType.blockHeight) {
      return null;
    }

    if (val == null || val.isEmpty) {
      return globalL10n.r3aRequiredForBlockHeightEvolution;
    }

    final parsed = int.tryParse(val);
    if (parsed == null) {
      return globalL10n.r3aInvalidValue;
    }

    if (ref.read(walletInfoProvider) == null) {
      return "Error";
    }

    final currentBh = ref.read(walletInfoProvider)!.blockHeight;

    if (parsed <= currentBh) {
      return globalL10n.r3aBlockHeightMustBeGreaterThan(currentBh.toString());
    }

    return null;
  }

  void setPhase(EvolvePhase phase) {
    state = phase;
    nameController.text = phase.name;
    descriptionController.text = phase.description;
    blockHeightController.text = phase.blockHeight == null ? '' : phase.blockHeight.toString();
  }

  bool save() {
    state = state.copyWith(
      name: nameController.text,
      description: descriptionController.text,
      // expectedValue: valueController.text,
      blockHeight: int.tryParse(blockHeightController.text),
    );

    if (state.asset == null) {
      OverlayToast.error(globalL10n.r3aAssetIsRequired);
      return false;
    }

    ref.read(evolveFormProvider.notifier).updatePhase(index, state);

    return true;
  }

  setAsset(Asset? asset) {
    state = state.copyWith(asset: asset);
  }

  updateDate(DateTime date) {
    final existing = state.dateTime;

    final d = existing == null ? date : DateTime(date.year, date.month, date.day, existing.hour, existing.minute);

    if (d.isBefore(DateTime.now())) {
      OverlayToast.error(globalL10n.r3aDateMustBeInFuture);

      return;
    }

    state = state.copyWith(dateTime: d);

    dateController.text = state.dateLabel;
  }

  updateTime(TimeOfDay time) {
    final existing = state.dateTime;
    final now = DateTime.now();

    final d = existing == null
        ? DateTime(now.year, now.month, now.day, time.hour, time.minute)
        : DateTime(existing.year, existing.month, existing.day, time.hour, time.minute);

    if (d.isBefore(DateTime.now())) {
      OverlayToast.error(globalL10n.r3aTimeMustBeInFuture);
      return;
    }

    state = state.copyWith(dateTime: d);

    timeController.text = state.timeLabel;
  }

  addProperty(ScProperty property) {
    state = state.copyWith(properties: [...state.properties, property]);
  }

  void updateProperty(ScProperty property, int index) {
    final updatedProperties = [...state.properties];
    updatedProperties.removeAt(index);
    updatedProperties.insert(index, property);
    state = state.copyWith(properties: updatedProperties);
  }

  removeProperty(int index) {
    state = state.copyWith(properties: [...state.properties]..removeAt(index));
  }

  clear() {
    nameController.text = "";
    descriptionController.text = "";
    blockHeightController.text = "";
    dateController.text = "";
    timeController.text = "";
    blockHeightController.text = "";
    setAsset(null);
  }
}

final evolvePhaseFormProvider = StateNotifierProvider.family<EvolvePhaseFormProvider, EvolvePhase, int>(
  (ref, index) => EvolvePhaseFormProvider(ref, index),
);
