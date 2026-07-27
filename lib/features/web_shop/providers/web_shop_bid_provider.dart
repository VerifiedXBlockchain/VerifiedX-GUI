import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/features/payment/components/on_ramp_initializer.dart';
import '../../../core/app_constants.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../../dst/models/bid.dart';
import '../../keygen/models/keypair.dart';
import '../../nft/models/nft.dart';
import '../../payment/components/onramp_purchase_details_widget.dart';
import '../../raw/raw_service.dart';
import '../../remote_shop/services/remote_shop_service.dart';
import '../../smart_contracts/features/royalty/royalty.dart';
import '../../web/utils/raw_transaction.dart';
import '../models/web_listing.dart';
import 'web_auth_token_provider.dart';
import 'web_listing_list_provider.dart';
import '../services/web_shop_service.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../../l10n/l10n_helper.dart';

import '../../global_loader/global_loading_provider.dart';

class WebBidListProvider extends StateNotifier<List<Bid>> {
  final Ref ref;
  final int listingId;

  WebBidListProvider(this.ref, this.listingId) : super([]);

  // Future<List<Bid>> fetchBids([OrganizedListing? listing]) async {
  //   List<Bid> globalBids = [];
  //   if (listing != null) {
  //     globalBids = await RemoteShopService().getBidsByListingId(listing.id);

  //   }

  //   final myBids = await DstService().listBuyerBids(listingId);

  //   final bids = [...myBids];

  //   for (final b in globalBids) {
  //     final exists = bids.firstWhereOrNull((bid) => bid.bidSignature == b.bidSignature) != null;
  //     if (!exists) {
  //       bids.add(b);
  //     }
  //   }

  //   bids.sort((a, b) => a.bidSendTime > b.bidSendTime ? -1 : 1);

  //   ref.read(connectedShopProvider.notifier).refresh(true);

  //   state = bids;
  //   return bids;
  // }

  bool? validateBeforeBid(WebListing listing, double? amount) {
    if (amount == null) {
      Toast.error();
      return false;
    }
    if (kIsWeb) {
      final balance = ref.read(webSessionProvider).balance;
      if (balance == null) {
        Toast.error(globalL10n.mktNoBalanceToast);
        return false;
      }

      if (balance < (amount + MIN_RBX_FOR_SC_ACTION)) {
        if (ALLOW_BIDS_WITHOUT_BALANCE) {
          return null;
        }
        Toast.error(globalL10n.mktNotEnoughBalanceToast);
        return false;
      }

      return true;
    }
    final wallet = ref.read(sessionProvider).currentWallet;

    if (wallet == null) {
      Toast.error(globalL10n.messageNoAccountSelected);
      return false;
    }

    if (wallet.balance < (amount + MIN_RBX_FOR_SC_ACTION)) {
      if (ALLOW_BIDS_WITHOUT_BALANCE) {
        return null;
      }

      Toast.error(globalL10n.mktNotEnoughBalanceToast);
      return false;
    }

    if (wallet.isValidating) {
      if (wallet.balance <
          (amount + MIN_RBX_FOR_SC_ACTION + ASSURED_AMOUNT_TO_VALIDATE)) {
        Toast.error(globalL10n.mktNotEnoughBalanceValidatingToast);
        return false;
      }
    }

    return true;
  }

  Future<String?> getBidSignature(
      String purchaseKey, double amount, Keypair keypair) async {
    const bidModifier = 100000000;

    final modifiedAmount = (amount * bidModifier).round();

    final message = "${purchaseKey}_${modifiedAmount}_${keypair.address}";

    print("message: $message");

    return await RawTransaction.getSignature(
        message: message,
        privateKey: keypair.private,
        publicKey: keypair.public);
  }

