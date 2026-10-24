import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/theme/app_theme.dart';
import '../../adnr/providers/adnr_pending_provider.dart';
import '../../bridge/providers/log_provider.dart';
import '../services/btc_service.dart';
import '../utils/btc_name_acceptance.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';

import '../../../core/utils/tx_refresh.dart';
import '../../../l10n/l10n_helper.dart';
import '../../bridge/models/log_entry.dart';

part 'btc_adnr_transfer_form_provider.freezed.dart';

@freezed
abstract class BtcAdnrTransferFormState with _$BtcAdnrTransferFormState {
  const BtcAdnrTransferFormState._();

  factory BtcAdnrTransferFormState({
    String? fromBtcAddress,
    String? domainName,
  }) = _BtcAdnrTransferFormState;
}

class BtcAdnrTransferFormProvider extends StateNotifier<BtcAdnrTransferFormState> {
  final Ref ref;
  BtcAdnrTransferFormProvider(this.ref) : super(BtcAdnrTransferFormState());

  final formKey = GlobalKey<FormState>();

  final toBtcAddressController = TextEditingController();
  final toRbxAddressController = TextEditingController();
  final acceptanceCodeController = TextEditingController();

  initWithFromBtcAddress({required String fromBtcAddress, required String? domainName}) {
    // An acceptance code is for one domain only.
    acceptanceCodeController.clear();
    state = state.copyWith(
      fromBtcAddress: fromBtcAddress,
      domainName: domainName,
    );
  }

  String? toBtcAddressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return globalL10n.bw2ToBtcAddressRequired;
    }
    return null;
  }

  String? toRbxAddressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return globalL10n.bw2ToVfxAddressRequired;
    }

    return formValidatorRbxAddress(value);
  }

  /// The receiver's acceptance code is optional (the node signs itself when it
  /// holds the receiving key), but when given it must name this domain and
  /// the VFX address it is going to.
  String? acceptanceCodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final acceptance = BtcNameAcceptance.parse(value);
    if (acceptance == null) {
      return globalL10n.btcAcceptanceCodeInvalid;
    }

    final domainName = state.domainName;
    if (domainName != null && !acceptance.matches(owner: toRbxAddressController.text, name: domainName)) {
      return globalL10n.btcAcceptanceCodeMismatch;
    }

    return null;
  }

  Future<bool?> submit() async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    if (state.fromBtcAddress == null) {
      Toast.error(globalL10n.bw2SelectBtcAddressRequired);
      return false;
    }

    final toBtcAddress = toBtcAddressController.text.trim();
    final toRbxAddress = toRbxAddressController.text.trim();
    final acceptance = BtcNameAcceptance.parse(acceptanceCodeController.text);

    ref.read(globalLoadingProvider.notifier).start();

    final hash = await BtcService().transferAdnr(
      fromBtcAddress: state.fromBtcAddress!,
      toBtcAddress: toBtcAddress,
      toRbxAddress: toRbxAddress,
      acceptance: acceptance,
    );

    ref.read(globalLoadingProvider.notifier).complete();

    // BtcService has already shown the node's error message.
    if (hash == null) {
      return false;
    }

    ref.read(adnrPendingProvider.notifier).addId(state.fromBtcAddress!, "transfer", state.domainName ?? 'null');

    notifyTransactionSubmitted();
    acceptanceCodeController.clear();
    state = BtcAdnrTransferFormState();

    return true;
  }
}

final btcAdnrTransferFormProvider = StateNotifierProvider<BtcAdnrTransferFormProvider, BtcAdnrTransferFormState>((ref) {
  return BtcAdnrTransferFormProvider(ref);
});
