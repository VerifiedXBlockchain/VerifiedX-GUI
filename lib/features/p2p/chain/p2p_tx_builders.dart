import 'dart:convert';

import '../models/p2p_listing.dart';
import '../models/p2p_me.dart';
import '../models/p2p_shop.dart';
import '../models/p2p_tx_description.dart';
import '../utils/p2p_amount.dart';
import '../utils/p2p_rules.dart';
import 'p2p_chain_error.dart';
import 'p2p_fee_quoter.dart';

/// The shop's chain steps as descriptions: the unsigned
/// `{type, function, from_address, to_address, amount, fee, timestamp, data}`
/// of the transaction a wallet would sign, with `data` in Core's field names.
/// A description is what a dry run posts to the registry and what the
/// confirmation sheet shows. Building one signs nothing and sends nothing.
///
/// Field names and order follow Core (`SmartContractService
/// .CompleteSaleSmartContractTX`) and the web wallet's `chain.ts`, which the
/// registry's dry-run checks (`p2p/dryrun.py`) were written against.

/// Core's TransactionType for a sale step.
const int p2pTxNftSale = 5;

/// How a sale's price is paid.
class P2pSaleSplit {
  /// To the seller.
  final P2pAmount seller;

  /// To the royalty address, or null when the NFT has no royalty.
  final P2pAmount? royalty;

  const P2pSaleSplit({required this.seller, this.royalty});
}

/// How [price] is split, as Core computes it: the royalty is
/// `price × royalty amount`, rounded to the nearest 1e-8, and the seller gets
/// the rest. Core applies the contract's amount as a fraction of the price
/// whatever the contract's royalty type, so an amount of 1 or more cannot be
/// paid through a sale. Throws a [P2pChainError].
P2pSaleSplit p2pSaleSplit(P2pAmount price, P2pRoyalty? royalty) {
  if (!price.isPositive) {
    throw const P2pChainError(P2pChainFailure.priceZero);
  }
  if (royalty == null) {
    return P2pSaleSplit(seller: price);
  }
  final rate = P2pAmount.tryParse(royalty.amount);
  if (rate == null || rate.units >= P2pAmount.unitsPerVfx) {
    throw const P2pChainError(P2pChainFailure.royaltyTooHigh);
  }
  final half = P2pAmount.unitsPerVfx ~/ BigInt.two;
  final royaltyUnits = (price.units * rate.units + half) ~/ P2pAmount.unitsPerVfx;
  if (royaltyUnits <= BigInt.zero || royaltyUnits >= price.units) {
    throw const P2pChainError(P2pChainFailure.royaltyZero);
  }
  return P2pSaleSplit(
    seller: P2pAmount.fromUnits(price.units - royaltyUnits),
    royalty: P2pAmount.fromUnits(royaltyUnits),
  );
}

/// The price a started sale must be paid: `Sale_Start()`'s `SoldFor`, which
/// Core locks into the contract, else the winner's bid. Null before a win.
P2pAmount? p2pSalePrice(P2pListing listing) {
  final soldFor = listing.sale?.start?.data['SoldFor'];
  if (soldFor is String) {
    final amount = P2pAmount.tryParse(soldFor);
    if (amount != null && amount.isPositive) {
      return amount;
    }
  }
  if (soldFor is num && soldFor.isFinite && soldFor > 0) {
    return P2pAmount.fromDouble(soldFor.toDouble());
  }
  if (listing.winnerAddress == null) {
    return null;
  }
  return P2pAmount.tryParse(listing.highBid?.amount);
}

/// One payment inside `Sale_Complete()`'s `Transactions`: Core's Transaction
/// fields, unsigned, with its own `Data` as JSON text.
Future<Map<String, dynamic>> _payment({
  required P2pFeeQuoter fees,
  required int timestamp,
  required String from,
  required String to,
  required P2pAmount amount,
  required Map<String, dynamic> data,
}) async {
  final fee = await fees.quote(from: from, to: to, amount: amount, type: p2pTxNftSale, data: data, timestamp: timestamp);
  return {
    'FromAddress': from,
    'ToAddress': to,
    'Amount': amount.toJsonNumber(),
    'Fee': fee.toJsonNumber(),
    'Timestamp': timestamp,
    'TransactionType': p2pTxNftSale,
    'Data': jsonEncode(data),
  };
}

