import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/services/locked_wallet_gate.dart';
import 'package:rbx_wallet/core/singletons.dart';

/// Stands in for the local node: while [locked], every path except the
/// unlock routes answers the LockedWalletPolicy 401; otherwise 200 with
/// [okBody].
class FakeNodeAdapter implements HttpClientAdapter {
  bool locked = true;
  String okBody = '{"Success":true}';
  String lockedBody = lockedWalletNodeMessage;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (locked) {
      return ResponseBody.fromString(lockedBody, 401, headers: {
        Headers.contentTypeHeader: ['text/plain; charset=utf-8'],
      });
    }
    return ResponseBody.fromString(okBody, 200, headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeNodeAdapter node;
  late int prompts;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
  });

  setUp(() {
    node = FakeNodeAdapter();
    prompts = 0;
    BaseService.httpClientAdapterOverride = node;
    BaseService.suppressErrors = true;
  });

  tearDown(() {
    BaseService.httpClientAdapterOverride = null;
    BaseService.suppressErrors = false;
    LockedWalletGate.unlocker = null;
  });

  /// An unlocker that "types the right password".
  void unlockSucceeds() {
    LockedWalletGate.unlocker = () async {
      prompts++;
      node.locked = false;
      return true;
    };
  }

  test('isLockedWalletResponse matches only the locked-wallet 401', () {
    final options = RequestOptions(path: '/x');
    DioException withResponse(int status, dynamic body) => DioException.badResponse(
          statusCode: status,
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: status, data: body),
        );

    expect(isLockedWalletResponse(withResponse(401, lockedWalletNodeMessage)), isTrue);
    expect(isLockedWalletResponse(withResponse(401, '"$lockedWalletNodeMessage"')), isTrue);
    expect(isLockedWalletResponse(withResponse(401, 'Invalid token')), isFalse);
    expect(isLockedWalletResponse(withResponse(403, lockedWalletNodeMessage)), isFalse);
    expect(isLockedWalletResponse(Exception('401')), isFalse);
  });

  test('getText prompts once after a locked-wallet 401 and retries the request', () async {
    unlockSucceeds();

    final body = await BaseService().getText('/GetPrivateKey/xAddr', cleanPath: false);

    expect(body, contains('Success'));
    expect(prompts, 1);
    expect(node.requests.map((r) => r.path), ['/GetPrivateKey/xAddr', '/GetPrivateKey/xAddr']);
  });

  test('postJson resends the same body after unlocking', () async {
    unlockSucceeds();

    final result = await BaseService(apiBasePathOverride: '/vbtcapi/vbtc').postJson(
      '/RequestWithdrawal',
      params: {'Amount': 0.1},
    );

    expect(result['data'], {'Success': true});
    expect(prompts, 1);
    expect(node.requests, hasLength(2));
    expect(node.requests.last.data, {'Amount': 0.1});
    expect(node.requests.last.method, 'POST');
  });

  test('cancelling the prompt fails with the translated wallet-locked message', () async {
    LockedWalletGate.unlocker = () async {
      prompts++;
      return false;
    };

    Object? error;
    try {
      await BaseService().getJson('/GetValidatorInfo');
    } catch (e) {
      error = e;
    }

    expect(error, isA<WalletLockedException>());
    // Still a DioException, so existing `on DioException` handlers catch it.
    expect(error, isA<DioException>());
    expect(error.toString(), 'Your wallet is locked. Unlock it with your password and try again.');
    expect(error.toString(), isNot(contains('DioException')));
    expect(prompts, 1);
    expect(node.requests, hasLength(1));
  });

  test('concurrent locked requests share one prompt and all complete', () async {
    final entered = Completer<void>();
    final release = Completer<bool>();
    LockedWalletGate.unlocker = () async {
      prompts++;
      entered.complete();
      final ok = await release.future;
      node.locked = !ok;
      return ok;
    };

    final service = BaseService();
    final calls = [
      service.getText('/a'),
      service.getJson('/b'),
      service.postJson('/c'),
    ];

    await entered.future;
    // Let the other two reach the gate while the prompt is on screen.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    release.complete(true);

    final results = await Future.wait(calls);
    expect(results, hasLength(3));
    expect(prompts, 1);
    expect(node.requests, hasLength(6));
  });

  test('each new locked period prompts again', () async {
    unlockSucceeds();
    final service = BaseService();

    await service.getText('/first');
    expect(prompts, 1);

    // The node clears the password again; a fresh refusal prompts again.
    node.locked = true;
    await service.getText('/second');
    expect(prompts, 2);
  });

  test('still refused after unlocking: one retry, then WalletLockedException', () async {
    LockedWalletGate.unlocker = () async {
      prompts++;
      return true; // the node stays locked
    };

    await expectLater(BaseService().getText('/x'), throwsA(isA<WalletLockedException>()));
    expect(prompts, 1);
    expect(node.requests, hasLength(2));
  });

  test('requests made by the unlock flow itself do not wait for that unlock', () async {
    LockedWalletGate.unlocker = () async {
      prompts++;
      // e.g. a status call on a route the node also refuses: must fail fast,
      // not queue behind the prompt it is part of.
      await expectLater(BaseService().getText('/inside'), throwsA(isA<DioException>()));
      node.locked = false;
      return true;
    };

    final body = await BaseService().getText('/outside').timeout(const Duration(seconds: 5));
    expect(body, contains('Success'));
    expect(prompts, 1);
  });

  test('unlockIfLocked: false passes the 401 through without prompting', () async {
    unlockSucceeds();

    Object? error;
    try {
      await BaseService().getJson('/GetLatestRelease/false/x.zip', cleanPath: false, unlockIfLocked: false);
    } catch (e) {
      error = e;
    }

    expect(error, isA<DioException>());
    expect(error, isNot(isA<WalletLockedException>()));
    expect(prompts, 0);
  });

  test('other hosts (Spyglass, mempool) never prompt', () async {
    unlockSucceeds();

    await expectLater(
      BaseService(hostOverride: 'https://data.verifiedx.io/api/v1').getJson('/addresses/x'),
      throwsA(isA<DioException>()),
    );
    expect(prompts, 0);
  });

  test('a 401 that is not the locked-wallet message is passed through', () async {
    unlockSucceeds();
    node.lockedBody = jsonEncode({'Message': 'Invalid API token'});

    await expectLater(BaseService().getText('/x'), throwsA(isNot(isA<WalletLockedException>())));
    expect(prompts, 0);
  });

  test('with no unlocker registered, a locked-wallet 401 becomes WalletLockedException', () async {
    await expectLater(BaseService().getText('/x'), throwsA(isA<WalletLockedException>()));
    expect(node.requests, hasLength(1));
  });
}