  Future<dynamic> buildSaleCompleteTx(
    Nft nft,
    double amount,
    String buyerAddress,
    String keySign, [
    int? timestampOverride,
    bool returnPayloadOnly = false,
    bool surpressErrors = false,
  ]) async {
    final txService = RawService();
    final keypair = ref.read(webSessionProvider).keypair;

    if (keypair == null) {
      Toast.error(globalL10n.mktNoAccountToast, surpressErrors);
      return;
    }

    final scId = nft.id;
    final currentOwnerAddress = nft.currentOwner;

    final royaltyType = nft.royalty?.type;
    final royaltyAmountBeforeConversion = nft.royalty?.amount;
    double? royaltyAmount;
    final royaltyAddress = nft.royalty?.address;

    double amountLessRoyalty = amount;

    final timestamp = timestampOverride ?? await txService.getTimestamp();
    if (timestamp == null) {
      Toast.error(globalL10n.mktCouldNotGetTimestampToast, surpressErrors);
      return false;
    }

    final nonce = await txService.getNonce(buyerAddress);
    if (nonce == null) {
      Toast.error(globalL10n.mktCouldNotGetNonceToast, surpressErrors);
      return false;
    }

    List<Map<String, dynamic>> subTxs = [];
    bool hasRoyalty = false;

    if (royaltyAmountBeforeConversion != null && royaltyAddress != null) {
      hasRoyalty = true;

      if (royaltyType == RoyaltyType.percent) {
        royaltyAmount = (royaltyAmountBeforeConversion * amount);
      } else {
        royaltyAmount = royaltyAmountBeforeConversion;
      }

      amountLessRoyalty = amount - royaltyAmount;

      final Map<String, dynamic> royaltyPayloadObj = {
        "Function": "Sale_Complete()",
        "ContractUID": scId,
        "Royalty": true,
        // "RoyaltyAmount": royaltyAmount,
        // "RoyaltyPaidTo": royaltyAddress,
        "TXNum": "2/2"
      };

      final royaltyPayload = jsonEncode(royaltyPayloadObj);

      var royaltyData = RawTransaction.buildTransaction(
        toAddress: royaltyAddress,
        fromAddress: buyerAddress,
        type: TxType.nftSale,
        amount: royaltyAmount,
        nonce: nonce,
        timestamp: timestamp,
        data: royaltyPayload,
      );

      final royaltyFee = await txService.getFee(royaltyData);
      if (royaltyFee == null) {
        Toast.error(globalL10n.mktCouldNotGetFeeToast, surpressErrors);
        return false;
      }

      royaltyData = RawTransaction.buildTransaction(
        toAddress: royaltyAddress,
        fromAddress: buyerAddress,
        type: TxType.nftSale,
        amount: royaltyAmount,
        nonce: nonce,
        timestamp: timestamp,
        data: royaltyPayload,
        fee: royaltyFee,
      );

      final royaltyHash = await txService.getHash(royaltyData);
      if (royaltyHash == null) {
        Toast.error(globalL10n.mktCouldNotGenerateHashToast, surpressErrors);
        return false;
      }

      final royaltySignature = await RawTransaction.getSignature(
        message: royaltyHash,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );
      if (royaltySignature == null) {
        Toast.error(globalL10n.webErrorSignatureGen, surpressErrors);
        return false;
      }

      final isValid = await txService.validateSignature(
        royaltyHash,
        keypair.address,
        royaltySignature,
      );

      if (!isValid) {
        Toast.error(globalL10n.webErrorSignatureInvalid, surpressErrors);
        return false;
      }

      royaltyData = RawTransaction.buildTransaction(
        toAddress: royaltyAddress,
        fromAddress: buyerAddress,
        type: TxType.nftSale,
        amount: royaltyAmount,
        nonce: nonce,
        timestamp: timestamp,
        data: royaltyPayload,
        fee: royaltyFee,
        hash: royaltyHash,
        signature: royaltySignature,
      );

      subTxs.add(royaltyData);
    }

    final Map<String, dynamic> payloadObject = hasRoyalty
        ? {
            "Function": "Sale_Complete()",
            "ContractUID": scId,
            "Royalty": true,
            "RoyaltyPaidTo": royaltyAddress,
            "RoyaltyAmount": royaltyAmount,
            "TXNum": "1/2",
          }
        : {
            "Function": "Sale_Complete()",
            "ContractUID": scId,
          };

    final payload = jsonEncode(payloadObject);

    var txData = RawTransaction.buildTransaction(
      toAddress: currentOwnerAddress,
      fromAddress: buyerAddress,
      type: TxType.nftSale,
      amount: amountLessRoyalty,
      nonce: nonce,
      timestamp: timestamp,
      data: payload,
    );

    final fee = await txService.getFee(txData);
    if (fee == null) {
      Toast.error(globalL10n.mktCouldNotGetFeeToast, surpressErrors);
      return false;
    }

    txData = RawTransaction.buildTransaction(
      toAddress: currentOwnerAddress,
      fromAddress: buyerAddress,
      type: TxType.nftSale,
      amount: amountLessRoyalty,
      nonce: nonce,
      timestamp: timestamp,
      data: payload,
      fee: fee,
    );

    final hash = await txService.getHash(txData);
    if (hash == null) {
      Toast.error(globalL10n.mktCouldNotGenerateHashToast, surpressErrors);
      return false;
    }

    final signature = await RawTransaction.getSignature(
      message: hash,
      privateKey: keypair.private,
      publicKey: keypair.public,
    );

    if (signature == null) {
      Toast.error(globalL10n.webErrorSignatureGen, surpressErrors);
      return false;
    }

    final isValid = await txService.validateSignature(
      hash,
      keypair.address,
      signature,
    );

    if (!isValid) {
      Toast.error(globalL10n.webErrorSignatureInvalid, surpressErrors);
      return false;
    }

    txData = RawTransaction.buildTransaction(
      toAddress: currentOwnerAddress,
      fromAddress: buyerAddress,
      type: TxType.nftSale,
      amount: amountLessRoyalty,
      nonce: nonce,
      timestamp: timestamp,
      data: payload,
      fee: fee,
      hash: hash,
      signature: signature,
    );

    subTxs.add(txData);

    subTxs = subTxs.reversed.toList();

    var primaryTxPayload = {
      "Function": "Sale_Complete()",
      "ContractUID": scId,
      "Royalty": hasRoyalty,
      "RoyaltyAmount": royaltyAmountBeforeConversion,
      "RoyaltyPayTo": royaltyAddress,
      "Transactions": subTxs,
      "KeySign": keySign
    };

    var primaryTxData = RawTransaction.buildTransaction(
      toAddress: currentOwnerAddress,
      fromAddress: buyerAddress,
      type: TxType.nftSale,
      amount: 0,
      nonce: nonce,
      timestamp: timestamp,
      data: primaryTxPayload,
    );

    final primaryFee = await txService.getFee(primaryTxData);
    if (primaryFee == null) {
      Toast.error(globalL10n.mktCouldNotGetFeeToast, surpressErrors);
      return false;
    }

    primaryTxData = RawTransaction.buildTransaction(
      toAddress: currentOwnerAddress,
      fromAddress: buyerAddress,
      type: TxType.nftSale,
      amount: 0,
      nonce: nonce,
      timestamp: timestamp,
      data: primaryTxPayload,
      fee: primaryFee,
    );

    final hashPrimary = await txService.getHash(primaryTxData);
    if (hashPrimary == null) {
      Toast.error(globalL10n.mktCouldNotGenerateHashToast, surpressErrors);
      return false;
    }

    final signaturePrimary = await RawTransaction.getSignature(
      message: hashPrimary,
      privateKey: keypair.private,
      publicKey: keypair.public,
    );

    if (signaturePrimary == null) {
      Toast.error(globalL10n.webErrorSignatureGen, surpressErrors);
      return false;
    }

    final isValidPrimary = await txService.validateSignature(
      hashPrimary,
      keypair.address,
      signaturePrimary,
    );

    if (!isValidPrimary) {
      Toast.error(globalL10n.mktSignatureNotValidPrimaryToast, surpressErrors);
      return false;
    }

    primaryTxData = RawTransaction.buildTransaction(
      toAddress: currentOwnerAddress,
      fromAddress: buyerAddress,
      type: TxType.nftSale,
      amount: 0,
      nonce: nonce,
      timestamp: timestamp,
      data: primaryTxPayload,
      fee: primaryFee,
      hash: hashPrimary,
      signature: signaturePrimary,
    );

    if (returnPayloadOnly) {
      return primaryTxData;
    }

    final verifyTransactionData = (await txService.sendTransaction(
      transactionData: primaryTxData,
      execute: false,
    ));

    if (verifyTransactionData == null) {
      Toast.error(globalL10n.mktCouldNotVerifyTransactionToast, surpressErrors);
      return false;
    }

    if (verifyTransactionData['Result'] != "Success") {
      print(verifyTransactionData['Message']);
      Toast.error(verifyTransactionData['Message'], surpressErrors);
      return false;
    }

    Toast.message(verifyTransactionData['Message'], surpressErrors);

    final tx = await txService.sendTransaction(
      transactionData: primaryTxData,
      execute: true,
    );

    if (tx != null) {
      if (tx['Result'] == "Success") {
        Toast.message(globalL10n.mktTxBroadcastedToast, surpressErrors);
        return true;
      }
    }

    Toast.error(globalL10n.mktProblemOccurredToast, surpressErrors);
    return false;
  }

