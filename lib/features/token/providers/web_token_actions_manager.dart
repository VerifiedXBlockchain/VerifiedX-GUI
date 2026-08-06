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
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../btc_web/models/btc_web_vbtc_token.dart';
import '../../btc_web/services/frost_resume_guard.dart';
import '../../btc_web/services/vbtc_media_detection.dart';
import '../../btc_web/services/pending_frost_signing_job_service.dart';
import '../../btc_web/services/pending_withdrawal_completion_service.dart';
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
      Toast.error(globalL10n.bw2NoKeypairToSign);
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
        Toast.error(globalL10n.btcInvalidTxData);
      }
      return false;
    }

    final txFee = txData['Fee'];

    if (showConfirmation) {
      final confirmed = await ConfirmDialog.show(
        title: globalL10n.btcValidTxTitle,
        body:
            globalL10n.bw2TxVerifiedFeeBody(txFee.toString()),
        confirmText: "Yes",
        cancelText: globalL10n.actionCancel,
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
    if (tx != null && tx['Result'] == 'Success') {
      if (showToasts) {
        Toast.message(globalL10n.bw2TransactionBroadcasted);
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

  /// Whether this vBTC contract has no media file to ship through a beacon.
  ///
  /// Returns false if the lookup fails: without positive evidence the transfer
  /// keeps requiring a beacon rather than risking a token whose file never
  /// reaches the recipient.
  Future<bool> _contractHasNoMedia(String scIdentifier) async {
    try {
      final token = await ExplorerService().getWebVbtcV2TokenDetail(scIdentifier);
      return vbtcContractHasNoMedia(token.nft);
    } catch (e) {
      print("Could not determine media for $scIdentifier: $e");
      return false;
    }
  }

  /// Signs a hash and sends the signature to a "send" endpoint.
  /// Common pattern for all V2 two-step operations.
  Future<bool?> transferVbtcOwnership({
    required String scIdentifier,
    required String toAddress,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error(globalL10n.bw2NoVfxAccountFound);
      return false;
    }

    // Step 1: Beacon upload
    final beaconSig = await RawTransaction.getSignature(
      message: scIdentifier,
      privateKey: keypair.private,
      publicKey: keypair.public,
    );
    if (beaconSig == null) {
      Toast.error(globalL10n.bw2FailedSignBeacon);
      return false;
    }

    ref.read(globalLoadingProvider.notifier).start();

    var locator = await RawService().beaconUpload(scIdentifier, toAddress, beaconSig);

    // A blank locator is as unusable as a missing one, and worse in practice: it
    // survives a null check and then collapses the transfer-data URL to an empty
    // path segment, which the explorer route cannot match and answers 404. A
    // no-media upload reports success with nothing to locate, so this is the
    // normal result for exactly the contracts that need the fallback.
    if (locator != null && locator.trim().isEmpty) {
      locator = null;
    }

    if (locator == null) {
      // A contract with no media has nothing to ship, so a dead beacon should
      // not stop the transfer. The node reaches the same conclusion from the
      // state trei and forces the "NA" locator itself; this stops the wallet
      // aborting before the node is ever asked.
      //
      // Only checked once the upload has already failed, so the working path is
      // untouched and this costs nothing when beacons are healthy.
      if (await _contractHasNoMedia(scIdentifier)) {
        locator = "NA";
      } else {
        ref.read(globalLoadingProvider.notifier).complete();
        Toast.error(
          globalL10n.bw2BeaconUploadFailedHasMedia,
        );
        return false;
      }
    }

    // Step 2: Get transfer TX data
    try {
      final response = await ExplorerService().getVbtcOwnershipTransferData(
        scIdentifier: scIdentifier,
        toAddress: toAddress,
        locator: locator,
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (response['success'] != true || response['tx_data'] == null) {
        Toast.error(response['message'] ?? globalL10n.bw2FailedPrepareOwnershipTransfer);
        return false;
      }

      // Step 3: Build, sign, send via standard raw TX pipeline
      return await _verifyConfirmAndSendTx(
        toAddress: toAddress,
        data: response['tx_data'],
        txType: 18, // TKNZ_TX
      );
    } catch (e) {
      ref.read(globalLoadingProvider.notifier).complete();
      Toast.error(globalL10n.bw2OwnershipTransferFailed(e.toString()));
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
      Toast.error(globalL10n.bw2NoKeypairToSign);
      return null;
    }

    final signature = await RawTransaction.getSignature(
      message: hash,
      privateKey: keypair.private,
      publicKey: keypair.public,
    );

    if (signature == null) {
      Toast.error(globalL10n.bw2FailedSignTransaction);
      return null;
    }

    try {
      return await sendFn(
        hash: hash,
        signature: signature,
        publicKey: keypair.public,
      );
    } catch (e) {
      Toast.error(globalL10n.bw2TransactionFailed(e.toString()));
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
        Toast.error(prepared['message'] ?? globalL10n.bw2FailedPrepareTransfer);
        return false;
      }

      final confirmed = await ConfirmDialog.show(
        title: globalL10n.bw2ConfirmTransfer,
        body: globalL10n.bw2ConfirmTransferBody(amount.toString(), toAddress),
        confirmText: globalL10n.btcTransferLabel,
        cancelText: globalL10n.actionCancel,
      );

      if (confirmed != true) return null;

      ref.read(globalLoadingProvider.notifier).start();

      final result = await _signAndSend(
        hash: prepared['Hash'],
        sendFn: ExplorerService().sendV2Transfer,
      );

      ref.read(globalLoadingProvider.notifier).complete();

      if (result != null && result['success'] == true) {
        Toast.message(globalL10n.bw2VbtcTransferBroadcastedSuccess);
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

      Toast.error(result?['message'] ?? globalL10n.bw2TransferFailed);
      return false;
    } catch (e) {
      ref.read(globalLoadingProvider.notifier).complete();
      Toast.error(globalL10n.bw2TransferFailedError(e.toString()));
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
        return {'success': false, 'message': prepared['message'] ?? globalL10n.bw2FailedPrepareWithdrawalRequest};
      }

      final confirmed = await ConfirmDialog.show(
        title: globalL10n.bw2ConfirmWithdrawalRequest,
        body: globalL10n.bw2WithdrawalRequestBody(amount.toString(), btcAddress, feeRate.toString()),
        confirmText: "Yes",
        cancelText: globalL10n.actionCancel,
      );

      if (confirmed != true) return {'success': false, 'message': globalL10n.bw2Cancelled};

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

      return {'success': false, 'message': result?['message'] ?? globalL10n.bw2WithdrawalRequestFailed};
    } catch (e) {
      ref.read(globalLoadingProvider.notifier).complete();
      return {'success': false, 'message': 'Withdrawal request failed: $e'};
    }
  }

  /// Records the Type 28 completion TX on the VFX chain for a withdrawal whose
  /// Bitcoin transaction has already been broadcast.
  ///
  /// This is the transaction that actually settles the withdrawal on chain — if
  /// it never lands, the BTC has left the vault but the contract still shows the
  /// request as pending. It is therefore reported and retried independently of
  /// the FROST signing, and must never be silently skipped.
  Future<Map<String, dynamic>> recordV2WithdrawalCompletion({
    required String scIdentifier,
    required String requestHash,
    required String btcTxHash,
    required double amount,
    required String btcDestination,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      return {'success': false, 'message': 'No keypair found to sign the completion transaction'};
    }

    try {
      final prepared = await ExplorerService().prepareV2WithdrawalCompleteTx(
        scIdentifier: scIdentifier,
        fromAddress: keypair.address,
        withdrawalRequestHash: requestHash,
        btcTransactionHash: btcTxHash,
        amount: amount,
        btcDestination: btcDestination,
      );

      if (prepared['success'] != true || prepared['Hash'] == null) {
        return {
          'success': false,
          'message': prepared['message'] ?? 'Failed to prepare the completion transaction',
        };
      }

      final hash = prepared['Hash'] as String;

      final signature = await RawTransaction.getSignature(
        message: hash,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      if (signature == null) {
        return {'success': false, 'message': 'Failed to sign the completion transaction'};
      }

      final result = await ExplorerService().sendV2WithdrawalCompleteTx(
        hash: hash,
        signature: signature,
        publicKey: keypair.public,
      );

      if (result['success'] != true) {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to broadcast the completion transaction',
        };
      }

      final completionHash = (result['Hash'] as String?) ?? hash;

      ref.read(webTransactionListProvider(keypair.address).notifier).insertPendingTx(
        WebTransaction(
          hash: completionHash,
          toAddress: keypair.address,
          fromAddress: keypair.address,
          type: TxType.vbtcV2WithdrawalComplete,
          amount: 0,
          fee: 0,
          date: DateTime.now(),
          height: 0,
        ),
      );

      await PendingWithdrawalCompletionService().clear(requestHash);

      return {'success': true, 'hash': completionHash};
    } catch (e) {
      return {'success': false, 'message': 'Completion transaction failed: $e'};
    }
  }

  /// Asks the explorer whether signing has already run for [requestHash],
  /// for the case where no local record survives to say so.
  ///
  /// Returns a result for the caller to hand straight back, or null to carry
  /// on with a fresh ceremony. Only consulted once both local lookups have
  /// missed — on the same browser the stored records are faster and better.
  Future<Map<String, dynamic>?> _guardAgainstResigning({
    required String scIdentifier,
    required String requestHash,
  }) async {
    Map<String, dynamic>? row;

    try {
      final detail = await ExplorerService().getWebVbtcV2TokenDetail(scIdentifier);
      for (final wr in detail.withdrawalRequests ?? <Map<String, dynamic>>[]) {
        if (wr['request_transaction_hash'] == requestHash) {
          row = wr;
          break;
        }
      }
    } catch (e) {
      // Left null: see frostResumeActionFor, which reads an unreadable row as
      // "carry on" so a transient explorer error cannot block a first-time
      // withdrawal.
      print("Could not read withdrawal state before signing: $e");
    }

    switch (frostResumeActionFor(row)) {
      case FrostResumeAction.ceremony:
        return null;

      case FrostResumeAction.completionOnly:
        final amount = (row!['amount'] as num?)?.toDouble() ?? 0;
        final btcDestination = row['btc_address'] as String? ?? '';
        final btcTxHash = row['btc_transaction_hash'] as String;

        final recorded = await recordV2WithdrawalCompletion(
          scIdentifier: scIdentifier,
          requestHash: requestHash,
          btcTxHash: btcTxHash,
          amount: amount,
          btcDestination: btcDestination,
        );

        return {
          'success': true,
          'btc_transaction_hash': btcTxHash,
          'completion_recorded': recorded['success'] == true,
          'completion_message': recorded['message'],
          'completion_recoverable': true,
          'withdrawal_amount': amount,
          'btc_destination': btcDestination,
        };

      case FrostResumeAction.refuse:
        return {
          'success': false,
          'signing_already_started': true,
          'message': 'This withdrawal has already been signed, and the Bitcoin transaction '
              'cannot be recovered from this browser. Do not start it again — signing a '
              'second time can send the Bitcoin twice. Reopen the withdrawal in the browser '
              'it was started from, or contact support so it can be settled manually.',
        };
    }
  }

  /// Watches a FROST signing job until it produces a Bitcoin transaction,
  /// fails outright, or outlives the poll budget.
  Future<_FrostSigningPollResult> _pollFrostSigningJob(String jobId) async {
    int notFoundCount = 0;
    for (int i = 0; i < 36; i++) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final status = await ExplorerService().getV2WithdrawalCompleteStatus(jobId);
        if (status['status'] == 'complete') {
          return _FrostSigningPollResult.signed(status['signed_btc_tx_hex'] as String?);
        } else if (status['status'] == 'failed') {
          return _FrostSigningPollResult.failed(status['message'] ?? globalL10n.bw2FrostSigningFailed);
        } else if (status['success'] == false) {
          notFoundCount++;
          // Job not registered yet (race) — tolerate a few misses, bail if persistent
          if (notFoundCount > 6) {
            return _FrostSigningPollResult.failed(status['message'] ?? globalL10n.bw2FrostJobNotFound);
          }
        } else {
          notFoundCount = 0; // reset if we get a valid pending response
        }
      } catch (_) {
        // transient error — keep polling
      }
    }
    return _FrostSigningPollResult.timedOut();
  }

  /// V2 withdrawal complete via prepare→sign two messages→execute→broadcast BTC.
  ///
  /// If a previous attempt already broadcast the Bitcoin transaction, this skips
  /// FROST entirely and only retries the completion TX — re-running the ceremony
  /// would sign against already-spent inputs. If a previous attempt got as far
  /// as starting a signing job, this resumes polling that job rather than asking
  /// for a second ceremony the validators would refuse.
  Future<Map<String, dynamic>?> completeV2Withdrawal({
    required String scIdentifier,
    required String requestHash,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error(globalL10n.bw2NoKeypairFound);
      return null;
    }

    final alreadyBroadcast = PendingWithdrawalCompletionService().get(requestHash);
    if (alreadyBroadcast != null) {
      // The signing job cannot tell us anything the broadcast has not already
      // settled, so drop it rather than leave it to be resumed later.
      await PendingFrostSigningJobService().clear(requestHash);

      final recorded = await recordV2WithdrawalCompletion(
        scIdentifier: scIdentifier,
        requestHash: requestHash,
        btcTxHash: alreadyBroadcast.btcTxHash,
        amount: alreadyBroadcast.amount,
        btcDestination: alreadyBroadcast.btcDestination,
      );

      return {
        'success': true,
        'btc_transaction_hash': alreadyBroadcast.btcTxHash,
        'completion_recorded': recorded['success'] == true,
        'completion_message': recorded['message'],
        'completion_recoverable': true,
        'withdrawal_amount': alreadyBroadcast.amount,
        'btc_destination': alreadyBroadcast.btcDestination,
      };
    }

    try {
      final String jobId;
      final double withdrawalAmount;
      final String btcDestination;
      // True when the job id only exists in memory, so nothing can pick this
      // signing run back up if the page goes away.
      bool signingRecoverable = true;

      // A job left over from an earlier attempt is resumed as-is. Starting a
      // second ceremony for the same request is refused for 24 hours, so the
      // stored id is the only way back to a signature that may already exist.
      final pendingJob = PendingFrostSigningJobService().get(requestHash);

      if (pendingJob != null) {
        jobId = pendingJob.jobId;
        withdrawalAmount = pendingJob.amount;
        btcDestination = pendingJob.btcDestination;
      } else {
        // Nothing local accounts for this withdrawal. Before asking for a
        // ceremony, check whether one has already run somewhere this browser
        // cannot see.
        final alreadySigned = await _guardAgainstResigning(
          scIdentifier: scIdentifier,
          requestHash: requestHash,
        );
        if (alreadySigned != null) return alreadySigned;

        // Step 1: Prepare — get messages to sign + withdrawal params
        final prepared = await ExplorerService().prepareV2WithdrawalComplete(
          scIdentifier: scIdentifier,
          withdrawalRequestHash: requestHash,
          ownerAddress: keypair.address,
        );

        if (prepared['success'] != true || prepared['StartMessage'] == null) {
          return {'success': false, 'message': prepared['message'] ?? globalL10n.bw2FailedPrepareFrost};
        }

        final startMessage = prepared['StartMessage'] as String;
        final startTimestamp = prepared['StartTimestamp'] as int;
        final shareMessage = prepared['ShareDistributionMessage'] as String;
        final shareTimestamp = prepared['ShareDistributionTimestamp'] as int;
        final sessionId = prepared['SessionId'] as String;
        withdrawalAmount = (prepared['Amount'] as num?)?.toDouble() ?? 0;
        btcDestination = prepared['BTCDestination'] as String? ?? '';

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
          return {'success': false, 'message': globalL10n.bw2FailedSignFrost};
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
          amount: withdrawalAmount,
          btcDestination: btcDestination,
          feeRate: prepared['FeeRate'] as int? ?? 0,
        );

        final startedJobId = executeResult['job_id'] as String?;
        if (startedJobId == null) {
          return {'success': false, 'message': globalL10n.bw2FailedStartFrost};
        }
        jobId = startedJobId;

        // Persist before polling. From here the validators are signing, and a
        // job id that only lives in this tab strands the withdrawal if the tab
        // closes — a fresh ceremony would be refused for 24 hours.
        signingRecoverable = await PendingFrostSigningJobService().record(
          PendingFrostSigningJob(
            scIdentifier: scIdentifier,
            requestHash: requestHash,
            jobId: jobId,
            amount: withdrawalAmount,
            btcDestination: btcDestination,
            fromAddress: keypair.address,
            createdAt: DateTime.now(),
          ),
        );
      }

      // Step 4: Poll for FROST signing result (up to 3 minutes)
      final poll = await _pollFrostSigningJob(jobId);

      if (poll.failureMessage != null) {
        // Signing will not produce anything and the id is now worthless, so it
        // must not be resumed — that would report a dead job forever.
        await PendingFrostSigningJobService().clear(requestHash);
        return {'success': false, 'message': poll.failureMessage};
      }

      final signedBtcTxHex = poll.signedBtcTxHex;
      if (signedBtcTxHex == null || signedBtcTxHex.isEmpty) {
        // The job is kept: signing may still land, and the stored id is what
        // lets a later session collect the result.
        return {
          'success': false,
          'signing_recoverable': signingRecoverable,
          'message': signingRecoverable
              ? 'FROST signing timed out. The withdrawal may still complete — reopen it from the token\'s withdrawal history to check.'
              : 'FROST signing timed out and could not be saved for later recovery. Do not close this page — reopening will not be able to pick the signing back up.',
        };
      }

      // Step 5: Broadcast the signed BTC TX
      final broadcastResult = await ExplorerService().broadcastBtcTransaction(signedBtcTxHex);

      if (broadcastResult['success'] != true) {
        return {
          'success': false,
          'message': broadcastResult['message'] ?? globalL10n.bw2FailedBroadcastBtc,
          'SignedBTCTxHex': signedBtcTxHex,
        };
      }

      final btcTxHash = broadcastResult['txid'] as String?;

      // The broadcast succeeded, so the BTC has left the vault even though we
      // cannot name the transaction. Retrying FROST here would sign against
      // spent inputs, so this gets its own terminal state rather than being
      // reported as a signing failure.
      if (btcTxHash == null || btcTxHash.isEmpty) {
        return {
          'success': false,
          'btc_broadcast_unconfirmed': true,
          'message': 'The Bitcoin transaction was broadcast but no transaction ID was returned. '
              'Do not retry — check the destination address on a block explorer and contact support '
              'so the withdrawal can be settled manually.',
          'SignedBTCTxHex': signedBtcTxHex,
        };
      }

      // Persist before attempting the completion TX. From here on the BTC is
      // gone, so a closed tab or a failed send must still be recoverable.
      // A failed write is not recoverable later, so it is reported rather than
      // swallowed — the caller has to keep the user on this screen.
      final persisted = await PendingWithdrawalCompletionService().record(
        PendingWithdrawalCompletion(
          scIdentifier: scIdentifier,
          requestHash: requestHash,
          btcTxHash: btcTxHash,
          amount: withdrawalAmount,
          btcDestination: btcDestination,
          fromAddress: keypair.address,
          createdAt: DateTime.now(),
        ),
      );

      // Signing is done and its output is on the Bitcoin network, so the job
      // is finished with. Cleared after the broadcast record lands so the two
      // are never both missing.
      await PendingFrostSigningJobService().clear(requestHash);

      // Step 6: Record completion on VFX chain (Type 28 TX)
      final recorded = await recordV2WithdrawalCompletion(
        scIdentifier: scIdentifier,
        requestHash: requestHash,
        btcTxHash: btcTxHash,
        amount: withdrawalAmount,
        btcDestination: btcDestination,
      );

      return {
        'success': true,
        'btc_transaction_hash': btcTxHash,
        'completion_recorded': recorded['success'] == true,
        'completion_message': recorded['message'],
        // False means no durable record exists, so this withdrawal cannot be
        // resumed in a later session.
        'completion_recoverable': persisted,
        // Returned so a retry can be driven from memory rather than from
        // storage, which may be exactly what failed.
        'withdrawal_amount': withdrawalAmount,
        'btc_destination': btcDestination,
      };
    } catch (e) {
      return {'success': false, 'message': 'FROST signing failed: $e'};
    }
  }

  /// V2 withdrawal cancel via prepare→sign→send.
  ///
  /// [requestorAddress] must be the address that made the withdrawal request,
  /// not the token owner: the node rejects anyone else with "Only the original
  /// requestor can cancel", and it builds the transaction from this address, so
  /// it also has to match the key that signs. The explorer names the field
  /// `owner_address` but forwards it as `RequestorAddress`.
  Future<bool> cancelV2Withdrawal({
    required String scIdentifier,
    required String requestorAddress,
    required String requestHash,
  }) async {
    try {
      final prepared = await ExplorerService().prepareV2WithdrawalCancel(
        scIdentifier: scIdentifier,
        ownerAddress: requestorAddress,
        withdrawalRequestHash: requestHash,
      );

      if (prepared['success'] != true || prepared['Hash'] == null) {
        Toast.error(prepared['message'] ?? globalL10n.bw2FailedPrepareCancellation);
        return false;
      }

      final result = await _signAndSend(
        hash: prepared['Hash'],
        sendFn: ExplorerService().sendV2WithdrawalCancel,
      );

      if (result != null && result['success'] == true) {
        ref.read(webTransactionListProvider(requestorAddress).notifier).insertPendingTx(
          WebTransaction(
            hash: result['Hash'] ?? prepared['Hash'] ?? '',
            toAddress: requestorAddress,
            fromAddress: requestorAddress,
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
      Toast.error(globalL10n.bw2CancellationFailedError(e.toString()));
      return false;
    }
  }

  bool verifyBalance({bool isRa = false}) {
    if (isRa) {
      if ((ref.read(webSessionProvider).raBalance ?? 0) <
          MIN_RBX_FOR_SC_ACTION) {
        Toast.error(
            globalL10n.bw2VaultBalanceRequired);

        return false;
      }
      return true;
    }

    if ((ref.read(webSessionProvider).balance ?? 0) < MIN_RBX_FOR_SC_ACTION) {
      Toast.error(
          globalL10n.bw2VfxBalanceRequiredBroadcast);

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
    Toast.error(globalL10n.bw2OnlyOwnerCanAction);
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
        globalL10n.bw2VaultCannotActionTransferFirst);
    return false;
  }

  bool guardIsNotPaused(WebFungibleToken token) {
    if (token.isPaused) {
      Toast.error(globalL10n.bw2TokenPaused);
      return false;
    }
    return true;
  }

  Future<String?> promptForAddress({String? title}) async {
    final address = await PromptModal.show(
      title: title ?? globalL10n.labelAddress,
      validator: formValidatorRbxAddress,
      labelText: globalL10n.labelAddress,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
      ],
    );

    if (address == null || address.isEmpty) {
      return null;
    }

    return address;
  }

  Future<double?> promptForAmount({String? title}) async {
    final amount = await PromptModal.show(
      title: title ?? globalL10n.labelAmount,
      validator: (val) => formValidatorNumber(val, globalL10n.labelAmount),
      labelText: globalL10n.labelAmount,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
    );
    if (amount == null || amount.isEmpty) {
      return null;
    }

    final amountDouble = double.tryParse(amount);

    if (amountDouble == null) {
      Toast.error(globalL10n.btcInvalidAmountToast);
      return null;
    }
    return amountDouble;
  }
}

final webTokenActionsManager = Provider((ref) {
  return WebTokenActionsManager(ref);
});

/// How a FROST signing poll ended. The outcomes call for different handling of
/// the stored job id: an outright failure finishes with it, a timeout does not
/// — signing may still be running behind it.
class _FrostSigningPollResult {
  /// Set when signing finished and produced a Bitcoin transaction to broadcast.
  final String? signedBtcTxHex;

  /// Set when the job will never produce one — signing failed, or the API no
  /// longer knows the id.
  final String? failureMessage;

  const _FrostSigningPollResult.signed(this.signedBtcTxHex)
      : failureMessage = null;

  const _FrostSigningPollResult.failed(this.failureMessage)
      : signedBtcTxHex = null;

  const _FrostSigningPollResult.timedOut()
      : signedBtcTxHex = null,
        failureMessage = null;
}
