import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/currency_segmented_button_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../btc/utils.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../token/providers/web_token_actions_manager.dart';
import '../models/btc_web_vbtc_token.dart';
import '../providers/btc_web_transaction_list_provider.dart';
import '../services/btc_web_service.dart';
import 'web_v2_withdrawal_dialog.dart';

class WebTokenizedBtcActionButtons extends BaseComponent {
  final BtcWebVbtcToken token;
  final bool isOwner;
  const WebTokenizedBtcActionButtons({
    super.key,
    required this.token,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAddress =
        ref.watch(webSessionProvider.select((value) => value.keypair?.address));
    final myBalance =
        myAddress != null ? token.balanceForAddress(myAddress) : 0.0;

    final btcKeypair =
        ref.watch(webSessionProvider.select((value) => value.btcKeypair));

    final l10n = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        AppButton(
          label: l10n.btcCopyDepositAddress,
          icon: Icons.copy,
          variant: AppColorVariant.Primary,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: token.depositAddress));
            Toast.message(l10n.btcAddressCopiedShort);
          },
        ),
        if (isOwner)
          AppButton(
            label: l10n.btcFundLabel,
            icon: Icons.outbox,
            onPressed: () {
              showModalBottomSheet(
                  context: rootNavigatorKey.currentContext!,
                  backgroundColor: Colors.black87,
                  builder: (context) {
                    return ModalContainer(
                      color: Colors.black,
                      withDecor: false,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [Text(l10n.bw2FundVbtcToken)],
                        ),
                        if (btcKeypair != null)
                          Consumer(builder: (context, ref, _) {
                            final balance = ref.watch(webSessionProvider.select(
                                (value) => value.btcBalanceInfo?.btcBalance));

                            return ListTile(
                              title: Text(btcKeypair.address),
                              subtitle: Text(
                                  "${balance?.toStringAsFixed(8) ?? 0} BTC"),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () async {
                                if (balance == null || balance <= 0) {
                                  Toast.error(
                                      l10n.bw2BtcAccountNoBalance);
                                  return;
                                }

                                Navigator.of(context).pop();
                                final amount = await PromptModal.show(
                                  title: l10n.btcAmountWithBalanceTitle(balance.toString()),
                                  validator: (val) =>
                                      formValidatorNumber(val, l10n.labelAmount),
                                  labelText: l10n.bw2DepositAmount,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9.]"))
                                  ],
                                  showUsdValue: true,
                                  currencyType: CurrencyType.btc,
                                );
                                if (amount == null) {
                                  return;
                                }
                                final parsedAmount = double.tryParse(amount);
                                if (parsedAmount == null) {
                                  return;
                                }

                                if (parsedAmount <= 0) {
                                  Toast.error(
                                      l10n.tkbAmountGreaterThanZero);
                                  return;
                                }

                                if (balance <= parsedAmount) {
                                  Toast.error(
                                      l10n.bw2NotEnoughBtcCoverFee);
                                  return;
                                }

                                final feeRate = await promptForFeeRate(context);

                                if (feeRate == null) {
                                  return;
                                }

                                final confirmed = await ConfirmDialog.show(
                                  title: l10n.btcPleaseConfirmTitle,
                                  body:
                                      l10n.bw2ConfirmSendBtcBody(amount, token.depositAddress, btcKeypair.address, feeRate.toString()),
                                  confirmText: l10n.actionSend,
                                  cancelText: l10n.actionCancel,
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                final txHash = await BtcWebService()
                                    .sendTransaction(
                                        btcKeypair.wif,
                                        token.depositAddress,
                                        parsedAmount,
                                        feeRate);

                                if (txHash == null) {
                                  Toast.error();
                                  return;
                                }

                                Toast.message(
                                    l10n.tkbBtcSentTo(amount, token.depositAddress));

                                ref.invalidate(btcWebTransactionListProvider(
                                    btcKeypair.address));

                                Future.delayed(Duration(seconds: 2), () {
                                  ref
                                      .read(webSessionProvider.notifier)
                                      .refreshBtcBalanceInfo();
                                });

                                InfoDialog.show(
                                    title: l10n.btcTransactionBroadcastedTitle,
                                    buttonColorOverride: Color(0xfff7931a),
                                    content: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 600),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            initialValue: txHash,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              label: Text(
                                                l10n.tkbTransactionHash,
                                                style: TextStyle(
                                                  color: Color(0xfff7931a),
                                                ),
                                              ),
                                              suffix: IconButton(
                                                icon: Icon(Icons.copy),
                                                onPressed: () async {
                                                  await Clipboard.setData(
                                                      ClipboardData(
                                                          text: txHash));
                                                  Toast.message(
                                                      l10n.tkbTransactionHashCopied);
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          AppButton(
                                            label: l10n.btcOpenInExplorer,
                                            variant: AppColorVariant.Btc,
                                            type: AppButtonType.Text,
                                            onPressed: () {
                                              if (Env.btcIsTestNet) {
                                                launchUrlString(
                                                    "https://mempool.space/testnet4/tx/$txHash");
                                              } else {
                                                launchUrlString(
                                                    "https://mempool.space/tx/$txHash");
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ));
                              },
                            );
                          }),
                        ListTile(
                          title: Text(l10n.btcManualSendTitle),
                          subtitle: Text(
                              l10n.tkbManualSendSubtitle),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: token.depositAddress));
                            Toast.message(
                                l10n.bw2DepositAddressCopied);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
            variant: AppColorVariant.Primary,
          ),
        AppButton(
          label: l10n.btcWithdrawLabel,
          icon: Icons.download,
          variant: AppColorVariant.Primary,
          onPressed: () async {
            final manager = ref.read(webTokenActionsManager);
            if (!manager.verifyBalance()) {
              return;
            }

            // Only this wallet's own outstanding withdrawals. Resuming
            // another holder's makes the FROST leader address and the
            // signature disagree, which validators reject — and the ceremony
            // then hangs rather than failing.
            final pending = token.liveResumableWithdrawalRequestsFor(myAddress);
            if (pending.isNotEmpty) {
              final requestHash = pending.first['request_transaction_hash'] as String?;
              if (requestHash != null) {
                WebV2WithdrawalDialog.show(
                  scIdentifier: token.scIdentifier,
                  requestorAddress: myAddress!,
                  btcAddress: pending.first['btc_address'] ?? '',
                  amount: (pending.first['amount'] is num) ? (pending.first['amount'] as num).toDouble() : (double.tryParse(pending.first['amount'].toString()) ?? 0),
                  feeRate: 0,
                  ownerAddress: token.ownerAddress,
                  existingRequestHash: requestHash,
                );
                return;
              }
            }

            // New withdrawal request
            final amountStr = await PromptModal.show(
              title: l10n.labelAmount,
              validator: (val) => formValidatorNumber(val, l10n.labelAmount),
              body: l10n.bw2HowMuchBtcWithdraw,
              labelText: l10n.bw2WithdrawalAmount,
            );
            if (amountStr == null) return;
            final withdrawAmount = double.tryParse(amountStr);
            if (withdrawAmount == null || withdrawAmount <= 0) {
              Toast.error(l10n.btcInvalidAmount);
              return;
            }

            final available = token.balanceForAddress(myAddress);
            if (withdrawAmount > available) {
              Toast.error(l10n.bw2InsufficientBalanceAvailable(available.toString()));
              return;
            }

            final address = await PromptModal.show(
              title: l10n.bw2BtcAddressTitle,
              validator: formValidatorBtcAddress,
              labelText: l10n.bw2ReceivingBtcAddress,
            );
            if (address == null) return;

            final feeRate = await promptForFeeRate(context);
            if (feeRate == null) return;

            WebV2WithdrawalDialog.show(
              scIdentifier: token.scIdentifier,
              requestorAddress: myAddress!,
              btcAddress: address,
              amount: withdrawAmount,
              feeRate: feeRate,
              ownerAddress: token.ownerAddress,
            );
          },
        ),
        if (WEB_VBTC_OWNERSHIP_TRANSFER_ENABLED && isOwner)
          AppButton(
            label: l10n.btcTransferOwnership,
            icon: Icons.person,
            variant: AppColorVariant.Primary,
            onPressed: () async {
              final manager = ref.read(webTokenActionsManager);
              if (token.globalBalance <= 0) {
                Toast.error(l10n.btcVbtcNoBalanceTransfer);
                return;
              }
              if (!manager.verifyBalance()) {
                return;
              }

              final toAddress = await PromptModal.show(
                title: l10n.btcTransferOwnership,
                validator: (val) => formValidatorNotEmpty(val, l10n.labelAddress),
                labelText: l10n.bw2RecipientVfxAddress,
              );
              if (toAddress == null || toAddress.isEmpty) return;

              final confirmed = await ConfirmDialog.show(
                title: l10n.btcTransferOwnership,
                body: l10n.bw2TransferOwnershipConfirmBody(toAddress),
                confirmText: l10n.btcTransferLabel,
                cancelText: l10n.actionCancel,
              );
              if (confirmed != true) return;

              await manager.transferVbtcOwnership(
                scIdentifier: token.scIdentifier,
                toAddress: toAddress,
              );
            },
          ),
        AppButton(
          label: l10n.btcTransferLabel,
          variant: AppColorVariant.Primary,
          icon: Icons.send,
          onPressed: () async {
            final manager = ref.read(webTokenActionsManager);
            if (!manager.verifyBalance()) {
              return;
            }
            if (myAddress != null) {
              final result = await showModalBottomSheet(
                context: rootNavigatorKey.currentContext!,
                builder: (context) {
                  return _TransferSharesModal(
                    forWithdrawl: false,
                    token: token,
                    thisAddress: myAddress,
                  );
                },
              );

              if (result is _TransferShareModalResponse) {
                await manager.transferVbtcV2(
                  token: token,
                  toAddress: result.toAddress,
                  fromAddress: myAddress,
                  amount: result.amount,
                );
              }
            }
          },
        ),
        if (isOwner)
          AppButton(
            label: l10n.btcProveOwnership,
            icon: Icons.security,
            onPressed: () {
              proveSmartContractOwnership(
                  context, ref, token.ownerAddress, token.scIdentifier);
            },
          ),
        AppButton(
          label: l10n.btcBorrowLend,
          icon: Icons.people,
          onPressed: () {
            Toast.message(l10n.btcActionNotAvailable);
          },
        ),
      ],
    );
  }
}

