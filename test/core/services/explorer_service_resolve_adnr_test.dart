import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/core/singletons.dart';

/// Answers every request with [statusCode] and [body], recording the paths asked for.
Future<HttpServer> serveJson(int statusCode, Object body, List<String> paths) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    paths.add(request.uri.path);
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  });
  return server;
}

ExplorerService serviceFor(HttpServer server) => ExplorerService(hostOverride: 'http://${server.address.host}:${server.port}');

void main() {
  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  group('ExplorerService.resolveAdnr', () {
    test('returns the address a known name resolves to', () async {
      final paths = <String>[];
      final server = await serveJson(200, {'domain': 'alice.vfx', 'address': 'xAliceAddress'}, paths);
      addTearDown(() => server.close(force: true));

      expect(await serviceFor(server).resolveAdnr('alice.vfx'), 'xAliceAddress');
    });

    test('asks for the name trimmed and lowercased, as names are stored', () async {
      final paths = <String>[];
      final server = await serveJson(200, {'address': 'xAliceAddress'}, paths);
      addTearDown(() => server.close(force: true));

      await serviceFor(server).resolveAdnr('  Alice.VFX ');

      expect(paths.single, contains('/addresses/adnr/alice.vfx'));
    });

    test('a 404 is an unknown name', () async {
      final server = await serveJson(404, {'detail': 'Not found.'}, []);
      addTearDown(() => server.close(force: true));

      expect(await serviceFor(server).resolveAdnr('nobody.vfx'), isNull);
    });

    test('an answer without an address is an unknown name', () async {
      final server = await serveJson(200, {'address': ''}, []);
      addTearDown(() => server.close(force: true));

      expect(await serviceFor(server).resolveAdnr('alice.vfx'), isNull);
    });

    test('a server error is rethrown, so nothing is sent on a guess', () async {
      final server = await serveJson(500, {'detail': 'boom'}, []);
      addTearDown(() => server.close(force: true));

      expect(serviceFor(server).resolveAdnr('alice.vfx'), throwsA(anything));
    });
  });
}
