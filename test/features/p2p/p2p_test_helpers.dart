import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/encrypt/providers/password_required_provider.dart';
import 'package:rbx_wallet/features/p2p/components/p2p_parts.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_auth_token.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_bid_summary.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_listing.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_page.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_shop.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_session_provider.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';
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

/// The wallet's lock state without the node: [check] asks nothing.
class StubPasswordRequired extends PasswordRequiredProvider {
  @override
  Future<bool> check() async => state;
}

/// The registry, answered from memory. Each method records its call in
/// [calls] and answers from the matching field, or throws [error] when set.
class FakeP2pService extends P2pService {
  final List<String> calls = [];
  Object? error;

  P2pPage<P2pShop> Function(String search, int page) shops = (_, __) => P2pPage.empty();
  Map<String, P2pShop> shopsByUrl = {};
  P2pPage<P2pListing> Function(String url, int? collectionId, int page) listings = (_, __, ___) => P2pPage.empty();
  Map<int, P2pListing> listingsById = {};
  List<P2pBidSummary> allBids = [];
  P2pBidResult Function(int listingId, String amount, bool isBuyNow, String signature)? onBid;

  FakeP2pService() : super(hostOverride: 'http://127.0.0.1:9');

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
    return P2pAuthToken(token: 'token-for-$address', address: address, expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)));
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
    return onBid!(listingId, amount, isBuyNow, signature);
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
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      p2pServiceProvider.overrideWithValue(service),
      p2pSignerProvider.overrideWithValue(signer ?? FakeP2pSigner()),
      passwordRequiredProvider.overrideWith((ref) => StubPasswordRequired()),
      sessionProvider.overrideWith((ref) => StubP2pSession(ref, address: address, balance: balance)),
      if (now != null) p2pClockProvider.overrideWithValue(() => now),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
