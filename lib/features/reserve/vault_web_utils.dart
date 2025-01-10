import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/dialogs.dart';
import '../../utils/toast.dart';
import '../global_loader/global_loading_provider.dart';
import '../keygen/models/ra_keypair.dart';
import '../raw/raw_service.dart';
import '../web/providers/web_ra_pending_activation_provider.dart';
import '../web/utils/raw_transaction.dart';

Future<bool?> activateVaultAccountWeb({
  required RaKeypair keypair,
  bool promptForConfirmation = true,
  bool silent = false,
  GlobalLoadingProvider? loadingProvider,
  WidgetRef? widgetRef,
  Ref? ref,
}) async {
  if (ref == null && widgetRef == null) {
    print("REF and WIDGET REF are null");
    return false;
  }

  if (promptForConfirmation) {
    final confirmed = await ConfirmDialog.show(
      title: "Activate Vault Account?",
      body: "There is a cost of $RA_ACTIVATION_COST VFX to activate your Vault Account which is burned.\n\nContinue?",
      confirmText: "Activate",
      cancelText: "Canacel",
    );

    if (confirmed != true) {
      return null;
    }
  }

  loadingProvider?.start();

  final txService = RawService();

  final timestamp = await txService.getTimestamp();

  if (timestamp == null) {
    if (!silent) Toast.error("Failed to retrieve timestamp");

    loadingProvider?.complete();
    return false;
  }

  final nonce = await txService.getNonce(keypair.address);
  if (nonce == null) {
    if (!silent) Toast.error("Failed to retrieve nonce");
    loadingProvider?.complete();
    return false;
  }

  final data = {
    "Function": "Register()",
    "RecoveryAddress": keypair.recoveryAddress,
  };

  var txData = RawTransaction.buildTransaction(
    amount: RA_ACTIVATION_COST,
    type: TxType.reserve,
    toAddress: "Reserve_Base",
    fromAddress: keypair.address,
    timestamp: timestamp,
    nonce: nonce,
    data: data,
  );

  final fee = await txService.getFee(txData);

  if (fee == null) {
    if (!silent) Toast.error("Failed to parse fee");
    loadingProvider?.complete();
    return false;
  }

  txData = RawTransaction.buildTransaction(
    amount: RA_ACTIVATION_COST,
    type: TxType.reserve,
    toAddress: "Reserve_Base",
    fromAddress: keypair.address,
    timestamp: timestamp,
    nonce: nonce,
    data: data,
    fee: fee,
  );

  final hash = (await txService.getHash(txData));
  if (hash == null) {
    if (!silent) Toast.error("Failed to parse hash");
    loadingProvider?.complete();
    return false;
  }

  final signature = await RawTransaction.getSignature(message: hash, privateKey: keypair.private, publicKey: keypair.public);
  if (signature == null) {
    if (!silent) Toast.error("Signature generation failed.");
    loadingProvider?.complete();
    return false;
  }

  final isValid = await txService.validateSignature(
    hash,
    keypair.address,
    signature,
  );

  if (!isValid) {
    if (!silent) Toast.error("Signature not valid");
    loadingProvider?.complete();
    return false;
  }

  txData = RawTransaction.buildTransaction(
    amount: RA_ACTIVATION_COST,
    type: TxType.reserve,
    toAddress: "Reserve_Base",
    fromAddress: keypair.address,
    timestamp: timestamp,
    nonce: nonce,
    data: data,
    fee: fee,
    hash: hash,
    signature: signature,
  );

  final verifyTransactionData = (await txService.sendTransaction(
    transactionData: txData,
    execute: false,
  ));

  if (verifyTransactionData == null) {
    if (!silent) Toast.error("Transaction not valid");
    loadingProvider?.complete();
    return false;
  }

  final tx = await RawService().sendTransaction(transactionData: txData, execute: true, widgetRef: widgetRef, ref: ref);

  if (tx != null) {
    if (tx['Result'] == "Success") {
      if (!silent) Toast.message("Activation transaction broadcasted");
      loadingProvider?.complete();
      if (ref != null) {
        ref.read(webRaPendingActivationProvider.notifier).addAddress(keypair.address);
      } else if (widgetRef != null) {
        widgetRef.read(webRaPendingActivationProvider.notifier).addAddress(keypair.address);
      }
      return true;
    }
  }

  if (!silent) Toast.error();
  loadingProvider?.complete();
  return false;
}
