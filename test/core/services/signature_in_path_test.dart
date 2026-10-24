import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/features/nft/services/nft_service.dart';
import 'package:rbx_wallet/features/raw/raw_service.dart';

/// Records each request and answers [body] (`true` unless a test sets it).
class RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  String body = 'true';
  String contentType = 'application/json; charset=utf-8';

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(body, 200, headers: {
      Headers.contentTypeHeader: [contentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late RecordingAdapter adapter;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    adapter = RecordingAdapter();
    BaseService.httpClientAdapterOverride = adapter;
    BaseService.suppressErrors = true;
  });

  tearDown(() {
    BaseService.httpClientAdapterOverride = null;
  });

  // VerifiedX-Issues#367: a base64 signature holding '//' reached Spyglass with
  // one '/' when the path was relative, so the pre-check failed at random.
  test("a signature containing '//' reaches the server intact", () async {
    const signature = 'MEUCIQDab//cd+ef/gh==.pubkey';
    await RawService().validateSignature('hash', 'xAddress', signature);
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.uri.toString(), contains('/validate-signature/hash/xAddress/$signature/'));
  });

  const signature = 'MEUCIQDab//cd+ef/gh==.pubkey';

  test("beaconUpload keeps a signature's '//' on the explorer's raw host", () async {
    await RawService().beaconUpload('sc:1', 'xTo', signature);
    final uri = adapter.requests.single.uri.toString();
    expect(uri, startsWith('${Env.explorerApiBaseUrl}/raw/beacon/upload/'));
    expect(uri, contains('/sc:1/xTo/$signature'));
  });

  test("beaconAssets keeps a signature's '//' on the explorer's raw host", () async {
    await RawService().beaconAssets('sc:1', 'loc', 'xAddr', signature);
    final uri = adapter.requests.single.uri.toString();
    expect(uri, startsWith('${Env.explorerApiBaseUrl}/raw/beacon-assets/'));
    expect(uri, contains('/sc:1/loc/xAddr/$signature'));
  });

  test("verifyOwnership keeps a signature's '//' on the node's smart contract API", () async {
    // verifyOwnership reads the answer as text and decodes it itself.
    adapter.body = '{"Success":true}';
    adapter.contentType = 'text/plain; charset=utf-8';
    await NftService().verifyOwnership(signature);
    final uri = adapter.requests.single.uri.toString();
    expect(uri, contains('/scapi/scv1/VerifyOwnership/$signature'));
  });
}
