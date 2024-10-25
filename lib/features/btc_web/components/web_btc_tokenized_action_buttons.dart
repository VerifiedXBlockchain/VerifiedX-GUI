import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/features/btc/providers/btc_balance_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../../app.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/validation.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../../btc/providers/btc_pending_tokenized_address_list_provider.dart';
import '../../btc/utils.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../utils/toast.dart';

import '../../token/providers/web_token_actions_manager.dart';
import '../models/btc_web_vbtc_token.dart';
import '../providers/btc_web_transaction_list_provider.dart';
import '../services/btc_web_service.dart';

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
    final myAddress = ref.watch(webSessionProvider.select((value) => value.keypair?.address));
    final myBalance = myAddress != null ? token.balanceForAddress(myAddress) : 0.0;

    final btcKeypair = ref.watch(webSessionProvider.select((value) => value.btcKeypair));

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        AppButton(
          label: "Copy Deposit Address",
          icon: Icons.copy,
          variant: AppColorVariant.Primary,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: token.depositAddress));
            Toast.message("BTC Address copied to clipboard");
          },
        ),
        if (isOwner)
          AppButton(
            label: "Fund",
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
                          children: [Text('Fund vBTC Token')],
                        ),
                        if (btcKeypair != null)
                          Consumer(builder: (context, ref, _) {
                            final balance = ref.watch(webSessionProvider.select((value) => value.btcBalanceInfo?.btcBalance));

                            return ListTile(
                              title: Text(btcKeypair.address),
                              subtitle: Text("${balance?.toStringAsFixed(8) ?? 0} BTC"),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () async {
                                if (balance == null || balance <= 0) {
                                  Toast.error("This BTC account doesn't have a balance");
                                  return;
                                }

                                Navigator.of(context).pop();
                                final amount = await PromptModal.show(
                                    title: "Amount (Balance: $balance BTC)",
                                    validator: (val) => formValidatorNumber(val, "Amount"),
                                    labelText: 'Deposit amount');
                                if (amount == null) {
                                  return;
                                }
                                final parsedAmount = double.tryParse(amount);
                                if (parsedAmount == null) {
                                  return;
                                }

                                if (parsedAmount <= 0) {
                                  Toast.error("Amount must be greater than 0.0 BTC");
                                  return;
                                }

                                if (balance <= parsedAmount) {
                                  Toast.error("Not enough BTC to cover this transaction + fee");
                                  return;
                                }

                                final feeRate = await promptForFeeRate(context);

                                if (feeRate == null) {
                                  return;
                                }

                                final confirmed = await ConfirmDialog.show(
                                  title: "Please Confirm",
                                  body:
                                      "Sending:\n$amount BTC\n\nTo:\n${token.depositAddress} (Token Deposit Address)\n\nFrom:\n${btcKeypair.address}\n\nFeeRate:\n$feeRate SATS",
                                  confirmText: "Send",
                                  cancelText: "Cancel",
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                final txHash = await BtcWebService().sendTransaction(btcKeypair.wif, token.depositAddress, parsedAmount, feeRate);

                                if (txHash == null) {
                                  Toast.error();
                                  return;
                                }

                                Toast.message("$amount BTC has been sent to ${token.depositAddress}.");

                                ref.invalidate(btcWebTransactionListProvider(btcKeypair.address));

                                Future.delayed(Duration(seconds: 2), () {
                                  ref.read(webSessionProvider.notifier).refreshBtcBalanceInfo();
                                });

                                InfoDialog.show(
                                    title: "Transaction Broadcasted",
                                    buttonColorOverride: Color(0xfff7931a),
                                    content: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 600),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            initialValue: txHash,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              label: Text(
                                                "Transaction Hash",
                                                style: TextStyle(
                                                  color: Color(0xfff7931a),
                                                ),
                                              ),
                                              suffix: IconButton(
                                                icon: Icon(Icons.copy),
                                                onPressed: () async {
                                                  await Clipboard.setData(ClipboardData(text: txHash));
                                                  Toast.message("Transaction Hash copied to clipboard");
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          AppButton(
                                            label: "Open in BTC Explorer",
                                            variant: AppColorVariant.Btc,
                                            type: AppButtonType.Text,
                                            onPressed: () {
                                              if (Env.isTestNet) {
                                                launchUrlString("https://mempool.space/testnet4/tx/$txHash");
                                              } else {
                                                launchUrlString("https://mempool.space/tx/$txHash");
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
                          title: Text("Manual Send"),
                          subtitle: Text("Send coin manually to this token’s BTC deposit address"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: token.depositAddress));
                            Toast.message("Deposit address copied to clipboard");
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
          label: "Withdraw",
          icon: Icons.download,
          variant: AppColorVariant.Primary,
          onPressed: () async {
            final manager = ref.read(webTokenActionsManager);
            if (!manager.verifyBalance()) {
              return;
            }
            final amount = await PromptModal.show(
              title: 'Amount',
              validator: (val) => formValidatorNumber(val, "Amount"),
              body: 'The amount you want to send',
              labelText: "Sending amount",
            );
            if (amount != null && double.tryParse(amount) != null) {
              final address = await PromptModal.show(
                title: 'Btc Address',
                validator: (val) => formValidatorNotEmpty(val, "Address"),
                labelText: "Recieving Address",
              );
              if (address != null) {
                final feeRate = await PromptModal.show(
                  title: 'Fee Rate',
                  validator: (val) => formValidatorInteger(val, "Fee Rate"),
                  labelText: "Fee Rate",
                );
                if (feeRate != null && int.tryParse(feeRate) != null) {
                  final result = await manager.withdrawVbtc(
                    scId: token.scIdentifier,
                    amount: double.parse(amount),
                    btcAddress: address,
                    feeRate: int.parse(feeRate),
                  );

                  if (result == null) {
                    Toast.error();
                    return;
                  }

                  InfoDialog.show(title: "Response", content: SelectableText(jsonEncode(result)));
                }
              }
            }
          },
        ),
        AppButton(
          label: "Transfer Ownership",
          icon: Icons.person,
          variant: AppColorVariant.Primary,
          onPressed: () async {
            final manager = ref.read(webTokenActionsManager);
            if (!manager.verifyBalance()) {
              return;
            }

            final toAddress = await manager.promptForAddress(title: "Transfer to");
            if (toAddress == null) {
              return;
            }

            final success = await manager.transferVbtcOwnership(token, toAddress);
          },
        ),
        AppButton(
          label: "Transfer",
          variant: AppColorVariant.Primary,
          icon: Icons.send,
          onPressed: () async {
            final manager = ref.read(webTokenActionsManager);
            if (!manager.verifyBalance()) {
              return;
            }

            final toAddress = await manager.promptForAddress(title: "Transfer to");
            if (toAddress == null) {
              return;
            }

            final amount = await manager.promptForAmount(title: "Amount to Transfer");
            if (amount == null) {
              return;
            }

            if (amount > myBalance) {
              Toast.error("Your balance is insufficent.");
              return;
            }

            final success = await manager.transferVbtcAmount(token, toAddress, amount);
          },
        ),
        AppButton(
          label: "Borrow/Lend",
          icon: Icons.people,
          onPressed: () {
            Toast.message("Action Not Available Yet.");
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
  final TokenizedBitcoin token;
  final bool forWithdrawl;
  _TransferSharesModal({
    required this.token,
    required this.forWithdrawl,
  });

  final TextEditingController toAddressController = TextEditingController();
  // final TextEditingController fromAddressController = TextEditingController(text: forWithdrawl ? token.rbxAddress : '');
  final TextEditingController amountControlller = TextEditingController();

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.btcOrange;
    // int fee = 0;
    // BtcFeeRatePreset btcFeeRatePreset = BtcFeeRatePreset.economy;
    int fee = 0;

    return ModalContainer(
      withClose: true,
      withDecor: false,
      children: [
        Text(
          forWithdrawl ? "Withdraw BTC" : "Transfer BTC",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
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
                    forWithdrawl ? "To BTC Address" : "To VFX Address",
                    style: TextStyle(color: color),
                  ),
                ),
              ),
              // if (forWithdrawl)
              //   TextFormField(
              //     controller: fromAddressController,
              //     readOnly: true,
              //     decoration: InputDecoration(
              //       label: Text(
              //         "From VFX Address",
              //         style: TextStyle(color: color),
              //       ),
              //     ),
              //   ),
              TextFormField(
                controller: amountControlller,
                decoration: InputDecoration(
                  label: Text(
                    "Amount of BTC to Send",
                    style: TextStyle(color: color),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Fee Rate: $BTC_WITHDRAWL_FEE_RATE SATS per byte (${satashiToBtcLabel(BTC_WITHDRAWL_FEE_RATE)} BTC per byte)"),
              ),
              Text(
                "This is a Multi-signature. The fee rate has been calculated for you.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              // if (forWithdrawl)
              //   Builder(
              //     builder: (context) {
              //       final state = ref.watch(vBtcOnboardProvider);

              //       final recommendedFees = ref.watch(sessionProvider).btcRecommendedFees ?? BtcRecommendedFees.fallback();

              //       switch (state.btcFeeRatePreset) {
              //         case BtcFeeRatePreset.custom:
              //           fee = 1;
              //           break;
              //         case BtcFeeRatePreset.minimum:
              //           fee = recommendedFees.minimumFee;
              //           break;
              //         case BtcFeeRatePreset.economy:
              //           fee = recommendedFees.economyFee;
              //           break;
              //         case BtcFeeRatePreset.hour:
              //           fee = recommendedFees.hourFee;
              //           break;
              //         case BtcFeeRatePreset.halfHour:
              //           fee = recommendedFees.halfHourFee;
              //           break;
              //         case BtcFeeRatePreset.fastest:
              //           fee = recommendedFees.fastestFee;
              //           break;
              //       }

              //       final feeBtc = satashiToBtcLabel(fee);
              //       final feeEstimate = satashiTxFeeEstimate(fee);
              //       final feeEstimateBtc = btcTxFeeEstimateLabel(fee);

              //       return Column(
              //         mainAxisSize: MainAxisSize.min,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           ListTile(
              //             contentPadding: EdgeInsets.zero,
              //             leading: const SizedBox(width: 100, child: Text("Fee Rate:")),
              //             title: Row(
              //               children: [
              //                 PopupMenuButton<BtcFeeRatePreset>(
              //                   color: Color(0xFF080808),
              //                   onSelected: (value) {
              //                     ref.read(vBtcOnboardProvider.notifier).setBtcFeeRatePreset(value);
              //                   },
              //                   itemBuilder: (context) {
              //                     return BtcFeeRatePreset.values.where((type) => type != BtcFeeRatePreset.custom).map((preset) {
              //                       return PopupMenuItem(
              //                         value: preset,
              //                         child: Text(preset.label),
              //                       );
              //                     }).toList();
              //                   },
              //                   child: Row(
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       Text(
              //                         state.btcFeeRatePreset.label,
              //                         style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.btcOrange),
              //                       ),
              //                       Icon(
              //                         Icons.arrow_drop_down,
              //                         size: 24,
              //                         color: Theme.of(context).colorScheme.btcOrange,
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           SizedBox(
              //             height: 8,
              //           ),
              //           Text(
              //             "Fee Estimate: ~$feeEstimate SATS | ~$feeEstimateBtc BTC    ($fee SATS /byte | $feeBtc BTC /byte)",
              //             style: Theme.of(context).textTheme.caption,
              //           ),
              //         ],
              //       );
              //     },
              //   ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    label: "Cancel",
                    type: AppButtonType.Text,
                    variant: AppColorVariant.Light,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  AppButton(
                    label: forWithdrawl ? "Withdraw" : "Transfer",
                    variant: forWithdrawl ? AppColorVariant.Secondary : AppColorVariant.Btc,
                    onPressed: () {
                      final toAddress = toAddressController.text.trim();
                      if (toAddress.isEmpty) {
                        print("Invalid To Address");
                        return;
                      }

                      // final fromAddress = forWithdrawl ? fromAddressController.text.trim() : null;
                      // if (forWithdrawl && fromAddress!.isEmpty) {
                      //   print("Invalid From Address");
                      //   return;
                      // }

                      final amount = double.tryParse(amountControlller.text);

                      if (amount == null || amount <= 0) {
                        Toast.error("Invalid Amount");
                        return;
                      }
                      print("-----");

                      if (amount > token.myBalance) {
                        Toast.error("Not enough balance");
                        return;
                      }
                      final result = _TransferShareModalResponse(toAddress: toAddress, amount: amount, feeRate: fee);
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
