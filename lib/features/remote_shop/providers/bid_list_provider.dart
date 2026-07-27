import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app.dart';
import '../../web_shop/services/web_shop_service.dart';
import '../../../core/app_constants.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/l10n_helper.dart';
import '../../dst/models/bid.dart';
import '../../dst/services/dst_service.dart';
import '../../global_loader/global_loading_provider.dart';
import '../models/shop_data.dart';
import 'connected_shop_provider.dart';
import '../services/remote_shop_service.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import 'package:collection/collection.dart';

class BidListProvider extends StateNotifier<List<Bid>> {
  final Ref ref;
  final String identifier;
  late final int listingId;
  late final int collectionId;

  BidListProvider(this.ref, this.identifier) : super([]) {
    final parts = identifier.split("_").map((p) => int.tryParse(p)).where((p) => p != null).toList();

    if (parts.length != 2) {
      print("Invalid identifier $identifier");
      return;
    }

    collectionId = parts.first!;
    listingId = parts.last!;

    fetchBids();
  }

  Future<List<Bid>> fetchBids([OrganizedListing? listing]) async {
    List<Bid> globalBids = [];
    if (listing != null) {
      globalBids = await RemoteShopService().getBidsByListingId(listing.id);

      // await RemoteShopService().getText("/GetShopListingBids/${listing.id}", cleanPath: false);
      // await Future.delayed(Duration(milliseconds: 250));
      // await ref.read(connectedShopProvider.notifier).refresh();
      // final data = ref.read(connectedShopProvider).decShop.b
    }

    final myBids = await DstService().listBuyerBids(listingId);
    // List<Bid> globalBids = listing != null ? listing.bids : [];
    final bids = [...myBids];

    for (final b in globalBids) {
      final exists = bids.firstWhereOrNull((bid) => bid.bidSignature == b.bidSignature) != null;
      if (!exists) {
        bids.add(b);
      }
    }

    bids.sort((a, b) => a.bidSendTime > b.bidSendTime ? -1 : 1);

    ref.read(connectedShopProvider.notifier).refresh(true);

    state = bids;
    return bids;
  }

  bool validateBeforeBid(OrganizedListing listing, double amount) {
    final wallet = ref.read(sessionProvider).currentWallet;

    if (wallet == null) {
      Toast.error(globalL10n.messageNoAccountSelected);
      return false;
    }

    if (wallet.balance < (amount + MIN_RBX_FOR_SC_ACTION)) {
      Toast.error(globalL10n.r3gNotEnoughBalanceDot);
      return false;
    }

    if (wallet.isValidating) {
      if (wallet.balance < (amount + MIN_RBX_FOR_SC_ACTION + ASSURED_AMOUNT_TO_VALIDATE)) {
        Toast.error(globalL10n.r3gNotEnoughBalanceValidating);
        return false;
      }
    }

    return true;
  }

  Future<bool?> buyNow(BuildContext context, OrganizedListing listing) async {
    if (!guardWalletIsSynced(ref)) {
      return null;
    }

    if (!validateBeforeBid(listing, listing.buyNowPrice!)) {
      return null;
    }

    final confirmed = await ConfirmDialog.show(
      context: rootNavigatorKey.currentContext,
      title: globalL10n.shopBuyNow,
      body: globalL10n.r3gConfirmBuyNowBody(listing.buyNowPrice.toString()),
      confirmText: globalL10n.shopBuyNow,
      cancelText: globalL10n.actionCancel,
    );

    if (confirmed != true) {
      return null;
    }
    ref.read(globalLoadingProvider.notifier).start();

    final bid = Bid.create(
      address: ref.read(sessionProvider).currentWallet!.address,
      listingId: listingId,
      collectionId: collectionId,
      bidAmount: listing.buyNowPrice!,
      maxBidAmount: listing.buyNowPrice!,
      isBuyNow: true,
      purchaseKey: listing.purchaseKey,
    );

    final success = await RemoteShopService().sendBid(bid);
    if (success) {
      ref.read(connectedShopProvider.notifier).refresh(true);
    }
    ref.read(globalLoadingProvider.notifier).complete();

    return success;
  }