  Future<void> waitForSaleStart(
      String nftId, String buyerAddress, double amount,
      [int attempt = 0]) async {
    print("Waiting for sale to start....");
    final nft = await ExplorerService().retrieveNft(nftId);
    if (nft != null) {
      final txs = (await ExplorerService()
              .getTransactions(address: buyerAddress, page: 1))
          .results;

      String? keySign;
      for (final t in txs) {
        if (t.type == TxType.nftSale) {
          final function = t.nftDataValue("Function");
          if (function == "Sale_Start()") {
            final scId = t.nftDataValue("ContractUID");
            print(scId);
            if (scId == nft.id) {
              final owner = t.nftDataValue("NextOwner");
              if (owner == buyerAddress) {
                keySign = t.nftDataValue("KeySign");
                if (keySign != null) {
                  break;
                }
              }
            }
          }
        }
      }

      if (keySign != null) {
        print("FOUND THE TX YO");
        buildSaleCompleteTx(nft, amount, buyerAddress, keySign);
        return;
      }
    }

    if (attempt > 20) {
      print("No TX after 20 tries. stopping watch");
      return;
    }

    await Future.delayed(Duration(seconds: 10));

    return await waitForSaleStart(nftId, buyerAddress, amount, attempt + 1);
  }

  Future<bool?> waitForBalanceToBuyNow(
      BuildContext context, WebListing listing) async {
    final balance = kIsWeb
        ? ref.read(webSessionProvider).currentWallet?.balance
        : ref.read(sessionProvider).currentWallet?.balance;

    if (balance != null) {
      final validBid = validateBeforeBid(listing, listing.buyNowPrice);
      if (validBid == true) {
        return await buyNow(context, listing);
      }

      print("still not enough balance...trying again in 10 sec");
      await Future.delayed(Duration(seconds: 5));
      return await waitForBalanceToBuyNow(context, listing);
    }

    return null;
  }