/// `Sale_Complete()`: from the buyer to the seller, moving 0 itself and
/// paying [price] through `data.Transactions`: one payment to the seller, or
/// with a royalty two, the seller's tagged "1/2" and the royalty address's
/// "2/2". Each payment and the transaction itself carry [fees]' quote.
/// Throws a [P2pChainError].
Future<P2pTxDescription> describeSaleComplete({
  required P2pFeeQuoter fees,
  required DateTime now,
  required P2pListing listing,
  required P2pAmount price,
}) async {
  final buyer = listing.winnerAddress;
  if (buyer == null) {
    throw const P2pChainError(P2pChainFailure.noWinner);
  }
  final royalty = listing.nft?.royalty;
  final split = p2pSaleSplit(price, royalty);
  final timestamp = now.millisecondsSinceEpoch ~/ 1000;
  final contract = listing.smartContractUid;
  const function = 'Sale_Complete()';

  final payments = <Map<String, dynamic>>[];
  if (royalty != null && split.royalty != null) {
    payments.add(await _payment(
      fees: fees,
      timestamp: timestamp,
      from: buyer,
      to: listing.sellerAddress,
      amount: split.seller,
      data: {
        'Function': function,
        'ContractUID': contract,
        'Royalty': true,
        'RoyaltyPaidTo': royalty.payTo,
        'RoyaltyAmount': split.royalty!.toJsonNumber(),
        'TXNum': '1/2',
      },
    ));
    payments.add(await _payment(
      fees: fees,
      timestamp: timestamp,
      from: buyer,
      to: royalty.payTo,
      amount: split.royalty!,
      data: {'Function': function, 'ContractUID': contract, 'Royalty': true, 'TXNum': '2/2'},
    ));
  } else {
    payments.add(await _payment(
      fees: fees,
      timestamp: timestamp,
      from: buyer,
      to: listing.sellerAddress,
      amount: split.seller,
      data: {'Function': function, 'ContractUID': contract},
    ));
  }

  final data = <String, dynamic>{
    'Function': function,
    'ContractUID': contract,
    'Royalty': royalty != null,
    'RoyaltyAmount': royalty == null ? null : P2pAmount.parse(royalty.amount).toJsonNumber(),
    'RoyaltyPayTo': royalty?.payTo,
    'Transactions': payments,
    'KeySign': listing.purchaseKey,
  };
  return _describe(
    fees: fees,
    timestamp: timestamp,
    type: p2pTxNftSale,
    from: buyer,
    to: listing.sellerAddress,
    amount: P2pAmount.fromUnits(BigInt.zero),
    data: data,
  );
}

/// `Sale_Start()`: from the seller to the winner, moving 0, carrying the
/// winner's bid (`SoldFor`, `BidSignature`) and the listing's purchase key.
/// Core checks the bid's signature over `{KeySign}_{SoldFor × 1e8}_{NextOwner}`
/// and locks the contract to the winner at that price. `Locators` is "NA":
/// a description asks no beacon to carry the NFT's media. Throws a
/// [P2pChainError].
Future<P2pTxDescription> describeSaleStart({
  required P2pFeeQuoter fees,
  required DateTime now,
  required P2pListing listing,
  required P2pWinningBid winner,
}) {
  final soldFor = P2pAmount.tryParse(winner.amount);
  if (soldFor == null || !soldFor.isPositive) {
    throw const P2pChainError(P2pChainFailure.priceZero);
  }
  return _describe(
    fees: fees,
    timestamp: now.millisecondsSinceEpoch ~/ 1000,
    type: p2pTxNftSale,
    from: listing.sellerAddress,
    to: winner.address,
    amount: P2pAmount.fromUnits(BigInt.zero),
    data: {
      'Function': 'Sale_Start()',
      'ContractUID': listing.smartContractUid,
      'NextOwner': winner.address,
      'SoldFor': soldFor.toJsonNumber(),
      'KeySign': listing.purchaseKey,
      'BidSignature': winner.signature,
      'Locators': 'NA',
    },
  );
}

