import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/btc/providers/btc_balance_provider.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/web_session_model.dart';
import '../../../utils/toast.dart';
import '../../btc_web/models/btc_web_account.dart';
import '../../btc_web/models/btc_web_vbtc_token.dart';
import '../../btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import '../../btc_web/services/btc_web_service.dart';
import '../../token/models/web_fungible_token.dart';
import '../../token/providers/web_token_list_provider.dart';
import '../models/btc_fee_rate_preset.dart';
import '../models/tokenized_bitcoin.dart';
import '../services/btc_service.dart';
import 'tokenized_bitcoin_list_provider.dart';

part 'web_tokenized_btc_onboard_provider.g.dart';

enum VBtcOnboardStep {
  faucetWithdrawl,
  transferBtc,
  tokenize,
  transferBtcToVbtc,
}

enum VBtcProcessingState {
  ready,
  waitingForVfxTransfer,
  waitingForBtcTransfer,
  waitingForTokenization,
  waitingForBtcToVbtcTransfer,
}

const VBTC_ONBOARD_VFX_AMOUNT = 1.0;

class VBtcOnboardState {
  final VBtcOnboardStep step;
  final Keypair? vfxWallet;
  final BtcWebAccount? btcAccount;
  final double amountOfBtcToTransfer;
  final BtcWebVbtcToken? tokenizedBtc;
  final VBtcProcessingState processingState;
  final bool completed;
  final BtcFeeRatePreset btcFeeRatePreset;
  final bool transferToTokenManually;

  VBtcOnboardState({
    this.step = VBtcOnboardStep.faucetWithdrawl,
    this.vfxWallet,
    this.btcAccount,
    this.amountOfBtcToTransfer = 0.0,
    this.tokenizedBtc,
    this.processingState = VBtcProcessingState.ready,
    this.completed = false,
    this.btcFeeRatePreset = BtcFeeRatePreset.economy,
    this.transferToTokenManually = false,
  });

  VBtcOnboardState copyWith({
    VBtcOnboardStep? step,
    Keypair? vfxWallet,
    BtcWebAccount? btcAccount,
    double? amountOfBtcToTransfer,
    BtcWebVbtcToken? tokenizedBtc,
    VBtcProcessingState? processingState,
    bool? completed,
    BtcFeeRatePreset? btcFeeRatePreset,
    bool? transferToTokenManually,
  }) {
    return VBtcOnboardState(
      step: step ?? this.step,
      vfxWallet: vfxWallet ?? this.vfxWallet,
      btcAccount: btcAccount ?? this.btcAccount,
      amountOfBtcToTransfer: amountOfBtcToTransfer ?? this.amountOfBtcToTransfer,
      tokenizedBtc: tokenizedBtc ?? this.tokenizedBtc,
      processingState: processingState ?? this.processingState,
      completed: completed ?? this.completed,
      btcFeeRatePreset: btcFeeRatePreset ?? this.btcFeeRatePreset,
      transferToTokenManually: transferToTokenManually ?? this.transferToTokenManually,
    );
  }

  int get stepNumber {
    switch (step) {
      case VBtcOnboardStep.faucetWithdrawl:
        return 1;

      case VBtcOnboardStep.transferBtc:
        return 2;

      case VBtcOnboardStep.tokenize:
        return 3;

      case VBtcOnboardStep.transferBtcToVbtc:
        return 4;
    }
  }

  String get stepTitle {
    switch (step) {
      case VBtcOnboardStep.faucetWithdrawl:
        return "Get VFX";

      case VBtcOnboardStep.transferBtc:
        return "Transfer BTC";

      case VBtcOnboardStep.tokenize:
        return "Tokenized vBTC";

      case VBtcOnboardStep.transferBtcToVbtc:
        return "Transfer BTC to vBTC Token";
    }
  }

