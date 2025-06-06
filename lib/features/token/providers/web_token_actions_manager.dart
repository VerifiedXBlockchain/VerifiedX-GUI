import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils.dart';
import '../../bridge/providers/wallet_info_provider.dart';
import '../../btc/models/vbtc_input.dart';
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
        body: "Transaction verified. There will be a fee of $txFee VFX. Would you like to proceed?",
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

    final tx = await RawService().sendTransaction(transactionData: txData, execute: true, ref: ref);

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

  Future<bool?> mintTokens(WebFungibleToken token, String address, double amount, [bool silent = false]) async {
    final data = {
      "Function": "TokenMint()",
      "ContractUID": token.smartContractId,
      "FromAddress": address,
      "Amount": amount,
      "TokenTicker": token.ticker,
      "TokenName": token.name,
    };

    return await _verifyConfirmAndSendTx(toAddress: "Token_Base", data: data, showConfirmation: !silent, showLoader: !silent, showToasts: !silent);
  }

  Future<bool?> transferAmount(WebFungibleToken token, String toAddress, String fromAddress, double amount) async {
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

  Future<bool?> burnAmount(WebFungibleToken token, String address, double amount) async {
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
    final end = (DateTime.now().add(Duration(days: topic.votingDaysAsInt)).millisecondsSinceEpoch / 1000).round();
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

  Future<bool?> voteOnTopic(String scId, String scOwnerAddress, String fromAddress, String topicId, bool value) async {
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

  Future<bool?> transferVbtcAmount(
    BtcWebVbtcToken token,
    String toAddress,
    double amount,
  ) async {
    final data = [
      {
        "Function": "TransferCoin()",
        "ContractUID": token.scIdentifier,
        "Amount": amount,
      }
    ];
    return await _verifyConfirmAndSendTx(
      toAddress: toAddress,
      data: data,
      txType: TxType.tokenizeTx,
    );
  }

  Future<bool?> transferVbtcOwnership(
    BtcWebVbtcToken token,
    String toAddress,
  ) async {
    final message = token.scIdentifier;
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No VFX account found");
      return null;
    }

    final beaconSignature = await RawTransaction.getSignature(
      message: message,
      privateKey: keypair.private,
      publicKey: keypair.public,
    );

    if (beaconSignature == null) {
      Toast.error("Couldn't produce beacon upload signature");
      return false;
    }

    final locator = await RawService().beaconUpload(token.scIdentifier, toAddress, beaconSignature);

    if (locator == null) {
      Toast.error("Could not create beacon upload request.");
      return false;
    }
    final txService = RawService();

    final nftTransferData = await txService.nftTransferData(token.scIdentifier, toAddress, locator);

    return await _verifyConfirmAndSendTx(
      toAddress: toAddress,
      data: nftTransferData,
      txType: TxType.tokenizeTx,
    );
  }

  Future<bool?> withdrawVbtc({
    required String scId,
    required double amount,
    required String btcAddress,
    required int feeRate,
  }) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No VFX account found");
      return null;
    }

    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final uniqueId = generateRandomString(16, 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz');
    final message = "${keypair.address}.$timestamp.$uniqueId";

    print("MESSAGE: $message");

    final signature = await RawTransaction.getSignature(message: message, privateKey: keypair.private, publicKey: keypair.public);
    print("MESSAGE: $signature");

    if (signature == null) {
      Toast.error("Signature generation failed.");
      return null;
    }

    final data = {
      'SmartContractUID': scId,
      'Amount': amount,
      'VFXAddress': keypair.address,
      'BTCToAddress': btcAddress,
      'Timestamp': timestamp,
      'UniqueId': uniqueId,
      'VFXSignature': signature,
      'ChosenFeeRate': feeRate,
      "IsTest": false,
    };
    print(data);
    print("------");

    final result = await RawService().withdrawVbtc(data);

    if (result == null) {
      Toast.error();
      return null;
    }

    return await sendWithdrawlFinializationTx(result);
  }

  Future<bool?> sendWithdrawlFinializationTx(WebWithdrawlBtcResult result) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No VFX account found");
      return null;
    }

    final data = {
      "Function": "TokenizedWithdrawalComplete()",
      "ContractUID": result.scId,
      "UniqueId": result.uniqueId,
      "TransactionHash": result.txHash,
    };

    return await _verifyConfirmAndSendTx(
      toAddress: "TW_Base",
      data: data,
      txType: 21,
      showConfirmation: false,
    );
  }

  Future<bool?> transferVbtcMulti(String toAddress, List<VBtcInput> inputs) async {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error("No VFX account found");
      return null;
    }

    ref.read(globalLoadingProvider.notifier).start();

    final signatureInput = generateRandomString(12);

    final inputsMapped = await Future.wait(
      inputs.map(
        (input) async {
          final message = "$signatureInput$toAddress${input.vfxFromAddress}";

          final signature = await RawTransaction.getSignature(
            message: message,
            privateKey: keypair.private,
            publicKey: keypair.public,
          );

          if (signature == null) {
            Toast.error("Could not generate signature");
            return null;
          }

          return {
            "SCUID": input.scId,
            "FromAddress": input.vfxFromAddress,
            "Amount": input.amount,
            "Signature": signature,
          };
        },
      ),
    );

    final validInputs = inputsMapped.whereType<Map<String, dynamic>>().toList();

    final data = {
      "Function": "TransferCoinMulti()",
      "Inputs": validInputs,
      "Amount": inputs.fold<double>(
        0.0,
        (previousValue, element) => previousValue + element.amount,
      ),
      "SignatureInput": signatureInput,
    };

    ref.read(globalLoadingProvider.notifier).complete();

    return await _verifyConfirmAndSendTx(
      toAddress: toAddress,
      data: data,
      txType: TxType.tokenizeTx,
    );
  }

  bool verifyBalance({bool isRa = false}) {
    if (isRa) {
      if ((ref.read(webSessionProvider).raBalance ?? 0) < MIN_RBX_FOR_SC_ACTION) {
        Toast.error("A balance on your Vault account is required to broadcast this transaction");

        return false;
      }
      return true;
    }

    if ((ref.read(webSessionProvider).balance ?? 0) < MIN_RBX_FOR_SC_ACTION) {
      Toast.error("A balance on your VFX account is required to broadcast this transaction");

      return false;
    }
    return true;
  }

  bool guardIsTokenOwner(WebFungibleToken token) {
    final sessionModel = ref.read(webSessionProvider);

    if ([sessionModel.keypair?.address, sessionModel.raKeypair?.address].contains(token.ownerAddress)) {
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

    Toast.error("Vault accounts cannot perform this action. Please transfer ownership to your standard VFX account first");
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
