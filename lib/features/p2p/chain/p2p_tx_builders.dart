import 'dart:convert';

import '../models/p2p_listing.dart';
import '../models/p2p_tx_description.dart';
import '../utils/p2p_amount.dart';
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
  final zero = P2pAmount.fromUnits(BigInt.zero);
  final fee = await fees.quote(from: buyer, to: listing.sellerAddress, amount: zero, type: p2pTxNftSale, data: data, timestamp: timestamp);
  return P2pTxDescription(
    type: p2pTxNftSale,
    function: function,
    fromAddress: buyer,
    toAddress: listing.sellerAddress,
    amount: zero.toDecimalString(),
    fee: fee.toDecimalString(),
    timestamp: timestamp,
    data: data,
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