/// `Sale_Cancel()`: from the seller to the buyer the sale was started for,
/// moving 0. It releases the contract's lock, so the NFT can be listed
/// again. The shape of Core's `CancelNFTSaleTX`. Throws a [P2pChainError].
Future<P2pTxDescription> describeSaleCancel({
  required P2pFeeQuoter fees,
  required DateTime now,
  required P2pListing listing,
}) {
  final buyer = listing.winnerAddress;
  if (buyer == null) {
    throw const P2pChainError(P2pChainFailure.noWinner);
  }
  return _describe(
    fees: fees,
    timestamp: now.millisecondsSinceEpoch ~/ 1000,
    type: p2pTxNftSale,
    from: listing.sellerAddress,
    to: buyer,
    amount: P2pAmount.fromUnits(BigInt.zero),
    data: {
      'Function': 'Sale_Cancel()',
      'ContractUID': listing.smartContractUid,
      'KeySign': listing.purchaseKey,
    },
  );
}

/// The description of a transaction with these fields, its fee quoted.
Future<P2pTxDescription> _describe({
  required P2pFeeQuoter fees,
  required int timestamp,
  required int type,
  required String from,
  required String to,
  required P2pAmount amount,
  required Map<String, dynamic> data,
}) async {
  final fee = await fees.quote(from: from, to: to, amount: amount, type: type, data: data, timestamp: timestamp);
  return P2pTxDescription(
    type: type,
    function: data['Function'] as String,
    fromAddress: from,
    toAddress: to,
    amount: amount.toDecimalString(),
    fee: fee.toDecimalString(),
    timestamp: timestamp,
    data: data,
  );
}

// DSTR: DecShopCreate(), DecShopUpdate(), DecShopDelete()

/// Core's TransactionType for a shop registration step.
const int p2pTxDstr = 7;

/// A shop's name, URL and description as its owner typed them.
class P2pShopValues {
  final String name;
  final String url;
  final String description;

  const P2pShopValues({required this.name, required this.url, required this.description});
}

/// Core's `DecShop` record for a third-party hosted shop, as the web wallet
/// sends it. Throws a [P2pChainError] when [values] are outside Core's
/// limits.
Map<String, dynamic> p2pDecShopRecord({
  required String uniqueId,
  required P2pShopValues values,
  required String owner,
  required String walletUrl,
  required String apiUrl,
}) {
  final name = values.name.trim();
  final description = values.description.trim();
  if (checkP2pShopFields(name: name, url: values.url, description: description).isNotEmpty) {
    throw const P2pChainError(P2pChainFailure.shopFields);
  }
  return {
    'UniqueId': uniqueId,
    'Name': name,
    'DecShopURL': normalizeP2pShopUrl(values.url),
    'ThirdPartyBaseURL': walletUrl,
    'ThirdPartyAPIURL': apiUrl,
    'Description': description,
    'OwnerAddress': owner,
    'HostingType': p2pShopHostingType,
    'IP': 'NA',
    'Port': 0,
    'STUNServerGroup': 0,
    'OriginalBlockHeight': 0,
    'OriginalTXHash': null,
    'LatestBlockHeight': 0,
    'LatestTXHash': null,
    'UpdateTimestamp': 0,
    'AutoUpdateNetworkDNS': true,
    'NeedsPublishToNetwork': true,
    'IsOffline': false,
    'IsPublished': true,
    'CollectionCount': 0,
    'ListingCount': 0,
    'AuctionCount': 0,
  };
}

/// `DecShopCreate()`: 10 VFX from the owner to `DecShop_Base`, with the new
/// shop's record.
Future<P2pTxDescription> describeShopCreate({
  required P2pFeeQuoter fees,
  required DateTime now,
  required String owner,
  required P2pShopValues values,
  required String walletUrl,
  required String apiUrl,
  String Function(int length)? letters,
}) {
  final timestamp = now.millisecondsSinceEpoch ~/ 1000;
  return _describe(
    fees: fees,
    timestamp: timestamp,
    type: p2pTxDstr,
    from: owner,
    to: p2pDecShopBase,
    amount: P2pAmount.parse(p2pShopCreateCost),
    data: {
      'Function': 'DecShopCreate()',
      'DecShop': p2pDecShopRecord(
        uniqueId: newP2pShopUniqueId(timestamp, letters),
        values: values,
        owner: owner,
        walletUrl: walletUrl,
        apiUrl: apiUrl,
      ),
    },
  );
}

