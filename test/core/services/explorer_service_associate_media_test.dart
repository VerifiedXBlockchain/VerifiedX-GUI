import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/core/singletons.dart';

class CapturedRequest {
  final String method;
  final String path;
  final String? authorization;
  final Map<String, dynamic> body;

  CapturedRequest(this.method, this.path, this.authorization, this.body);
}

class CapturingServer {
  final HttpServer server;
  final List<CapturedRequest> requests = [];

  CapturingServer(this.server);

  static Future<CapturingServer> start(int statusCode, Object body) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final capturing = CapturingServer(server);
    server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      capturing.requests.add(CapturedRequest(
        request.method,
        request.uri.path,
        request.headers.value(HttpHeaders.authorizationHeader),
        raw.isEmpty ? {} : jsonDecode(raw),
      ));
      request.response
        ..statusCode = statusCode
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(body));
      await request.response.close();
    });
    return capturing;
  }

  ExplorerService get service => ExplorerService(
      hostOverride: 'http://${server.address.host}:${server.port}');
}

void main() {
  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(
        ApiTokenManagerImplementation(),
      );
    }
  });

  group('ExplorerService.associateMedia', () {
    test('sends the media map with the owner token as the Authorization header',
        () async {
      final capturing = await CapturingServer.start(200, {'success': true});
      addTearDown(() => capturing.server.close(force: true));

      final mediaMap = {
        'sc-d.png': 'https://rbx-nft-web-assets-testnet.s3.amazonaws.com/abc/sc-d.png',
      };
      final associated = await capturing.service
          .associateMedia('scid:123', mediaMap, authToken: 'owner-token');

      expect(associated, isTrue);
      expect(capturing.requests, hasLength(1));
      final request = capturing.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/media/associate-media/scid:123/');
      expect(request.authorization, 'basic owner-token');
      expect(request.body['media_map'], mediaMap);
    });

    test('reports failure when the explorer refuses the token', () async {
      final capturing = await CapturingServer.start(401, {
        'detail': 'Only the NFT owner can replace its media.',
      });
      addTearDown(() => capturing.server.close(force: true));

      final associated = await capturing.service.associateMedia(
        'scid:123',
        {'a.png': 'https://rbx-nft-web-assets-testnet.s3.amazonaws.com/x/a.png'},
        authToken: 'stale-token',
      );

      expect(associated, isFalse);
    });
  });
}
