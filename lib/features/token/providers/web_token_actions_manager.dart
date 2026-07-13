import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/utils.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../../nft/models/nft.dart';
import '../models/web_fungible_token.dart';
import '../../web/utils/raw_transaction.dart';

import '../../../core/app_constants.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../btc_web/models/btc_web_vbtc_token.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../keygen/models/keypair.dart';
import '../../keygen/models/ra_keypair.dart';
import '../../raw/raw_service.dart';
import '../../transactions/models/web_transaction.dart';
import '../../transactions/providers/web_transaction_list_provider.dart';
import '../models/new_token_topic.dart';

class WebTokenActionsManager {
  final Ref ref;

  WebTokenActionsManager(this.ref);

  Future<bool?> _verifyConfirmAndSendTx({
    required String toAddress,
    dynamic data,
    Keypair? keypairOverride,
    int txType = TxType.tokenTx,
    double amount = 0,
    int? unlockHours,
    bool showConfirmation = true,
    bool showLoader = true,
    bool showToasts = true,
  }) async {
    final keypair = keypairOverride ?? ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No keypair found to sign transaction");
      return false;
    }

    if (showLoader) {
      ref.read(globalLoadingProvider.notifier).start();
    }

    final txData = await RawTransaction.generate(
      keypair: keypair,
      toAddress: toAddress,
      amount: amount,
      txType: txType,
      data: data,
      unlockHours: unlockHours,
    );
    if (showLoader) {
      ref.read(globalLoadingProvider.notifier).complete();
    }
    if (txData == null) {
      if (showToasts) {
        Toast.error("Invalid transaction data.");
      }
      return false;
    }

    final txFee = txData['Fee'];

    if (showConfirmation) {
      final confirmed = await ConfirmDialog.show(
        title: "Valid Transaction",
        body:
            "Transaction verified. There will be a fee of $txFee VFX. Would you like to proceed?",
        confirmText: "Yes",
        cancelText: "Cancel",
      );

      if (confirmed != true) {
        return null;
      }
    }
    if (showLoader) {
      ref.read(globalLoadingProvider.notifier).start();
    }

    final tx = await RawService()
        .sendTransaction(transactionData: txData, execute: true, ref: ref);

