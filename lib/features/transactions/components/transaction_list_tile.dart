import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/components.dart';
import '../../nft/providers/pending_sale_provider.dart';
import '../../smart_contracts/services/smart_contract_service.dart';
import '../providers/transaction_list_provider.dart';
import '../../../core/dialogs.dart';
import '../../../core/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../reserve/components/callback_button.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../models/transaction.dart';
import 'nft_data_modal.dart';
import "package:collection/collection.dart";

class TransactionListTile extends BaseStatefulComponent {
  final bool compact;
  final Transaction transaction;
  const TransactionListTile(
    this.transaction, {
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  TransactionListTileState createState() => TransactionListTileState();
}

class TransactionListTileState extends BaseComponentState<TransactionListTile> {
  bool _expanded = false;
  Future<void> _copy(String value, String name) async {
    await Clipboard.setData(
      ClipboardData(text: value),
    );
    Toast.message(globalL10n.btcLabelCopiedToast(name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Wallet? toWallet = ref.read(walletListProvider.notifier).getWallet(widget.transaction.toAddress);

    final Wallet? fromWallet = ref.read(walletListProvider.notifier).getWallet(widget.transaction.fromAddress);

    final toMe = toWallet != null;
    final fromMe = fromWallet != null;

    final bool canCallBack = widget.transaction.status == TransactionStatus.Reserved &&
        fromMe &&
        widget.transaction.amount <= 0 &&
        (widget.transaction.unlockTime != null && widget.transaction.unlockTime! > (DateTime.now().millisecondsSinceEpoch / 1000));

    // bool canSettle = widget.transaction.type == TxType.nftSale && !fromMe;
    // if (canSettle) {
    //   final data = parseNftData(widget.transaction);
    //   final function = nftDataValue(data!, "Function");
    //   if (function != "Sale_Start()") {
    //     canSettle = false;
    //   }
    // }
    // final bool canCallBack = widget.transaction.status == TransactionStatus.Reserved && fromMe && widget.transaction.amount < 0;
    // final bool canCallBack = widget.transaction.status == TransactionStatus.Reserved && fromMe;

    // final DateTime? callbackUntil = widget.transaction.unlockTime != null ?

    return AppCard(
      padding: 8,
      // margin: widget.compact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 0),
      // color: Colors.white.withOpacity(0.03),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Builder(builder: (context) {
                  if (toMe && fromMe) {
                    return const Icon(Icons.refresh);
                  }

                  if (toMe) {
                    return const Icon(Icons.move_to_inbox);
                  }

                  if (fromMe) {
                    return const Icon(Icons.outbox);
                  }

                  return const Icon(Icons.star, color: Colors.transparent);
                }),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.txpTileHashLabel(widget.transaction.hash),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        InkWell(
                          onTap: () {
                            _copy(widget.transaction.hash, "Hash");
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        if (widget.transaction.status != TransactionStatus.Fail && widget.transaction.status != TransactionStatus.Pending)
                          InkWell(
                            onTap: () async {
                              final url = "${Env.baseExplorerUrl}transaction/${widget.transaction.hash}";
                              await launchUrl(Uri.parse(url));
                            },
                            child: const Icon(
                              Icons.open_in_new,
                              size: 12,
                            ),
                          ),
                      ],
                    ),
                    // const SizedBox(height: 4),
                    if (widget.transaction.amount != 0)
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(text: l10n.txpTileAmountLabel),
                            TextSpan(
                              text: "${widget.transaction.amount} VFX",
                              style: TextStyle(
                                color: widget.transaction.amount < 0 ? Colors.red.shade500 : Theme.of(context).colorScheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.transaction.amount == 0)
                      Builder(
                        builder: (context) {
                          double? amountOverride;
                          String? ticker;
                          Color amountColor = Colors.white;

                          if (widget.transaction.type == 3) {
                            final data = parseNftData(widget.transaction);
                            if (data != null) {
                              if (nftDataValue(data, 'Function') == "TokenTransfer()") {
                                amountOverride = double.tryParse(nftDataValue(data, "Amount") ?? '');
                                ticker = nftDataValue(data, "TokenTicker");
                              } else if (nftDataValue(data, 'Function') == "TokenMint()") {
                                amountOverride = double.tryParse(nftDataValue(data, "Amount") ?? '');
                                ticker = nftDataValue(data, "TokenTicker");
                              } else if (nftDataValue(data, 'Function') == "TokenBurn()") {
                                amountOverride = double.tryParse(nftDataValue(data, "Amount") ?? '');
                                ticker = nftDataValue(data, "TokenTicker");
                                amountColor = Colors.red.shade500;
                              }
                            }
                          }

                          if (amountOverride != null) {
                            return RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(text: l10n.txpTileAmountLabel),
                                  TextSpan(
                                    text: "$amountOverride ${ticker != null ? '[$ticker]' : ''}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: amountColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SizedBox();
                        },
                      ),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(text: l10n.txpTileTypeLabel),
                          TextSpan(
                            text: widget.transaction.typeLabel,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.transaction.status != null)
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(text: l10n.txpTileStatusLabel),
                            TextSpan(
                              text: widget.transaction.statusLabel,
                              style: TextStyle(
                                color: widget.transaction.statusColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              l10n.btcToAddress(
                                  "${widget.transaction.toAddress}${toWallet != null && toWallet.friendlyName != null ? ' (${toWallet.friendlyName})' : ''}"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: widget.transaction.isToReserveAccount ? Colors.deepPurple.shade200 : null),
                            ),
                            SelectableText(
                              l10n.btcFromAddress(
                                  "${widget.transaction.fromAddress}${fromWallet != null && fromWallet.friendlyName != null ? ' (${fromWallet.friendlyName})' : ''}"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: widget.transaction.isFromReserveAccount ? Colors.deepPurple.shade200 : null),
                            ),
                            Text(
                              l10n.txpTileDateLabel(
                                  widget.transaction.parseTimeStamp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (widget.transaction.callbackUntil != null)
                              Text(
                                l10n.txpTileSettlementDateLabel(
                                    widget.transaction.parseUnlockTimeAsDate),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        )),
                        if (widget.transaction.nftData != null)
                          AppButton(
                            label: l10n.txpTileViewData,
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return NftDataModal(widget.transaction.nftData);
                                  });
                            },
                          ),
                        if (widget.transaction.type == 5) //NFT Sale
                          Builder(
                            builder: (context) {
                              if (widget.transaction.status != TransactionStatus.Success) {
                                return SizedBox.shrink();
                              }
                              final data = parseNftData(widget.transaction);
                              if (data == null) {
                                return SizedBox.shrink();
                              }
                              final func = nftDataValue(data, "Function");
                              if (func == "M_Sale_Start()") {
                                if (!toMe) {
                                  return SizedBox.shrink();
                                }

                                final scId = nftDataValue(data, "ContractUID");
                                final purchaseKey = nftDataValue(data, "KeySign");
                                final amount = nftDataValue(data, "SoldFor");

                                if (scId == null || purchaseKey == null) {
                                  return SizedBox.shrink();
                                }

                                final canPress = ref.watch(pendingSaleProvider).contains(widget.transaction.hash);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: AppButton(
                                    label: l10n.txpCompleteSale,
                                    variant: AppColorVariant.Success,
                                    onPressed: canPress
                                        ? null
                                        : () async {
                                            final confirmed = await ConfirmDialog.show(
                                              title: l10n.txpCompleteSale,
                                              body: l10n.txpCompleteSaleConfirmBody(
                                                  "$scId", "$amount"),
                                              confirmText: l10n.txpCompleteSale,
                                              cancelText: l10n.actionCancel,
                                            );

                                            if (confirmed != true) {
                                              return;
                                            }

                                            final success = await SmartContractService().completeTransferSale(purchaseKey, scId);
                                            if (success) {
                                              ref.read(pendingSaleProvider.notifier).addHash(widget.transaction.hash);
                                            }
                                          },
                                  ),
                                );
                              }

                              return SizedBox.shrink();
                            },
                          ),
                        if (widget.transaction.type == 10) //Reserve Transaction
                          Builder(builder: (context) {
                            final data = parseNftData(widget.transaction);
                            if (data == null) {
                              return SizedBox.shrink();
                            }
                            final func = nftDataValue(data, "Function");
                            if (func != "CallBack()") {
                              return SizedBox.shrink();
                            }

                            final hash = nftDataValue(data, "Hash");
                            if (hash == null) {
                              return SizedBox.shrink();
                            }

                            final originalTx = ref.watch(transactionListProvider(TransactionListType.All)).lastWhereOrNull((t) => t.hash == hash);
                            if (originalTx == null) {
                              return SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: AppButton(
                                label: l10n.txpOriginalTx,
                                variant: AppColorVariant.Warning,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(color: Colors.black, child: TransactionListTile(originalTx));
                                    },
                                  );
                                },
                              ),
                            );
                          }),
                        if (canCallBack)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // SizedBox(
                              //   width: 6,
                              // ),
                              // RecoverButton(transaction: widget.transaction),
                              // SizedBox(
                              //   width: 6,
                              // ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: CallbackButton(transaction: widget.transaction),
                              ),
                            ],
                          ),
                        // if (canSettle)
                        //   Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        //     child: AppButton(
                        //       label: "Settle",
                        //       variant: AppColorVariant.Success,
                        //       onPressed: () async {
                        //         final nftData = parseNftData(widget.transaction);
                        //         if (nftData == null) {
                        //           Toast.error("Data could not be parsed");
                        //           return;
                        //         }
                        //         final scId = nftDataValue(nftData, 'ContractUID');
                        //         final amount = nftDataValue(nftData, 'SoldFor');

                        //         if (scId == null) {
                        //           Toast.error("Could not get smart contract id");
                        //           return;
                        //         }

                        //         if (amount == null) {
                        //           Toast.error("Could not parse amount");
                        //           return;
                        //         }

                        //         final confirmed = await ConfirmDialog.show(
                        //           title: "NFT Sale Validated",
                        //           body:
                        //               "The sale for the NFT ($scId) has been validated. Would you like to finalize the transaction for $amount VFX?",
                        //           confirmText: "Complete",
                        //           cancelText: "Cancel",
                        //         );

                        //         if (confirmed == true) {
                        //           RemoteShopService().completeNftPurchase(scId).then((value) {
                        //             if (value == true) {
                        //               print("NFT Complete Sale TX Sent");
                        //               Toast.message("NFT Sale Finalization TX sent");
                        //             } else {
                        //               print("NFT Sale Error");
                        //             }
                        //           });
                        //         }
                        //       },
                        //     ),
                        //   )
                      ],
                    ),
                    if (_expanded)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.txpBlockNumber),
                              Text("${widget.transaction.height}"),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.labelFee),
                              Text("${widget.transaction.fee}"),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.txpNonce),
                              Text("${widget.transaction.nonce}"),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.txpData),
                              const Text("-"),
                            ],
                          ),
                          const Divider(),
                        ],
                      )
                  ],
                ),
              ),
              if (!widget.compact)
                Column(
                  children: [
                    IconButton(
                      icon: Icon(_expanded ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }
}
