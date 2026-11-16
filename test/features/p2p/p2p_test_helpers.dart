import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/encrypt/providers/password_required_provider.dart';
import 'package:rbx_wallet/features/p2p/chain/p2p_fee_quoter.dart';
import 'package:rbx_wallet/features/p2p/components/p2p_parts.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_auth_token.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_bid_summary.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_collection.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_me.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_owned_nft.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_tx_description.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_listing_providers.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_seller_providers.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_session_provider.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_email_prompt.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_nft_source.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_amount.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

/// The decoded body of `test/features/p2p/fixtures/[name].json`.
Map<String, dynamic> p2pFixture(String name) {
  return jsonDecode(File('test/features/p2p/fixtures/$name.json').readAsStringSync()) as Map<String, dynamic>;
}

class P2pRecordedRequest {
  final String method;
  final Uri uri;
  final String? authorization;
  final dynamic body;

  P2pRecordedRequest(this.method, this.uri, this.authorization, this.body);

  String get path => uri.path;
}

class P2pCannedResponse {
  final int status;
  final Object? body;

  const P2pCannedResponse(this.status, [this.body]);
}

/// A loopback HTTP server standing in for Spyglass. Each request is recorded
/// and answered by [respond].
class P2pTestServer {
  final HttpServer _server;
  final List<P2pRecordedRequest> requests = [];
  P2pCannedResponse Function(P2pRecordedRequest request) respond;

  P2pTestServer._(this._server, this.respond);

  static Future<P2pTestServer> start([P2pCannedResponse Function(P2pRecordedRequest request)? respond]) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = P2pTestServer._(server, respond ?? (_) => const P2pCannedResponse(200, {}));
    server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      final recorded = P2pRecordedRequest(
        request.method,
        request.uri,
        request.headers.value(HttpHeaders.authorizationHeader),
        raw.isEmpty ? null : jsonDecode(raw),
      );
      fake.requests.add(recorded);
      final answer = fake.respond(recorded);
      request.response.statusCode = answer.status;
      if (answer.body is String) {
        request.response.headers.contentType = ContentType.html;
        request.response.write(answer.body);
      } else if (answer.body != null) {
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(answer.body));
      }
      await request.response.close();
    });
    return fake;
  }

  /// Answers every request with [status] and [body].
  void always(int status, [Object? body]) {
    respond = (_) => P2pCannedResponse(status, body);
  }

  String get host => 'http://${_server.address.host}:${_server.port}';

  Future<void> close() => _server.close(force: true);
}

/// A signer that records what it was asked to sign and answers [signature],
/// or throws [error] when one is set.
class FakeP2pSigner implements P2pMessageSigner {
  final List<List<String>> signed = [];
  String signature;
  Object? error;

  /// Completes before each signature is returned, to hold a sign-in open.
  Future<void>? gate;

  FakeP2pSigner([this.signature = 'SIG.KEY']);

  @override
  Future<String> sign(String message, String address) async {
    signed.add([message, address]);
    if (gate != null) {
      await gate;
    }
    if (error != null) {
      throw error!;
    }
    return signature;
  }
}

/// A wallet session with [address] selected that never launches the CLI.
class StubP2pSession extends SessionProvider {
  StubP2pSession(Ref ref, {String? address, double balance = 100})
      : super(
          ref,
          SessionModel(
            cliStarted: true,
            currentWallet: address == null ? null : Wallet(id: 1, publicKey: 'pub', address: address, balance: balance, isValidating: false),
          ),
        );

  @override
  Future<void> init(bool inLoop) async {}
}

/// The wallet's lock state without the node: [check] asks nothing. The
/// real provider's 10-second timer still runs and may fire after a test has
/// disposed its container, so [check] reads no state once disposed.
class StubPasswordRequired extends PasswordRequiredProvider {
  @override
  Future<bool> check() async => mounted && state;
}

/// The registry, answered from memory. Each method records its call in
/// [calls] and answers from the matching field, or throws [error] when set.
class FakeP2pService extends P2pService {
  final List<String> calls = [];
  Object? error;

  P2pPage<P2pShop> Function(String search, int page) shops = (_, __) => const P2pPage(count: 0, next: null, results: []);
  Map<String, P2pShop> shopsByUrl = {};
  P2pPage<P2pListing> Function(String url, int? collectionId, int page) listings = (_, __, ___) => const P2pPage(count: 0, next: null, results: []);
  Map<int, P2pListing> listingsById = {};

