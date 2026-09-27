import 'dart:async';

import 'package:dio/dio.dart';

/// Checks that a bulk-import asset URL answers before the web wallet keeps it
/// as an asset location. The desktop downloads each file instead, so a dead
/// link fails at import on both platforms rather than at or after mint.
class AssetUrlChecker {
  static const defaultTimeout = Duration(seconds: 10);

  final Dio _dio;
  final Duration timeout;

  AssetUrlChecker({Dio? dio, this.timeout = defaultTimeout}) : _dio = dio ?? Dio();

  /// True when [url] is an http(s) URL that answers with a 2xx status within
  /// [timeout]. Tries HEAD first and falls back to GET for servers that refuse
  /// HEAD. Any network error, timeout or non-2xx status counts as unreachable.
  Future<bool> isReachable(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
      return false;
    }

    final headStatus = await _statusFor(uri, 'HEAD');
    if (_isSuccess(headStatus)) {
      return true;
    }
    if (headStatus == null || !_headRefused(headStatus)) {
      return false;
    }

    return _isSuccess(await _statusFor(uri, 'GET'));
  }

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  bool _headRefused(int status) => status == 403 || status == 405 || status == 501;

  /// The response status, or null when the request failed or timed out.
  Future<int?> _statusFor(Uri uri, String method) async {
    final cancelToken = CancelToken();
    try {
      final response = await _dio
          .requestUri<dynamic>(
            uri,
            cancelToken: cancelToken,
            options: Options(
              method: method,
              responseType: ResponseType.bytes,
              followRedirects: true,
              validateStatus: (_) => true,
              receiveTimeout: timeout,
            ),
          )
          .timeout(timeout);
      return response.statusCode;
    } on TimeoutException {
      cancelToken.cancel();
      return null;
    } on DioException catch (e) {
      print("Asset URL check failed for $uri: ${e.message}");
      return null;
    }
  }
}