  String get stepDetails {
    switch (step) {
      case VBtcOnboardStep.faucetWithdrawl:
        return "The community has provided a faucet to withdraw a minimal amount of VFX from in order to try out this feature. A phone number is required for verification purposes and to reduce the chance of abuse. Please note that only a hash of the phone number is stored with the faucet. Alternatively, you are welcome to purchase VFX via an exchange if you like. ";

      case VBtcOnboardStep.transferBtc:
        return "Looks like this account doesn't have any BTC. Please transfer BTC to this account to continue.";

      case VBtcOnboardStep.tokenize:
        return "Time to tokenize a vBTC token. The following fields are all optional!";

      case VBtcOnboardStep.transferBtcToVbtc:
        return "Now you are ready to transfer BTC to your vBTC token. Select the amount and Fee Rate below";
    }
  }

  String get processingStateMessage {
    switch (processingState) {
      case VBtcProcessingState.ready:
        return "";

      case VBtcProcessingState.waitingForVfxTransfer:
        return "Waiting for VFX Transfer to reflect on-chain.";

      case VBtcProcessingState.waitingForBtcTransfer:
        return "Waiting for BTC transfer to reflect on-chain.";

      case VBtcProcessingState.waitingForTokenization:
        return "Waiting for vBTC Tokenization to compile.";

      case VBtcProcessingState.waitingForBtcToVbtcTransfer:
        return "Waiting for BTC to vBTC transaction to reflect on-chain.";
    }
  }

  bool get stepIsBtc {
    switch (step) {
      case VBtcOnboardStep.faucetWithdrawl:
        return false;

      case VBtcOnboardStep.transferBtc:
        return true;

      case VBtcOnboardStep.tokenize:
        return true;

      case VBtcOnboardStep.transferBtcToVbtc:
        return true;
    }
  }
}

@Riverpod(keepAlive: true)
class WebVBtcOnboard extends _$WebVBtcOnboard {
  ProviderSubscription<WebSessionModel>? vfxTransferListener;
  ProviderSubscription<WebSessionModel>? btcTransferListener;
  ProviderSubscription<List<BtcWebVbtcToken>>? btcTokenizationListener;
  ProviderSubscription<List<BtcWebVbtcToken>>? btcToVbtcListener;

  final GlobalKey<FormState> btcTransferFormKey = GlobalKey<FormState>();

  final TextEditingController btcTransferAmountController = TextEditingController();

  @override
  VBtcOnboardState build() {
    final session = ref.read(webSessionProvider);
    final vfxAccount = session.keypair;
    final btcAccount = session.btcKeypair;
    final vfxBalance = session.balance;
    final btcBalance = session.btcBalanceInfo;
    if (vfxBalance != null && vfxBalance >= VBTC_ONBOARD_VFX_AMOUNT) {
      if ((btcBalance?.btcBalance ?? 0) > 0) {
        return VBtcOnboardState(vfxWallet: vfxAccount, btcAccount: btcAccount, step: VBtcOnboardStep.tokenize);
      }
      return VBtcOnboardState(vfxWallet: vfxAccount, btcAccount: btcAccount, step: VBtcOnboardStep.transferBtc);
    }
    return VBtcOnboardState(vfxWallet: vfxAccount, btcAccount: btcAccount);
  }

  void setupVfxTransferListener() {
    vfxTransferListener = ref.listen(webSessionProvider, (previous, WebSessionModel model) {
      if (state.step == VBtcOnboardStep.faucetWithdrawl) {
        if ((model.balance ?? 0) >= VBTC_ONBOARD_VFX_AMOUNT) {
          Toast.message("VFX Funds Received!");
          state = state.copyWith(step: VBtcOnboardStep.transferBtc, processingState: VBtcProcessingState.ready);
          vfxTransferListener?.close();
        }
      }
    });
  }

  void setupBtcTransferListener() {
    btcTransferListener = ref.listen(webSessionProvider, (previous, WebSessionModel session) {
      if (state.step == VBtcOnboardStep.transferBtc) {
        if ((session.btcBalanceInfo?.balance ?? 0) > 0) {
          Toast.message("BTC Funds Received!");
          state = state.copyWith(step: VBtcOnboardStep.tokenize, processingState: VBtcProcessingState.ready);
          btcTransferListener?.close();
        }
      }
    });
  }

