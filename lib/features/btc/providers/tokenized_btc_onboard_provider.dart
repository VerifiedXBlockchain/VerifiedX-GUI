import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/btc_account.dart';
import '../models/btc_fee_rate_preset.dart';
import '../models/tokenized_bitcoin.dart';
import 'btc_account_list_provider.dart';
import 'tokenize_btc_form_provider.dart';
import 'tokenized_bitcoin_list_provider.dart';
import '../services/btc_service.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_list_provider.dart';
import '../../wallet/models/wallet.dart';
import '../../../utils/toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'tokenized_btc_onboard_provider.g.dart';

enum VBtcOnboardStep {
  createVfxWallet,
  faucetWithdrawl,
  createOrImportBtcAccount,
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

const VBTC_ONBOARD_VFX_AMOUNT = 6.0;

class VBtcOnboardState {
  final VBtcOnboardStep step;
  final Wallet? vfxWallet;
  final BtcAccount? btcAccount;
  final double amountOfBtcToTransfer;
  final TokenizedBitcoin? tokenizedBtc;
  final VBtcProcessingState processingState;
  final bool completed;
  final BtcFeeRatePreset btcFeeRatePreset;
  final bool transferToTokenManually;

  VBtcOnboardState({
    this.step = VBtcOnboardStep.createVfxWallet,
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
    Wallet? vfxWallet,
    BtcAccount? btcAccount,
    double? amountOfBtcToTransfer,
    TokenizedBitcoin? tokenizedBtc,
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
      case VBtcOnboardStep.createVfxWallet:
        return 1;

      case VBtcOnboardStep.faucetWithdrawl:
        return 2;

      case VBtcOnboardStep.createOrImportBtcAccount:
        return 3;

      case VBtcOnboardStep.transferBtc:
        return 4;

      case VBtcOnboardStep.tokenize:
        return 5;

      case VBtcOnboardStep.transferBtcToVbtc:
        return 6;
    }
  }

