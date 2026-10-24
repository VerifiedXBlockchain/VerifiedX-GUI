import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/explorer_service.dart';
import 'package:rbx_wallet/core/singletons.dart';

class _Request {
  final String path;
  final Map<String, dynamic> body;

  _Request(this.path, this.body);
}

/// Answers every request with [statusCode] and [body], recording what was asked.
Future<HttpServer> serveJson(int statusCode, Object body, List<_Request> requests) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    final sent = await utf8.decoder.bind(request).join();
    requests.add(_Request(request.uri.path, sent.isEmpty ? {} : jsonDecode(sent) as Map<String, dynamic>));
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

  group('ExplorerService.prepareV2WithdrawalRequestMulti', () {
    Future<Map<String, dynamic>> prepare(ExplorerService service) => service.prepareV2WithdrawalRequestMulti(
          requestorAddress: 'xREQ',
          btcAddress: 'tb1qdest',
          totalAmount: 0.00007,
          feeRate: 3,
          inputs: [
            {'sc_identifier': 'big:2', 'amount': 0.00005},
            {'sc_identifier': 'small:1', 'amount': 0.00002},
          ],
        );

    test("sends the wallet's shares to the multi prepare route", () async {
      final requests = <_Request>[];
      final server = await serveJson(200, {'success': true, 'Hash': 'abc'}, requests);
      addTearDown(() => server.close(force: true));

      final answer = await prepare(serviceFor(server));

      expect(answer['Hash'], 'abc');
      expect(requests.single.path, endsWith('/btc/vbtc-v2/withdraw/multi/prepare/'));
      expect(requests.single.body, {
        'requestor_address': 'xREQ',
        'btc_address': 'tb1qdest',
        'total_amount': 0.00007,
        'fee_rate': 3,
        'inputs': [
          {'sc_identifier': 'big:2', 'amount': 0.00005},
          {'sc_identifier': 'small:1', 'amount': 0.00002},
        ],
      });
    });

    test("a refusal is rethrown so the caller can show Core's reason", () async {
      final server = await serveJson(500, {'success': false, 'message': 'below the fee floor'}, []);
      addTearDown(() => server.close(force: true));

      expect(prepare(serviceFor(server)), throwsA(anything));
    });
  });
}
