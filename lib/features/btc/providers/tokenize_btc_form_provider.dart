import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/app_constants.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../asset/asset.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../smart_contracts/components/sc_creator/common/compile_animation.dart';
import '../../smart_contracts/models/multi_asset.dart';
import '../../smart_contracts/models/smart_contract.dart';
import '../../../utils/toast.dart';

import '../../../core/services/explorer_service.dart';
import '../../nft/providers/nft_list_provider.dart';
import '../../raw/raw_service.dart';
import '../../wallet/models/wallet.dart';
import './mpc_ceremony_provider.dart';
import 'tokenized_bitcoin_list_provider.dart';

part 'tokenize_btc_form_provider.freezed.dart';

@freezed
abstract class TokenizeBtcFormState with _$TokenizeBtcFormState {
  const TokenizeBtcFormState._();

  factory TokenizeBtcFormState({
    @Default(false) bool isProcessing,
    Asset? asset,
    String? vfxAddress,
    @Default([]) List<Asset> additionalAssets,
    String? imageBase64,
  }) = _TokenizeBtcFormState;
}

class TokenizeBtcFormProvider extends StateNotifier<TokenizeBtcFormState> {
  final Ref ref;
  TokenizeBtcFormProvider(this.ref) : super(TokenizeBtcFormState());

  final formKey = GlobalKey<FormState>();

  final tokenNameController = TextEditingController();
  final tokenDescriptionController = TextEditingController();
  final tokenTickerController = TextEditingController();

  setAsset(Asset? asset) {
    state = state.copyWith(asset: asset);
  }

  setImageBase64(String? imageBase64) {
    state = state.copyWith(imageBase64: imageBase64);
  }

  setAddress(String address) {
    state = state.copyWith(vfxAddress: address);
  }

  addAdditonalAsset(Asset asset) {
    state = state.copyWith(additionalAssets: [
      ...state.additionalAssets,
      asset,
    ]);
  }

  replaceAdditionalAsset(int index, Asset asset) {
    state = state.copyWith(
      additionalAssets: [...state.additionalAssets]
        ..removeAt(index)
        ..insert(index, asset),
    );
  }

  removeAdditionalAsset(int index) {
    state = state.copyWith(additionalAssets: [...state.additionalAssets]..removeAt(index));
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
      Toast.error("A VFX account with a balance is required to proceed.");
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

  Future<bool?> submitWeb() async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("A VFX account is required to proceed.");
      return null;
    }

    final balance = ref.read(webSessionProvider).balance;
    if (balance == null || balance < MIN_RBX_FOR_SC_ACTION) {
      Toast.error("A VFX account with a balance is required to proceed.");
      return null;
    }

    // if (state.additionalAssets.isNotEmpty) {
    //   final multiAsset = MultiAsset(
    //     assets: state.additionalAssets,
    //   );
    //   final List<Map<String, dynamic>> features = [];
    //   final f = {
    //     'FeatureName': MultiAsset.compilerEnum,
    //     'FeatureFeatures': multiAsset.serializeForCompiler(keypair.address),
    //   };
    //   features.add(f);

    //   params['Features'] = features;
    // }

    state = state.copyWith(isProcessing: true);

    String? tokenName = tokenNameController.text.trim();
    String? tokenDescription = tokenDescriptionController.text.trim();

    if (tokenName.isEmpty) {
      tokenName = null;
    }

    if (tokenDescription.isEmpty) {
      tokenDescription = null;
    }

    final vbtcExtraData = await ExplorerService().vbtcCompileData(keypair.address);
    if (vbtcExtraData == null) {
      Toast.error("Could not connect to arbiter. Try again later");
      return false;
    }

    // if (state.imageBase64 == null) {
    //   final imageData = await ExplorerService().vbtcDefaultImageData();
    //   state = state.copyWith(imageBase64: imageData);
    // }

    final sc = SmartContract(
      id: vbtcExtraData.smartContractUID,
      owner: Wallet.fromWebWallet(keypair: keypair, balance: balance),
      name: tokenName ?? "vBTC Token",
      description: tokenDescription ?? "vBTC Token",
      minterName: keypair.address,
      primaryAsset: state.asset ??
          Asset(
            id: '00000000-0000-0000-0000-000000000000',
            location: 'default',
            extension: 'png',
            authorName: 'VerifiedX',
            fileSize: 6778,
            name: "vBTC Token",
          ),
      multiAssets: state.additionalAssets.isNotEmpty
          ? [
              MultiAsset(
                assets: state.additionalAssets,
              )
            ]
          : [],
    );

    final timezoneName = ref.read(webSessionProvider).timezoneName;
    final payload = sc.serializeForCompiler(timezoneName);

    final updatedPayload = {
      ...payload,
      'SmartContractUID': vbtcExtraData.smartContractUID,
      'Features': [
        ...payload['Features'],
        {
          'FeatureName': 3,
          'FeatureFeatures': {
            'AssetName': "Bitcoin",
            'AssetTicker': 'BTC',
            'DepositAddress': vbtcExtraData.depositAddress,
            'PublicKeyProofs': vbtcExtraData.publicKeyProofs,
            'ImageBase': state.imageBase64 ?? 'default',
          },
        },
      ]
    };

    final success = await RawService().compileAndMintSmartContract(updatedPayload, keypair, ref, 17);

    state = state.copyWith(isProcessing: false);
    if (success == true) {
      ref.read(nftListProvider.notifier).reloadCurrentPage(address: [
        ref.read(webSessionProvider).keypair?.address,
        ref.read(webSessionProvider).raKeypair?.address,
      ]);
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