    if (showLoader) {
      ref.read(globalLoadingProvider.notifier).complete();
    }
    if (tx != null && tx['Result'] == "Success") {
      if (showToasts) {
        Toast.message("Transaction broadcasted!");
      }
      return true;
    }
    if (showToasts) {
      Toast.error(tx?['Message']);
    }
    return false;
  }

  Future<bool?> mintTokens(
      WebFungibleToken token, String address, double amount,
      [bool silent = false]) async {
    final data = {
      "Function": "TokenMint()",
      "ContractUID": token.smartContractId,
      "FromAddress": address,
      "Amount": amount,
      "TokenTicker": token.ticker,
      "TokenName": token.name,
    };

    return await _verifyConfirmAndSendTx(
        toAddress: "Token_Base",
        data: data,
        showConfirmation: !silent,
        showLoader: !silent,
        showToasts: !silent);
  }

  Future<bool?> transferAmount(WebFungibleToken token, String toAddress,
      String fromAddress, double amount) async {
    final data = {
      "Function": "TokenTransfer()",
      "ContractUID": token.smartContractId,
      "FromAddress": fromAddress,
      "ToAddress": toAddress,
      "Amount": amount,
      "TokenTicker": token.ticker,
      "TokenName": token.name,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: toAddress,
      data: data,
    );
  }

  Future<bool?> burnAmount(
      WebFungibleToken token, String address, double amount) async {
    final data = {
      "Function": "TokenBurn()",
      "ContractUID": token.smartContractId,
      "FromAddress": address,
      "Amount": amount,
      "TokenTicker": token.ticker,
      "TokenName": token.name,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: "Token_Base",
      data: data,
    );
  }

  Future<bool?> transferOwnership(
    WebFungibleToken token,
    String toAddress,
    String fromAddress,
  ) async {
    final data = {
      "Function": "TokenContractOwnerChange()",
      "ContractUID": token.smartContractId,
      "FromAddress": fromAddress,
      "ToAddress": toAddress,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: toAddress,
      data: data,
    );
  }

  Future<bool?> transferOwnershipFromVault(
    WebFungibleToken token,
    String toAddress,
    String fromAddress,
    RaKeypair raKeypair,
    int unlockHours,
  ) async {
    final data = {
      "Function": "TokenContractOwnerChange()",
      "ContractUID": token.smartContractId,
      "FromAddress": fromAddress,
      "ToAddress": toAddress,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: toAddress,
      data: data,
      keypairOverride: raKeypair.asKeypair,
      unlockHours: unlockHours,
    );
  }

  Future<bool?> pause(
    WebFungibleToken token,
    String address,
    bool pause,
  ) async {
    final data = {
      "Function": "TokenPause()",
      "ContractUID": token.smartContractId,
      "FromAddress": address,
      "Pause": pause,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: "Token_Base",
      data: data,
    );
  }

  Future<bool?> banAddress(
    WebFungibleToken token,
    String ownerAddress,
    String banAddress,
  ) async {
    final data = {
      "Function": "TokenBanAddress()",
      "ContractUID": token.smartContractId,
      "FromAddress": ownerAddress,
      "BanAddress": banAddress,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: "Token_Base",
      data: data,
    );
  }

  Future<bool?> createVotingTopic(NewTokenTopic topic) async {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final end = (DateTime.now()
                .add(Duration(days: topic.votingDaysAsInt))
                .millisecondsSinceEpoch /
            1000)
        .round();
    final topicUid = "${generateRandomString(8)}$now";
    final h = ref.read(walletInfoProvider)?.blockHeight ?? 0;

    final data = {
      "Function": "TokenVoteTopicCreate()",
      "ContractUID": topic.smartContractUid, //**
      "FromAddress": topic.fromAddress, //**
      "TokenVoteTopic": {
        "SmartContractUID": topic.smartContractUid, //**
        "TopicUID": topicUid, //** GENERATE RANDOM?
        "TopicName": topic.name, //**
        "TopicDescription": topic.description, //**
        "MinimumVoteRequirement": topic.minimumVoteRequirement, //**
        "BlockHeight": h, //**  use most recent block
        "TokenHolderCount": 1, //**
        "TopicCreateDate": now, //**
        "VotingEndDate": end, //** based on timestamp + length
        "VoteYes": 0,
        "VoteNo": 0,
        "TotalVotes": 0,
        "PercentVotesYes": 0,
        "PercentVotesNo": 0,
        "PercentInFavor": 0,
        "PercentAgainst": 0
      }
    };

    return await _verifyConfirmAndSendTx(
      toAddress: "Token_Base",
      data: data,
      txType: TxType.tokenTx,
    );
  }

  Future<bool?> voteOnTopic(String scId, String scOwnerAddress,
      String fromAddress, String topicId, bool value) async {
    final data = {
      "Function": "TokenVoteTopicCast()",
      "ContractUID": scId,
      "FromAddress": fromAddress,
      "TopicUID": topicId,
      "VoteType": value ? 1 : 0
    };

    return await _verifyConfirmAndSendTx(
      toAddress: scOwnerAddress,
      data: data,
      txType: TxType.tokenTx,
    );
  }

  /// Signs a hash and sends the signature to a "send" endpoint.
  /// Common pattern for all V2 two-step operations.
  Future<bool?> transferVbtcOwnership({
    required String scIdentifier,
    required String toAddress,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No VFX account found");
      return false;
    }

    ref.read(globalLoadingProvider.notifier).start();

    // Step 1: Get transfer TX data.
    // vBTC V2 tokens are media-less (synthetic placeholder asset, MD5List "NA"
    // in the state trei), so the beacon upload step must be skipped: no file
    // exists to push, and a failed push leaves a stale beacon record that
    // poisons all retries of this transfer. "NA" is the protocol's standing
    // no-media locator — recipient nodes skip the beacon download and create
    // the contract from chain data.
    try {
      final response = await ExplorerService().getVbtcOwnershipTransferData(
        scIdentifier: scIdentifier,
        toAddress: toAddress,
        locator: "NA",
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (response['success'] != true || response['tx_data'] == null) {
        Toast.error(response['message'] ?? "Failed to prepare ownership transfer");
        return false;
      }

      // Step 2: Build, sign, send via standard raw TX pipeline
      return await _verifyConfirmAndSendTx(
        toAddress: toAddress,
        data: response['tx_data'],
        txType: 18, // TKNZ_TX
      );
    } catch (e) {
      ref.read(globalLoadingProvider.notifier).complete();
      Toast.error("Ownership transfer failed: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> _signAndSend({
    required String hash,
    required Future<Map<String, dynamic>> Function({
      required String hash,
      required String signature,
      required String publicKey,
    }) sendFn,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No keypair found to sign transaction");
      return null;
    }

    final signature = await RawTransaction.getSignature(
      message: hash,
      privateKey: keypair.private,
      publicKey: keypair.public,
    );

    if (signature == null) {
      Toast.error("Failed to sign transaction");
      return null;
    }

    try {
      return await sendFn(
        hash: hash,
        signature: signature,
        publicKey: keypair.public,
      );
    } catch (e) {
      Toast.error("Transaction failed: $e");
      return null;
    }
  }

  Future<bool?> transferVbtcV2({
    required BtcWebVbtcToken token,
    required String toAddress,
    required String fromAddress,
    required double amount,
  }) async {
    ref.read(globalLoadingProvider.notifier).start();

    try {
      final prepared = await ExplorerService().prepareV2Transfer(
        scIdentifier: token.scIdentifier,
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (prepared['success'] != true || prepared['Hash'] == null) {
        Toast.error(prepared['message'] ?? "Failed to prepare transfer");
        return false;
      }

      final confirmed = await ConfirmDialog.show(
        title: "Confirm Transfer",
        body: "Transfer $amount vBTC to $toAddress?",
        confirmText: "Transfer",
        cancelText: "Cancel",
      );

      if (confirmed != true) return null;

      ref.read(globalLoadingProvider.notifier).start();

      final result = await _signAndSend(
        hash: prepared['Hash'],
        sendFn: ExplorerService().sendV2Transfer,
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (result != null && result['success'] == true) {
        Toast.message("vBTC transfer broadcasted successfully");
        ref.read(webTransactionListProvider(fromAddress).notifier).insertPendingTx(
          WebTransaction(
            hash: result['Hash'] ?? prepared['Hash'] ?? '',
            toAddress: toAddress,
            fromAddress: fromAddress,
            type: TxType.vbtcV2Transfer,
            amount: 0,
            fee: 0,
            date: DateTime.now(),
            height: 0,
          ),
        );
        return true;
      }

      Toast.error(result?['message'] ?? "Transfer failed");
      return false;
    } catch (e) {
      ref.read(globalLoadingProvider.notifier).complete();
      Toast.error("Transfer failed: $e");
      return false;
    }
  }

  /// V2 withdrawal request via prepare→sign→send.
  /// Returns { 'success': true, 'hash': '...' } or { 'success': false, 'message': '...' }.
  Future<Map<String, dynamic>> requestV2Withdrawal({
    required String scIdentifier,
    required String requestorAddress,
    required String btcAddress,
    required double amount,
    required int feeRate,
  }) async {
    ref.read(globalLoadingProvider.notifier).start();

    try {
      final prepared = await ExplorerService().prepareV2WithdrawalRequest(
        scIdentifier: scIdentifier,
        requestorAddress: requestorAddress,
        btcAddress: btcAddress,
        amount: amount,
        feeRate: feeRate,
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (prepared['success'] != true || prepared['Hash'] == null) {
        return {'success': false, 'message': prepared['message'] ?? 'Failed to prepare withdrawal request'};
      }

      final confirmed = await ConfirmDialog.show(
        title: "Confirm Withdrawal Request",
        body: "Withdraw $amount BTC to $btcAddress\nFee rate: $feeRate sats/byte\n\nProceed?",
        confirmText: "Yes",
        cancelText: "Cancel",
      );

      if (confirmed != true) return {'success': false, 'message': 'Cancelled'};

      ref.read(globalLoadingProvider.notifier).start();

      final result = await _signAndSend(
        hash: prepared['Hash'],
        sendFn: ExplorerService().sendV2WithdrawalRequest,
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (result != null && result['success'] == true) {
        final hash = result['Hash'] as String?;
        if (hash != null) {
          ref.read(webTransactionListProvider(requestorAddress).notifier).insertPendingTx(
            WebTransaction(
              hash: hash,
              toAddress: requestorAddress,
              fromAddress: requestorAddress,
              type: TxType.vbtcV2WithdrawalRequest,
              amount: 0,
              fee: 0,
              date: DateTime.now(),
              height: 0,
            ),
          );
        }
        return {'success': true, 'hash': hash};
      }

      return {'success': false, 'message': result?['message'] ?? 'Withdrawal request failed'};
    } catch (e) {
      ref.read(globalLoadingProvider.notifier).complete();
      return {'success': false, 'message': 'Withdrawal request failed: $e'};
    }
  }

  /// V2 withdrawal complete via prepare→sign two messages→execute→broadcast BTC.
  Future<Map<String, dynamic>?> completeV2Withdrawal({
    required String scIdentifier,
    required String requestHash,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No keypair found");
      return null;
    }

    try {
      // Step 1: Prepare — get messages to sign + withdrawal params
      final prepared = await ExplorerService().prepareV2WithdrawalComplete(
        scIdentifier: scIdentifier,
        withdrawalRequestHash: requestHash,
        ownerAddress: keypair.address,
      );

      if (prepared['success'] != true || prepared['StartMessage'] == null) {
        return {'success': false, 'message': prepared['message'] ?? 'Failed to prepare FROST signing'};
      }

      final startMessage = prepared['StartMessage'] as String;
      final startTimestamp = prepared['StartTimestamp'] as int;
      final shareMessage = prepared['ShareDistributionMessage'] as String;
      final shareTimestamp = prepared['ShareDistributionTimestamp'] as int;
      final sessionId = prepared['SessionId'] as String;

      // Step 2: Sign both messages (same pattern as ceremony)
      final startSig = await RawTransaction.getSignature(
        message: startMessage,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      final shareSig = await RawTransaction.getSignature(
        message: shareMessage,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      if (startSig == null || shareSig == null) {
        return {'success': false, 'message': 'Failed to sign FROST messages'};
      }

      // Step 3: Execute — kicks off FROST signing asynchronously, returns job_id
      final executeResult = await ExplorerService().executeV2WithdrawalComplete(
        scIdentifier: scIdentifier,
        withdrawalRequestHash: requestHash,
        ownerAddress: keypair.address,
        sessionId: sessionId,
        startSignature: startSig,
        startTimestamp: startTimestamp,
        shareDistributionSignature: shareSig,
        shareDistributionTimestamp: shareTimestamp,
        amount: (prepared['Amount'] as num?)?.toDouble() ?? 0,
        btcDestination: prepared['BTCDestination'] as String? ?? '',
        feeRate: prepared['FeeRate'] as int? ?? 0,
      );

      final jobId = executeResult['job_id'] as String?;
      if (jobId == null) {
        return {'success': false, 'message': 'Failed to start FROST signing'};
      }

      // Step 4: Poll for FROST signing result (up to 3 minutes)
      String? signedBtcTxHex;
      int notFoundCount = 0;
      for (int i = 0; i < 36; i++) {
        await Future.delayed(const Duration(seconds: 5));
        try {
          final status = await ExplorerService().getV2WithdrawalCompleteStatus(jobId);
          if (status['status'] == 'complete') {
            signedBtcTxHex = status['signed_btc_tx_hex'] as String?;
            break;
          } else if (status['status'] == 'failed') {
            return {'success': false, 'message': status['message'] ?? 'FROST signing failed'};
          } else if (status['success'] == false) {
            notFoundCount++;
            // Job not registered yet (race) — tolerate a few misses, bail if persistent
            if (notFoundCount > 6) {
              return {'success': false, 'message': status['message'] ?? 'FROST signing job not found'};
            }
          } else {
            notFoundCount = 0; // reset if we get a valid pending response
          }
        } catch (_) {
          // transient error — keep polling
        }
      }

      if (signedBtcTxHex == null || signedBtcTxHex.isEmpty) {
        return {'success': false, 'message': 'FROST signing timed out. The withdrawal may still complete — check back shortly.'};
      }

      // Step 5: Broadcast the signed BTC TX
      final broadcastResult = await ExplorerService().broadcastBtcTransaction(signedBtcTxHex);

      if (broadcastResult['success'] != true) {
        return {
          'success': false,
          'message': broadcastResult['message'] ?? 'Failed to broadcast BTC transaction',
          'SignedBTCTxHex': signedBtcTxHex,
        };
      }

      final btcTxHash = broadcastResult['txid'] as String;

      // Step 6: Record completion on VFX chain (Type 28 TX)
      try {
        final completePrepared = await ExplorerService().prepareV2WithdrawalCompleteTx(
          scIdentifier: scIdentifier,
          fromAddress: keypair.address,
          withdrawalRequestHash: requestHash,
          btcTransactionHash: btcTxHash,
          amount: (prepared['Amount'] as num?)?.toDouble() ?? 0,
          btcDestination: prepared['BTCDestination'] as String? ?? '',
        );

        if (completePrepared['success'] == true && completePrepared['Hash'] != null) {
          final completeSig = await RawTransaction.getSignature(
            message: completePrepared['Hash'] as String,
            privateKey: keypair.private,
            publicKey: keypair.public,
          );

          if (completeSig != null) {
            await ExplorerService().sendV2WithdrawalCompleteTx(
              hash: completePrepared['Hash'] as String,
              signature: completeSig,
              publicKey: keypair.public,
            );
          }
        }
      } catch (e) {
        // Type 28 TX failed but BTC was already sent — not critical
        print('Warning: Failed to record withdrawal completion on VFX chain: $e');
      }

      return {
        'success': true,
        'btc_transaction_hash': btcTxHash,
      };
    } catch (e) {
      return {'success': false, 'message': 'FROST signing failed: $e'};
    }
  }

  /// V2 withdrawal cancel via prepare→sign→send.
  Future<bool> cancelV2Withdrawal({
    required String scIdentifier,
    required String ownerAddress,
    required String requestHash,
  }) async {
    try {
      final prepared = await ExplorerService().prepareV2WithdrawalCancel(
        scIdentifier: scIdentifier,
        ownerAddress: ownerAddress,
        withdrawalRequestHash: requestHash,
      );

      if (prepared['success'] != true || prepared['Hash'] == null) {
        Toast.error(prepared['message'] ?? "Failed to prepare cancellation");
        return false;
      }

      final result = await _signAndSend(
        hash: prepared['Hash'],
        sendFn: ExplorerService().sendV2WithdrawalCancel,
      );

      if (result != null && result['success'] == true) {
        ref.read(webTransactionListProvider(ownerAddress).notifier).insertPendingTx(
          WebTransaction(
            hash: result['Hash'] ?? prepared['Hash'] ?? '',
            toAddress: ownerAddress,
            fromAddress: ownerAddress,
            type: TxType.vbtcV2WithdrawalCancel,
            amount: 0,
            fee: 0,
            date: DateTime.now(),
            height: 0,
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      Toast.error("Cancellation failed: $e");
      return false;
    }
  }

  bool verifyBalance({bool isRa = false}) {
    if (isRa) {
      if ((ref.read(webSessionProvider).raBalance ?? 0) <
          MIN_RBX_FOR_SC_ACTION) {
        Toast.error(
            "A balance on your Vault account is required to broadcast this transaction");

        return false;
      }
      return true;
    }

    if ((ref.read(webSessionProvider).balance ?? 0) < MIN_RBX_FOR_SC_ACTION) {
      Toast.error(
          "A balance on your VFX account is required to broadcast this transaction");

      return false;
    }
    return true;
  }

  bool guardIsTokenOwner(WebFungibleToken token) {
    final sessionModel = ref.read(webSessionProvider);

    if ([sessionModel.keypair?.address, sessionModel.raKeypair?.address]
        .contains(token.ownerAddress)) {
      return true;
    }
    Toast.error("Only the owner of this token can perform this action");
    return false;
  }

  bool guardIsTokenOwnerAndNotVault(WebFungibleToken token) {
    if (!guardIsTokenOwner(token)) {
      return false;
    }

    final sessionModel = ref.read(webSessionProvider);

    if (sessionModel.keypair?.address == token.ownerAddress) {
      return true;
    }

    Toast.error(
        "Vault accounts cannot perform this action. Please transfer ownership to your standard VFX account first");
    return false;
  }

  bool guardIsNotPaused(WebFungibleToken token) {
    if (token.isPaused) {
      Toast.error("Transactions on this token are currently paused.");
      return false;
    }
    return true;
  }

  Future<String?> promptForAddress({String title = "Address"}) async {
    final address = await PromptModal.show(
      title: title,
      validator: formValidatorRbxAddress,
      labelText: "Address",
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
      ],
    );

    if (address == null || address.isEmpty) {
      return null;
    }

    return address;
  }

  Future<double?> promptForAmount({String title = "Amount"}) async {
    final amount = await PromptModal.show(
      title: title,
      validator: (val) => formValidatorNumber(val, "Amount"),
      labelText: "Amount",
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
    );
    if (amount == null || amount.isEmpty) {
      return null;
    }

    final amountDouble = double.tryParse(amount);

    if (amountDouble == null) {
      Toast.error("Invalid Amount");
      return null;
    }
    return amountDouble;
  }
}

final webTokenActionsManager = Provider((ref) {
  return WebTokenActionsManager(ref);
});
