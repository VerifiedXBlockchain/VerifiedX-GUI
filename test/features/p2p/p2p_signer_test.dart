import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/services/locked_wallet_gate.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';

/// Stands in for the local node: records each request and answers [body]
/// with [status], or fails to connect when [refuseConnection] is set.
class NodeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  int status = 200;
  String body = '';
  bool refuseConnection = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (refuseConnection) {
      throw DioException.connectionError(requestOptions: options, reason: 'Connection refused');
    }
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['text/plain; charset=utf-8'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final signature = 'ME${'Q' * 90}==.${'3' * 88}';
  late NodeAdapter node;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    node = NodeAdapter();
    BaseService.httpClientAdapterOverride = node;
    BaseService.suppressErrors = true;
    LockedWalletGate.unlocker = null;
  });

  tearDown(() {
    BaseService.httpClientAdapterOverride = null;
    LockedWalletGate.unlocker = null;
  });

  Future<P2pSigningFailure> failure(Future<String> signing) async {
    try {
      await signing;
    } on P2pSigningError catch (e) {
      return e.failure;
    }
    fail('Expected a P2pSigningError');
  }

  test('asks Core to sign the message for the address, the dot of a sign-in message intact', () async {
    node.body = signature;
    final signed = await P2pCoreSigner().sign('AbCdEfGhIjKlMnOp.1794846000', 'xBidder');

    expect(signed, signature);
    final uri = node.requests.single.uri.toString();
    expect(uri, endsWith('/api/V1/CreateSignature/AbCdEfGhIjKlMnOp.1794846000/xBidder'));
    expect(node.requests.single.method, 'GET');
  });

  test('sends a bid message as it is', () async {
    node.body = signature;
    await P2pCoreSigner().sign('QLHYeWQCuH1794842796_500000000_xBidder', 'xBidder');
    expect(node.requests.single.uri.toString(), endsWith('/CreateSignature/QLHYeWQCuH1794842796_500000000_xBidder/xBidder'));
  });

  test('trims the answer', () async {
    node.body = '$signature\n';
    expect(await P2pCoreSigner().sign('m', 'xBidder'), signature);
  });

  test('an address that is not in the wallet is told apart', () async {
    node.body = 'ERROR - Account not associated with wallet.';
    expect(await failure(P2pCoreSigner().sign('m', 'xStranger')), P2pSigningFailure.notInWallet);
  });

  test('an answer that is not a signature is refused, not passed on', () async {
    node.body = '<html>proxy error</html>';
    expect(await failure(P2pCoreSigner().sign('m', 'xBidder')), P2pSigningFailure.unexpected);
  });

  test('a locked wallet that stays locked is reported as locked', () async {
    node.status = 401;
    node.body = lockedWalletNodeMessage;
    expect(await failure(P2pCoreSigner().sign('m', 'xBidder')), P2pSigningFailure.walletLocked);
  });

  test('a locked wallet is unlocked through the gate and the message signed', () async {
    node.status = 401;
    node.body = lockedWalletNodeMessage;
    LockedWalletGate.unlocker = () async {
      node.status = 200;
      node.body = signature;
      return true;
    };
    expect(await P2pCoreSigner().sign('m', 'xBidder'), signature);
    expect(node.requests, hasLength(2));
  });

  test('a node that does not answer is reported as unreachable', () async {
    node.refuseConnection = true;
    expect(await failure(P2pCoreSigner().sign('m', 'xBidder')), P2pSigningFailure.unreachable);
  });
}
