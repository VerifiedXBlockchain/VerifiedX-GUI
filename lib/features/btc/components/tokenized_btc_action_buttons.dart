import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/providers/currency_segmented_button_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components.dart';
import '../../../core/utils.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../encrypt/utils.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../nft/services/nft_service.dart';
import '../../nft/utils.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../models/tokenized_bitcoin.dart';
import '../providers/btc_account_list_provider.dart';
import '../providers/btc_pending_tokenized_address_list_provider.dart';
import '../providers/tokenized_bitcoin_list_provider.dart';
import '../services/btc_service.dart';
import '../services/vbtc_v2_service.dart';
import '../utils.dart';
import '../models/btc_fee_rate_preset.dart';
import '../models/btc_recommended_fees.dart';
import '../../../core/providers/session_provider.dart';
import './withdrawal_processing_dialog.dart';

class TokenizedBtcActionButtons extends BaseComponent {
  final TokenizedBitcoin token;
  final String scOwner;
  const TokenizedBtcActionButtons({
    super.key,
    required this.token,
    required this.scOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingIds = ref.watch(btcPendingTokenizedAddressListProvider);

    bool debuggingAddressExists = true;

    final isRa = token.rbxAddress.startsWith("xRBX");

    return Builder(
      builder: (context) {
        if (token.btcAddress == null) {
          if (pendingIds.contains(token.smartContractUid)) {
            return Center(
              child: AppBadge(
                label: "BTC Address Pending",
                variant: AppColorVariant.Primary,
              ),
            );
          }

          return Center(
            child: AppButton(
              label: "Generate BTC Address",
              variant: AppColorVariant.Primary,
              icon: Icons.star,
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  title: "Generate BTC Address",
                  body:
                      "Are you sure you want to generate this token's BTC address?",
                  confirmText: "Generate",
                  cancelText: "Cancel",
                );
                if (confirmed == true) {
                  ref.read(globalLoadingProvider.notifier).start();
                  final address = await BtcService()
                      .generateTokenizedBitcoinAddress(token.smartContractUid);
                  ref.read(globalLoadingProvider.notifier).complete();

                  if (address == null) {
                    return;
                  }

                  Toast.message("BTC Address generated ($address)");
                  ref.read(logProvider.notifier).append(
                        LogEntry(
                          message: "BTC Address generated ($address)",
                          textToCopy: address,
                          variant: AppColorVariant.Primary,
                        ),
                      );
                  ref.read(tokenizedBitcoinListProvider.notifier).refresh();
                  ref
                      .read(btcPendingTokenizedAddressListProvider.notifier)
                      .addScId(token.smartContractUid);
                }
              },
            ),
          );
        }

        final isOwner = ref
                    .watch(walletListProvider)
                    .firstWhereOrNull((w) => w.address == scOwner) !=
                null &&
            scOwner == token.rbxAddress;

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
                await Clipboard.setData(ClipboardData(text: token.btcAddress));
                Toast.message("BTC Address copied to clipboard");
              },
            ),
            if (isOwner && token.btcAddress != null)
              AppButton(
                label: "Fund",
                icon: Icons.outbox,
                onPressed: () {
                  final btcAccounts = ref
                      .watch(btcAccountListProvider)
                      .where((a) => a.balance > 0)
                      .toList();

                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ModalContainer(
                        withDecor: false,
                        withClose: true,
                        children: [
                          Text(
                            "Choose BTC Account to Send From",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white),
                          ),
                          ListView(
                            shrinkWrap: true,
                            children: [
                              ...btcAccounts.map((account) {
                                return AppCard(
                                  padding: 0,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(account.address),
                                    subtitle: Text("${account.balance} BTC"),
                                    trailing: Icon(Icons.send),
                                    onTap: () async {
                                      Navigator.of(context).pop();

                                      final amount = await PromptModal.show(
                                        title: "BTC Amount",
                                        validator: (v) =>
                                            formValidatorNumber(v, "Amount"),
                                        labelText: "Amount",
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9.]"))
                                        ],
                                        showUsdValue: true,
                                        currencyType: CurrencyType.btc,
                                      );

                                      if (amount != null) {
                                        final parsedAmount =
                                            double.tryParse(amount);

                                        if (parsedAmount == null) {
                                          Toast.error("Invalid Amount");
                                          return;
                                        }

                                        if (parsedAmount <= 0) {
                                          Toast.error(
                                              "Amount must be greater than 0.0 BTC");
                                          return;
                                        }

                                        if (parsedAmount >= account.balance) {
                                          Toast.error(
                                              "Insufficient Balance to cover tx and fee. This account only has ${account.balance} BTC.");
                                          return;
                                        }

                                        final feeRate =
                                            await promptForFeeRate(context);

                                        if (feeRate == null) {
                                          return;
                                        }

                                        // final amountRequired = parsedAmount + satashisToBtc(feeRate);

                                        // if (amountRequired > account.balance) {
                                        //   Toast.error(
                                        //       "Insufficient Balance. This account only has ${account.balance} BTC. With the fee, the amount required is ${amountRequired.toStringAsFixed(9)} BTC.");
                                        //   return;
                                        // }

                                        final calculatedFeeRate =
                                            await BtcService().getFee(
                                                account.address,
                                                token.btcAddress!,
                                                parsedAmount,
                                                feeRate);

                                        if (calculatedFeeRate == null) {
                                          return;
                                        }

                                        final confirmed =
                                            await ConfirmDialog.show(
                                          title: "Confirm Transaction",
                                          body:
                                              "Sending ${parsedAmount.toStringAsFixed(9)} BTC from ${account.address} to ${token.btcAddress}.\n\nFee:\n${calculatedFeeRate.toStringAsFixed(8)} BTC",
                                          confirmText: "Send",
                                          cancelText: "Cancel",
                                        );

                                        if (confirmed != true) {
                                          return;
                                        }
                                        ref
                                            .read(
                                                globalLoadingProvider.notifier)
                                            .start();

                                        final result =
                                            await BtcService().sendTransaction(
                                          amount: parsedAmount,
                                          feeRate: feeRate,
                                          fromAddress: account.address,
                                          toAddress: token.btcAddress!,
                                        );
                                        ref
                                            .read(
                                                globalLoadingProvider.notifier)
                                            .complete();

                                        if (!result.success) {
                                          Toast.error(result.message);
                                          return;
                                        }
                                        final txHash = result.message;
                                        final message =
                                            "BTC TX broadcasted with hash of $txHash";
                                        ref.read(logProvider.notifier).append(
                                              LogEntry(
                                                message: message,
                                                textToCopy: txHash,
                                                variant: AppColorVariant.Btc,
                                              ),
                                            );
                                        Toast.message(
                                            "$amount BTC has been sent to ${token.btcAddress}.");

                                        InfoDialog.show(
                                            title: "Transaction Broadcasted",
                                            buttonColorOverride:
                                                Color(0xfff7931a),
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
                                                        "Transaction Hash",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xfff7931a),
                                                        ),
                                                      ),
                                                      suffix: IconButton(
                                                        icon: Icon(Icons.copy),
                                                        onPressed: () async {
                                                          await Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      txHash));
                                                          Toast.message(
                                                              "Transaction Hash copied to clipboard");
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  AppButton(
                                                    label:
                                                        "Open in BTC Explorer",
                                                    variant:
                                                        AppColorVariant.Btc,
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
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                              AppCard(
                                padding: 0,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text("Manual Send"),
                                  subtitle: Text(
                                      "Send coin manually to this token's BTC deposit address"),
                                  trailing: Icon(Icons.send),
                                  onTap: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: token.btcAddress));
                                    Toast.message(
                                        "Send funds to ${token.btcAddress} (address copied to clipboard)");
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                variant: AppColorVariant.Primary,
              ),

            AppButton(
              label: "Withdraw",
              icon: Icons.download,
              variant: AppColorVariant.Primary,
              onPressed: () async {
                if (isRa) {
                  Toast.error(
                      "Vault Accounts can not withdrawl. Please transfer vBTC to a standard VFX address");
                  return;
                }

                final result = await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return _TransferSharesModal(
                      forWithdrawl: true,
                      token: token,
                    );
                  },
                );

                if (result is _TransferShareModalResponse) {
                  final confirmed = await ConfirmDialog.show(
                    title: "Withdraw BTC",
                    body:
                        "Are you sure you want to withdraw ${result.amount} BTC to ${result.toAddress}?",
                  );

                  if (confirmed != true) {
                    return;
                  }

                  if (token.version >= 2) {
                    // V2: request withdrawal first, then show processing dialog
                    final withdrawResult = await VbtcV2Service().requestWithdrawal(
                      scUid: token.smartContractUid,
                      requestorAddress: token.rbxAddress,
                      btcAddress: result.toAddress,
                      amount: result.amount,
                      feeRate: result.feeRate,
                    );

                    String? requestHash = withdrawResult.requestHash;

                    if (!withdrawResult.success) {
                      // Check for active withdrawal — show recovery dialog
                      final message = withdrawResult.message ?? "";
                      final match = RegExp(r'Request Hash:\s*(0x[a-fA-F0-9]+)').firstMatch(message);
                      if (match != null) {
                        requestHash = match.group(1);

                        // Phase 5: Ask user if they want to complete the pending withdrawal
                        final shouldComplete = await ConfirmDialog.show(
                          title: "Pending Withdrawal Found",
                          body: "You have a pending withdrawal for this contract. Would you like to complete it?",
                          confirmText: "Complete",
                          cancelText: "Dismiss",
                        );

                        if (shouldComplete != true) return;
                      } else {
                        Toast.error(withdrawResult.message ?? "Failed to request withdrawal.");
                        return;
                      }
                    }

                    if (requestHash == null) {
                      Toast.error("No request hash returned.");
                      return;
                    }

                    final dialogResult = await WithdrawalProcessingDialog.show(
                      scUid: token.smartContractUid,
                      requestHash: requestHash,
                      ownerAddress: isOwner ? token.rbxAddress : null,
                    );

                    ref.read(tokenizedBitcoinListProvider.notifier).refresh();

                    if (dialogResult != null && dialogResult.success) {
                      final message = "vBTC V2 Withdrawal completed successfully.";
                      ref.read(logProvider.notifier).append(
                            LogEntry(
                              message: message,
                              variant: AppColorVariant.Btc,
                              textToCopy: dialogResult.btcTransactionHash,
                            ),
                          );
                    }
                  } else {
                    // V1: existing flow
                    ref.read(globalLoadingProvider.notifier).start();
                    final withdrawlHash = await BtcService().withdrawCoin(
                      token.smartContractUid,
                      result.toAddress,
                      token.rbxAddress,
                      result.amount,
                      result.feeRate,
                    );
                    ref.read(globalLoadingProvider.notifier).complete();

                    if (withdrawlHash != null) {
                      final message =
                          "BTC Withdrawl TX Broadcasted successfully. Hash: $withdrawlHash";
                      Toast.message(message);

                      ref.read(logProvider.notifier).append(
                            LogEntry(
                                message: message,
                                variant: AppColorVariant.Btc,
                                textToCopy: withdrawlHash),
                          );
                    }
                  }
                }
              },
            ),
            AppButton(
              label: "Transfer",
              variant: AppColorVariant.Primary,
              icon: Icons.send,
              onPressed: () async {
                final int? option = await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ModalContainer(
                        withClose: true,
                        withDecor: false,
                        children: [
                          Text(
                            "Transfer",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white),
                          ),
                          if (isOwner)
                            AppCard(
                              padding: 0,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text("Transfer Token Ownership"),
                                subtitle: Text(
                                    "Transfer the ownership of this token to another VFX account."),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).pop(1);
                                },
                              ),
                            ),
                          AppCard(
                            padding: 0,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text("Transfer vBTC"),
                              // leading: Icon(FontAwesomeIcons.btc),

                              subtitle: Text(
                                  "Transfer a specific portion of the vBTC within the token to another VFX address."),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).pop(2);
                              },
                            ),
                          ),
                          // Card(
                          //   color: Colors.white10,
                          //   child: ListTile(
                          //     title: Text("Withdraw BTC"),
                          //     subtitle: Text("Convert vBTC to BTC and transfer it from this token to a BTC address."),
                          //     trailing: Icon(Icons.chevron_right),
                          //     onTap: () {
                          //       Navigator.of(context).pop(3);
                          //     },
                          //   ),
                          // ),
                          if (isOwner)
                            AppCard(
                              padding: 0,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(
                                    "Transfer Ownership To Reserve/Protected Account"),
                                subtitle: Text(
                                    "Transfer the ownership of this token to your reserve/protected account."),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).pop(4);
                                },
                              ),
                            ),
                        ],
                      );
                    });

                if (option == null) {
                  return;
                }

                if (option == 1) {
                  if (token.balance == 0) {
                    Toast.error(
                        "vBTC tokens with zero balance can not be transferred.");
                    return;
                  }

                  if (token.version >= 2) {
                    // V2: prompt for destination address, then call VbtcV2Service
                    final toAddress = await PromptModal.show(
                      title: "Transfer Ownership",
                      labelText: "To VFX Address",
                      validator: (v) =>
                          formValidatorNotEmpty(v, "VFX Address"),
                    );

                    if (toAddress == null || toAddress.isEmpty) return;

                    final confirmed = await ConfirmDialog.show(
                      title: "Transfer Ownership",
                      body:
                          "Are you sure you want to transfer ownership of this vBTC token to $toAddress?",
                    );

                    if (confirmed != true) return;

                    ref.read(globalLoadingProvider.notifier).start();
                    final success = await VbtcV2Service().transferOwnership(
                      scUid: token.smartContractUid,
                      toAddress: toAddress,
                    );
                    ref.read(globalLoadingProvider.notifier).complete();

                    if (success) {
                      Toast.message("Ownership transfer initiated.");
                      ref.read(logProvider.notifier).append(
                            LogEntry(
                              message:
                                  "vBTC V2 ownership transfer initiated to $toAddress",
                              variant: AppColorVariant.Btc,
                            ),
                          );
                      ref.read(tokenizedBitcoinListProvider.notifier).refresh();
                    }
                  } else {
                    // V1: existing NFT transfer flow
                    final nft =
                        await NftService().retrieve(token.smartContractUid);

                    if (nft == null) {
                      Toast.error(
                          "Could not resolve nft from ${token.smartContractUid}");
                      return;
                    }
                    await initTransferNftProcess(
                      context,
                      ref,
                      nft,
                      backupRequired: false,
                      titleOverride: "Transfer Token",
                      isToken: true,
                    );
                  }
                }
                if (option == 2) {
                  final result = await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return _TransferSharesModal(
                        forWithdrawl: false,
                        token: token,
                      );
                    },
                  );

                  if (result is _TransferShareModalResponse) {
                    final confirmed = await ConfirmDialog.show(
                      title: "Transfer BTC",
                      body:
                          "Are you sure you want to transfer ${result.amount} vBTC to ${result.toAddress}?",
                    );

                    if (confirmed != true) {
                      return;
                    }

                    if (isRa) {
                      if (!await passwordRequiredGuardV2(
                          context, ref, token.rbxAddress)) {
                        return;
                      }
                    }

                    if (token.version >= 2) {
                      // V2: use VbtcV2Service for transfer
                      ref.read(globalLoadingProvider.notifier).start();
                      final txHash = await VbtcV2Service().transferVbtc(
                        scUid: token.smartContractUid,
                        fromAddress: token.rbxAddress,
                        toAddress: result.toAddress,
                        amount: result.amount,
                      );
                      ref.read(globalLoadingProvider.notifier).complete();

                      if (txHash != null) {
                        final message =
                            "vBTC V2 Transfer TX Broadcasted. Hash: $txHash";
                        Toast.message(message);

                        ref.read(logProvider.notifier).append(
                              LogEntry(
                                message: message,
                                variant: AppColorVariant.Btc,
                                textToCopy: txHash,
                              ),
                            );
                        ref.read(tokenizedBitcoinListProvider.notifier).refresh();
                      }
                    } else {
                      // V1: existing flow
                      ref.read(globalLoadingProvider.notifier).start();
                      final success = await BtcService().transferTokenShares(
                        token.smartContractUid,
                        result.toAddress,
                        token.rbxAddress,
                        result.amount,
                      );
                      ref.read(globalLoadingProvider.notifier).complete();

                      if (success) {
                        const message =
                            "BTC Transfer TX Broadcasted successfully.";
                        Toast.message(
                            "BTC Transfer TX Broadcasted successfully. ");

                        ref.read(logProvider.notifier).append(
                              LogEntry(
                                  message: message, variant: AppColorVariant.Btc),
                            );
                      }
                    }
                  }
                }

                if (option == 4) {
                  final nft =
                      await NftService().retrieve(token.smartContractUid);
                  if (nft == null) {
                    Toast.error(
                        "Could not resolve nft from ${token.smartContractUid}");
                    return;
                  }

                  final wallets = ref
                      .read(walletListProvider)
                      .where((w) => w.isReserved)
                      .toList();
                  if (wallets.isEmpty) {
                    Toast.error(
                        "You don't have any Vault Accounts in this wallet");
                    return;
                  }

                  final wallet = await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ModalContainer(
                          children: [
                            Text("Choose Vault Account"),
                            ...wallets
                                .map(
                                  (w) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      boxShadow: glowingBoxRa,
                                    ),
                                    child: Card(
                                      color: Colors.black,
                                      child: ListTile(
                                        title: Text(w.fullLabel),
                                        subtitle: Text(w.balanceLabel),
                                        leading: Icon(Icons.security),
                                        trailing: Icon(Icons.chevron_right),
                                        onTap: () {
                                          Navigator.of(context).pop(w);
                                        },
                                      ),
                                    ),
                                  ),
                                )
                                .toList()
                          ],
                        );
                      });

                  if (wallet is Wallet) {
                    await initTransferNftProcess(
                      context,
                      ref,
                      nft,
                      backupRequired: false,
                      titleOverride: "Transfer Token",
                      isToken: true,
                      prefillAddress: wallet.address,
                    );
                  }
                }
              },
            ),
            if (isOwner)
              AppButton(
                label: "Prove Ownership",
                icon: Icons.security,
                onPressed: () {
                  proveSmartContractOwnership(
                      context, ref, token.rbxAddress, token.smartContractUid);
                },
              ),
            AppButton(
              label: "Borrow/Lend",
              icon: Icons.people,
              onPressed: () {
                Toast.message("Action Not Available Yet.");
              },
            ),
            // AppButton(
            //   label: "Unlock",
            //   icon: Icons.lock_open_sharp,
            //   variant: AppColorVariant.Danger,
            //   onPressed: () async {
            //     final confirmed = await ConfirmDialog.show(
            //       title: "Withdraw Token",
            //       body:
            //           "Are you sure you want to unlock and reveal the private key of this BTC token? Once unlocked, the token will become obsolete.",
            //       confirmText: "Reveal",
            //       cancelText: "Cancel",
            //     );

            //     if (confirmed == true) {
            //       final privateKey = await BtcService().withdrawCoin(token.smartContractUid);
            //       if (privateKey == null) {
            //         Toast.error();
            //         return;
            //       }

            //       showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (context) {
            //           return AlertDialog(
            //             title: Text("BTC Private Key"),
            //             content: ConstrainedBox(
            //               constraints: BoxConstraints(maxWidth: 600),
            //               child: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   TextFormField(
            //                     readOnly: true,
            //                     decoration: InputDecoration(
            //                       label: Text(
            //                         "Private Key",
            //                         style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
            //                       ),
            //                       suffixIcon: IconButton(
            //                         icon: Icon(
            //                           Icons.copy,
            //                           color: Theme.of(context).colorScheme.btcOrange,
            //                         ),
            //                         onPressed: () async {
            //                           await Clipboard.setData(ClipboardData(text: privateKey));
            //                           Toast.message("BTC Private Key copied to clipboard");
            //                         },
            //                       ),
            //                     ),
            //                     initialValue: privateKey,
            //                   ),
            //                   TextFormField(
            //                     readOnly: true,
            //                     decoration: InputDecoration(
            //                       label: Text(
            //                         "Address",
            //                         style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
            //                       ),
            //                       suffixIcon: IconButton(
            //                         icon: Icon(
            //                           Icons.copy,
            //                           color: Theme.of(context).colorScheme.btcOrange,
            //                         ),
            //                         onPressed: () async {
            //                           await Clipboard.setData(ClipboardData(text: token.btcAddress));
            //                           Toast.message("BTC Address copied to clipboard");
            //                         },
            //                       ),
            //                     ),
            //                     initialValue: token.btcAddress,
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             actions: [
            //               TextButton(
            //                 onPressed: () async {
            //                   final confirmed = await ConfirmDialog.show(
            //                     title: "Confirm Close",
            //                     body: "Have you copy and pasted your private key to a safe location?",
            //                     confirmText: "Yes",
            //                     cancelText: "No",
            //                   );
            //                   if (confirmed == true) {
            //                     Navigator.of(context).pop();
            //                   }
            //                 },
            //                 child: Text(
            //                   "Close",
            //                   style: TextStyle(color: Colors.white),
            //                 ),
            //               )
            //             ],
            //           );
            //         },
            //       );
            //     }
            //   },
            // ),
          ],
        );
      },
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
          forWithdrawl ? "Withdraw BTC" : "Transfer vBTC",
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
                  suffix: !forWithdrawl
                      ? AddressChoosingIconButton(
                          controller: toAddressController)
                      : null,
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
                    "Amount of BTC to ${forWithdrawl ? 'Withdraw' : 'Send'}",
                    style: TextStyle(color: color),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                ],
              ),
              if (forWithdrawl && token.version >= 2)
                Builder(
                  builder: (context) {
                    final selectedPreset = ref.watch(_v2FeeRatePresetProvider);
                    final recommendedFees = ref.watch(sessionProvider).btcRecommendedFees ?? BtcRecommendedFees.fallback();

                    switch (selectedPreset) {
                      case BtcFeeRatePreset.custom:
                        fee = 1;
                        break;
                      case BtcFeeRatePreset.minimum:
                        fee = recommendedFees.minimumFee;
                        break;
                      case BtcFeeRatePreset.economy:
                        fee = recommendedFees.economyFee;
                        break;
                      case BtcFeeRatePreset.hour:
                        fee = recommendedFees.hourFee;
                        break;
                      case BtcFeeRatePreset.halfHour:
                        fee = recommendedFees.halfHourFee;
                        break;
                      case BtcFeeRatePreset.fastest:
                        fee = recommendedFees.fastestFee;
                        break;
                    }

                    final feeBtc = satashiToBtcLabel(fee);
                    final feeEstimate = satashiTxFeeEstimate(fee);
                    final feeEstimateBtc = btcTxFeeEstimateLabel(fee);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SizedBox(width: 100, child: Text("Fee Rate:")),
                          title: Row(
                            children: [
                              PopupMenuButton<BtcFeeRatePreset>(
                                color: Color(0xFF080808),
                                onSelected: (value) {
                                  ref.read(_v2FeeRatePresetProvider.notifier).state = value;
                                },
                                itemBuilder: (context) {
                                  return BtcFeeRatePreset.values.where((type) => type != BtcFeeRatePreset.custom).map((preset) {
                                    return PopupMenuItem(
                                      value: preset,
                                      child: Text(preset.label),
                                    );
                                  }).toList();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      selectedPreset.label,
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.btcOrange),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 24,
                                      color: Theme.of(context).colorScheme.btcOrange,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Fee Estimate: ~$feeEstimate SATS | ~$feeEstimateBtc BTC    ($fee SATS /byte | $feeBtc BTC /byte)",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
              if (forWithdrawl && token.version < 2) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                      "Fee Rate: $BTC_WITHDRAWL_FEE_RATE SATS per byte (${satashiToBtcLabel(BTC_WITHDRAWL_FEE_RATE)} BTC per byte)"),
                ),
                Text(
                  "This is a Multi-signature. The fee rate has been calculated for you.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
                        Toast.error("Invalid Amount");
                        return;
                      }

                      if (amount > token.myBalance) {
                        Toast.error("Not enough balance");
                        return;
                      }

                      // For V2 withdrawal, compute fee from the selected preset
                      int resolvedFee = fee;
                      if (forWithdrawl && token.version >= 2) {
                        final preset = ref.read(_v2FeeRatePresetProvider);
                        final recommendedFees = ref.read(sessionProvider).btcRecommendedFees ?? BtcRecommendedFees.fallback();
                        switch (preset) {
                          case BtcFeeRatePreset.custom:
                            resolvedFee = 1;
                            break;
                          case BtcFeeRatePreset.minimum:
                            resolvedFee = recommendedFees.minimumFee;
                            break;
                          case BtcFeeRatePreset.economy:
                            resolvedFee = recommendedFees.economyFee;
                            break;
                          case BtcFeeRatePreset.hour:
                            resolvedFee = recommendedFees.hourFee;
                            break;
                          case BtcFeeRatePreset.halfHour:
                            resolvedFee = recommendedFees.halfHourFee;
                            break;
                          case BtcFeeRatePreset.fastest:
                            resolvedFee = recommendedFees.fastestFee;
                            break;
                        }
                      }

                      final result = _TransferShareModalResponse(
                          toAddress: toAddress, amount: amount, feeRate: resolvedFee);
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

final _v2FeeRatePresetProvider = StateProvider.autoDispose<BtcFeeRatePreset>(
  (ref) => BtcFeeRatePreset.economy,
);
