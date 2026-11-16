import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_chain_error.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_tx_builders.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_tx_description.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';

import 'p2p_test_helpers.dart';

void main() {
  const seller = 'xJwSHB75g85bfhPLBFJ7JS1QzkDRhNJksJ';
  const buyer = 'xBidderAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  final now = DateTime.utc(2026, 11, 16, 17);
  final timestamp = now.millisecondsSinceEpoch ~/ 1000;

  /// The fixture's started sale: 5 VFX, a 2% royalty to the seller's address.
  P2pListing pending([Map<String, dynamic> changes = const {}]) {
    return P2pListing.fromJson({...p2pFixture('listing_sale_pending'), ...changes});
  }

  P2pFailureMatcher fails(P2pChainFailure failure) => P2pFailureMatcher(failure);

  group('p2pSaleSplit', () {
    final royalty = P2pRoyalty(amount: '0.02', payTo: 'xArtist');

    test('without a royalty the seller gets the whole price', () {
      final split = p2pSaleSplit(P2pAmount.parse('5'), null);
      expect(split.seller.toDecimalString(), '5');
      expect(split.royalty, isNull);
    });

    test('a royalty is price × amount and the seller gets the rest, to the unit', () {
      final split = p2pSaleSplit(P2pAmount.parse('5'), royalty);
      expect(split.royalty!.toDecimalString(), '0.1');
      expect(split.seller.toDecimalString(), '4.9');
      expect(split.seller + split.royalty!, P2pAmount.parse('5'));
    });

    test('the royalty is rounded to the nearest 1e-8 and the two still add up to the price', () {
      // 0.00000333 × 0.075 = 0.00000024975: 25 units, rounding half up.
      final price = P2pAmount.parse('0.00000333');
      final split = p2pSaleSplit(price, P2pRoyalty(amount: '0.075', payTo: 'xArtist'));
      expect(split.royalty!.units, BigInt.from(25));
      expect(split.seller.units, BigInt.from(308));
      expect(split.seller + split.royalty!, price);
    });

    test('a price that is not above zero is refused', () {
      expect(() => p2pSaleSplit(P2pAmount.fromUnits(BigInt.zero), null), throwsA(fails(P2pChainFailure.priceZero)));
    });

    test('a royalty amount of 1 or more cannot be paid through a sale', () {
      for (final amount in ['1', '2', '12.5', 'lots']) {
        expect(
          () => p2pSaleSplit(P2pAmount.parse('5'), P2pRoyalty(amount: amount, payTo: 'xArtist')),
          throwsA(fails(P2pChainFailure.royaltyTooHigh)),
          reason: amount,
        );
      }
    });

    test('a royalty that rounds to nothing is refused: every sale payment is above zero', () {
      expect(
        () => p2pSaleSplit(P2pAmount.parse('0.00000001'), royalty),
        throwsA(fails(P2pChainFailure.royaltyZero)),
      );
    });
  });

  group('p2pSalePrice', () {
    test('is the started sale\'s SoldFor, as a string or a number', () {
      expect(p2pSalePrice(pending())!.toDecimalString(), '5');

      final json = p2pFixture('listing_sale_pending');
      (((json['sale'] as Map)['start'] as Map)['data'] as Map)['SoldFor'] = 4.25;
      expect(p2pSalePrice(P2pListing.fromJson(json))!.toDecimalString(), '4.25');
    });

    test('before the sale starts it is the winner\'s bid', () {
      final won = pending({'state': 'awaiting_sale_start', 'sale': {'start': null, 'complete': null}});
      expect(p2pSalePrice(won)!.toDecimalString(), '5');
    });

    test('is null before there is a winner', () {
      expect(p2pSalePrice(P2pListing.fromJson(p2pFixture('listing_auction_live'))), isNull);
    });
  });

  group('describeSaleComplete', () {
    test('with a royalty: two payments from the buyer, the seller\'s tagged 1/2 and the royalty\'s 2/2', () async {
      final fees = FakeP2pFeeQuoter('0.00002');
      final tx = await describeSaleComplete(fees: fees, now: now, listing: pending(), price: P2pAmount.parse('5'));

      expect(tx.type, 5);
      expect(tx.function, 'Sale_Complete()');
      expect(tx.fromAddress, buyer);
      expect(tx.toAddress, seller);
      // The transaction itself moves nothing: the price is in its payments.
      expect(tx.amount, '0');
      expect(tx.fee, '0.00002');
      expect(tx.timestamp, timestamp);

      final data = tx.data;
      expect(data['Function'], 'Sale_Complete()');
      expect(data['ContractUID'], '0b6ea1abd1da425fab80029f8f20944c:1794213169');
      expect(data['KeySign'], 'KlMnOpQrSt1794843000');
      expect(data['Royalty'], isTrue);
      // The contract's own amount and address, which the registry compares.
      expect(data['RoyaltyAmount'], 0.02);
      expect(data['RoyaltyPayTo'], seller);

      final payments = (data['Transactions'] as List).cast<Map<String, dynamic>>();
      expect(payments, hasLength(2));
      for (final payment in payments) {
        expect(payment['FromAddress'], buyer);
        expect(payment['TransactionType'], 5);
        expect(payment['Timestamp'], timestamp);
        expect(payment['Fee'], 0.00002);
        expect(payment['Data'], isA<String>());
      }
      final toSeller = payments[0];
      expect(toSeller['ToAddress'], seller);
      expect(toSeller['Amount'], 4.9);
      expect(jsonDecode(toSeller['Data'] as String), {
        'Function': 'Sale_Complete()',
        'ContractUID': '0b6ea1abd1da425fab80029f8f20944c:1794213169',
        'Royalty': true,
        'RoyaltyPaidTo': seller,
        'RoyaltyAmount': 0.1,
        'TXNum': '1/2',
      });
      final toRoyalty = payments[1];
      expect(toRoyalty['ToAddress'], seller);
      expect(toRoyalty['Amount'], 0.1);
      expect(jsonDecode(toRoyalty['Data'] as String)['TXNum'], '2/2');

      // A fee was quoted for each payment and then for the whole
      // transaction, which carries the payments in its data.
      expect(fees.quoted, hasLength(3));
      expect(fees.quoted.last['amount'], '0');
      expect((fees.quoted.last['data'] as Map)['Transactions'], hasLength(2));
    });

    test('without a royalty: one payment of the whole price to the seller', () async {
      final json = p2pFixture('listing_sale_pending');
      (json['nft'] as Map)['royalty'] = null;
      final tx = await describeSaleComplete(fees: FakeP2pFeeQuoter(), now: now, listing: P2pListing.fromJson(json), price: P2pAmount.parse('5'));

      expect(tx.data['Royalty'], isFalse);
      expect(tx.data['RoyaltyAmount'], isNull);
      expect(tx.data['RoyaltyPayTo'], isNull);
      final payment = (tx.data['Transactions'] as List).single as Map<String, dynamic>;
      expect(payment['ToAddress'], seller);
      // A whole amount is written as an integer.
      expect(payment['Amount'], 5);
      expect(jsonDecode(payment['Data'] as String), {'Function': 'Sale_Complete()', 'ContractUID': json['smart_contract_uid']});
    });

    test('meets what the registry checks of a dry-run Sale_Complete', () async {
      // p2p/dryrun.py _check_payments, for the fixture's 5 VFX sale at 2%.
      final listing = pending();
      final tx = await describeSaleComplete(fees: FakeP2pFeeQuoter(), now: now, listing: listing, price: P2pAmount.parse('5'));
      final payments = p2pInnerPayments(tx);
      final toSeller = payments.singleWhere((p) => p.tag == '1/2');
      final toPayee = payments.singleWhere((p) => p.tag == '2/2');
      expect(toSeller.to, listing.sellerAddress);
      expect(toPayee.to, listing.nft!.royalty!.payTo);
      expect(toSeller.amount.isPositive && toPayee.amount.isPositive, isTrue);
      // The payments cover the price (the registry allows 1 VFX less).
      expect(toSeller.amount + toPayee.amount, P2pAmount.parse('5'));
    });

    test('a listing with no winner has nobody to pay from', () async {
      await expectLater(
        describeSaleComplete(fees: FakeP2pFeeQuoter(), now: now, listing: pending({'winner_address': null}), price: P2pAmount.parse('5')),
        throwsA(fails(P2pChainFailure.noWinner)),
      );
    });

    test('a fee that cannot be quoted stops the description', () async {
      final fees = FakeP2pFeeQuoter()..error = const P2pChainError(P2pChainFailure.feeUnavailable);
      await expectLater(
        describeSaleComplete(fees: fees, now: now, listing: pending(), price: P2pAmount.parse('5')),
        throwsA(fails(P2pChainFailure.feeUnavailable)),
      );
    });
  });

  group('what a description would take', () {
    test('adds the payments inside it and every fee', () async {
      final tx = await describeSaleComplete(fees: FakeP2pFeeQuoter('0.00002'), now: now, listing: pending(), price: P2pAmount.parse('5'));
      final totals = P2pTxTotals.of(tx);
      expect(totals.amount.toDecimalString(), '5');
      expect(totals.fee.toDecimalString(), '0.00006');
      expect(totals.total.toDecimalString(), '5.00006');
    });

    test('a step with no payments inside is just its own amount and fee', () {
      final tx = P2pTxDescription(type: 7, function: 'DecShopCreate()', fromAddress: 'xOwner', toAddress: 'DecShop_Base', amount: '10', fee: '0.00003', timestamp: timestamp);
      expect(p2pInnerPayments(tx), isEmpty);
      expect(P2pTxTotals.of(tx).total.toDecimalString(), '10.00003');
    });

    test('names the transaction types the shop uses', () {
      expect(p2pTxTypeName(5), 'NFT_SALE');
      expect(p2pTxTypeName(7), 'DSTR');
      expect(p2pTxTypeName(99), '99');
    });
  });

  test('a description is posted as the eight fields the registry reads', () async {
    final tx = await describeSaleComplete(fees: FakeP2pFeeQuoter(), now: now, listing: pending(), price: P2pAmount.parse('5'));
    final json = tx.toDryRunJson();
    expect(json.keys, ['type', 'function', 'from_address', 'to_address', 'amount', 'fee', 'timestamp', 'data']);
    // It survives the trip to JSON: nothing in it is a Dart-only value.
    expect(jsonDecode(jsonEncode(json))['data']['Transactions'], hasLength(2));
  });
}

/// Matches a [P2pChainError] with a given failure.
class P2pFailureMatcher extends Matcher {
  final P2pChainFailure failure;

  const P2pFailureMatcher(this.failure);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) => item is P2pChainError && item.failure == failure;

  @override
  Description describe(Description description) => description.add('a P2pChainError(${failure.name})');
}
