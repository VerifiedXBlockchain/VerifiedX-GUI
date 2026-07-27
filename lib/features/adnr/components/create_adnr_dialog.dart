import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/features/faucet/components/faucet_form.dart';
import '../../btc_web/services/btc_web_service.dart';

import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../raw/raw_service.dart';
import '../../web/utils/raw_transaction.dart';
import '../providers/adnr_pending_provider.dart';
import '../services/adnr_service.dart';

class CreateAdnrDialog extends BaseComponent {
  final String address;
  final String? adnr;
  final bool isBtc;
  const CreateAdnrDialog({
    required this.address,
    required this.adnr,
    this.isBtc = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(isBtc ? l10n.adnrCreateDialogTitleBtc : l10n.adnrCreateDialogTitleVfx),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isBtc ? l10n.adnrCreateDialogCostBtc(ADNR_COST.toString()) : l10n.adnrCreateDialogCostVfx(ADNR_COST.toString())),
              Text(
                isBtc ? l10n.adnrCreateDialogSuffixHelpBtc : l10n.adnrCreateDialogSuffixHelpVfx,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextFormField(
                controller: controller,
                validator: (value) =>
                    formValidatorAlphaNumeric(value, l10n.adnrDomainNameLabel),
                decoration: InputDecoration(
                    label: Text(l10n.adnrDomainNameLabel),
                    suffix: Text(isBtc ? '.btc' : '.vfx')),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            l10n.actionCancel,
            style: const TextStyle(color: Colors.white38),
          ),
        ),
        Consumer(builder: (context, ref, _) {
          final balance =
              ref.watch(webSessionProvider.select((value) => value.balance)) ??
                  0;

          final useFaucet = isBtc &&
              ALLOW_FAUCET_FOR_BTC_DOMAINS &&
              balance < (ADNR_COST + MIN_RBX_FOR_SC_ACTION);

          return useFaucet
              ? TextButton(
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                        title: l10n.adnrFaucetRequiredTitle(ADNR_COST.toString()),
                        body: l10n.adnrFaucetRequiredBody(ADNR_COST.toString()),
                        confirmText: l10n.adnrFaucetContinue,
                        cancelText: l10n.adnrFaucetNoThanks);

                    if (confirmed != true) {
                      Toast.error(
                          l10n.adnrInsufficientFundsCreateBtc(ADNR_COST.toString()));
                      Navigator.of(context).pop();
                    }

                    await InfoDialog.show(
                      title: l10n.adnrFaucetTitle,
                      content: FaucetForm(forceAmount: 6.0),
                      closeText: l10n.actionClose,
                    );

                    Toast.message(l10n.adnrFaucetWaitToast);
                  },
                  child:
                      Text(l10n.adnrFaucetContinue, style: const TextStyle(color: Colors.white)))
              : TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    if (address.length > 65) {
                      Toast.error(l10n.adnrMaxLengthToast);
                      return;
                    }

                    if (kIsWeb) {
                      final keyPair = ref.read(webSessionProvider).keypair;
                      if (keyPair == null) {
                        Toast.error(l10n.adnrNoAccountToast);
                        return;
                      }

                      final domainWithoutSuffix = controller.text;
                      final domain =
                          "$domainWithoutSuffix.${isBtc ? 'btc' : 'vfx'}";

                      ref.read(globalLoadingProvider.notifier).start();

                      final available =
                          await ExplorerService().adnrAvailable(domain);

                      if (!available) {
                        ref.read(globalLoadingProvider.notifier).complete();
                        Toast.error(
                            l10n.adnrAlreadyExistsToast(isBtc ? 'BTC' : 'VFX'));
                        return;
                      }
                      final btcAddress = isBtc
                          ? ref.read(webSessionProvider).btcKeypair?.address
                          : null;
                      if (isBtc && btcAddress == null) {
                        Toast.error(l10n.adnrNoBtcAddress);
                        return;
                      }
                      final btcWif =
                          ref.read(webSessionProvider).btcKeypair?.wif;
                      if (isBtc && btcWif == null) {
                        Toast.error(l10n.adnrNoBtcWif);
                        return;
                      }

                      String? btcMessage;
                      String? btcSignature;

                      if (isBtc) {
                        // btcMessage = "1711996047";
                        btcMessage =
                            (DateTime.now().millisecondsSinceEpoch / 1000)
                                .round()
                                .toString();
                        btcSignature = await BtcWebService().signMessage(
                            ref.read(webSessionProvider).btcKeypair!.wif,
                            btcMessage);
                        print("SIGNATURE: $btcSignature");
                      }

                      final data = isBtc
                          ? {
                              "Function": "BTCAdnrCreate()",
                              "Name": domainWithoutSuffix,
                              "BTCAddress": btcAddress,
                              "Message": btcMessage,
                              "Signature": btcSignature,
                            }
                          : {
                              "Function": "AdnrCreate()",
                              "Name": domainWithoutSuffix
                            };

                      print(data);

                      final txData = await RawTransaction.generate(
                        keypair: ref.read(webSessionProvider).keypair!,
                        amount: ADNR_COST,
                        toAddress: "Adnr_Base",
                        txType: TxType.adnr,
                        data: data,
                      );

                      ref.read(globalLoadingProvider.notifier).complete();

                      if (txData == null) {
                        Toast.error(l10n.btcInvalidTxData);
                        return;
                      }

                      final txFee = txData['Fee'];

                      final confirmed = await ConfirmDialog.show(
                        title: l10n.btcValidTxTitle,
                        body:
                            "The ${isBtc ? 'BTC' : 'VFX'} Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: $domain\nAmount: $ADNR_COST VFX\nFee: $txFee VFX\nTotal: ${ADNR_COST + txFee} VFX",
                        confirmText: l10n.actionSend,
                        cancelText: l10n.actionCancel,
                      );

                      if (confirmed != true) {
                        Navigator.of(context).pop();
                        return;
                      }
                      ref.read(globalLoadingProvider.notifier).start();

                      final tx = await RawService().sendTransaction(
                          transactionData: txData,
                          execute: true,
                          widgetRef: ref);
                      ref.read(globalLoadingProvider.notifier).complete();

                      if (tx != null && tx['Result'] == "Success") {
                        ref
                            .read(adnrPendingProvider.notifier)
                            .addId(address, "create", "null");
                        Toast.message(isBtc ? l10n.adnrBtcTxBroadcastedToast : l10n.adnrTxBroadcastedToast);
                        Navigator.of(context).pop();

                        return;
                      }

                      Toast.error();
                    } else {
                      ref.read(globalLoadingProvider.notifier).start();
                      final result = await AdnrService()
                          .createAdnr(address, controller.text);
                      ref.read(globalLoadingProvider.notifier).complete();

                      if (result.success) {
                        Toast.message(l10n.adnrTxBroadcastedToast);
                        if (result.hash != null) {
                          ref.read(logProvider.notifier).append(
                                LogEntry(
                                    message: l10n.adnrLogCreateEntry(result.hash!),
                                    textToCopy: result.hash,
                                    variant: AppColorVariant.Success),
                              );

                          ref
                              .read(adnrPendingProvider.notifier)
                              .addId(address, "create", adnr ?? "null");
                        }

                        Navigator.of(context).pop();
                        return;
                      }

                      Toast.error(result.message);
                    }
                  },
                  child: Text(
                    l10n.adnrCreateButton,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
        })
      ],
    );
  }
}