  Future<bool?> waitForBalanceToPlaceBid(
      BuildContext context, WebListing listing, double amount) async {
    final balance = kIsWeb
        ? ref.read(webSessionProvider).currentWallet?.balance
        : ref.read(sessionProvider).currentWallet?.balance;

    if (balance != null) {
      final validBid = validateBeforeBid(listing, listing.floorPrice!);
      if (validBid == true) {
        return await sendBid(context, listing, forceAmount: amount);
      }

      print("still not enough balance...trying again in 10 sec");
      await Future.delayed(Duration(seconds: 5));
      return await waitForBalanceToPlaceBid(context, listing, amount);
    }

    return null;
  }

  Future<bool?> buyNow(BuildContext context, WebListing listing) async {
    if (!kIsWeb) {
      if (!guardWalletIsSynced(ref)) {
        return null;
      }
    }

    bool? validBid = validateBeforeBid(listing, listing.buyNowPrice);

    if (validBid == null) {
      // send to on-ramp first
      final address = kIsWeb
          ? ref.read(webSessionProvider).currentWallet?.address
          : ref.read(sessionProvider).currentWallet?.address;
      if (address == null) {
        return null;
      }
      final confirmed = await ConfirmDialog.show(
        title: globalL10n.mktInsufficientBalanceTitle,
        body: globalL10n.mktBuyNowInsufficientBody(listing.buyNowPrice.toString()),
        cancelText: globalL10n.actionNo,
        confirmText: globalL10n.actionYes,
      );
      if (confirmed == true) {
        final purchaseUuid = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text(globalL10n.mktPayWithCardCryptoTitle),
                content: OnRampInitializer(
                  walletAddress: address,
                  vfxAmount: listing.buyNowPrice! + (MIN_RBX_FOR_SC_ACTION * 2),
                ),
              );
            });
        if (purchaseUuid != null && purchaseUuid is String) {
          final success = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  content: OnrampPurchaseDetailsWidget(
                    purchaseUuid: purchaseUuid,
                    targetBalance: listing.buyNowPrice!,
                  ),
                );
              });

          if (success == true) {
            return await waitForBalanceToBuyNow(context, listing);
          }
          return null;
        }
        return null;
      }

      return null;
    }

    if (!validBid) {
      return null;
    }

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: globalL10n.shopBuyNow,
      body: globalL10n.mktBuyNowConfirmBody(listing.buyNowPrice.toString()),
      confirmText: globalL10n.shopBuyNow,
      cancelText: globalL10n.actionCancel,
    );

    if (confirmed != true) {
      return null;
    }
    ref.read(globalLoadingProvider.notifier).start();

    final address = kIsWeb
        ? ref.read(webSessionProvider).keypair?.address
        : ref.read(sessionProvider).currentWallet?.address;
    if (address == null) {
      Toast.error(globalL10n.mktNoAccountToast);
      ref.read(globalLoadingProvider.notifier).complete();

      return null;
    }

    String? signature;
    String? preSignedSaleCompleteTx;

    if (kIsWeb) {
      final keypair = ref.read(webSessionProvider).keypair;
      if (keypair == null) {
        Toast.error(globalL10n.mktNoAccountToast);
        ref.read(globalLoadingProvider.notifier).complete();

        return null;
      }

      signature = await getBidSignature(
          listing.purchaseKey, listing.buyNowPrice!, keypair);

      if (signature == null) {
        Toast.error(globalL10n.mktCouldNotProduceSignatureToast);
        ref.read(globalLoadingProvider.notifier).complete();

        return null;
      }

      if (listing.nft != null) {
        final dynamic presignedTx = await buildSaleCompleteTx(
          listing.nft!.smartContract,
          listing.buyNowPrice!,
          address,
          listing.purchaseKey,
          listing.endDate.millisecondsSinceEpoch.round(),
          true,
          false,
        );

        if (presignedTx == null) {
          Toast.error(globalL10n.mktPresignProblemToast);
          return null;
        }

        if (presignedTx != null) {
          if (presignedTx is Map) {
            preSignedSaleCompleteTx = jsonEncode(presignedTx);
          }
        }
      }
    }

    final success = await WebShopService()
        .sendBid(
      amount: listing.buyNowPrice!,
      address: address,
      listingId: listing.id,
      isBuyNow: true,
      signature: signature,
      preSignedSaleCompleteTx: preSignedSaleCompleteTx,
    )
        .catchError(
      (e) {
        Toast.error();
        ref.read(globalLoadingProvider.notifier).complete();
        return false;
      },
    );

    if (kIsWeb) {
      if (success) {
        // Future.delayed(Duration(seconds: 10)).then((_) {
        //   waitForSaleStart(listing.nft!.smartContract.id, address, listing.buyNowPrice!);
        // });
        Toast.message(globalL10n.mktBuyNowTxBroadcastedToast);

        ref.read(globalLoadingProvider.notifier).complete();
        String body = globalL10n.mktWaitForFinalizeBody;
        if (listing.collection.shop!.isThirdParty) {
          body += "\n${globalL10n.mktThirdPartySaleStartNote}";
        }
        InfoDialog.show(
            contextOverride: context,
            title: globalL10n.mktBuyNowTxBroadcastedTitle,
            body: body);
      }
    } else {
      final coreBid = Bid.create(
        address: address,
        listingId: listingId,
        collectionId: listing.collection.id,
        bidAmount: listing.buyNowPrice!,
        maxBidAmount: listing.buyNowPrice!,
        purchaseKey: listing.purchaseKey,
        isBuyNow: true,
        bidStatus: success ? BidStatus.Rejected : BidStatus.Accepted,
      );

      final bidSaved = await RemoteShopService().sendBid(coreBid, listing.id);
      ref
          .read(webListingListProvider(
                  "${listing.collection.shop?.id},${listing.collection.id}")
              .notifier)
          .refresh();
      ref.read(globalLoadingProvider.notifier).complete();

      return bidSaved && success;
    }

    return success;
  }

  Future<bool?> sendBid(BuildContext context, WebListing listing,
      {double? forceAmount}) async {
    if (!kIsWeb) {
      if (!guardWalletIsSynced(ref)) {
        return null;
      }
    }

    if (listing.auction == null) {
      Toast.error(globalL10n.mktAuctionNotLiveToast);
      return null;
    }

    if (!listing.isActive) {
      Toast.error(globalL10n.mktAuctionOverToast);
      return null;
    }

    final address = kIsWeb
        ? ref.read(webSessionProvider).keypair?.address
        : ref.read(sessionProvider).currentWallet?.address;

    if (address == null) {
      Toast.error(globalL10n.adnrNoAccountToast);
      return null;
    }

    final minimumBid =
        (listing.auction?.currentBidPrice ?? listing.floorPrice!) +
            (listing.auction?.incrementAmount ?? 0.01);

    double? amount = 0;

    if (forceAmount == null) {
      final amountStr = await PromptModal.show(
        contextOverride: context,
        title: globalL10n.mktPlaceBid,
        validator: (val) => formValidatorNumber(val, "Bid Amount"),
        labelText: globalL10n.mktBidAmountLabel,
        footer: globalL10n.mktBidMustBeGreaterFooter(minimumBid.toString()),
        confirmText: globalL10n.actionContinue,
        cancelText: globalL10n.actionCancel,
      );

      if (amountStr == null) {
        return null;
      }

      amount = double.tryParse(amountStr);
      if (amount == null) {
        Toast.error(globalL10n.webInvalidAmount);
        return null;
      }

      if (listing.auction == null) {
        Toast.error(globalL10n.mktNoAuctionToast);
        return null;
      }
    } else {
      amount = forceAmount;
    }

    if (amount <= listing.auction!.currentBidPrice!) {
      Toast.error(globalL10n
          .mktBidMustBeGreaterToast(listing.auction!.currentBidPrice.toString()));
      return null;
    }

    if (amount <=
        listing.auction!.currentBidPrice! + listing.auction!.incrementAmount) {
      Toast.error(globalL10n.mktBidIncrementToast(
        listing.auction!.incrementAmount.toString(),
        (listing.auction!.currentBidPrice! + listing.auction!.incrementAmount)
            .toString(),
      ));
      return null;
    }

    bool? validBid = validateBeforeBid(listing, amount);

    if (validBid == null) {
      // send to on-ramp first
      final address = kIsWeb
          ? ref.read(webSessionProvider).currentWallet?.address
          : ref.read(sessionProvider).currentWallet?.address;
      if (address == null) {
        return null;
      }
      final confirmed = await ConfirmDialog.show(
        title: globalL10n.mktInsufficientBalanceTitle,
        body: globalL10n.mktBidInsufficientBody,
        cancelText: globalL10n.actionNo,
        confirmText: globalL10n.actionYes,
      );
      if (confirmed == true) {
        final purchaseUuid = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text(globalL10n.mktPayWithCardCryptoTitle),
                content: OnRampInitializer(
                  walletAddress: address,
                  vfxAmount: amount! + (MIN_RBX_FOR_SC_ACTION * 2),
                ),
              );
            });
        if (purchaseUuid != null && purchaseUuid is String) {
          final success = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  content: OnrampPurchaseDetailsWidget(
                    purchaseUuid: purchaseUuid,
                    targetBalance: amount!,
                  ),
                );
              });

          if (success == true) {
            return await waitForBalanceToPlaceBid(context, listing, amount);
          }
          return null;
        }
        return null;
      }

      return null;
    }

    if (!validBid) {
      return null;
    }

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: globalL10n.mktPlaceBid,
      body: globalL10n.mktPlaceBidConfirmBody(amount.toString()),
      confirmText: globalL10n.mktPlaceBid,
      cancelText: globalL10n.actionCancel,
    );

    if (confirmed != true) {
      return null;
    }
    ref.read(globalLoadingProvider.notifier).start();

    String? signature;
    String? preSignedSaleCompleteTx;
    if (kIsWeb) {
      final keypair = ref.read(webSessionProvider).keypair;
      if (keypair == null) {
        ref.read(globalLoadingProvider.notifier).complete();
        Toast.error(globalL10n.mktNoAccountToast);
        return null;
      }

      signature = await getBidSignature(listing.purchaseKey, amount, keypair);

      if (signature == null) {
        Toast.error(globalL10n.mktCouldNotProduceSignatureToast);
        ref.read(globalLoadingProvider.notifier).complete();
        return null;
      }
      if (listing.nft != null) {
        final dynamic presignedTx = await buildSaleCompleteTx(
          listing.nft!.smartContract,
          amount,
          address,
          listing.purchaseKey,
          listing.endDate.millisecondsSinceEpoch.round(),
          true,
          true,
        );

        if (presignedTx == null) {
          Toast.error(globalL10n.mktPresignProblemToast);
          return null;
        }

        if (presignedTx != null) {
          if (presignedTx is Map) {
            preSignedSaleCompleteTx = jsonEncode(presignedTx);
          }
        }
      }
    }

    bool success = await WebShopService()
        .sendBid(
      amount: amount,
      address: address,
      listingId: listing.id,
      isBuyNow: false,
      signature: signature,
      preSignedSaleCompleteTx: preSignedSaleCompleteTx,
    )
        .catchError((e) {
      Toast.error();
      ref.read(globalLoadingProvider.notifier).complete();
      return false;
    });

    if (kIsWeb) {
      //TODO: web
    } else {
      final coreBid = Bid.create(
        address: address,
        listingId: listingId,
        collectionId: listing.collection.id,
        bidAmount: amount,
        maxBidAmount: amount,
        purchaseKey: listing.purchaseKey,
        isBuyNow: false,
        bidStatus: success ? BidStatus.Rejected : BidStatus.Accepted,
      );

      success =
          success && await RemoteShopService().sendBid(coreBid, listing.id);
    }

    if (success) {
      if (kIsWeb) {
        final authenticated =
            await guardWebAuthorizedFromProvider(ref, address);
        print("authenticated: $authenticated");
        if (authenticated) {
          final currentEmail = ref.read(webAuthTokenProvider)?.email;
          print("currentEmail: $currentEmail");
          if (currentEmail == null) {
            String? email = await PromptModal.show(
              contextOverride: context,
              title: globalL10n.mktSubscribeUpdatesTitle,
              body: globalL10n.mktSubscribeUpdatesBody,
              validator: formValidatorEmail,
              labelText: globalL10n.keygenEmailAddressTitle,
            );

            email = email?.trim();

            if (email == null || email.isEmpty) {
              Toast.error(globalL10n.mktNotNotifiedToast);
            } else {
              final subscribed =
                  await WebShopService().createContact(email, address);
              if (subscribed) {
                ref.read(webAuthTokenProvider.notifier).addEmail(email);
                Toast.message(globalL10n.mktSubscribedToast);
              }
            }
          }
        }
      }
      ref
          .read(webListingListProvider(
                  "${listing.collection.shop?.id},${listing.collection.id}")
              .notifier)
          .refresh();
      Toast.message(globalL10n.mktBidSubmittedToast);
    } else {
      Toast.error();
    }
    ref.read(globalLoadingProvider.notifier).complete();

    return success;
  }
}

final webBidListProvider =
    StateNotifierProvider.family<WebBidListProvider, List<Bid>, int>(
        (ref, listingId) {
  return WebBidListProvider(ref, listingId);
});