/// What changing [shop] at [now] moves: 1 VFX within 12 hours of its last
/// change, else nothing.
P2pAmount p2pShopUpdateAmount(P2pShop shop, DateTime now) {
  final last = shop.updatedAt;
  final paid = last != null && now.toUtc().difference(last) < p2pShopFreeUpdateAfter;
  return paid ? P2pAmount.parse(p2pShopUpdateCost) : P2pAmount.fromUnits(BigInt.zero);
}

/// `DecShopUpdate()`: the shop's whole record again with its new name, URL
/// and description, from its owner.
Future<P2pTxDescription> describeShopUpdate({
  required P2pFeeQuoter fees,
  required DateTime now,
  required P2pShop shop,
  required P2pShopValues values,
  required String walletUrl,
  required String apiUrl,
}) {
  return _describe(
    fees: fees,
    timestamp: now.millisecondsSinceEpoch ~/ 1000,
    type: p2pTxDstr,
    from: shop.ownerAddress,
    to: p2pDecShopBase,
    amount: p2pShopUpdateAmount(shop, now),
    data: {
      'Function': 'DecShopUpdate()',
      'DecShop': p2pDecShopRecord(
        uniqueId: shop.uniqueId,
        values: values,
        owner: shop.ownerAddress,
        walletUrl: walletUrl,
        apiUrl: apiUrl,
      ),
    },
  );
}

/// `DecShopDelete()`: 1 VFX from the owner, naming the shop by its
/// `UniqueId`.
Future<P2pTxDescription> describeShopDelete({
  required P2pFeeQuoter fees,
  required DateTime now,
  required P2pShop shop,
}) {
  return _describe(
    fees: fees,
    timestamp: now.millisecondsSinceEpoch ~/ 1000,
    type: p2pTxDstr,
    from: shop.ownerAddress,
    to: p2pDecShopBase,
    amount: P2pAmount.parse(p2pShopDeleteCost),
    data: {'Function': 'DecShopDelete()', 'UniqueId': shop.uniqueId},
  );
}

/// A payment inside a description's data, as the confirmation sheet lists it.
class P2pInnerPayment {
  final String to;
  final P2pAmount amount;
  final P2pAmount fee;

  /// "1/2" or "2/2" on a royalty sale's payments, else null.
  final String? tag;

  const P2pInnerPayment({required this.to, required this.amount, required this.fee, this.tag});
}

P2pAmount _amountOf(Object? value) {
  if (value is String) {
    return P2pAmount.tryParse(value) ?? P2pAmount.fromUnits(BigInt.zero);
  }
  if (value is num && value.isFinite && value >= 0) {
    return P2pAmount.fromDouble(value.toDouble());
  }
  return P2pAmount.fromUnits(BigInt.zero);
}

final RegExp _txNum = RegExp(r'"TXNum":"(\d/\d)"');

/// The payments inside [tx]'s data (`Sale_Complete()`'s `Transactions`), in
/// order; empty for a step that pays nothing through its data.
List<P2pInnerPayment> p2pInnerPayments(P2pTxDescription tx) {
  final raw = tx.data['Transactions'];
  if (raw is! List) {
    return const [];
  }
  return [
    for (final entry in raw.whereType<Map>())
      P2pInnerPayment(
        to: (entry['ToAddress'] ?? '').toString(),
        amount: _amountOf(entry['Amount']),
        fee: _amountOf(entry['Fee']),
        tag: _txNum.firstMatch(entry['Data'] is String ? entry['Data'] as String : '')?.group(1),
      ),
  ];
}

/// Everything [tx] would move and every fee it would pay, inner payments
/// included.
class P2pTxTotals {
  final P2pAmount amount;
  final P2pAmount fee;

  const P2pTxTotals({required this.amount, required this.fee});

  P2pAmount get total => amount + fee;

  factory P2pTxTotals.of(P2pTxDescription tx) {
    var amount = _amountOf(tx.amount);
    var fee = _amountOf(tx.fee);
    for (final payment in p2pInnerPayments(tx)) {
      amount = amount + payment.amount;
      fee = fee + payment.fee;
    }
    return P2pTxTotals(amount: amount, fee: fee);
  }
}

/// Core's name for a transaction type a shop step uses.
String p2pTxTypeName(int type) {
  switch (type) {
    case 5:
      return 'NFT_SALE';
    case 7:
      return 'DSTR';
  }
  return type.toString();
}
