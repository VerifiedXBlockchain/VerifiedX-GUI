import '../models/p2p_listing.dart';
import '../models/p2p_shop.dart';
import '../models/p2p_tx_description.dart';
import '../services/p2p_service.dart';
import '../services/p2p_session.dart';
import 'p2p_chain_error.dart';
import 'p2p_fee_quoter.dart';
import 'p2p_tx_builders.dart';

/// The shop's steps that are transactions on chain. Each is described first
/// (so the person sees the whole transaction before agreeing) and then
/// carried out.
///
/// There are to be two implementations, chosen by `Env.p2pBroadcast`: the
/// dry run here, which posts the description to the registry and signs and
/// sends nothing, and one that signs and sends through Core, written once
/// testnet's audit hold is lifted. The screens are the same for both.
abstract class P2pChainSteps {
  /// Whether steps are recorded as dry runs instead of being sent.
  bool get isDryRun;

  /// The `Sale_Complete()` that pays for [listing], whose sale has started
  /// for the buyer. Throws a [P2pChainError] when there is nothing to pay or
  /// Core would refuse it.
  Future<P2pTxDescription> describeCompletePurchase(P2pListing listing);

  /// Carries out the described purchase and returns the listing as it now
  /// stands. Throws a `P2pError`, a `P2pSigningError` or a
  /// `P2pSignInMismatch`.
  Future<P2pListing> completePurchase(P2pListing listing, P2pTxDescription tx);

  /// The `DecShopCreate()` that registers a shop for [owner].
  Future<P2pTxDescription> describeRegisterShop(String owner, P2pShopValues values);

  /// The `DecShopUpdate()` that gives [shop] a new name, URL or description.
  Future<P2pTxDescription> describeUpdateShop(P2pShop shop, P2pShopValues values);

  /// The `DecShopDelete()` that removes [shop].
  Future<P2pTxDescription> describeDeleteShop(P2pShop shop);

  /// Carries out a described shop step (create, update or delete) and
  /// returns the shop as it now stands.
  Future<P2pShop> sendShopStep(P2pTxDescription tx);
}

/// Every step as a dry run: the unsigned description goes to the registry's
/// `/p2p/dry-run/*` with the sender's sign-in token, and the registry
/// applies what its indexer would apply for the real transaction, marked
/// `dry_run`. Nothing is signed into a transaction and nothing reaches a
/// node; the fee in a description is Core's quote, a calculation.
class P2pDryRunChainSteps implements P2pChainSteps {
  final P2pService _service;
  final P2pSession _session;
  final P2pFeeQuoter _fees;
  final DateTime Function() _now;

  /// What a shop's record names as its host (`Env.p2pShopWalletUrl`,
  /// `Env.p2pShopApiUrl`).
  final String _walletUrl;
  final String _apiUrl;

  P2pDryRunChainSteps({
    required P2pService service,
    required P2pSession session,
    required P2pFeeQuoter fees,
    required String walletUrl,
    required String apiUrl,
    DateTime Function()? now,
  })  : _service = service,
        _session = session,
        _fees = fees,
        _walletUrl = walletUrl,
        _apiUrl = apiUrl,
        _now = now ?? DateTime.now;

  @override
  bool get isDryRun => true;

  @override
  Future<P2pTxDescription> describeCompletePurchase(P2pListing listing) {
    final price = p2pSalePrice(listing);
    if (price == null) {
      throw const P2pChainError(P2pChainFailure.noWinner);
    }
    return describeSaleComplete(fees: _fees, now: _now(), listing: listing, price: price);
  }

  @override
  Future<P2pListing> completePurchase(P2pListing listing, P2pTxDescription tx) {
    return _session.withToken(
      tx.fromAddress,
      (token) => _service.dryRunSaleComplete(token: token, listingId: listing.id, tx: tx),
    );
  }

  @override
  Future<P2pTxDescription> describeRegisterShop(String owner, P2pShopValues values) {
    return describeShopCreate(fees: _fees, now: _now(), owner: owner, values: values, walletUrl: _walletUrl, apiUrl: _apiUrl);
  }

  @override
  Future<P2pTxDescription> describeUpdateShop(P2pShop shop, P2pShopValues values) {
    return describeShopUpdate(fees: _fees, now: _now(), shop: shop, values: values, walletUrl: _walletUrl, apiUrl: _apiUrl);
  }

  @override
  Future<P2pTxDescription> describeDeleteShop(P2pShop shop) {
    return describeShopDelete(fees: _fees, now: _now(), shop: shop);
  }

  @override
  Future<P2pShop> sendShopStep(P2pTxDescription tx) {
    return _session.withToken(tx.fromAddress, (token) => _service.dryRunDstr(token: token, tx: tx));
  }
}