  /// A shop's listings in one state, keyed "url state" (`shop awaiting_sale_start`).
  Map<String, List<P2pListing>> listingsByState = {};
  List<P2pBidSummary> allBids = [];
  P2pBidResult Function(int listingId, String amount, bool isBuyNow, String signature)? onBid;

  /// Thrown by [placeBid] only.
  Object? bidError;

  /// What `GET /p2p/me/` answers for an address.
  P2pMe Function(String token) onMe = (_) => const P2pMe();

  /// What a dry-run `Sale_Complete()` answers; each description is kept in
  /// [dryRuns].
  P2pListing Function(int listingId, P2pTxDescription tx)? onSaleComplete;
  final List<P2pTxDescription> dryRuns = [];

  /// What a dry-run `Sale_Start()` and `Sale_Cancel()` answer.
  P2pListing Function(int listingId, P2pTxDescription tx)? onSaleStart;
  P2pListing Function(int listingId, P2pTxDescription tx)? onSaleCancel;

  /// Thrown by the dry-run calls only.
  Object? dryRunError;

  /// The registry's listed NFT ids, by owner.
  Map<String, Set<String>> listedByOwner = {};

  /// The shop each address owns.
  Map<String, P2pShop> shopsByOwner = {};

  /// URLs another shop holds.
  Set<String> takenUrls = {};

  /// What a dry-run DSTR answers; each description is kept in [dryRuns].
  P2pShop Function(P2pTxDescription tx)? onDstr;

  /// The email Spyglass holds for an address: sent back at sign-in.
  Map<String, String> emails = {};

  /// Thrown by [subscribeEmail] only.
  Object? emailError;

  /// Each shop's collections as its owner sees them. The collection calls
  /// change this list as the registry would.
  Map<String, List<P2pCollection>> collectionsByShop = {};

  /// Thrown by the collection writes only.
  Object? collectionError;

  /// What listing an NFT, changing a listing and withdrawing one answer.
  P2pListing Function(int collectionId, P2pListingInput input)? onCreateListing;
  P2pListing Function(int id, P2pListingInput input)? onUpdateListing;
  P2pListing Function(int id)? onCancelListing;

  /// Thrown by the listing writes only.
  Object? listingError;

  FakeP2pService() : super(hostOverride: 'http://127.0.0.1:9');

  @override
  Future<P2pPage<P2pCollection>> listCollections(String shopUrl, {String? token, int page = 1, int? limit}) async {
    calls.add('listCollections($shopUrl, token: $token)');
    _fail();
    final all = collectionsByShop[shopUrl] ?? [];
    final seen = token == null ? all.where((c) => c.isLive).toList() : List.of(all);
    return P2pPage(count: seen.length, next: null, results: seen);
  }

  @override
  Future<P2pCollection> createCollection({
    required String token,
    required String shopUrl,
    required String name,
    String description = '',
    bool isLive = true,
  }) async {
    calls.add('createCollection($shopUrl, $name, token: $token)');
    if (collectionError != null) {
      throw collectionError!;
    }
    final all = collectionsByShop.putIfAbsent(shopUrl, () => []);
    final created = P2pCollection(id: 100 + all.length, shopUrl: shopUrl, name: name, description: description, isLive: isLive);
    all.add(created);
    return created;
  }

  @override
  Future<P2pCollection> updateCollection({
    required String token,
    required int id,
    String? name,
    String? description,
    bool? isLive,
  }) async {
    calls.add('updateCollection($id, name: $name, description: $description, isLive: $isLive, token: $token)');
    if (collectionError != null) {
      throw collectionError!;
    }
    for (final all in collectionsByShop.values) {
      final at = all.indexWhere((c) => c.id == id);
      if (at >= 0) {
        all[at] = all[at].copyWith(
          name: name ?? all[at].name,
          description: description ?? all[at].description,
          isLive: isLive ?? all[at].isLive,
        );
        return all[at];
      }
    }
    throw StateError('No collection $id');
  }

  @override
  Future<void> deleteCollection({required String token, required int id}) async {
    calls.add('deleteCollection($id, token: $token)');
    if (collectionError != null) {
      throw collectionError!;
    }
    for (final all in collectionsByShop.values) {
      all.removeWhere((c) => c.id == id);
    }
  }

  @override
  Future<P2pListing> createListing({required String token, required int collectionId, required P2pListingInput input}) async {
    calls.add('createListing($collectionId, ${input.smartContractUid}, token: $token)');
    if (listingError != null) {
      throw listingError!;
    }
    return onCreateListing!(collectionId, input);
  }

