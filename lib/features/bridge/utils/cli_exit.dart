import 'dart:async';

import 'package:dio/dio.dart';

/// True when [error] is the node refusing a request for lack of credentials:
/// 401 while an encrypted wallet is locked, or 403 when the apitoken header
/// does not match. A refusal proves the CLI is still running.
bool isCredentialRefusal(Object error) {
  if (error is! DioException) {
    return false;
  }
  final status = error.response?.statusCode;
  return status == 401 || status == 403;
}

/// Asks the CLI to exit and waits until it has gone. When the node refuses
/// the exit request (a locked wallet refuses SendExit with 401), the process
/// this GUI launched is terminated instead, so quitting never leaves a CLI
/// running in the background. Returns true once the CLI stops answering,
/// false if it is still answering when [maxWait] runs out.
Future<bool> exitCli({
  required Future<void> Function() sendExit,
  required Future<bool> Function() stillAnswering,
  required Future<bool> Function() terminateLaunchedCli,
  Duration maxWait = const Duration(seconds: 15),
  Duration interval = const Duration(milliseconds: 500),
}) {
  var exitRefused = false;
  var terminationRequested = false;

  // SendExit never completes its response when it is accepted (the process
  // exits mid-request), so its connection error is expected and discarded.
  // Caught with await rather than catchError: the future the HTTP client
  // returns is a Future<String>, so a catchError handler would have to
  // return a String or fail with an ArgumentError.
  unawaited(() async {
    try {
      await sendExit();
    } catch (error) {
      if (isCredentialRefusal(error)) {
        exitRefused = true;
      }
    }
  }());

  return waitUntilCliStops(
    () async {
      if (exitRefused && !terminationRequested) {
        terminationRequested = true;
        await terminateLaunchedCli();
      }
      return stillAnswering();
    },
    maxWait: maxWait,
    interval: interval,
  );
}

/// Polls [stillAnswering] until the CLI stops responding or [maxWait]
/// elapses. Returns true once the CLI is gone, false on timeout.
///
/// The CLI's SendExit handler sleeps two seconds, waits for any in-flight
/// trie update, and only then records a clean shutdown. Quitting the GUI
/// before that point flags the next launch as an improper shutdown, which
/// triggers a full state rebuild that zeros every balance while it replays.
Future<bool> waitUntilCliStops(
  Future<bool> Function() stillAnswering, {
  Duration maxWait = const Duration(seconds: 15),
  Duration interval = const Duration(milliseconds: 500),
}) async {
  final deadline = DateTime.now().add(maxWait);
  while (DateTime.now().isBefore(deadline)) {
    await Future.delayed(interval);
    if (!await stillAnswering()) {
      return true;
    }
  }
  return false;
}
