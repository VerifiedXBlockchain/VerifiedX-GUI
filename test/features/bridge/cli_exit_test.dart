import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/bridge/utils/cli_exit.dart';

void main() {
  group('waitUntilCliStops', () {
    test('returns true once the CLI stops answering', () async {
      var polls = 0;
      final stopped = await waitUntilCliStops(
        () async => ++polls < 3,
        maxWait: const Duration(seconds: 1),
        interval: const Duration(milliseconds: 1),
      );

      expect(stopped, isTrue);
      expect(polls, 3);
    });

    test('returns false when the CLI keeps answering past the deadline',
        () async {
      var polls = 0;
      final stopped = await waitUntilCliStops(
        () async {
          polls++;
          return true;
        },
        maxWait: const Duration(milliseconds: 200),
        interval: const Duration(milliseconds: 10),
      );

      expect(stopped, isFalse);
      expect(polls, greaterThanOrEqualTo(1));
    });
  });

  group('isCredentialRefusal', () {
    test('treats 401 and 403 from the node as a refusal', () {
      expect(isCredentialRefusal(_statusError(401)), isTrue);
      expect(isCredentialRefusal(_statusError(403)), isTrue);
    });

    test('treats other failures as the CLI being gone', () {
      expect(isCredentialRefusal(_statusError(500)), isFalse);
      expect(isCredentialRefusal(_connectionError()), isFalse);
      expect(isCredentialRefusal(Exception('socket closed')), isFalse);
    });
  });

  group('exitCli', () {
    const interval = Duration(milliseconds: 5);

    test('does not terminate the CLI when SendExit is accepted', () async {
      var polls = 0;
      var terminated = false;
      final stopped = await exitCli(
        sendExit: () => Future.error(_connectionError()),
        stillAnswering: () async => ++polls < 2,
        terminateLaunchedCli: () async => terminated = true,
        maxWait: const Duration(seconds: 1),
        interval: interval,
      );

      expect(stopped, isTrue);
      expect(terminated, isFalse);
    });

    test('accepts a SendExit future typed like the HTTP client', () async {
      // BridgeService.getText returns Future<String>. The connection error
      // that means "exit accepted" must not surface as an unhandled error.
      var polls = 0;
      var terminated = false;
      final stopped = await exitCli(
        sendExit: () => Future<String>.error(_connectionError()),
        stillAnswering: () async => ++polls < 2,
        terminateLaunchedCli: () async => terminated = true,
        maxWait: const Duration(seconds: 1),
        interval: interval,
      );

      expect(stopped, isTrue);
      expect(terminated, isFalse);
    });

    test('terminates the launched CLI once when SendExit is refused', () async {
      var terminations = 0;
      final stopped = await exitCli(
        sendExit: () => Future.error(_statusError(401)),
        stillAnswering: () async => terminations == 0,
        terminateLaunchedCli: () async {
          terminations++;
          return true;
        },
        maxWait: const Duration(seconds: 1),
        interval: interval,
      );

      expect(stopped, isTrue);
      expect(terminations, 1);
    });

    test('reports a CLI that keeps answering after a refused exit', () async {
      var terminations = 0;
      final stopped = await exitCli(
        sendExit: () => Future.error(_statusError(403)),
        stillAnswering: () async => true,
        terminateLaunchedCli: () async {
          terminations++;
          return false;
        },
        maxWait: const Duration(milliseconds: 100),
        interval: interval,
      );

      expect(stopped, isFalse);
      expect(terminations, 1);
    });
  });
}

DioException _statusError(int statusCode) {
  final options = RequestOptions(path: '/SendExit');
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: statusCode),
    type: DioExceptionType.badResponse,
  );
}

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/SendExit'),
      type: DioExceptionType.connectionError,
    );