class _TransferShareModalResponse {
  final String toAddress;
  final double amount;
  final int feeRate;

  _TransferShareModalResponse({
    required this.toAddress,
    required this.amount,
    this.feeRate = 0,
  });
}

class _TransferSharesModal extends BaseComponent {
  final BtcWebVbtcToken token;
  final bool forWithdrawl;
  final String thisAddress;
  _TransferSharesModal({
    required this.token,
    required this.forWithdrawl,
    required this.thisAddress,
  });

  final TextEditingController toAddressController = TextEditingController();
  // final TextEditingController fromAddressController = TextEditingController(text: forWithdrawl ? token.rbxAddress : '');
  final TextEditingController amountControlller = TextEditingController();

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.btcOrange;
    // int fee = 0;
    // BtcFeeRatePreset btcFeeRatePreset = BtcFeeRatePreset.economy;
    int fee = 0;

    return ModalContainer(
      withClose: true,
      withDecor: false,
      children: [
        Text(
          forWithdrawl ? l10n.tkbWithdrawBtc : l10n.tkbTransferVbtc,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white),
        ),
        SizedBox(
          height: 8,
        ),
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: toAddressController,
                decoration: InputDecoration(
                  label: Text(
                    forWithdrawl ? l10n.tkbToBtcAddress : l10n.tkbToVfxAddress,
                    style: TextStyle(color: color),
                  ),
                ),
              ),
              TextFormField(
                controller: amountControlller,
                decoration: InputDecoration(
                  label: Text(
                    l10n.bw2AmountOfBtcToSend,
                    style: TextStyle(color: color),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //   child: Text("Fee Rate: $BTC_WITHDRAWL_FEE_RATE SATS per byte (${satashiToBtcLabel(BTC_WITHDRAWL_FEE_RATE)} BTC per byte)"),
              // ),
              Text(
                l10n.bw2MultiSigHigherFee,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    label: l10n.actionCancel,
                    type: AppButtonType.Text,
                    variant: AppColorVariant.Light,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  AppButton(
                    label: forWithdrawl ? l10n.btcWithdrawLabel : l10n.btcTransferLabel,
                    variant: forWithdrawl
                        ? AppColorVariant.Secondary
                        : AppColorVariant.Btc,
                    onPressed: () {
                      final toAddress = toAddressController.text.trim();
                      if (toAddress.isEmpty) {
                        print("Invalid To Address");
                        return;
                      }
                      final amount = double.tryParse(amountControlller.text);

                      if (amount == null || amount <= 0) {
                        Toast.error(l10n.btcInvalidAmount);
                        return;
                      }
                      print("-----");

                      if (amount > token.balanceForAddress(thisAddress)) {
                        Toast.error(l10n.btcNotEnoughBalanceShort);
                        return;
                      }
                      final result = _TransferShareModalResponse(
                          toAddress: toAddress, amount: amount, feeRate: fee);
                      Navigator.of(context).pop(result);
                    },
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
