import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';

/// Answers every request with one status code and JSON body, the way the
/// Spyglass FROST status view answers a failed (500) or expired (404) job.
Future<HttpServer> serveJson(int statusCode, Map<String, dynamic> body) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  });
  return server;
}

BaseService serviceFor(HttpServer server) =>
    BaseService(hostOverride: 'http://${server.address.host}:${server.port}');

void main() {
  setUpAll(() {
    // getJson attaches the desktop API token header, read through get_it.
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(
        ApiTokenManagerImplementation(),
      );
    }
  });

  group('BaseService.getJson validateStatus', () {
    test('returns a non-2xx JSON body as data when validateStatus accepts it',
        () async {
      final server = await serveJson(500, {
        'success': false,
        'status': 'failed',
        'message': 'FROST signing ceremony failed',
        'failure_code': 'Round2InsufficientShares',
        'retryable': true,
      });
      addTearDown(() => server.close(force: true));

      final data = await serviceFor(server).getJson(
        '/status/',
        auth: false,
        validateStatus: (status) => status != null && status < 600,
      );

      expect(data['status'], 'failed');
      expect(data['failure_code'], 'Round2InsufficientShares');
      expect(data['retryable'], isTrue);
    });

    test('returns an expired-job 404 body as data when validateStatus accepts it',
        () async {
      final server =
          await serveJson(404, {'success': false, 'message': 'Job not found'});
      addTearDown(() => server.close(force: true));

      final data = await serviceFor(server).getJson(
        '/status/',
        auth: false,
        validateStatus: (status) => status != null && status < 600,
      );

      expect(data['success'], isFalse);
      expect(data['message'], 'Job not found');
    });

    test('still throws on a non-2xx response without validateStatus',
        () async {
      final server =
          await serveJson(404, {'success': false, 'message': 'Job not found'});
      addTearDown(() => server.close(force: true));

      await expectLater(
        serviceFor(server).getJson('/status/', auth: false),
        throwsA(anything),
      );
    });
  });
}
