import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/btc_account.dart';
import '../models/btc_fee_rate_preset.dart';
import '../models/tokenized_bitcoin.dart';
import 'btc_account_list_provider.dart';
import 'mpc_ceremony_provider.dart';
import 'tokenize_btc_form_provider.dart';
import 'tokenized_bitcoin_list_provider.dart';
import '../services/btc_service.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_list_provider.dart';
import '../../wallet/models/wallet.dart';
import '../../../utils/toast.dart';
import '../../../core/utils/tx_refresh.dart';
import '../../../l10n/l10n_helper.dart';
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

const VBTC_ONBOARD_VFX_AMOUNT = 1.0;

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
      amountOfBtcToTransfer:
          amountOfBtcToTransfer ?? this.amountOfBtcToTransfer,
      tokenizedBtc: tokenizedBtc ?? this.tokenizedBtc,
      processingState: processingState ?? this.processingState,
      completed: completed ?? this.completed,
      btcFeeRatePreset: btcFeeRatePreset ?? this.btcFeeRatePreset,
      transferToTokenManually:
          transferToTokenManually ?? this.transferToTokenManually,
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
        return globalL10n.bw2StepCreateVfxAccount;

      case VBtcOnboardStep.faucetWithdrawl:
        return globalL10n.bw2StepGetVfx;

      case VBtcOnboardStep.createOrImportBtcAccount:
        return globalL10n.bw2StepImportBtcAccount;

      case VBtcOnboardStep.transferBtc:
        return globalL10n.bw2StepTransferBtc;

      case VBtcOnboardStep.tokenize:
        return globalL10n.bw2StepTokenizedVbtc;

      case VBtcOnboardStep.transferBtcToVbtc:
        return globalL10n.bw2StepTransferBtcToVbtc;
    }
  }

  String get stepDetails {
    switch (step) {
      case VBtcOnboardStep.createVfxWallet:
        return globalL10n.bw2OnboardCreateVfxDetails;

      case VBtcOnboardStep.faucetWithdrawl:
        return globalL10n.bw2OnboardFaucetDetails;

      case VBtcOnboardStep.createOrImportBtcAccount:
        return globalL10n.bw2OnboardImportBtcDetails;

      case VBtcOnboardStep.transferBtc:
        return globalL10n.bw2OnboardTransferBtcDetails;

      case VBtcOnboardStep.tokenize:
        return globalL10n.bw2OnboardTokenizeDetails;

      case VBtcOnboardStep.transferBtcToVbtc:
        return globalL10n.bw2OnboardTransferToVbtcDetails;
    }
  }

  String get processingStateMessage {
    switch (processingState) {
      case VBtcProcessingState.ready:
        return "";

      case VBtcProcessingState.waitingForVfxTransfer:
        return globalL10n.bw2WaitingVfxTransfer;

      case VBtcProcessingState.waitingForBtcTransfer:
        return globalL10n.bw2WaitingBtcTransfer;

      case VBtcProcessingState.waitingForTokenization:
        return globalL10n.bw2WaitingTokenization;

      case VBtcProcessingState.waitingForBtcToVbtcTransfer:
        return globalL10n.bw2WaitingBtcToVbtc;
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
  ProviderSubscription<MpcCeremonyState>? ceremonyCeremonyListener;
  ProviderSubscription<List<TokenizedBitcoin>>? btcToVbtcListener;
  ProviderSubscription<List<TokenizedBitcoin>>? tokenInListListener;

  final GlobalKey<FormState> btcTransferFormKey = GlobalKey<FormState>();

  final TextEditingController btcTransferAmountController =
      TextEditingController();

  @override
  VBtcOnboardState build() {
    return VBtcOnboardState();
  }

  void setupVfxTransferListener() {
    vfxTransferListener = ref
        .listen(transactionListProvider(TransactionListType.Success),
            (previous, List<Transaction> transactions) {
      if (state.step == VBtcOnboardStep.faucetWithdrawl) {
        final tx = transactions.firstWhereOrNull((t) =>
            t.toAddress == state.vfxWallet?.address &&
            t.amount >= VBTC_ONBOARD_VFX_AMOUNT);
        if (tx != null) {
          Toast.message(globalL10n.bw2VfxFundsReceived);
          state = state.copyWith(
              step: VBtcOnboardStep.createOrImportBtcAccount,
              processingState: VBtcProcessingState.ready);
          vfxTransferListener?.close();
        }
      }
    });
  }

  void setupBtcTransferListener() {
    btcTransferListener = ref.listen(btcAccountListProvider,
        (previous, List<BtcAccount> accounts) {
      if (state.step == VBtcOnboardStep.transferBtc) {
        final account = accounts.firstWhereOrNull(
            (a) => a.address == state.btcAccount?.address && a.balance > 0);
        if (account != null) {
          Toast.message(globalL10n.bw2BtcFundsReceived);
          state = state.copyWith(
              step: VBtcOnboardStep.tokenize,
              processingState: VBtcProcessingState.ready);

          btcTransferListener?.close();
        }
      }
    });
  }

  void setupTokenizationListener() {
    // Check if ceremony already completed (handles timing where state
    // transitioned before listener was attached)
    final currentCeremonyState = ref.read(mpcCeremonyProvider);
    if (currentCeremonyState.isContractCreated) {
      ref.invalidate(tokenizedBitcoinListProvider);
      _waitForTokenInList();
      return;
    }

    ceremonyCeremonyListener = ref.listen(mpcCeremonyProvider,
        (previous, MpcCeremonyState ceremonyState) {
      if (state.step != VBtcOnboardStep.tokenize) return;

      if (ceremonyState.isContractCreated) {
        ref.invalidate(tokenizedBitcoinListProvider);
        _waitForTokenInList();
        ceremonyCeremonyListener?.close();
      }

      if (ceremonyState.isFailed) {
        state = state.copyWith(processingState: VBtcProcessingState.ready);
        ceremonyCeremonyListener?.close();
      }
    });
  }

  void _waitForTokenInList() {
    tokenInListListener?.close();
    tokenInListListener = ref.listen(tokenizedBitcoinListProvider,
        (previous, List<TokenizedBitcoin> tokens) {
      if (state.step == VBtcOnboardStep.tokenize) {
        final token = tokens
            .firstWhereOrNull((t) => t.rbxAddress == state.vfxWallet?.address);

        if (token != null) {
          Toast.message(globalL10n.bw2TokenDeployed);
          state = state.copyWith(
              step: VBtcOnboardStep.transferBtcToVbtc,
              processingState: VBtcProcessingState.ready,
              tokenizedBtc: token);
        }
      }
    });
  }

  void setupBtcToVbtcListener() {
    btcToVbtcListener = ref.listen(tokenizedBitcoinListProvider,
        (previous, List<TokenizedBitcoin> tokens) {
      if (state.step == VBtcOnboardStep.transferBtcToVbtc) {
        if (state.tokenizedBtc == null) {
          print("tokenized btc is null. closing listener");
          btcToVbtcListener?.close();

          return;
        }
        final token = tokens.firstWhereOrNull(
            (t) => t.id == state.tokenizedBtc!.id && t.balance > 0);
        if (token != null) {
          Toast.message(globalL10n.bw2TransferComplete);
          state = state.copyWith(
              completed: true, processingState: VBtcProcessingState.ready);

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
    ceremonyCeremonyListener?.close();
    tokenInListListener?.close();
    btcToVbtcListener?.close();
    ref.read(mpcCeremonyProvider.notifier).reset();
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
      state = state.copyWith(
          vfxWallet: vfxWallet, step: VBtcOnboardStep.createOrImportBtcAccount);
    } else {
      state = state.copyWith(
          vfxWallet: vfxWallet, step: VBtcOnboardStep.faucetWithdrawl);
    }
    ref.read(tokenizeBtcFormProvider.notifier).setAddress(vfxWallet.address);
  }

  void setBtcAccount(BtcAccount account) {
    if (account.balance > 0) {
      state =
          state.copyWith(btcAccount: account, step: VBtcOnboardStep.tokenize);
    } else {
      state = state.copyWith(
          btcAccount: account, step: VBtcOnboardStep.transferBtc);
      setProcessingState(VBtcProcessingState.waitingForBtcTransfer);
    }
  }

  void refreshBtcAccount() {
    if (state.btcAccount == null) {
      return;
    }

    final b = ref
        .read(btcAccountListProvider)
        .firstWhereOrNull((a) => a.address == state.btcAccount!.address);
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
      Toast.error(globalL10n.bw2NoBtcAccountSelected);
      return false;
    }

    if (state.tokenizedBtc == null) {
      Toast.error(globalL10n.bw2NoBtcTokenSelected);
      return false;
    }
    if (state.tokenizedBtc!.btcAddress == null) {
      Toast.error(globalL10n.bw2NoBtcAddressInToken);
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
      notifyTransactionSubmitted();
      return true;
    }

    Toast.error(result.message);
    return false;
  }
}
