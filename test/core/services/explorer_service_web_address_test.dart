import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/core/singletons.dart';

Future<HttpServer> serveJson(int statusCode, Object body) async {
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

ExplorerService serviceFor(HttpServer server) =>
    ExplorerService(hostOverride: 'http://${server.address.host}:${server.port}');

void main() {
  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(
        ApiTokenManagerImplementation(),
      );
    }
  });

  group('ExplorerService.getWebAddress', () {
    test('reports a recovered Vault as deactivated when balances are strings', () async {
      final server = await serveJson(200, {
        'address': 'xVault',
        'balance': '0.0000000000000000',
        'balance_total': '0.0000000000000000',
        'balance_locked': 0.0,
        'adnr': null,
        'activated': true,
        'deactivated': true,
      });
      addTearDown(() => server.close(force: true));

      final address = await serviceFor(server).getWebAddress('xVault');

      expect(address.deactivated, isTrue);
      expect(address.activated, isTrue);
      expect(address.balance, 0.0);
    });

    test('treats a 404 (address never seen on chain) as an empty address', () async {
      final server = await serveJson(404, {'detail': 'Address not found'});
      addTearDown(() => server.close(force: true));

      final address = await serviceFor(server).getWebAddress('xNew');

      expect(address.address, 'xNew');
      expect(address.balance, 0.0);
      expect(address.deactivated, isFalse);
    });

    test('rethrows a server error instead of returning a misleading default', () async {
      final server = await serveJson(500, {'detail': 'boom'});
      addTearDown(() => server.close(force: true));

      expect(serviceFor(server).getWebAddress('xA'), throwsA(anything));
    });

    test('rethrows an unparseable payload instead of returning a default', () async {
      final server = await serveJson(200, {
        'address': 'xA',
        'balance': 'not-a-number',
        'deactivated': true,
      });
      addTearDown(() => server.close(force: true));

      expect(serviceFor(server).getWebAddress('xA'), throwsA(isA<FormatException>()));
    });
  });
}
