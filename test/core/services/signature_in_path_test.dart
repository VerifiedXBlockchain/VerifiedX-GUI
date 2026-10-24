import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/features/raw/raw_service.dart';

/// Records each request and answers `true`.
class RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString('true', 200, headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late RecordingAdapter adapter;

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
}
