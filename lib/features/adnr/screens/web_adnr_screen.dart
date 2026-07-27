import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/breakpoints.dart';
import '../../../core/theme/components.dart';
import '../../btc_web/components/web_btc_adnr_content.dart';
import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../web/components/web_currency_segmented_button.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../components/create_adnr_dialog.dart';
import '../providers/adnr_pending_provider.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../raw/raw_service.dart';
import '../../web/components/web_no_wallet.dart';
import '../../web/utils/raw_transaction.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';

class WebAdnrScreen extends BaseScreen {
  const WebAdnrScreen({Key? key})
      : super(
          key: key,
          includeWebDrawer: true,
          backgroundColor: Colors.black87,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);

    return AppBar(
      title: Text(AppLocalizations.of(context).adnrTitleAny),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
      leading: isMobile ? WebMobileDrawerButton() : null,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webSessionProvider);

    final currencyType = ref.watch(webCurrencySegementedButtonProvider);

    final btcKeypair = session.btcKeypair;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WebCurrencySegementedButton(withVault: false),
            SizedBox(
              height: 32,
            ),
            if ([WebCurrencyType.any, WebCurrencyType.vfx, WebCurrencyType.vault].contains(currencyType)) ...[
              Text(
                AppLocalizations.of(context).adnrVfxDomainBadge,
                style: TextStyle(
                  color: AppColors.getBlue(),
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _VfxDomain(),
              ),
            ],
            if (currencyType == WebCurrencyType.any)
              SizedBox(
                height: 16,
              ),
            if ([WebCurrencyType.any, WebCurrencyType.btc].contains(currencyType) && btcKeypair != null) ...[
              Text(
                AppLocalizations.of(context).adnrBtcDomainBadge,
                style: TextStyle(
                  color: AppColors.getBtc(),
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WebBtcAdnrContent(account: btcKeypair),
              )
            ],
            SizedBox(
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _VfxDomain extends BaseComponent {
  const _VfxDomain({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webSessionProvider);
    final keypair = session.keypair;
    final address = keypair?.address;
    final adnr = session.adnr;

    if (keypair == null || address == null) {
      return const WebNotWallet();
    }

    final balance = session.balance ?? 0;
    final isPendingCreate = ref.watch(adnrPendingProvider).contains("$address.create.${adnr ?? 'null'}");
    final isPendingBurn = ref.watch(adnrPendingProvider).contains("$address.delete.${adnr ?? 'null'}");
    final isPendingTransfer = ref.watch(adnrPendingProvider).contains("$address.transfer.${adnr ?? 'null'}");

    if (isPendingCreate) {
      return Center(
        child: AppBadge(
          label: AppLocalizations.of(context).adnrVfxDomainPending,
          variant: AppColorVariant.Success,
        ),
      );
    }

    if (isPendingTransfer) {
      return Center(
        child: AppBadge(
          label: AppLocalizations.of(context).adnrVfxDomainTransferPending,
          variant: AppColorVariant.Primary,
        ),
      );
    }

    if (isPendingBurn) {
      return Center(
        child: AppBadge(
          label: AppLocalizations.of(context).adnrVfxDomainDeletePending,
          variant: AppColorVariant.Danger,
        ),
      );
    }

    if (adnr == null) {
      return Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).adnrCreateVfxOnAccount,
                style: const TextStyle(
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                AppLocalizations.of(context).adnrCostNoteVfx(ADNR_COST.toString()),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16,
              ),
              AppButton(
                label: AppLocalizations.of(context).adnrCreateDomain,
                variant: AppColorVariant.Success,
                onPressed: () async {
                  if (balance < (ADNR_COST + MIN_RBX_FOR_SC_ACTION)) {
                    Toast.error(AppLocalizations.of(context).adnrInsufficientFundsCreateVfx(ADNR_COST.toString()));
                    return;
                  }

                  await showDialog(
                      context: context,
                      builder: (context) {
                        return CreateAdnrDialog(
                          address: address,
                          adnr: "",
                        );
                      });
                },
              )
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AppCard(
          padding: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  adnr,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  address,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton(
                      label: AppLocalizations.of(context).adnrTransfer,
                      onPressed: () async {
                        if (balance < (ADNR_TRANSFER_COST + MIN_RBX_FOR_SC_ACTION)) {
                          Toast.error(AppLocalizations.of(context).adnrInsufficientFundsTransfer);
                          return;
                        }

                        PromptModal.show(
                            contextOverride: context,
                            title: AppLocalizations.of(context).adnrTransferDomainTitle,
                            body: AppLocalizations.of(context).adnrTransferDomainBody(ADNR_TRANSFER_COST.toString()),
                            validator: (value) => formValidatorRbxAddress(value, false),
                            labelText: AppLocalizations.of(context).adnrAddressFieldLabel,
                            onValidSubmission: (toAddress) async {
                              ref.read(globalLoadingProvider.notifier).start();

                              final txData = await RawTransaction.generate(
                                keypair: ref.read(webSessionProvider).keypair!,
                                amount: ADNR_TRANSFER_COST,
                                toAddress: toAddress,
                                txType: TxType.adnr,
                                data: {"Function": "AdnrTransfer()", "Name": adnr},
                              );

                              ref.read(globalLoadingProvider.notifier).complete();

                              if (txData == null) {
                                Toast.error(AppLocalizations.of(context).btcInvalidTxData);
                                return;
                              }

                              final txFee = txData['Fee'];

                              final confirmed = await ConfirmDialog.show(
                                title: AppLocalizations.of(context).btcValidTxTitle,
                                body:
                                    "The VFX Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: $adnr.vfx\nAmount: $ADNR_COST VFX\nFee: $txFee RBX\nTotal: ${ADNR_COST + txFee} VFX",
                                confirmText: AppLocalizations.of(context).actionSend,
                                cancelText: AppLocalizations.of(context).actionCancel,
                              );

                              if (confirmed != true) {
                                Toast.message(AppLocalizations.of(context).btcTxCancelledToast);
                                return;
                              }

                              ref.read(globalLoadingProvider.notifier).start();

                              final tx = await RawService().sendTransaction(
                                transactionData: txData,
                                execute: true,
                                widgetRef: ref,
                              );

                              ref.read(globalLoadingProvider.notifier).complete();

                              if (tx != null && tx['Result'] == "Success") {
                                ref.read(adnrPendingProvider.notifier).addId(address, "transfer", adnr);

                                Toast.message(AppLocalizations.of(context).adnrTxBroadcastedToast);

                                return;
                              }

                              Toast.error();
                            });
                      },
                    ),
                    AppButton(
                      label: AppLocalizations.of(context).adnrDelete,
                      variant: AppColorVariant.Danger,
                      onPressed: () async {
                        if (balance < (ADNR_DELETE_COST + MIN_RBX_FOR_SC_ACTION)) {
                          Toast.error(AppLocalizations.of(context).adnrInsufficientFundsTransfer);
                          return;
                        }

                        final confirmed = await ConfirmDialog.show(
                          title: AppLocalizations.of(context).adnrDeleteTitle,
                          body:
                              "Are you sure you want to delete this VFX Domain?\n${ADNR_DELETE_COST == 0 ? 'There is no cost to delete and VFX Domain (aside from the TX fee).' : 'There is a cost of $ADNR_DELETE_COST RBX to delete an RBX Domain.'}\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.",
                          destructive: true,
                          cancelText: AppLocalizations.of(context).actionCancel,
                          confirmText: AppLocalizations.of(context).adnrDelete,
                        );

                        if (confirmed == true) {
                          ref.read(globalLoadingProvider.notifier).start();
                          final txData = await RawTransaction.generate(
                            keypair: ref.read(webSessionProvider).keypair!,
                            amount: ADNR_DELETE_COST,
                            toAddress: "Adnr_Base",
                            txType: TxType.adnr,
                            data: {"Function": "AdnrDelete()", "Name": adnr},
                          );

                          ref.read(globalLoadingProvider.notifier).complete();
                          if (txData == null) {
                            Toast.error(AppLocalizations.of(context).btcInvalidTxData);

                            return;
                          }

                          final txFee = txData['Fee'];

                          final confirmed = await ConfirmDialog.show(
                            title: AppLocalizations.of(context).btcValidTxTitle,
                            body:
                                "The VFX Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: $adnr.vfx\nAmount: $ADNR_COST VFX\nFee: $txFee RBX\nTotal: ${ADNR_COST + txFee} VFX",
                            confirmText: AppLocalizations.of(context).actionSend,
                            cancelText: AppLocalizations.of(context).actionCancel,
                          );

                          if (confirmed != true) {
                            Toast.message(AppLocalizations.of(context).btcTxCancelledToast);
                            return;
                          }

                          ref.read(globalLoadingProvider.notifier).start();

                          final tx = await RawService().sendTransaction(transactionData: txData, execute: true, widgetRef: ref);
                          ref.read(globalLoadingProvider.notifier).complete();

                          if (tx != null && tx['Result'] == "Success") {
                            ref.read(adnrPendingProvider.notifier).addId(address, "delete", adnr);

                            Toast.message(AppLocalizations.of(context).adnrTxBroadcastedToast);
                            return;
                          }

                          Toast.error();
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
