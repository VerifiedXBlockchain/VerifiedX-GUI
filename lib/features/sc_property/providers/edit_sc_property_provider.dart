import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sc_property.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/validation.dart';

class EditScPropertyProvider extends StateNotifier<ScProperty> {
  EditScPropertyProvider(ScProperty initial) : super(initial);

  final GlobalKey<FormState> formKey = GlobalKey();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();

  String? nameValidator(value) => formValidatorNotEmpty(value, globalL10n.scwName);

  String? valueValidator(String? value) {
    if (value == null || value.isEmpty) {
      return globalL10n.r3eValueRequired;
    }

    if (state.type == ScPropertyType.color) {
      if (!value.contains("#") || value.length != 7) {
        return globalL10n.r3eInvalidHexColor;
      }
    }

    return null;
  }

  set(ScProperty property) {
    state = property;
    nameController.text = property.name;
    valueController.text = property.value;
  }

  clear() {
    set(ScProperty());
  }

  setType(ScPropertyType type) {
    state = state.copyWith(type: type);

    if (type == ScPropertyType.number) {
      valueController.text = valueController.text.replaceAll(RegExp(r"\D"), "");
    }
    if (type == ScPropertyType.color) {
      valueController.text = "#ff0000";
    }
  }

  ScProperty? submit() {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    return ScProperty(
      name: nameController.text,
      value: valueController.text,
      type: state.type,
    );
  }
}

final editScPropertyProvider = StateNotifierProvider<EditScPropertyProvider, ScProperty>((ref) {
  return EditScPropertyProvider(ScProperty());
});
