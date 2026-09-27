import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/smart_contracts/services/asset_url_checker.dart';

/// Answers each request from [respond] instead of the network and records
/// the methods it saw.
class _FakeAdapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(RequestOptions options) respond;
  final List<String> methods = [];

  _FakeAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    methods.add(options.method);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _status(int code, {String contentType = 'image/png'}) {
  return ResponseBody.fromBytes(
    Uint8List(0),
    code,
    headers: {
      Headers.contentTypeHeader: [contentType],
    },
  );
}

AssetUrlChecker _checker(_FakeAdapter adapter, {Duration timeout = AssetUrlChecker.defaultTimeout}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return AssetUrlChecker(dio: dio, timeout: timeout);
}

void main() {
  group('AssetUrlChecker.isReachable', () {
    test('accepts a URL that answers HEAD with 200', () async {
      final adapter = _FakeAdapter((_) => _status(200));

      expect(await _checker(adapter).isReachable('https://example.com/a.png'), isTrue);
      expect(adapter.methods, ['HEAD']);
    });

    test('refuses a URL that answers 404 without retrying', () async {
      final adapter = _FakeAdapter((_) => _status(404, contentType: 'text/html'));

      expect(await _checker(adapter).isReachable('https://example.com/missing.png'), isFalse);
      expect(adapter.methods, ['HEAD']);
    });

    test('falls back to GET when the server refuses HEAD', () async {
      final adapter = _FakeAdapter((options) => _status(options.method == 'HEAD' ? 405 : 200));

      expect(await _checker(adapter).isReachable('https://example.com/a.png'), isTrue);
      expect(adapter.methods, ['HEAD', 'GET']);
    });

    test('refuses when both HEAD and GET fail', () async {
      final adapter = _FakeAdapter((options) => _status(options.method == 'HEAD' ? 405 : 500));

      expect(await _checker(adapter).isReachable('https://example.com/a.png'), isFalse);
    });

    test('refuses a URL whose request errors out', () async {
      final adapter = _FakeAdapter((options) => throw DioException.connectionError(
            requestOptions: options,
            reason: 'host not found',
          ));

      expect(await _checker(adapter).isReachable('https://example.invalid/a.png'), isFalse);
    });

    test('refuses a URL that does not answer within the timeout', () async {
      final adapter = _FakeAdapter((_) => Completer<ResponseBody>().future);
      final checker = _checker(adapter, timeout: const Duration(milliseconds: 50));

      expect(await checker.isReachable('https://example.com/slow.png'), isFalse);
      expect(adapter.methods, ['HEAD']);
    });

    test('refuses malformed and non-http URLs without a request', () async {
      final adapter = _FakeAdapter((_) => _status(200));
      final checker = _checker(adapter);

      expect(await checker.isReachable(''), isFalse);
      expect(await checker.isReachable('not a url'), isFalse);
      expect(await checker.isReachable('ftp://example.com/a.png'), isFalse);
      expect(await checker.isReachable('ipfs://bafy/a.png'), isFalse);
      expect(adapter.methods, isEmpty);
    });
  });
}
