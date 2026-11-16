import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../models/p2p_auth_token.dart';
import '../models/p2p_bid_summary.dart';
import '../models/p2p_collection.dart';
import '../models/p2p_error.dart';
import '../models/p2p_listing.dart';
import '../models/p2p_me.dart';
import '../models/p2p_page.dart';
import '../models/p2p_shop.dart';
import '../models/p2p_tx_description.dart';

/// The P2P shop registry in Spyglass, `/api/p2p/` (contract: `docs/p2p.md`
/// in VerifiedX-SpyglassService). Reads are public; a write and
/// `GET /p2p/me/` send the address's sign-in token as
/// `Authorization: Bearer`. Every refusal is thrown as a [P2pError].
///
/// Nothing here reaches a node: these are plain JSON requests to Spyglass.
class P2pService extends BaseService {
  /// [hostOverride] is for tests; the app always talks to Spyglass.
  P2pService({String? hostOverride})
      : super(
          hostOverride: hostOverride ?? Env.explorerApiBaseUrl,
        );

  static Map<String, String> bearer(String token) => {'Authorization': 'Bearer $token'};

  static String _segment(Object value) => Uri.encodeComponent(value.toString());

  /// Runs [request] and reads its body with [read]. A 4xx or 5xx becomes the
  /// [P2pError] its body carries, no answer becomes [P2pError.unreachable],
  /// and a body out of shape becomes [P2pError.badResponse].
  Future<T> _call<T>(
    Future<Map<String, dynamic>> Function() request,
    T Function(Map<String, dynamic> body) read, {
    P2pError Function(DioException e) errorOf = P2pService.errorOf,
  }) async {
    final Map<String, dynamic> body;
    try {
      body = await request();
    } on DioException catch (e) {
      throw errorOf(e);
    } on FormatException catch (e) {
      throw P2pError(status: null, code: P2pError.badResponse, message: e.message);
    } on TypeError catch (e) {
      throw P2pError(status: null, code: P2pError.badResponse, message: e.toString());
    }
    try {
      return read(body);
    } on FormatException catch (e) {
      throw P2pError(status: null, code: P2pError.badResponse, message: e.message);
    } on TypeError catch (e) {
      throw P2pError(status: null, code: P2pError.badResponse, message: e.toString());
    }
  }

