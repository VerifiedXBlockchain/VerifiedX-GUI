import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/utils.dart';

import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';

class FaucetFormstate {
  final String verificationUuid;
  final double amount;
  final PhoneNumber? phone;

  FaucetFormstate(
      {required this.verificationUuid,
      required this.amount,
      required this.phone});

  factory FaucetFormstate.empty() {
    return FaucetFormstate(
      verificationUuid: '',
      amount: 5,
      phone: null,
    );
  }

  FaucetFormstate requestCompleted(String uuid) {
    return FaucetFormstate(
      verificationUuid: uuid,
      amount: amount,
      phone: phone,
    );
  }
}

class FaucetFormProvider extends StateNotifier<FaucetFormstate> {
  final Ref ref;
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<FormState> verificationFormKey = GlobalKey();

  late final TextEditingController amountController;
  late final PhoneController phoneController;
  late final TextEditingController verificationController;

  FaucetFormProvider(this.ref, FaucetFormstate model) : super(model) {
    amountController = TextEditingController(text: model.amount.toString());
    phoneController = PhoneController(model.phone);
    verificationController = TextEditingController();
  }

  String? amountValidator(String? val) =>
      formValidatorNumber(val, globalL10n.labelAmount);
  String? verificationValidator(String? val) =>
      formValidatorNumber(val, globalL10n.faucetVerificationCodeLabel);

  load(FaucetFormstate model) {
    state = model;
    amountController.text = model.amount.toString();
    phoneController.value = model.phone;
    verificationController.text = '';
  }

  clear() {
    load(FaucetFormstate.empty());
  }

  Future<bool?> submitRequest([double? amountOverride]) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    final address = kIsWeb
        ? ref.watch(webSessionProvider.select((v) => v.keypair?.address))
        : ref.watch(sessionProvider.select((v) => v.currentWallet?.address));

    if (address == null) {
      Toast.error(globalL10n.r3eNoAccountSelected);
      return null;
    }

    final phoneNumber = phoneController.value;
    if (phoneNumber == null) {
      Toast.error(globalL10n.r3ePhoneNumberRequired);
      return false;
    }
    
    final cleanPhone = phoneNumber.international;

    final parsedAmount =
        amountOverride ?? double.tryParse(amountController.text);

    if (parsedAmount == null) {
      Toast.error(globalL10n.btcInvalidAmount);
      return false;
    }

    try {
      final result = await ExplorerService()
          .faucetRequest(cleanPhone, parsedAmount, address);

      state = state.requestCompleted(result);
      return true;
    } catch (e) {
      Toast.error(e.toString());
      return false;
    }
  }

  Future<bool?> submitVerification() async {
    if (!verificationFormKey.currentState!.validate()) {
      return null;
    }

    try {
      final result = await ExplorerService().faucetVerify(
        state.verificationUuid,
        verificationController.text.trim(),
      );
      clear();

      Toast.message(globalL10n.r3eFaucetSuccess(result.toString()));
      return true;
    } catch (e) {
      Toast.error(e.toString());
      return false;
    }
  }
}

final faucetFormProvider =
    StateNotifierProvider<FaucetFormProvider, FaucetFormstate>(
  (ref) => FaucetFormProvider(ref, FaucetFormstate.empty()),
);