  @override
  Future<P2pListing> updateListing({required String token, required int id, required P2pListingInput input}) async {
    calls.add('updateListing($id, token: $token)');
    if (listingError != null) {
      throw listingError!;
    }
    return onUpdateListing!(id, input);
  }

  @override
  Future<P2pListing> cancelListing({required String token, required int id}) async {
    calls.add('cancelListing($id, token: $token)');
    if (listingError != null) {
      throw listingError!;
    }
    return onCancelListing!(id);
  }

  void _fail() {
    if (error != null) {
      throw error!;
    }
  }

  @override
  Future<P2pPage<P2pShop>> listShops({String? search, String? owner, int page = 1, int? limit}) async {
    calls.add('listShops(search: ${search ?? ''}, page: $page)');
    _fail();
    return shops(search ?? '', page);
  }

  @override
  Future<P2pShop?> getShop(String url) async {
    calls.add('getShop($url)');
    _fail();
    return shopsByUrl[url];
  }

  @override
  Future<P2pPage<P2pListing>> listListings(
    String shopUrl, {
    int? collectionId,
    P2pListingState? state,
    int page = 1,
    int? limit,
  }) async {
    if (state != null) {
      // The seller's notices: a shop's listings in one state.
      calls.add('listListings($shopUrl, state: ${state.wire})');
      _fail();
      final waiting = listingsByState['$shopUrl ${state.wire}'] ?? const <P2pListing>[];
      return P2pPage(count: waiting.length, next: null, results: waiting);
    }
    calls.add('listListings($shopUrl, collection: $collectionId, page: $page, limit: $limit)');
    _fail();
    return listings(shopUrl, collectionId, page);
  }

  @override
  Future<P2pListing?> getListing(int id) async {
    calls.add('getListing($id)');
    _fail();
    return listingsById[id];
  }

  @override
  Future<P2pPage<P2pBidSummary>> listBids(int listingId, {int page = 1, int? limit}) async {
    calls.add('listBids($listingId, page: $page)');
    _fail();
    return P2pPage(count: allBids.length, next: null, results: allBids);
  }

  @override
  Future<P2pAuthToken> signToken({required String address, required String message, required String signature}) async {
    calls.add('signToken($address)');
    return P2pAuthToken(
      token: 'token-for-$address',
      address: address,
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      email: emails[address],
    );
  }

  @override
  Future<void> subscribeEmail({required String token, required String address, required String email}) async {
    calls.add('subscribeEmail($address, $email, token: $token)');
    if (emailError != null) {
      throw emailError!;
    }
    emails[address] = email;
  }

  @override
  Future<P2pShop?> ownerShop(String owner) async {
    calls.add('ownerShop($owner)');
    _fail();
    return shopsByOwner[owner];
  }

  @override
  Future<P2pUrlAvailability> urlAvailability(String url) async {
    calls.add('urlAvailability($url)');
    _fail();
    final taken = takenUrls.contains(url);
    return P2pUrlAvailability(url: url, normalized: url, available: !taken, reason: taken ? 'taken' : null);
  }

  @override
  Future<P2pShop> dryRunDstr({required String token, required P2pTxDescription tx}) async {
    calls.add('dryRunDstr(${tx.function}, token: $token)');
    if (dryRunError != null) {
      throw dryRunError!;
    }
    dryRuns.add(tx);
    return onDstr!(tx);
  }

  @override
  Future<P2pMe> me(String token) async {
    calls.add('me($token)');
    _fail();
    return onMe(token);
  }

  @override
  Future<P2pListing> dryRunSaleComplete({required String token, required int listingId, required P2pTxDescription tx}) async {
    calls.add('dryRunSaleComplete($listingId, token: $token)');
    if (dryRunError != null) {
      throw dryRunError!;
    }
    dryRuns.add(tx);
    return onSaleComplete!(listingId, tx);
  }

  @override
  Future<P2pListing> dryRunSaleStart({required String token, required int listingId, required P2pTxDescription tx}) async {
    calls.add('dryRunSaleStart($listingId, token: $token)');
    if (dryRunError != null) {
      throw dryRunError!;
    }
    dryRuns.add(tx);
    return onSaleStart!(listingId, tx);
  }

  @override
  Future<P2pListing> dryRunSaleCancel({required String token, required int listingId, required P2pTxDescription tx}) async {
    calls.add('dryRunSaleCancel($listingId, token: $token)');
    if (dryRunError != null) {
      throw dryRunError!;
    }
    dryRuns.add(tx);
    return onSaleCancel!(listingId, tx);
  }