  String get stepTitle {
    switch (step) {
      case VBtcOnboardStep.createVfxWallet:
        return "Create VFX Account";

      case VBtcOnboardStep.faucetWithdrawl:
        return "Get VFX";

      case VBtcOnboardStep.createOrImportBtcAccount:
        return "Import BTC Account";

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
      case VBtcOnboardStep.createVfxWallet:
        return "First you'll need a VFX Wallet. You can either import an existing one or create one now.";

      case VBtcOnboardStep.faucetWithdrawl:
        return "The community has provided a faucet to withdraw a minimal amount of VFX from in order to try out this feature. A phone number is required for verification purposes and to reduce the chance of abuse. Please note that only a hash of the phone number is stored with the faucet. Alternatively, you are welcome to purchase VFX via an exchange if you like. ";

      case VBtcOnboardStep.createOrImportBtcAccount:
        return "Now you need a BTC account added to your wallet. You can either import a private key or generate a new one.";

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
      case VBtcOnboardStep.createVfxWallet:
        return false;

      case VBtcOnboardStep.faucetWithdrawl:
        return false;

      case VBtcOnboardStep.createOrImportBtcAccount:
        return true;

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
class VBtcOnboard extends _$VBtcOnboard {
  ProviderSubscription<List<Transaction>>? vfxTransferListener;
  ProviderSubscription<List<BtcAccount>>? btcTransferListener;
  ProviderSubscription<List<TokenizedBitcoin>>? btcTokenizationListener;
  ProviderSubscription<List<TokenizedBitcoin>>? btcToVbtcListener;

  final GlobalKey<FormState> btcTransferFormKey = GlobalKey<FormState>();

  final TextEditingController btcTransferAmountController = TextEditingController();

  @override
  VBtcOnboardState build() {
    return VBtcOnboardState();
  }

  void setupVfxTransferListener() {
    vfxTransferListener = ref.listen(transactionListProvider(TransactionListType.Success), (previous, List<Transaction> transactions) {
      if (state.step == VBtcOnboardStep.faucetWithdrawl) {
        final tx = transactions.firstWhereOrNull((t) => t.toAddress == state.vfxWallet?.address && t.amount >= VBTC_ONBOARD_VFX_AMOUNT);
        if (tx != null) {
          Toast.message("VFX Funds Received!");
          state = state.copyWith(step: VBtcOnboardStep.createOrImportBtcAccount, processingState: VBtcProcessingState.ready);
          vfxTransferListener?.close();
        }
      }
    });
  }

  void setupBtcTransferListener() {
    btcTransferListener = ref.listen(btcAccountListProvider, (previous, List<BtcAccount> accounts) {
      if (state.step == VBtcOnboardStep.transferBtc) {
        final account = accounts.firstWhereOrNull((a) => a.address == state.btcAccount?.address && a.balance > 0);
        if (account != null) {
          Toast.message("BTC Funds Received!");
          state = state.copyWith(step: VBtcOnboardStep.tokenize, processingState: VBtcProcessingState.ready);

          btcTransferListener?.close();
        }
      }
    });
  }

  void setupTokenizationListener() {
    btcTokenizationListener = ref.listen(tokenizedBitcoinListProvider, (previous, List<TokenizedBitcoin> tokens) {
      if (state.step == VBtcOnboardStep.tokenize) {
        final token = tokens.firstWhereOrNull((t) => t.rbxAddress == state.vfxWallet?.address);

        if (token != null) {
          final tx = ref.read(transactionListProvider(TransactionListType.Success)).firstWhereOrNull((t) => t.timestamp == token.timestamp);
          // check to make sure the tx has succeeeded

          if (tx != null) {
            Toast.message("Token Deployed!");
            state = state.copyWith(step: VBtcOnboardStep.transferBtcToVbtc, processingState: VBtcProcessingState.ready, tokenizedBtc: token);

            btcTokenizationListener?.close();
          }
        }
      }
    });
  }

  void setupBtcToVbtcListener() {
    btcToVbtcListener = ref.listen(tokenizedBitcoinListProvider, (previous, List<TokenizedBitcoin> tokens) {
      if (state.step == VBtcOnboardStep.transferBtcToVbtc) {
        if (state.tokenizedBtc == null) {
          print("tokenized btc is null. closing listener");
          btcToVbtcListener?.close();

          return;
        }
        final token = tokens.firstWhereOrNull((t) => t.id == state.tokenizedBtc!.id && t.balance > 0);
        if (token != null) {
          Toast.message("Transfer Complete!");
          state = state.copyWith(completed: true, processingState: VBtcProcessingState.ready);

          btcToVbtcListener?.close();
        }
      }
    });
  }

  void reset() {
    state = VBtcOnboardState();
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

  void setVfxWallet(Wallet vfxWallet) {
    if (vfxWallet.balance >= VBTC_ONBOARD_VFX_AMOUNT) {
      state = state.copyWith(vfxWallet: vfxWallet, step: VBtcOnboardStep.createOrImportBtcAccount);
    } else {
      state = state.copyWith(vfxWallet: vfxWallet, step: VBtcOnboardStep.faucetWithdrawl);
    }
    ref.read(tokenizeBtcFormProvider.notifier).setAddress(vfxWallet.address);
  }

  void setBtcAccount(BtcAccount account) {
    if (account.balance > 0) {
      state = state.copyWith(btcAccount: account, step: VBtcOnboardStep.tokenize);
    } else {
      state = state.copyWith(btcAccount: account, step: VBtcOnboardStep.transferBtc);
      setProcessingState(VBtcProcessingState.waitingForBtcTransfer);
    }
  }

  void refreshBtcAccount() {
    if (state.btcAccount == null) {
      return;
    }

    final b = ref.read(btcAccountListProvider).firstWhereOrNull((a) => a.address == state.btcAccount!.address);
    print(b);
    if (b != null) {
      state = state.copyWith(btcAccount: b);
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
    if (state.tokenizedBtc!.btcAddress == null) {
      Toast.error("No BTC address in token");
      return false;
    }

    final result = await BtcService().sendTransaction(
      fromAddress: state.btcAccount!.address,
      toAddress: state.tokenizedBtc!.btcAddress!,
      amount: amount,
      feeRate: feeRate,
    );

    if (result.success) {
      Toast.message(result.message);
      return true;
    }

    Toast.error(result.message);
    return false;
  }
}
