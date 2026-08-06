import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../adnr/providers/adnr_pending_provider.dart';
import '../../bridge/providers/log_provider.dart';
import '../services/btc_service.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../utils/toast.dart';
import 'package:collection/collection.dart';

import '../../../core/utils/tx_refresh.dart';
import '../../../l10n/l10n_helper.dart';
import '../../bridge/models/log_entry.dart';

part 'btc_adnr_create_form_provider.freezed.dart';

@freezed
abstract class BtcAdnrCreateFormState with _$BtcAdnrCreateFormState {
  const BtcAdnrCreateFormState._();

  factory BtcAdnrCreateFormState({
    String? btcAddress,
    String? selectedAddress,
    @Default("") String name,
  }) = _BtcAdnrCreateFormState;
}

class BtcAdnrCreateFormProvider extends StateNotifier<BtcAdnrCreateFormState> {
  final Ref ref;
  BtcAdnrCreateFormProvider(this.ref) : super(BtcAdnrCreateFormState());

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  initWithData({required String btcAddress, String? selectedAddress, String name = ''}) {
    state = state.copyWith(
      btcAddress: btcAddress,
      selectedAddress: selectedAddress,
      name: name,
    );

    nameController.text = name;
  }

  setSelectedAddress(String address) {
    state = state.copyWith(selectedAddress: address);
  }

  String? nameValidator(String? value) {
    value = value?.trim() ?? '';
    value = value.replaceAll(".btc", "");

    if (value.isEmpty) {
      return globalL10n.bw2DomainNameRequired;
    }

    if (value.length > BTC_ADNR_MAX_LENGTH) {
      return globalL10n.bw2DomainTooLong((BTC_ADNR_MAX_LENGTH + 1).toString());
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return globalL10n.bw2InvalidDomainLetters;
    }

    return null;
  }

  Future<bool?> submit() async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    if (state.btcAddress == null) {
      Toast.error(globalL10n.bw2SelectBtcAddressRequired);
      return null;
    }

    if (state.selectedAddress == null) {
      Toast.error(globalL10n.bw2SelectVfxAddressRequired);
      return null;
    }

    final wallet = ref.read(walletListProvider).firstWhereOrNull((w) => w.address == state.selectedAddress);

    if (wallet == null) {
      Toast.error(globalL10n.bw2VfxControllerNotFound(state.selectedAddress ?? ''));
      return null;
    }

    if (wallet.balance < (ADNR_COST + MIN_RBX_FOR_SC_ACTION)) {
      Toast.error(globalL10n.bw2NotEnoughVfxDeleteDomain(state.selectedAddress ?? ''));
      return null;
    }

    final nameValue = nameController.text.trim().replaceAll(".btc", "");

    ref.read(globalLoadingProvider.notifier).start();

    final hash = await BtcService().createAdnr(
      address: state.selectedAddress!,
      btcAddress: state.btcAddress!,
      name: nameValue,
    );

    ref.read(globalLoadingProvider.notifier).complete();

    if (hash != null) {
      ref.read(adnrPendingProvider.notifier).addId(state.btcAddress!, "create", 'null');
      ref.read(logProvider.notifier).append(
            LogEntry(message: "BTC Domain Create TX Sent: $hash", textToCopy: hash, variant: AppColorVariant.Btc),
          );
      notifyTransactionSubmitted();
      state = BtcAdnrCreateFormState();
      return true;
    }

    return false;
  }
}

final btcAdnrCreateFormProvider = StateNotifierProvider<BtcAdnrCreateFormProvider, BtcAdnrCreateFormState>((ref) {
  return BtcAdnrCreateFormProvider(ref);
});
