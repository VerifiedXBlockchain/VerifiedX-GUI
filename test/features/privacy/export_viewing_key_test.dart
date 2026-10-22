import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/privacy/services/privacy_service.dart';

/// Answers every request with [body] and records the JSON bodies it received.
Future<HttpServer> serveJson(Object body, List<Map<String, dynamic>> received) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    received.add(jsonDecode(await utf8.decoder.bind(request).join()) as Map<String, dynamic>);
    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  });
  return server;
}

PrivacyService serviceFor(HttpServer server) => PrivacyService(hostOverride: 'http://${server.address.host}:${server.port}/api/V1');

void main() {
  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  group('PrivacyService.exportViewingKey', () {
    test('sends the wallet password Core 9.0 asks for and returns the key', () async {
      final received = <Map<String, dynamic>>[];
      final server = await serveJson({
        'Success': true,
        'Result': {'ViewingKeyBase64': 'a2V5', 'CanSpend': true},
      }, received);
      addTearDown(() => server.close(force: true));

      final result = await serviceFor(server).exportViewingKey(zfxAddress: 'zfx_abc', walletPassword: 'secret');

      expect(received.single, {'ZfxAddress': 'zfx_abc', 'WalletPassword': 'secret'});
      expect(result['ViewingKeyBase64'], 'a2V5');
    });

    test("a refusal comes back with the node's message", () async {
      const message = "The viewing key can spend this wallet's funds, so exporting it needs the wallet password, as a spend does: GCM authentication failed.";
      final server = await serveJson({'Success': false, 'Message': message}, []);
      addTearDown(() => server.close(force: true));

      expect(
        serviceFor(server).exportViewingKey(zfxAddress: 'zfx_abc', walletPassword: 'wrong'),
        throwsA(predicate((e) => e.toString().contains('GCM authentication failed'))),
      );
    });
  });
}
