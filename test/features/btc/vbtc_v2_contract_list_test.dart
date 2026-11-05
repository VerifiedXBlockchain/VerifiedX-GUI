import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/btc/services/vbtc_v2_service.dart';

/// Stands in for a node that knows about three V2 contracts: one owned by
/// `holder`, one `holder` was transferred a balance on, and one belonging to
/// someone else entirely.
class _NodeFixture implements HttpClientAdapter {
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    paths.add(options.path);
    final Map<String, dynamic> body;
    if (options.path == '/GetContractList') {
      body = {
        'Success': true,
        'Contracts': [
          {'SmartContractUID': 'owned:1', 'OwnerAddress': 'holder', 'Name': 'vBTC'},
          {'SmartContractUID': 'received:1', 'OwnerAddress': 'someone', 'Name': 'vBTC'},
          {'SmartContractUID': 'other:1', 'OwnerAddress': 'someone', 'Name': 'vBTC'},
        ],
      };
    } else if (options.path.startsWith('/GetVBTCBalance/holder/')) {
      body = {
        'Success': true,
        'AvailableBalance': options.path.endsWith('/received:1') ? 0.002 : 0,
      };
    } else {
      throw StateError('Unexpected fixture request: ${options.path}');
    }
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _NodeFixture node;

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    node = _NodeFixture();
    BaseService.httpClientAdapterOverride = node;
  });

  tearDown(() {
    BaseService.httpClientAdapterOverride = null;
  });

  group('VbtcV2Service.getContractList', () {
    test('lists only the contracts the address owns or holds a balance on', () async {
      final tokens = await VbtcV2Service().getContractList(address: 'holder');

      expect(tokens.map((t) => t.smartContractUid), ['owned:1', 'received:1']);
    });

    test('a wallet with no accounts lists nothing and asks the node nothing', () async {
      expect(await VbtcV2Service().getContractList(address: null), isEmpty);
      expect(await VbtcV2Service().getContractList(address: ''), isEmpty);
      expect(node.paths, isEmpty);
    });
  });
}