  Future<bool?> sendBid(BuildContext context, OrganizedListing listing) async {
    if (!guardWalletIsSynced(ref)) {
      return null;
    }

    if (listing.auction == null) {
      Toast.error(globalL10n.mktAuctionNotLiveToast);
      return null;
    }

    if (!listing.isActive) {
      Toast.error(globalL10n.mktAuctionOverToast);
      return null;
    }

    final wallet = ref.read(sessionProvider).currentWallet;

    if (wallet == null) {
      Toast.error(globalL10n.messageNoAccountSelected);
      return null;
    }

    final minimumBid = listing.auction!.currentBidPrice + listing.auction!.incrementAmount;

    final amountStr = await PromptModal.show(
      title: globalL10n.mktPlaceBid,
      validator: (val) => formValidatorNumber(val, globalL10n.r3gBidAmount),
      labelText: globalL10n.mktBidAmountLabel,
      footer: globalL10n.r3gMustBeGreaterThanBid(minimumBid.toString()),
      confirmText: globalL10n.actionContinue,
      cancelText: globalL10n.actionCancel,
    );

    if (amountStr == null) {
      return null;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null) {
      Toast.error(globalL10n.webInvalidAmount);
      return null;
    }

    if (amount <= listing.auction!.currentBidPrice) {
      Toast.error(globalL10n.r3gBidGreaterThanHighest(listing.auction!.currentBidPrice.toString()));
      return null;
    }

    if (amount <= listing.auction!.currentBidPrice + listing.auction!.incrementAmount) {
      Toast.error(globalL10n.r3gMinIncrementAmount(
        listing.auction!.incrementAmount.toString(),
        (listing.auction!.currentBidPrice + listing.auction!.incrementAmount).toString(),
      ));
      return null;
    }

    double maxAmount = amount;

    //TODO: put this back in when autobidding is supported :)
    // final maxAmountStr = await PromptModal.show(
    //   title: "Max Bid",
    //   body: "You can set the maximum amount you are willing to bid here.",
    //   initialValue: "$amount",
    //   validator: (val) => formValidatorNumber(val, "Bid Amount"),
    //   labelText: "Bid Amount (VFX)",
    //   confirmText: "Continue",
    //   cancelText: "Cancel",
    // );

    // if (maxAmountStr != null) {
    //   maxAmount = double.tryParse(maxAmountStr) ?? maxAmount;
    // }

    // if (maxAmount < amount) {
    //   Toast.error("Max amount can not be less than the bid amount");
    //   return null;
    // }

    if (!validateBeforeBid(listing, listing.floorPrice!)) {
      return null;
    }

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: globalL10n.mktPlaceBid,
      body: globalL10n.r3gConfirmPlaceBidBody(
        amount.toString(),
        amount != maxAmount ? globalL10n.r3gMaxBidSuffix(maxAmount.toString()) : '',
      ),
      confirmText: globalL10n.mktPlaceBid,
      cancelText: globalL10n.actionCancel,
    );

    if (confirmed != true) {
      return null;
    }
    ref.read(globalLoadingProvider.notifier).start();

    final bid = Bid.create(
      address: wallet.address,
      listingId: listingId,
      collectionId: collectionId,
      bidAmount: amount,
      maxBidAmount: maxAmount,
      purchaseKey: listing.purchaseKey,
    );

    final success = await RemoteShopService().sendBid(bid);
    if (success) {
      await RemoteShopService().getBidsByListingId(listingId);
      await Future.delayed(Duration(milliseconds: 500));
      ref.read(connectedShopProvider.notifier).refresh(true);
      final url = ref.read(connectedShopProvider).url;
      if (url != null) {
        WebShopService().requestShopSync(url, delay: 10);
      }
    }
    ref.read(globalLoadingProvider.notifier).complete();

    return success;
  }
}

final bidListProvider = StateNotifierProvider.family<BidListProvider, List<Bid>, String>((ref, identifier) {
  return BidListProvider(ref, identifier);
});