  @override
  Future<Set<String>> listedNftIds(String owner) async {
    calls.add('listedNftIds($owner)');
    _fail();
    return listedByOwner[owner] ?? {};
  }

  @override
  Future<P2pBidResult> placeBid({
    required String token,
    required int listingId,
    required String amount,
    required bool isBuyNow,
    required String signature,
  }) async {
    calls.add('placeBid($listingId, $amount, buyNow: $isBuyNow, token: $token)');
    _fail();
    if (bidError != null) {
      throw bidError!;
    }
    return onBid!(listingId, amount, isBuyNow, signature);
  }
}

/// The wallet's NFTs from memory. [withMedia] are the ids Spyglass already
/// holds media for; each upload is kept in [uploaded], or throws
/// [uploadError] when set.
class FakeP2pNftSource implements P2pNftSource {
  List<P2pOwnedNft> nfts;
  Set<String> withMedia = {};
  final List<String> uploaded = [];
  Object? uploadError;

  FakeP2pNftSource([this.nfts = const []]);

  @override
  Future<List<P2pOwnedNft>> walletNfts() async => nfts;

  @override
  Future<bool> hasMedia(String id) async => withMedia.contains(id);

  @override
  Future<void> uploadMedia(String id, String token) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    uploaded.add('$id as $token');
    withMedia.add(id);
  }
}

/// Which accounts were asked for an email, in memory. With [everyone] set,
/// every account counts as asked: the prompt never shows.
class FakeP2pEmailAsked implements P2pEmailAsked {
  final bool everyone;
  final Set<String> asked = {};

  FakeP2pEmailAsked({this.everyone = false});

  @override
  bool wasAsked(String address) => everyone || asked.contains(address);

  @override
  void markAsked(String address) => asked.add(address);
}

/// Quotes every fee as [fee], or throws [error] when set. Each request is
/// kept in [quoted].
class FakeP2pFeeQuoter implements P2pFeeQuoter {
  String fee;
  Object? error;
  final List<Map<String, dynamic>> quoted = [];

  FakeP2pFeeQuoter([this.fee = '0.00002']);

  @override
  Future<P2pAmount> quote({
    required String from,
    required String to,
    required P2pAmount amount,
    required int type,
    required Map<String, dynamic> data,
    required int timestamp,
  }) async {
    quoted.add({'from': from, 'to': to, 'amount': amount.toDecimalString(), 'type': type, 'data': data, 'timestamp': timestamp});
    if (error != null) {
      throw error!;
    }
    return P2pAmount.parse(fee);
  }
}

/// [child] inside the app's localizations and a provider scope whose
/// registry is [service], with [address] as the selected account and the
/// clock held at [now].
Widget p2pTestApp({
  required Widget child,
  required FakeP2pService service,
  String? address = 'xViewerAAAAAAAAAAAAAAAAAAAAAAAAAAA',
  double balance = 100,
  DateTime? now,
  P2pMessageSigner? signer,
  P2pFeeQuoter? fees,
  P2pNftSource? nfts,
  P2pEmailAsked? emailAsked,
  List<Override> overrides = const [],
}) {
  // Dialogs open on the root navigator.
  rootNavigatorKey = GlobalKey<NavigatorState>();
  final messageSigner = signer ?? FakeP2pSigner();
  return ProviderScope(
    overrides: [
      p2pServiceProvider.overrideWithValue(service),
      p2pSignerProvider.overrideWithValue(messageSigner),
      // Built here, not by the app's provider: that one follows the wallet's
      // lock state, whose provider polls the node on a timer.
      p2pSessionProvider.overrideWithValue(P2pSession(service: service, signer: messageSigner)),
      p2pFeeQuoterProvider.overrideWithValue(fees ?? FakeP2pFeeQuoter()),
      p2pNftSourceProvider.overrideWithValue(nfts ?? FakeP2pNftSource()),
      // Unless a test is about the email prompt, nobody is asked.
      p2pEmailAskedProvider.overrideWithValue(emailAsked ?? FakeP2pEmailAsked(everyone: true)),
      sessionProvider.overrideWith((ref) => StubP2pSession(ref, address: address, balance: balance)),
      if (now != null) p2pClockProvider.overrideWithValue(() => now),
      ...overrides,
    ],
    child: MaterialApp(
      navigatorKey: rootNavigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
