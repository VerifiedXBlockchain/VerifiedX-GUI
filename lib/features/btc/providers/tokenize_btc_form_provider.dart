import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/theme/app_theme.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../smart_contracts/components/sc_creator/common/compile_animation.dart';
import '../../../utils/toast.dart';
import '../../../l10n/l10n_helper.dart';

import './mpc_ceremony_provider.dart';
import 'tokenized_bitcoin_list_provider.dart';

part 'tokenize_btc_form_provider.freezed.dart';

@freezed
abstract class TokenizeBtcFormState with _$TokenizeBtcFormState {
  const TokenizeBtcFormState._();

  factory TokenizeBtcFormState({
    @Default(false) bool isProcessing,
    String? vfxAddress,
  }) = _TokenizeBtcFormState;
}

class TokenizeBtcFormProvider extends StateNotifier<TokenizeBtcFormState> {
  final Ref ref;
  TokenizeBtcFormProvider(this.ref) : super(TokenizeBtcFormState());

  final formKey = GlobalKey<FormState>();

  final tokenNameController = TextEditingController();
  final tokenDescriptionController = TextEditingController();
  final tokenTickerController = TextEditingController();

  setAddress(String address) {
    state = state.copyWith(vfxAddress: address);
  }

  void showCompileAnimation(
    BuildContext context,
    Completer<BuildContext> completer, [
    bool mint = false,
  ]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // barrierColor: Colors.transparent,
      builder: (dialogContext) {
        if (!completer.isCompleted) {
          completer.complete(dialogContext);
        }
        return Center(
            child: CompileAnimation(
          mint,
          btc: true,
        ));
      },
    );
  }

  void showCompileComplete(
    BuildContext context,
    Completer<BuildContext> completer, [
    bool mint = false,
  ]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // barrierColor: Colors.transparent,
      builder: (dialogContext) {
        if (!completer.isCompleted) {
          completer.complete(dialogContext);
        }
        return Center(
            child: CompileAnimationComplete(
          mint,
          btc: true,
        ));
      },
    );
  }

  /// V2 submit: validates form, starts MPC ceremony, returns immediately.
  /// The screen is responsible for showing the progress modal and watching
  /// the ceremony provider state for completion.
  Future<bool?> submit() async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    if (state.vfxAddress == null) {
      Toast.error(globalL10n.bw2VfxAccountBalanceRequired);
      return null;
    }

    state = state.copyWith(isProcessing: true);

    await ref.read(mpcCeremonyProvider.notifier).startCeremony(state.vfxAddress!);

    state = state.copyWith(isProcessing: false);

    // Check if ceremony started successfully
    final ceremonyState = ref.read(mpcCeremonyProvider);
    if (ceremonyState.isFailed) {
      return false;
    }

    return true;
  }

  /// Called by the screen after ceremony completes to create the on-chain contract.
  Future<bool> createContractFromCeremony() async {
    final name = tokenNameController.text.trim();
    final description = tokenDescriptionController.text.trim();
    final ticker = tokenTickerController.text.trim();

    await ref.read(mpcCeremonyProvider.notifier).createContract(
      name: name.isNotEmpty ? name : "vBTC Token",
      description: description.isNotEmpty ? description : "vBTC Token",
      ticker: ticker.isNotEmpty ? ticker : "vBTC",
    );

    final ceremonyState = ref.read(mpcCeremonyProvider);
    if (ceremonyState.isContractCreated) {
      ref.read(logProvider.notifier).append(
            LogEntry(
              message: "vBTC Contract Created. Hash: ${ceremonyState.contractHash}",
              textToCopy: ceremonyState.contractHash,
              variant: AppColorVariant.Btc,
            ),
          );
      ref.invalidate(tokenizedBitcoinListProvider);
      clear();
      return true;
    }

    return false;
  }

  void clear() {
    state = TokenizeBtcFormState();
    tokenNameController.clear();
    tokenDescriptionController.clear();
    tokenTickerController.clear();
  }
}

final tokenizeBtcFormProvider = StateNotifierProvider<TokenizeBtcFormProvider, TokenizeBtcFormState>((ref) {
  return TokenizeBtcFormProvider(ref);
});
