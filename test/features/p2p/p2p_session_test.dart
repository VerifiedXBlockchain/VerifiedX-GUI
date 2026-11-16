import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/features/encrypt/providers/password_required_provider.dart';
import 'package:rbx_wallet/features/p2p/models/p2p_error.dart';
import 'package:rbx_wallet/features/p2p/providers/p2p_session_provider.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_service.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_session.dart';
import 'package:rbx_wallet/features/p2p/services/p2p_signer.dart';
import 'package:rbx_wallet/features/p2p/utils/p2p_rules.dart';

import 'p2p_test_helpers.dart';

void main() {
  const alice = 'xAliceAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  const bob = 'xBobBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

  late P2pTestServer server;
  late FakeP2pSigner signer;
  late DateTime now;
  late P2pSession session;
  late int issued;

  /// Spyglass's answer to a sign-in: a new token each time, good for an hour.
  P2pCannedResponse signIn(P2pRecordedRequest request) {
    issued++;
    final body = request.body as Map<String, dynamic>;
    return P2pCannedResponse(201, {
      'message': body['message'],
      'token': 'token-$issued',
      'address': body['address'],
      'expires_at': now.add(const Duration(hours: 1)).toIso8601String(),
      'signature': body['signature'],
      'email': null,
    });
  }

  setUpAll(() {
    if (!singleton.isRegistered<ApiTokenManager>()) {
      singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
    }
    BaseService.suppressErrors = true;
  });

  setUp(() async {
    issued = 0;
    now = DateTime.utc(2026, 11, 16, 16);
    server = await P2pTestServer.start(signIn);
    signer = FakeP2pSigner();
    session = P2pSession(
      service: P2pService(hostOverride: server.host),
      signer: signer,
      now: () => now,
    );
  });

  tearDown(() => server.close());

  test('signs in with a timed message signed for the address, and posts it', () async {
    final token = await session.token(alice);

    expect(token, 'token-1');
    final signed = signer.signed.single;
    expect(isP2pSignInMessage(signed[0]), isTrue, reason: signed[0]);
    expect(signed[0], endsWith('.${now.millisecondsSinceEpoch ~/ 1000}'));
    expect(signed[1], alice);

    final request = server.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/auth/sign-token/');
    expect(request.authorization, isNull);
    expect(request.body, {'address': alice, 'message': signed[0], 'signature': 'SIG.KEY'});
  });

  test('keeps the token for its hour: a second ask signs nothing', () async {
    await session.token(alice);
    now = now.add(const Duration(minutes: 30));
    expect(await session.token(alice), 'token-1');
    expect(session.cached(alice), 'token-1');
    expect(signer.signed, hasLength(1));
    expect(server.requests, hasLength(1));
  });

  test('holds one token per address', () async {
    expect(await session.token(alice), 'token-1');
    expect(await session.token(bob), 'token-2');
    expect(session.cached(alice), 'token-1');
    expect(session.cached(bob), 'token-2');
    expect(signer.signed.map((s) => s[1]), [alice, bob]);
  });

  test('callers that ask together share one sign-in', () async {
    final tokens = await Future.wait([session.token(alice), session.token(alice), session.token(alice)]);
    expect(tokens, ['token-1', 'token-1', 'token-1']);
    expect(signer.signed, hasLength(1));
    expect(server.requests, hasLength(1));
  });

  test('replaces a token that is within two minutes of its end', () async {
    await session.token(alice);
    now = now.add(const Duration(minutes: 58, seconds: 1));
    expect(session.cached(alice), isNull);
    expect(await session.token(alice), 'token-2');
    expect(signer.signed, hasLength(2));
    // A new message each time: Spyglass accepts each once.
    expect(signer.signed[0][0], isNot(signer.signed[1][0]));
  });

  test('never keeps a token past an hour from signing, whatever the server\'s clock says', () async {
    server.respond = (request) {
      final body = request.body as Map<String, dynamic>;
      return P2pCannedResponse(201, {
        'token': 'long-lived',
        'address': body['address'],
        'expires_at': now.add(const Duration(hours: 5)).toIso8601String(),
      });
    };
    await session.token(alice);
    now = now.add(const Duration(minutes: 59));
    expect(session.cached(alice), isNull);
  });

  test('remembers the email Spyglass already has for the address', () async {
    server.respond = (request) {
      final body = request.body as Map<String, dynamic>;
      return P2pCannedResponse(201, {
        'token': 't',
        'address': body['address'],
        'expires_at': now.add(const Duration(hours: 1)).toIso8601String(),
        'email': 'seller@example.com',
      });
    };
    expect(session.emailOf(alice), isNull);
    await session.token(alice);
    expect(session.emailOf(alice), 'seller@example.com');
  });

  group('withToken', () {
    test('runs the call with the address\'s token', () async {
      final used = <String>[];
      final result = await session.withToken(alice, (token) async {
        used.add(token);
        return 42;
      });
      expect(result, 42);
      expect(used, ['token-1']);
    });

    test('on a 401 signs in once more and runs the call once more', () async {
      final used = <String>[];
      final result = await session.withToken(alice, (token) async {
        used.add(token);
        if (used.length == 1) {
          throw const P2pError(status: 401, code: P2pError.tokenExpired);
        }
        return 'done';
      });
      expect(result, 'done');
      expect(used, ['token-1', 'token-2']);
      expect(signer.signed, hasLength(2));
      expect(session.cached(alice), 'token-2');
    });

    test('a second 401 is the caller\'s: it does not sign in for ever', () async {
      var calls = 0;
      Object? thrown;
      try {
        await session.withToken(alice, (token) async {
          calls++;
          throw const P2pError(status: 401, code: P2pError.tokenInvalid);
        });
      } on P2pError catch (e) {
        thrown = e;
      }
      expect((thrown as P2pError).code, P2pError.tokenInvalid);
      expect(calls, 2);
      expect(signer.signed, hasLength(2));
    });

    test('any other refusal is passed on with no second sign-in', () async {
      var calls = 0;
      Object? thrown;
      try {
        await session.withToken(alice, (token) async {
          calls++;
          throw const P2pError(status: 400, code: 'bid_too_low');
        });
      } on P2pError catch (e) {
        thrown = e;
      }
      expect((thrown as P2pError).code, 'bid_too_low');
      expect(calls, 1);
      expect(signer.signed, hasLength(1));
      expect(session.cached(alice), 'token-1');
    });
  });

  test('forget drops one address\'s token', () async {
    await session.token(alice);
    await session.token(bob);
    session.forget(alice);
    expect(session.cached(alice), isNull);
    expect(session.cached(bob), 'token-2');
  });

  test('clear drops every token, as when the wallet locks', () async {
    await session.token(alice);
    await session.token(bob);
    session.clear();
    expect(session.cached(alice), isNull);
    expect(session.cached(bob), isNull);
  });

  test('a sign-in under way when the wallet locks does not put its token back', () async {
    final gate = Completer<void>();
    signer.gate = gate.future;
    final pending = session.token(alice);
    await Future<void>.delayed(Duration.zero);
    session.clear();
    gate.complete();
    await pending;
    expect(session.cached(alice), isNull);
  });

  test('refuses a token issued for another address', () async {
    server.respond = (_) => P2pCannedResponse(201, {
          'token': 't',
          'address': bob,
          'expires_at': now.add(const Duration(hours: 1)).toIso8601String(),
        });
    await expectLater(session.token(alice), throwsA(isA<P2pSignInMismatch>()));
    expect(session.cached(alice), isNull);
  });

  test('a signing failure is passed on and nothing is posted or kept', () async {
    signer.error = const P2pSigningError(P2pSigningFailure.walletLocked);
    await expectLater(
      session.token(alice),
      throwsA(isA<P2pSigningError>().having((e) => e.failure, 'failure', P2pSigningFailure.walletLocked)),
    );
    expect(server.requests, isEmpty);
    expect(session.cached(alice), isNull);

    // The failed sign-in does not block the next one.
    signer.error = null;
    expect(await session.token(alice), 'token-1');
  });

  test('a sign-in Spyglass refuses carries its words', () async {
    Future<P2pError> refusedSignIn() async {
      try {
        await session.token(alice);
      } on P2pError catch (e) {
        return e;
      }
      fail('Expected a P2pError');
    }

    server.always(400, {
      'message': ['Message time is not current']
    });
    final stale = await refusedSignIn();
    expect(stale.status, 400);
    expect(stale.code, P2pError.signInRefused);
    expect(stale.message, 'Message time is not current');

    server.always(400, ['Signature is not valid']);
    expect((await refusedSignIn()).message, 'Signature is not valid');
  });

  test('a sign-in answer with no token is a bad response', () async {
    server.always(201, {'address': alice});
    Object? thrown;
    try {
      await session.token(alice);
    } on P2pError catch (e) {
      thrown = e;
    }
    expect((thrown as P2pError).code, P2pError.badResponse);
  });

  test('the app\'s session drops its tokens when the wallet locks', () async {
    final container = ProviderContainer(overrides: [
      p2pServiceProvider.overrideWithValue(P2pService(hostOverride: server.host)),
      p2pSignerProvider.overrideWithValue(signer),
      passwordRequiredProvider.overrideWith((ref) => StubPasswordRequired()),
    ]);
    addTearDown(container.dispose);

    final appSession = container.read(p2pSessionProvider);
    final token = await appSession.token(alice);
    expect(appSession.cached(alice), token);

    container.read(passwordRequiredProvider.notifier).markRequired();
    expect(appSession.cached(alice), isNull);
  });
}
