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
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../bridge/components/bridge_to_base_dialog.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../encrypt/utils.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../nft/services/nft_service.dart';
import '../../nft/utils.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../wallet/utils.dart';
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
import '../../price/providers/price_detail_providers.dart';
import '../../../core/utils/tx_refresh.dart';

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
    final l10n = AppLocalizations.of(context);
    final pendingIds = ref.watch(btcPendingTokenizedAddressListProvider);

    bool debuggingAddressExists = true;

    final isRa = token.rbxAddress.startsWith("xRBX");

    return Builder(
      builder: (context) {
        if (token.btcAddress == null) {
          if (pendingIds.contains(token.smartContractUid)) {
            return Center(
              child: AppBadge(
                label: l10n.tkbBtcAddressPending,
                variant: AppColorVariant.Primary,
              ),
            );
          }

          return Center(
            child: AppButton(
              label: l10n.tkbGenerateBtcAddress,
              variant: AppColorVariant.Primary,
              icon: Icons.star,
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  title: l10n.tkbGenerateBtcAddress,
                  body: l10n.tkbGenerateBtcAddressBody,
                  confirmText: l10n.tkbGenerate,
                  cancelText: l10n.actionCancel,
                );
                if (confirmed == true) {
                  ref.read(globalLoadingProvider.notifier).start();
                  final address = await BtcService()
                      .generateTokenizedBitcoinAddress(token.smartContractUid);
                  ref.read(globalLoadingProvider.notifier).complete();

                  if (address == null) {
                    return;
                  }

                  Toast.message(l10n.tkbBtcAddressGenerated(address));
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
              label: l10n.btcCopyDepositAddress,
              icon: Icons.copy,
              variant: AppColorVariant.Primary,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: token.btcAddress));
                Toast.message(l10n.btcAddressCopiedShort);
              },
            ),
            if (isOwner && token.btcAddress != null)
              AppButton(
                label: l10n.btcFundLabel,
                icon: Icons.outbox,
                onPressed: () {
                  final btcAccounts = ref
                      .watch(btcAccountListProvider)
                      .where((a) => a.balance > 0)
                      .toList();

                  bool isSending = false;
                  final parentContext = context;
                  showModalBottomSheet(
                    context: parentContext,
                    builder: (context) {
                      return ModalContainer(
                        withDecor: false,
                        withClose: true,
                        children: [
                          Text(
                            l10n.tkbFundToken,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white),
                          ),
                          ListView(
                            shrinkWrap: true,
                            children: [
                              AppCard(
                                padding: 0,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(l10n.bw2BuyBtcOnRamp),
                                  subtitle: Text(
                                      l10n.bw2BuyBtcOnRampSubtitle),
                                  trailing: Icon(Icons.credit_card),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    AccountUtils.getCoin(
                                      parentContext,
                                      ref,
                                      VfxOrBtcOption.btc,
                                      btcAddressOverride: token.btcAddress!,
                                    );
                                  },
                                ),
                              ),
                              ...btcAccounts.map((account) {
                                return AppCard(
                                  padding: 0,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(account.address),
                                    subtitle: Text("${account.balance} BTC"),
                                    trailing: Icon(Icons.send),
                                    onTap: () async {
                                      if (isSending) return;
                                      isSending = true;
                                      Navigator.of(context).pop();

                                      final amount = await PromptModal.show(
                                        title: l10n.tkbBtcAmount,
                                        validator: (v) =>
                                            formValidatorNumber(v, l10n.labelAmount),
                                        labelText: l10n.labelAmount,
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
                                          Toast.error(l10n.btcInvalidAmount);
                                          return;
                                        }

                                        if (parsedAmount <= 0) {
                                          Toast.error(
                                              l10n.tkbAmountGreaterThanZero);
                                          return;
                                        }

                                        if (parsedAmount >= account.balance) {
                                          Toast.error(
                                              l10n.tkbInsufficientBalanceAccount(account.balance.toString()));
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
                                          title: l10n.tkbConfirmTransaction,
                                          body: l10n.tkbConfirmSendBtcBody(
                                            parsedAmount.toStringAsFixed(9),
                                            account.address,
                                            token.btcAddress!,
                                            calculatedFeeRate.toStringAsFixed(8),
                                          ),
                                          confirmText: l10n.actionSend,
                                          cancelText: l10n.actionCancel,
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
                                            l10n.tkbBtcSentTo(amount, token.btcAddress!));
                                        notifyTransactionSubmitted();

                                        InfoDialog.show(
                                            title: l10n.btcTransactionBroadcastedTitle,
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
                                                        l10n.tkbTransactionHash,
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
                                                              l10n.tkbTransactionHashCopied);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  AppButton(
                                                    label:
                                                        l10n.btcOpenInExplorer,
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
                                  title: Text(l10n.btcManualSendTitle),
                                  subtitle: Text(
                                      l10n.tkbManualSendExchangeSubtitle),
                                  trailing: Icon(Icons.content_copy),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _showManualSendDialog(
                                        parentContext, token.btcAddress!);
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
              label: l10n.btcWithdrawLabel,
              icon: Icons.download,
              variant: AppColorVariant.Primary,
              onPressed: () async {
                if (isRa) {
                  Toast.error(l10n.tkbVaultCannotWithdraw);
                  return;
                }

                // V2: refresh token data and check for pending withdrawal before showing the form
                if (token.version >= 2) {
                  // Fetch fresh V2 contract data to get current withdrawal state
                  final freshContracts = await VbtcV2Service().getContractList();
                  final freshToken = freshContracts.firstWhereOrNull(
                    (t) => t.smartContractUid == token.smartContractUid,
                  );

                  if (freshToken != null && freshToken.hasPendingWithdrawal) {
                    final shouldComplete = await ConfirmDialog.show(
                      title: l10n.tkbPendingWithdrawalFound,
                      body: l10n.tkbPendingWithdrawalBody(freshToken.activeWithdrawalAmount.toString(), freshToken.activeWithdrawalBtcDestination.toString()),
                      confirmText: l10n.tkbComplete,
                      cancelText: l10n.tkbDismiss,
                    );

                    if (shouldComplete != true) return;

                    final dialogResult = await WithdrawalProcessingDialog.show(
                      scUid: token.smartContractUid,
                      requestHash: freshToken.activeWithdrawalRequestHash!,
                      ownerAddress: isOwner ? token.rbxAddress : null,
                    );

                    ref.read(tokenizedBitcoinListProvider.notifier).refresh();

                    if (dialogResult != null && dialogResult.success) {
                      ref.read(logProvider.notifier).append(
                            LogEntry(
                              message: "vBTC Withdrawal completed successfully.",
                              variant: AppColorVariant.Btc,
                            ),
                          );
                    }
                    return;
                  }
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
                    title: l10n.tkbWithdrawBtc,
                    body: l10n.tkbWithdrawBtcBody(result.amount.toString(), result.toAddress),
                  );

                  if (confirmed != true) {
                    return;
                  }

                  if (token.version >= 2) {
                    // V2: request withdrawal first, then show processing dialog
                    ref.read(globalLoadingProvider.notifier).start();
                    final withdrawResult = await VbtcV2Service().requestWithdrawal(
                      scUid: token.smartContractUid,
                      requestorAddress: token.rbxAddress,
                      btcAddress: result.toAddress,
                      amount: result.amount,
                      feeRate: result.feeRate,
                    );
                    ref.read(globalLoadingProvider.notifier).complete();

                    String? requestHash = withdrawResult.requestHash;
                    bool needsBlockConfirmation = withdrawResult.success;

                    if (!withdrawResult.success) {
                      // Fallback: parse hash from error if model data was stale
                      final message = withdrawResult.message ?? "";
                      final match = RegExp(r'Request Hash:\s*((?:0x)?[a-fA-F0-9]+)').firstMatch(message);
                      if (match != null) {
                        requestHash = match.group(1);
                        needsBlockConfirmation = false; // already in a block

                        final shouldComplete = await ConfirmDialog.show(
                          title: l10n.tkbPendingWithdrawalFound,
                          body: l10n.tkbPendingWithdrawalContractBody,
                          confirmText: l10n.tkbComplete,
                          cancelText: l10n.tkbDismiss,
                        );

                        if (shouldComplete != true) return;
                      } else {
                        Toast.error(withdrawResult.message ?? l10n.tkbFailedRequestWithdrawal);
                        return;
                      }
                    }

                    if (requestHash == null) {
                      Toast.error(l10n.tkbNoRequestHash);
                      return;
                    }

                    final dialogResult = await WithdrawalProcessingDialog.show(
                      scUid: token.smartContractUid,
                      requestHash: requestHash,
                      ownerAddress: isOwner ? token.rbxAddress : null,
                      waitForConfirmation: needsBlockConfirmation,
                    );

                    ref.read(tokenizedBitcoinListProvider.notifier).refresh();

                    if (dialogResult != null && dialogResult.success) {
                      final message = "vBTC Withdrawal completed successfully.";
                      ref.read(logProvider.notifier).append(
                            LogEntry(
                              message: message,
                              variant: AppColorVariant.Btc,
                              textToCopy: dialogResult.btcTransactionHash,
                            ),
                          );
                      notifyTransactionSubmitted();
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
                          l10n.tkbBtcWithdrawalBroadcasted(withdrawlHash);
                      Toast.message(message);

                      ref.read(logProvider.notifier).append(
                            LogEntry(
                                message: message,
                                variant: AppColorVariant.Btc,
                                textToCopy: withdrawlHash),
                          );
                      notifyTransactionSubmitted();
                    }
                  }
                }
              },
            ),
            // Force a line break after Withdraw — a full-width zero-height
            // SizedBox makes the surrounding `Wrap` start a new run.
            const SizedBox(width: double.infinity, height: 0),
            AppButton(
              label: l10n.btcTransferLabel,
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
                            l10n.btcTransferLabel,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white),
                          ),
                          AppCard(
                            padding: 0,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(l10n.tkbTransferVbtc),
                              subtitle: Text(l10n.tkbTransferVbtcSubtitle),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).pop(2);
                              },
                            ),
                          ),
                          if (isOwner)
                            AppCard(
                              padding: 0,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(l10n.tkbTransferTokenOwnership),
                                subtitle: Text(l10n.tkbTransferTokenOwnershipSubtitle),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).pop(1);
                                },
                              ),
                            ),
                          if (isOwner)
                            AppCard(
                              padding: 0,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(l10n.tkbTransferOwnershipToReserve),
                                subtitle: Text(l10n.tkbTransferOwnershipToReserveSubtitle),
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
                    Toast.error(l10n.tkbVbtcZeroBalance);
                    return;
                  }

                  if (token.version >= 2) {
                    // V2: prompt for destination address, then call VbtcV2Service
                    final toAddress = await PromptModal.show(
                      title: l10n.btcTransferOwnership,
                      labelText: l10n.tkbToVfxAddress,
                      validator: (v) =>
                          formValidatorNotEmpty(v, l10n.bw2LabelVfxAddress),
                    );

                    if (toAddress == null || toAddress.isEmpty) return;

                    final confirmed = await ConfirmDialog.show(
                      title: l10n.btcTransferOwnership,
                      body: l10n.tkbTransferOwnershipBody(toAddress),
                    );

                    if (confirmed != true) return;

                    ref.read(globalLoadingProvider.notifier).start();
                    final success = await VbtcV2Service().transferOwnership(
                      scUid: token.smartContractUid,
                      toAddress: toAddress,
                    );
                    ref.read(globalLoadingProvider.notifier).complete();

                    if (success) {
                      Toast.message(l10n.tkbOwnershipTransferInitiated);
                      ref.read(logProvider.notifier).append(
                            LogEntry(
                              message:
                                  "vBTC ownership transfer initiated to $toAddress",
                              variant: AppColorVariant.Btc,
                            ),
                          );
                      notifyTransactionSubmitted();
                      ref.read(tokenizedBitcoinListProvider.notifier).refresh();
                    }
                  } else {
                    // V1: existing NFT transfer flow
                    final nft =
                        await NftService().retrieve(token.smartContractUid);

                    if (nft == null) {
                      Toast.error(
                          l10n.tkbCouldNotResolveNft(token.smartContractUid));
                      return;
                    }
                    await initTransferNftProcess(
                      context,
                      ref,
                      nft,
                      backupRequired: false,
                      titleOverride: l10n.tkbTransferToken,
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
                      title: l10n.tkbTransferBtc,
                      body: l10n.tkbTransferVbtcBody(result.amount.toString(), result.toAddress),
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
                            l10n.tkbVbtcTransferBroadcasted(txHash);
                        Toast.message(message);

                        ref.read(logProvider.notifier).append(
                              LogEntry(
                                message: message,
                                variant: AppColorVariant.Btc,
                                textToCopy: txHash,
                              ),
                            );
                        notifyTransactionSubmitted();
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
                        Toast.message(l10n.tkbBtcTransferBroadcasted);

                        ref.read(logProvider.notifier).append(
                              LogEntry(
                                  message: message, variant: AppColorVariant.Btc),
                            );
                        notifyTransactionSubmitted();
                      }
                    }
                  }
                }

                if (option == 4) {
                  final wallets = ref
                      .read(walletListProvider)
                      .where((w) => w.isReserved)
                      .toList();
                  if (wallets.isEmpty) {
                    Toast.error(l10n.tkbNoVaultAccounts);
                    return;
                  }

                  final wallet = await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ModalContainer(
                          children: [
                            Text(l10n.tkbChooseVaultAccount),
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
                    if (token.version >= 2) {
                      // V2 tokens are media-less and must not go through the
                      // NFT/beacon transfer flow — the V2 CLI endpoint handles
                      // the ownership transfer without beacon involvement.
                      final confirmed = await ConfirmDialog.show(
                        title: "Transfer Ownership",
                        body:
                            "Are you sure you want to transfer ownership of this vBTC token to ${wallet.address}?",
                      );

                      if (confirmed != true) return;

                      ref.read(globalLoadingProvider.notifier).start();
                      final success = await VbtcV2Service().transferOwnership(
                        scUid: token.smartContractUid,
                        toAddress: wallet.address,
                      );
                      ref.read(globalLoadingProvider.notifier).complete();

                      if (success) {
                        Toast.message("Ownership transfer initiated.");
                        ref.read(logProvider.notifier).append(
                              LogEntry(
                                message:
                                    "vBTC ownership transfer initiated to ${wallet.address}",
                                variant: AppColorVariant.Btc,
                              ),
                            );
                        notifyTransactionSubmitted();
                        ref
                            .read(tokenizedBitcoinListProvider.notifier)
                            .refresh();
                      }
                    } else {
                      final nft =
                          await NftService().retrieve(token.smartContractUid);
                      if (nft == null) {
                        Toast.error(
                            l10n.tkbCouldNotResolveNft(token.smartContractUid));
                        return;
                      }
                      await initTransferNftProcess(
                        context,
                        ref,
                        nft,
                        backupRequired: false,
                        titleOverride: l10n.tkbTransferToken,
                        isToken: true,
                        prefillAddress: wallet.address,
                      );
                    }
                  }
                }
              },
            ),
            // Bridge to Base — v2 contracts only, owner only. Disabled (with
            // tooltip) when the contract has no vBTC; the dialog itself
            // handles the per-user `availableVbtc` refinement via preflight.
            if (isOwner && token.version == 2)
              Tooltip(
                message: token.balance > 0
                    ? l10n.bw2BridgeVbtcToBase
                    : l10n.bw2NoVbtcToBridge,
                child: AppButton(
                  label: l10n.bw2BridgeToBase,
                  icon: Icons.swap_horiz,
                  disabled: token.balance <= 0,
                  onPressed: () {
                    BridgeToBaseDialog.show(context, token, scOwner);
                  },
                ),
              ),
            if (isOwner)
              AppButton(
                label: l10n.btcProveOwnership,
                icon: Icons.security,
                onPressed: () {
                  proveSmartContractOwnership(
                      context, ref, token.rbxAddress, token.smartContractUid);
                },
              ),
            AppButton(
              label: l10n.btcBorrowLend,
              icon: Icons.people,
              onPressed: () {
                Toast.message(l10n.btcActionNotAvailable);
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

void _showManualSendDialog(BuildContext context, String btcAddress) {
  showDialog(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.send, color: Color(0xfff7931a)),
            SizedBox(width: 8),
            Text(l10n.bw2FundViaManualSend),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bw2ManualSendInstructions,
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                l10n.bw2DepositAddress,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xfff7931a),
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        btcAddress,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.copy, size: 18, color: Color(0xfff7931a)),
                      tooltip: l10n.txpCopyAddress,
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: btcAddress));
                        Toast.message(l10n.messageAddressCopied);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                l10n.bw2VbtcBalanceUpdateHint,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.actionClose, style: TextStyle(color: Colors.white70)),
          ),
        ],
      );
    },
  );
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
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.btcOrange;
    final btcPrice = ref.watch(btcCurrentPriceDataDetailProvider);
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
        if (!forWithdrawl) ...[
          SizedBox(height: 4),
          Builder(builder: (context) {
            final usd = btcPrice != null && token.myBalance > 0
                ? ' (\$${(token.myBalance * btcPrice).toStringAsFixed(2)} USD)'
                : '';
            return Text(
              l10n.tkbYourBalanceVbtc(token.myBalance.toString(), usd),
              style: TextStyle(color: Colors.white70, fontSize: 13),
            );
          }),
        ],
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
                    forWithdrawl ? l10n.tkbToBtcAddress : l10n.tkbToVfxAddress,
                    style: TextStyle(color: color),
                  ),
                ),
              ),
              TextFormField(
                controller: amountControlller,
                decoration: InputDecoration(
                  label: Text(
                    l10n.tkbAmountOfVbtcTo(forWithdrawl ? l10n.btcWithdrawLabel : l10n.actionSend),
                    style: TextStyle(color: color),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                ],
              ),
              if (btcPrice != null)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: amountControlller,
                  builder: (context, value, _) {
                    final amount = double.tryParse(value.text);
                    if (amount == null || amount <= 0) {
                      return SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, left: 2),
                      child: Text(
                        '\$${(amount * btcPrice).toStringAsFixed(2)} USD',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    );
                  },
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
                          leading: SizedBox(width: 100, child: Text(l10n.btcFeeRateLabel)),
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
                          l10n.tkbFeeEstimate(feeEstimate.toString(), feeEstimateBtc, fee.toString(), feeBtc),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
              if (forWithdrawl && token.version < 2) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(l10n.tkbFeeRatePerByte(BTC_WITHDRAWL_FEE_RATE.toString(), satashiToBtcLabel(BTC_WITHDRAWL_FEE_RATE))),
                ),
                Text(
                  l10n.tkbMultiSigFeeCalculated,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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

                      if (amount > token.myBalance) {
                        Toast.error(l10n.btcNotEnoughBalanceShort);
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
