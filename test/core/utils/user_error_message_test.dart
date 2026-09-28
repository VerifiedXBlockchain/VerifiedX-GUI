import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/services/locked_wallet_gate.dart';
import 'package:rbx_wallet/core/utils/user_error_message.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

final _options = RequestOptions(path: '/RequestWithdrawal');

DioException badResponse(int status, dynamic body) => DioException.badResponse(
      statusCode: status,
      requestOptions: _options,
      response: Response(requestOptions: _options, statusCode: status, data: body),
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    rootNavigatorKey = GlobalKey<NavigatorState>();
  });

  group('userErrorMessage (English)', () {
    test('shows the node text of a plain-text error body', () {
      final e = badResponse(400, 'Bitcoin transaction failed: Fee 5000 exceeds 10% of amount');
      expect(userErrorMessage(e), 'Bitcoin transaction failed: Fee 5000 exceeds 10% of amount');
    });

    test('reads Message / message / detail from a JSON body', () {
      expect(userErrorMessage(badResponse(500, {'Success': false, 'Message': 'Preflight error: no UTXOs'})),
          'Preflight error: no UTXOs');
      expect(
          userErrorMessage(badResponse(500, {
            'success': false,
            'message': 'A withdrawal is already in progress for contract abc',
            'raw': {},
          })),
          'A withdrawal is already in progress for contract abc');
      expect(userErrorMessage(badResponse(404, {'detail': 'Not found.'})), 'Not found.');
      expect(userErrorMessage(badResponse(400, '{"Message":"Insufficient balance"}')), 'Insufficient balance');
      expect(userErrorMessage(badResponse(401, '"You must type in your encryption password first!"')),
          'You must type in your encryption password first!');
    });

    test('falls back to a generic message for an unreadable body', () {
      expect(userErrorMessage(badResponse(502, '<html><body>Bad gateway</body></html>')),
          'The request failed. Please try again.');
      expect(userErrorMessage(badResponse(500, {'raw': 1})), 'The request failed. Please try again.');
      expect(userErrorMessage(badResponse(500, '')), 'The request failed. Please try again.');
      expect(userErrorMessage(badResponse(500, null), fallback: 'Failed to transfer'), 'Failed to transfer');
    });

    test('connection problems say the server could not be reached', () {
      expect(userErrorMessage(DioException.connectionError(requestOptions: _options, reason: 'refused')),
          'Could not reach the server. Check your connection and try again.');
      expect(
          userErrorMessage(DioException.receiveTimeout(
            requestOptions: _options,
            timeout: const Duration(seconds: 30),
          )),
          'Could not reach the server. Check your connection and try again.');
    });

    test('wallet locked gives the translated locked message', () {
      final e = WalletLockedException(badResponse(401, lockedWalletNodeMessage));
      expect(userErrorMessage(e), 'Your wallet is locked. Unlock it with your password and try again.');
    });

    test('unwraps Exception("...") and thrown strings', () {
      expect(userErrorMessage(Exception('Only the original requestor can cancel')),
          'Only the original requestor can cancel');
      expect(userErrorMessage('Error sending V2 transfer'), 'Error sending V2 transfer');
    });

    test('never shows a Dio dump or an arbitrary error', () {
      final wrapped = Exception(badResponse(401, null).toString());
      expect(userErrorMessage(wrapped), 'The request failed. Please try again.');
      expect(userErrorMessage(StateError('bad state')), 'The request failed. Please try again.');
      expect(userErrorMessage(ArgumentError('x'), fallback: 'Fallback'), 'Fallback');

      for (final e in [
        badResponse(401, null),
        badResponse(500, '<html/>'),
        DioException.connectionError(requestOptions: _options, reason: 'refused'),
        wrapped,
      ]) {
        expect(userErrorMessage(e), isNot(contains('DioException')));
      }
    });

    test('long node text is shortened', () {
      final text = 'x' * 1000;
      expect(userErrorMessage(badResponse(500, text)).length, lessThan(410));
    });
  });

  testWidgets('Spanish UI adds a Spanish lead-in to node text', (tester) async {
    final key = GlobalKey<NavigatorState>();
    rootNavigatorKey = key;
    addTearDown(() => rootNavigatorKey = GlobalKey<NavigatorState>());

    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      locale: const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SizedBox.shrink(),
    ));

    expect(userErrorMessage(badResponse(400, 'A withdrawal is already in progress for contract abc')),
        'Mensaje del nodo: A withdrawal is already in progress for contract abc');
    expect(
        userErrorMessage(badResponse(400, 'A withdrawal is already in progress'), withLeadIn: false),
        'A withdrawal is already in progress');
    expect(userErrorMessage(WalletLockedException(badResponse(401, lockedWalletNodeMessage))),
        'Tu billetera está bloqueada. Desbloquéala con tu contraseña e inténtalo de nuevo.');
    expect(userErrorMessage(badResponse(500, null)), 'La solicitud falló. Inténtalo de nuevo.');

    // A refusal inside a 200 reply ({"Success": false, "Message": ...}) gets the same lead-in (QA T2c).
    const floor = 'vBTC V2 withdrawal request: 0.0000001 BTC cannot pay a Bitcoin withdrawal at 12 sat/vB.';
    expect(nodeRefusalMessage({'Success': false, 'Message': floor}, fallback: 'x'), 'Mensaje del nodo: $floor');
    expect(nodeRefusalMessage(floor, fallback: 'x'), 'Mensaje del nodo: $floor');
    expect(nodeRefusalMessage({'Success': false}, fallback: 'Sin motivo'), 'Sin motivo');
  });

  group('nodeRefusalMessage (English)', () {
    test('shows the Message of a 2xx refusal as is', () {
      expect(nodeRefusalMessage({'Success': false, 'Message': 'Insufficient balance. Available: -0.00070'}, fallback: 'x'),
          'Insufficient balance. Available: -0.00070');
    });

    test('falls back when there is no readable reason', () {
      expect(nodeRefusalMessage(null, fallback: 'Failed to request withdrawal.'), 'Failed to request withdrawal.');
      expect(nodeRefusalMessage({'Success': false, 'Message': '  '}, fallback: 'fb'), 'fb');
      expect(nodeRefusalMessage('DioException [bad response]: ...', fallback: 'fb'), 'fb');
    });
  });
}
