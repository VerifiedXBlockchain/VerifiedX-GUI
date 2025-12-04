import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/butterfly_create_response.dart';
import '../models/butterfly_link.dart';
import '../services/butterfly_service.dart';
import 'butterfly_links_provider.dart';

enum ButterflyCreationStep {
  input,
  confirm,
  sendingTx,
  waitingForFund,
  complete,
  error,
}

class ButterflyCreationState {
  final ButterflyCreationStep step;
  final double amount;
  final String message;
  final ButterflyIcon icon;
  final ButterflyCreateResponse? createResponse;
  final String? txHash;
  final String? errorMessage;
  final bool isProcessing;
  final ButterflyLink? completedLink;

  const ButterflyCreationState({
    this.step = ButterflyCreationStep.input,
    this.amount = 0,
    this.message = '',
    this.icon = ButterflyIcon.defaultIcon,
    this.createResponse,
    this.txHash,
    this.errorMessage,
    this.isProcessing = false,
    this.completedLink,
  });

  ButterflyCreationState copyWith({
    ButterflyCreationStep? step,
    double? amount,
    String? message,
    ButterflyIcon? icon,
    ButterflyCreateResponse? createResponse,
    String? txHash,
    String? errorMessage,
    bool? isProcessing,
    ButterflyLink? completedLink,
  }) {
    return ButterflyCreationState(
      step: step ?? this.step,
      amount: amount ?? this.amount,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      createResponse: createResponse ?? this.createResponse,
      txHash: txHash ?? this.txHash,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      completedLink: completedLink ?? this.completedLink,
    );
  }

  String get stepTitle {
    switch (step) {
      case ButterflyCreationStep.input:
        return 'Create Payment Link';
      case ButterflyCreationStep.confirm:
        return 'Confirm Details';
      case ButterflyCreationStep.sendingTx:
        return 'Sending VFX';
      case ButterflyCreationStep.waitingForFund:
        return 'Waiting for Confirmation';
      case ButterflyCreationStep.complete:
        return 'Link Ready!';
      case ButterflyCreationStep.error:
        return 'Error';
    }
  }

  int get stepNumber {
    switch (step) {
      case ButterflyCreationStep.input:
        return 1;
      case ButterflyCreationStep.confirm:
        return 2;
      case ButterflyCreationStep.sendingTx:
      case ButterflyCreationStep.waitingForFund:
        return 3;
      case ButterflyCreationStep.complete:
      case ButterflyCreationStep.error:
        return 4;
    }
  }
}

class ButterflyCreationProvider extends StateNotifier<ButterflyCreationState> {
  final Ref ref;
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int _maxPollAttempts = 60; // 5 minutes at 5 second intervals

  ButterflyCreationProvider(this.ref) : super(const ButterflyCreationState());

  void setInput(double amount, String message, ButterflyIcon icon) {
    state = state.copyWith(
      amount: amount,
      message: message,
      icon: icon,
      step: ButterflyCreationStep.confirm,
      errorMessage: null,
    );
  }

  void goBack() {
    if (state.step == ButterflyCreationStep.confirm) {
      state = state.copyWith(step: ButterflyCreationStep.input);
    }
  }

  Future<bool> createAndSend({
    required Future<String?> Function(double amount, String toAddress)
        sendTransaction,
    required String senderAddress,
  }) async {
    state = state.copyWith(
      isProcessing: true,
      step: ButterflyCreationStep.sendingTx,
      errorMessage: null,
    );

    // Step 1: Create the Butterfly link
    final response = await ButterflyService().createButterflyLink(
      amount: state.amount,
      message: state.message.isEmpty ? 'Payment from VFX Wallet' : state.message,
      icon: state.icon,
    );

    if (response == null) {
      state = state.copyWith(
        errorMessage: 'Failed to create payment link. Please try again.',
        isProcessing: false,
        step: ButterflyCreationStep.error,
      );
      return false;
    }

    state = state.copyWith(createResponse: response);

    // Step 2: Send VFX to escrow address
    final amountWithFee = response.amountDouble;
    final txHash = await sendTransaction(amountWithFee, response.escrowAddress);

    if (txHash == null) {
      state = state.copyWith(
        errorMessage: 'Failed to send VFX to escrow. Please try again.',
        isProcessing: false,
        step: ButterflyCreationStep.error,
      );
      return false;
    }

    state = state.copyWith(
      txHash: txHash,
      step: ButterflyCreationStep.waitingForFund,
    );

    // Step 3: Start polling for confirmation
    _startPolling(senderAddress);
    return true;
  }

  void _startPolling(String senderAddress) {
    _pollingTimer?.cancel();
    _pollCount = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (state.createResponse == null) {
        timer.cancel();
        return;
      }

      _pollCount++;

      if (_pollCount > _maxPollAttempts) {
        timer.cancel();
        state = state.copyWith(
          errorMessage:
              'Timeout waiting for deposit confirmation. The link was created but may need manual verification.',
          isProcessing: false,
          step: ButterflyCreationStep.error,
        );
        return;
      }

      final status =
          await ButterflyService().getButterflyStatus(state.createResponse!.linkId);

      if (status != null && status.isReadyForRedemption) {
        timer.cancel();

        // Create the completed link
        final completedLink = ButterflyLink(
          linkId: state.createResponse!.linkId,
          shortUrl: state.createResponse!.shortUrl,
          fullUrl: state.createResponse!.fullUrl,
          escrowAddress: state.createResponse!.escrowAddress,
          amount: state.createResponse!.amountDouble,
          claimAmount: status.claimAmountDouble ?? state.amount,
          message: state.message.isEmpty ? 'Payment from VFX Wallet' : state.message,
          icon: state.icon,
          status: ButterflyLinkStatus.readyForRedemption,
          senderAddress: senderAddress,
          createdAt: DateTime.now(),
          txHash: state.txHash,
        );

        // Save to history
        ref.read(butterflyLinksProvider.notifier).addLink(completedLink);

        state = state.copyWith(
          step: ButterflyCreationStep.complete,
          isProcessing: false,
          completedLink: completedLink,
        );
      }
    });
  }

  void reset() {
    _pollingTimer?.cancel();
    _pollCount = 0;
    state = const ButterflyCreationState();
  }

  void setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      step: ButterflyCreationStep.error,
      isProcessing: false,
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final butterflyCreationProvider = StateNotifierProvider.autoDispose<
    ButterflyCreationProvider, ButterflyCreationState>((ref) {
  return ButterflyCreationProvider(ref);
});