  /// The [P2pError] a failed request stands for.
  static P2pError errorOf(DioException e) {
    final response = e.response;
    if (response == null) {
      return P2pError(status: null, code: P2pError.unreachable, message: e.message ?? '');
    }
    dynamic body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } on FormatException {
        // Not JSON (a proxy's HTML error page, say): worded by its status.
        body = null;
      }
    }
    return P2pError.fromResponse(response.statusCode, body);
  }

  /// The [P2pError] a failed sign-in stands for. `/auth/sign-token/` is
  /// outside `/api/p2p/` and refuses in DRF's own shapes, `{"message":
  /// ["..."]}` or `["..."]`, which become [P2pError.signInRefused] with the
  /// server's words.
  static P2pError signInErrorOf(DioException e) {
    final response = e.response;
    if (response == null || response.statusCode != 400) {
      return errorOf(e);
    }
    dynamic body = response.data;
    if (body is Map && body.isNotEmpty) {
      body = body.values.first;
    }
    if (body is List && body.isNotEmpty) {
      body = body.first;
    }
    return P2pError(status: 400, code: P2pError.signInRefused, message: body is String ? body : '');
  }

  /// A read that is null when the API answers 404.
  Future<T?> _find<T>(String path, T Function(Map<String, dynamic> body) read) async {
    try {
      return await _call(() => getJson(path), read);
    } on P2pError catch (e) {
      if (e.isNotFound) {
        return null;
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _query(Map<String, Object?> params) {
    final query = <String, dynamic>{};
    params.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        query[key] = value;
      }
    });
    return query;
  }

  // Sign-in

  /// `POST /auth/sign-token/`: a one-hour token for [address], in exchange
  /// for its [signature] over a timed [message] (`p2pSignInMessage`).
  /// Spyglass accepts each message once, within 10 minutes of its time.
  Future<P2pAuthToken> signToken({
    required String address,
    required String message,
    required String signature,
  }) {
    return _call(
      () async {
        final response = await postJson(
          '/auth/sign-token/',
          params: {'address': address, 'message': message, 'signature': signature},
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pAuthToken.fromJson,
      errorOf: signInErrorOf,
    );
  }

  // Shops

  /// `GET /p2p/shops/`: live shops, newest first. [search] matches the URL
  /// or the name; [owner] is an address.
  Future<P2pPage<P2pShop>> listShops({String? search, String? owner, int page = 1, int? limit}) {
    return _call(
      () => getJson('/p2p/shops/', params: _query({'search': search?.trim(), 'owner': owner, 'page': page, 'limit': limit})),
      (body) => P2pPage.fromJson(body, P2pShop.fromJson),
    );
  }

  /// The live shop [owner] has, or null: a public read, so it needs no
  /// sign-in. An address has at most one.
  Future<P2pShop?> ownerShop(String owner) async {
    final shops = await listShops(owner: owner, limit: 1);
    return shops.results.isEmpty ? null : shops.results.first;
  }

  /// `GET /p2p/shops/{url}/`: the shop with its `collections`, or null when
  /// no shop has this URL.
  Future<P2pShop?> getShop(String url) {
    return _find('/p2p/shops/${_segment(url)}/', P2pShop.fromJson);
  }

  /// `GET /p2p/shops/available/?url=`.
  Future<P2pUrlAvailability> urlAvailability(String url) {
    return _call(
      () => getJson('/p2p/shops/available/', params: {'url': url}),
      P2pUrlAvailability.fromJson,
    );
  }

  // Collections

  /// `GET /p2p/shops/{url}/collections/`: the collections a visitor sees.
  /// With the owner's [token], the hidden ones too.
  Future<P2pPage<P2pCollection>> listCollections(String shopUrl, {String? token, int page = 1, int? limit}) {
    return _call(
      () => getJson(
        '/p2p/shops/${_segment(shopUrl)}/collections/',
        params: _query({'page': page, 'limit': limit}),
        headers: token == null ? const {} : bearer(token),
      ),
      (body) => P2pPage.fromJson(body, P2pCollection.fromJson),
    );
  }

  /// `GET /p2p/collections/{id}/`, or null when there is none to see.
  Future<P2pCollection?> getCollection(int id) {
    return _find('/p2p/collections/${_segment(id)}/', P2pCollection.fromJson);
  }

  /// `POST /p2p/shops/{url}/collections/`: a new collection in the shop of
  /// [token]'s address.
  Future<P2pCollection> createCollection({
    required String token,
    required String shopUrl,
    required String name,
    String description = '',
    bool isLive = true,
  }) {
    return _call(
      () async {
        final response = await postJson(
          '/p2p/shops/${_segment(shopUrl)}/collections/',
          params: {'name': name, 'description': description, 'is_live': isLive},
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pCollection.fromJson,
    );
  }

  /// `PATCH /p2p/collections/{id}/`: any of its name, description and
  /// whether it shows. Hiding a collection stops bids on its listings.
  Future<P2pCollection> updateCollection({
    required String token,
    required int id,
    String? name,
    String? description,
    bool? isLive,
  }) {
    return _call(
      () async {
        final response = await patchJson(
          '/p2p/collections/${_segment(id)}/',
          params: {
            if (name != null) 'name': name,
            if (description != null) 'description': description,
            if (isLive != null) 'is_live': isLive,
          },
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pCollection.fromJson,
    );
  }

  /// `DELETE /p2p/collections/{id}/`: refused for the default collection
  /// (`default_collection`) and while it has active listings
  /// (`collection_has_active_listings`).
  Future<void> deleteCollection({required String token, required int id}) async {
    try {
      await deleteJson('/p2p/collections/${_segment(id)}/', headers: bearer(token), responseIsJson: true);
    } on DioException catch (e) {
      throw errorOf(e);
    }
  }

  // Listings

  /// `GET /p2p/shops/{url}/listings/`: the shop's active listings and those
  /// sold in the last 7 days, newest first.
  Future<P2pPage<P2pListing>> listListings(
    String shopUrl, {
    int? collectionId,
    P2pListingState? state,
    int page = 1,
    int? limit,
  }) {
    return _call(
      () => getJson(
        '/p2p/shops/${_segment(shopUrl)}/listings/',
        params: _query({'collection': collectionId, 'state': state?.wire, 'page': page, 'limit': limit}),
      ),
      (body) => P2pPage.fromJson(body, P2pListing.fromJson),
    );
  }

  /// `GET /p2p/listings/{id}/`: the listing with its newest 100 `bids`, or
  /// null when there is no such listing.
  Future<P2pListing?> getListing(int id) {
    return _find('/p2p/listings/${_segment(id)}/', P2pListing.fromJson);
  }

  /// `POST /p2p/collections/{id}/listings/`: lists an NFT that [token]'s
  /// address owns. Not a transaction: the registry records the listing and
  /// gives it a purchase key.
  Future<P2pListing> createListing({required String token, required int collectionId, required P2pListingInput input}) {
    return _call(
      () async {
        final response = await postJson(
          '/p2p/collections/${_segment(collectionId)}/listings/',
          params: input.toJson(),
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pListing.fromJson,
    );
  }

  /// `PATCH /p2p/listings/{id}/`: a listing's prices and dates, while it is
  /// live with no bids (`listing_not_live`, `listing_has_bids`).
  Future<P2pListing> updateListing({required String token, required int id, required P2pListingInput input}) {
    return _call(
      () async {
        final response = await patchJson(
          '/p2p/listings/${_segment(id)}/',
          params: input.toJson(forUpdate: true),
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pListing.fromJson,
    );
  }

  /// `DELETE /p2p/listings/{id}/`: withdraws a listing before its sale
  /// starts, and returns it as `cancelled`. No transaction.
  Future<P2pListing> cancelListing({required String token, required int id}) {
    return _call(
      () async {
        final response = await deleteJson('/p2p/listings/${_segment(id)}/', headers: bearer(token), responseIsJson: true);
        return response['data'] as Map<String, dynamic>;
      },
      P2pListing.fromJson,
    );
  }

  /// `GET /p2p/listings/{id}/bids/`: every bid, newest first, a page at a time.
  Future<P2pPage<P2pBidSummary>> listBids(int listingId, {int page = 1, int? limit}) {
    return _call(
      () => getJson('/p2p/listings/${_segment(listingId)}/bids/', params: _query({'page': page, 'limit': limit})),
      (body) => P2pPage.fromJson(body, P2pBidSummary.fromJson),
    );
  }

  /// `POST /p2p/listings/{id}/bids/`: a bid, or a buy-now offer at the
  /// buy-now price exactly. The bidder is [token]'s address, and [signature]
  /// is theirs over the bid message (`p2pBidMessage`). A signed message, not
  /// a transaction.
  Future<P2pBidResult> placeBid({
    required String token,
    required int listingId,
    required String amount,
    required bool isBuyNow,
    required String signature,
  }) {
    return _call(
      () async {
        final response = await postJson(
          '/p2p/listings/${_segment(listingId)}/bids/',
          params: {'amount': amount, 'is_buy_now': isBuyNow, 'signature': signature},
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pBidResult.fromJson,
    );
  }

  /// `GET /nft/listed/{owner}/`: the ids of [owner]'s NFTs that are in an
  /// active listing of the P2P registry.
  Future<Set<String>> listedNftIds(String owner) {
    return _call(
      () => getJson('/nft/listed/${_segment(owner)}/'),
      (body) {
        final results = body['results'];
        if (results is! List) {
          throw const FormatException('A listed-NFT answer has no results');
        }
        return results.map((id) => id.toString()).toSet();
      },
    );
  }

  // Dry runs of chain steps

  /// `POST /p2p/dry-run/sale-complete/`: records [tx], the unsigned
  /// description of the buyer's `Sale_Complete()`, and returns the listing
  /// as `sold`. The registry checks it as Core would; nothing is signed or
  /// sent, and the NFT's owner on chain does not change.
  Future<P2pListing> dryRunSaleComplete({
    required String token,
    required int listingId,
    required P2pTxDescription tx,
  }) {
    return _dryRunSaleStep('/p2p/dry-run/sale-complete/', token, listingId, tx);
  }

  /// `POST /p2p/dry-run/sale-start/`: records [tx], the unsigned description
  /// of the seller's `Sale_Start()` for the winner, and returns the listing
  /// as `sale_pending`. The registry checks the winning bid's signature as
  /// Core would.
  Future<P2pListing> dryRunSaleStart({
    required String token,
    required int listingId,
    required P2pTxDescription tx,
  }) {
    return _dryRunSaleStep('/p2p/dry-run/sale-start/', token, listingId, tx);
  }

  /// `POST /p2p/dry-run/sale-cancel/`: records [tx], the unsigned description
  /// of the seller's `Sale_Cancel()` of a started sale, and returns the
  /// listing as `cancelled`.
  Future<P2pListing> dryRunSaleCancel({
    required String token,
    required int listingId,
    required P2pTxDescription tx,
  }) {
    return _dryRunSaleStep('/p2p/dry-run/sale-cancel/', token, listingId, tx);
  }

  /// `POST /p2p/dry-run/dstr/`: records [tx], the unsigned description of a
  /// `DecShopCreate()`, `DecShopUpdate()` or `DecShopDelete()`, and returns
  /// the shop as it now stands (`chain_state: dry_run`, or `deleted`).
  Future<P2pShop> dryRunDstr({required String token, required P2pTxDescription tx}) {
    return _call(
      () async {
        final response = await postJson(
          '/p2p/dry-run/dstr/',
          params: {'tx': tx.toDryRunJson()},
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pShop.fromJson,
    );
  }

  Future<P2pListing> _dryRunSaleStep(String path, String token, int listingId, P2pTxDescription tx) {
    return _call(
      () async {
        final response = await postJson(
          path,
          params: {'listing_id': listingId, 'tx': tx.toDryRunJson()},
          headers: bearer(token),
          responseIsJson: true,
        );
        return response['data'] as Map<String, dynamic>;
      },
      P2pListing.fromJson,
    );
  }

  // Mine

  /// `GET /p2p/me/`: [token]'s address's shop, listings and bids.
  Future<P2pMe> me(String token) {
    return _call(() => getJson('/p2p/me/', headers: bearer(token)), P2pMe.fromJson);
  }
}