  void setupTokenizationListener() {
    btcTokenizationListener = ref.listen(btcWebVbtcTokenListProvider, (previous, List<BtcWebVbtcToken> tokens) {
      if (state.step == VBtcOnboardStep.tokenize) {
        print("tokens: $tokens  address:${state.vfxWallet?.address}");
        final token = tokens.firstWhereOrNull((t) => t.ownerAddress == state.vfxWallet?.address);
        if (token != null) {
          Toast.message("Token Deployed!");
          state = state.copyWith(step: VBtcOnboardStep.transferBtcToVbtc, processingState: VBtcProcessingState.ready, tokenizedBtc: token);

          btcTokenizationListener?.close();
        }
      }
    });
  }

  void setupBtcToVbtcListener() {
    btcToVbtcListener = ref.listen(btcWebVbtcTokenListProvider, (previous, List<BtcWebVbtcToken> tokens) {
      if (state.step == VBtcOnboardStep.transferBtcToVbtc) {
        if (state.tokenizedBtc == null) {
          print("tokenized btc is null. closing listener");
          btcToVbtcListener?.close();

          return;
        }
        final token = tokens.firstWhereOrNull((t) => t.scIdentifier == state.tokenizedBtc!.scIdentifier && t.globalBalance > 0);
        if (token != null) {
          Toast.message("Transfer Complete!");
          state = state.copyWith(completed: true, processingState: VBtcProcessingState.ready);

          btcToVbtcListener?.close();
        }
      }
    });
  }

  void reset() {
    final vfxAccount = ref.read(webSessionProvider).keypair;
    final btcAccount = ref.read(webSessionProvider).btcKeypair;
    final balance = ref.read(webSessionProvider).balance;
    if (balance != null && balance >= VBTC_ONBOARD_VFX_AMOUNT) {
      state = VBtcOnboardState(vfxWallet: vfxAccount, btcAccount: btcAccount, step: VBtcOnboardStep.transferBtc);
    }
    state = VBtcOnboardState(vfxWallet: vfxAccount, btcAccount: btcAccount);
    btcTransferAmountController.clear();
    vfxTransferListener?.close();
    btcTransferListener?.close();
    btcTokenizationListener?.close();
    btcToVbtcListener?.close();
  }

  void setProcessingState(VBtcProcessingState processingState) {
    state = state.copyWith(processingState: processingState);

    switch (processingState) {
      case VBtcProcessingState.waitingForBtcTransfer:
        setupBtcTransferListener();
        break;
      case VBtcProcessingState.waitingForVfxTransfer:
        setupVfxTransferListener();

        break;
      case VBtcProcessingState.waitingForTokenization:
        setupTokenizationListener();
        break;

      case VBtcProcessingState.waitingForBtcToVbtcTransfer:
        setupBtcToVbtcListener();
        break;

      default:
        break;
    }
  }

  void setBtcAccount(BtcWebAccount account) {
    if ((ref.read(webSessionProvider).btcBalanceInfo?.balance ?? 0) > 0) {
      state = state.copyWith(btcAccount: account, step: VBtcOnboardStep.tokenize);
    } else {
      state = state.copyWith(btcAccount: account, step: VBtcOnboardStep.transferBtc);
      setProcessingState(VBtcProcessingState.waitingForBtcTransfer);
    }
  }

  void setBtcFeeRatePreset(BtcFeeRatePreset value) {
    state = state.copyWith(btcFeeRatePreset: value);
  }

  void setTransferToTokenManually(bool value) {
    state = state.copyWith(transferToTokenManually: value);
  }

  Future<bool> transferBtcToVbtc(double amount, int feeRate) async {
    if (state.btcAccount == null) {
      Toast.error("No BTC Account selected");
      return false;
    }

    if (state.tokenizedBtc == null) {
      Toast.error("No BTC Token selected");
      return false;
    }
    if (state.tokenizedBtc == null) {
      Toast.error("No BTC address in token");
      return false;
    }

    final txHash = await BtcWebService().sendTransaction(state.btcAccount!.wif, state.tokenizedBtc!.depositAddress, amount, feeRate);

    if (txHash != null) {
      Toast.message("Transaction completed: $txHash");
      return true;
    }

    Toast.error("An error has occurred");
    return false;
  }
}
