import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../raw/raw_service.dart';
import '../providers/web_ra_pending_recovery_provider.dart';
import '../utils/raw_transaction.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';

class WebRecoverRaButton extends BaseComponent {
  const WebRecoverRaButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final keypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));
    final hasRecovered = ref.watch(webRaPendingRecoveryProvider).contains(keypair?.address);

    if (keypair == null) {
      return SizedBox();
    }
    return AppButton(
      label: l10n.reserveRecoverLabel,
      disabled: hasRecovered,
      type: AppButtonType.Elevated,
      variant: AppColorVariant.Warning,
      onPressed: () async {
        final raKeypair = ref.read(webSessionProvider).raKeypair;
        final loadingProvider = ref.read(globalLoadingProvider.notifier);

        if (raKeypair == null) {
          Toast.error();
          return null;
        }

        final confirmed = await ConfirmDialog.show(
          title: l10n.reserveRecoverTitle,
          body: l10n.r3fRecoverBody(raKeypair.recoveryAddress),
          confirmText: l10n.reserveRecoverProceed,
          cancelText: l10n.actionCancel,
          destructive: true,
        );

        if (confirmed != true) {
          return null;
        }

        loadingProvider.start();

        final txService = RawService();

        final timestamp = await txService.getTimestamp();

        if (timestamp == null) {
          Toast.error(l10n.r3fFailedRetrieveTimestamp);
          loadingProvider.complete();

          return false;
        }

        final nonce = await txService.getNonce(raKeypair.address);
        if (nonce == null) {
          Toast.error(l10n.r3fFailedRetrieveNonce);
          loadingProvider.complete();
          return false;
        }

        final currentTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();

        final recoverySigScriptMessage = "$currentTime${raKeypair.recoveryAddress}";

        final recoverySigScript = await RawTransaction.getSignature(
            message: recoverySigScriptMessage, privateKey: raKeypair.recoveryPrivate, publicKey: raKeypair.recoveryPublic);

        if (recoverySigScript == null) {
          Toast.error(l10n.r3fProblemRecoverySigScript);
          loadingProvider.complete();
          return false;
        }

        final data = {
          "Function": "Recover()",
          "RecoveryAddress": raKeypair.recoveryAddress,
          "RecoverySigScript": recoverySigScript,
          "SignatureTime": currentTime,
        };

        var txData = RawTransaction.buildTransaction(
          amount: 0,
          type: TxType.reserve,
          toAddress: "Reserve_Base",
          fromAddress: raKeypair.address,
          timestamp: timestamp,
          nonce: nonce,
          data: data,
          unlockTimestamp: 0,
        );

        final fee = await txService.getFee(txData);

        if (fee == null) {
          Toast.error(l10n.r3fFailedParseFee);
          loadingProvider.complete();
          return false;
        }

        txData = RawTransaction.buildTransaction(
          amount: 0,
          type: TxType.reserve,
          toAddress: "Reserve_Base",
          fromAddress: raKeypair.address,
          timestamp: timestamp,
          nonce: nonce,
          data: data,
          fee: fee,
          unlockTimestamp: 0,
        );

        final hash = (await txService.getHash(txData));
        if (hash == null) {
          Toast.error(l10n.r3fFailedParseHash);
          loadingProvider.complete();
          return false;
        }

        final signature = await RawTransaction.getSignature(message: hash, privateKey: raKeypair.private, publicKey: raKeypair.public);
        if (signature == null) {
          Toast.error(l10n.webErrorSignatureGen);
          loadingProvider.complete();
          return false;
        }

        final isValid = await txService.validateSignature(
          hash,
          raKeypair.address,
          signature,
        );

        if (!isValid) {
          Toast.error(l10n.webErrorSignatureInvalid);
          loadingProvider.complete();
          return false;
        }

        txData = RawTransaction.buildTransaction(
          amount: 0,
          type: TxType.reserve,
          toAddress: "Reserve_Base",
          fromAddress: raKeypair.address,
          timestamp: timestamp,
          nonce: nonce,
          data: data,
          fee: fee,
          hash: hash,
          signature: signature,
          unlockTimestamp: 0,
        );

        final verifyTransactionData = (await txService.sendTransaction(
          transactionData: txData,
          execute: false,
        ));

        if (verifyTransactionData == null) {
          Toast.error(l10n.webErrorTxInvalid);
          loadingProvider.complete();
          return false;
        }

        final tx = await RawService().sendTransaction(
          transactionData: txData,
          execute: true,
          widgetRef: ref,
        );

        if (tx != null) {
          if (tx['Result'] == "Success") {
            Toast.message(l10n.webRecoveryBroadcasted);
            ref.read(webRaPendingRecoveryProvider.notifier).addAddress(keypair.address);
            loadingProvider.complete();
            return true;
          }
        }

        Toast.error();
        loadingProvider.complete();
        return false;
      },
    );
  }
}
