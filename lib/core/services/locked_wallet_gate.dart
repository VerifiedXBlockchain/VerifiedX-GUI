import 'dart:async';

import 'package:dio/dio.dart';

import '../../l10n/l10n_helper.dart';

/// Body of the 401 the node's LockedWalletPolicy returns for every route that
/// is not allowed while an encrypted wallet is locked (Core
/// ActionFilterController.LockedWalletMessage).
const lockedWalletNodeMessage = "You must type in your encryption password first!";

/// True when [error] is the node refusing a call because the encrypted wallet
/// is locked (HTTP 401 carrying [lockedWalletNodeMessage]).
bool isLockedWalletResponse(Object error) {
  if (error is! DioException) {
    return false;
  }
  final response = error.response;
  if (response?.statusCode != 401) {
    return false;
  }
  final body = response?.data;
  final text = body is String ? body : body?.toString() ?? '';
  return text.contains('encryption password first');
}

/// Thrown when a node call was refused because the wallet is locked and the
/// user did not unlock it. It is a [DioException] so existing
/// `on DioException` handlers still see it (with the node's 401 response),
/// and its [toString] is the translated "wallet is locked" message, so the
/// many call sites that toast `e.toString()` show that instead of a Dio dump.
class WalletLockedException extends DioException {
  WalletLockedException(DioException cause)
      : super(
          requestOptions: cause.requestOptions,
          response: cause.response,
          type: cause.type,
          error: cause.error,
          stackTrace: cause.stackTrace,
          message: globalL10n.errWalletLocked,
        );

  @override
  String toString() => message ?? globalL10n.errWalletLocked;
}

/// Asks the user for the wallet password and unlocks the node. Returns true
/// once the node is unlocked.
typedef LockedWalletUnlocker = Future<bool> Function();

/// Central handling of the node's locked-wallet 401 for native node calls
/// (MTI#8): prompt once, unlock, retry the refused request once.
class LockedWalletGate {
  LockedWalletGate._();

  /// Registered by the native app once the provider scope exists. Null (web,
  /// tests, early startup) means a locked-wallet 401 is passed through as a
  /// [WalletLockedException] without prompting.
  static LockedWalletUnlocker? unlocker;

  static Future<bool>? _pending;
  static int _unlockGeneration = 0;

  static const _unlockingZoneKey = #lockedWalletGateUnlocking;

  /// Requests made by the unlock flow itself must never wait for the unlock
  /// they are part of.
  static bool get _insideUnlock => Zone.current[_unlockingZoneKey] == true;

  /// Runs [unlocker], or joins the prompt already on screen, so concurrent
  /// refused requests share one prompt.
  static Future<bool> requestUnlock() {
    final existing = _pending;
    if (existing != null) {
      return existing;
    }
    final u = unlocker;
    if (u == null) {
      return Future.value(false);
    }

    final future = runZoned(
      () => u(),
      zoneValues: {_unlockingZoneKey: true},
    ).then((unlocked) {
      if (unlocked) {
        _unlockGeneration++;
      }
      return unlocked;
    }, onError: (Object e) {
      print("Locked wallet unlock failed: $e");
      return false;
    }).whenComplete(() => _pending = null);

    _pending = future;
    return future;
  }

  /// Sends [request]. If the node refuses it because the wallet is locked,
  /// prompts for the password (once, shared with concurrent refusals) and
  /// sends it again once after a successful unlock. When the user cancels or
  /// the unlock fails, throws a [WalletLockedException].
  static Future<T> run<T>(Future<T> Function() request, {bool enabled = true}) async {
    final generation = _unlockGeneration;
    try {
      return await request();
    } catch (e) {
      if (!enabled || _insideUnlock || !isLockedWalletResponse(e)) {
        rethrow;
      }

      // Another request's prompt already unlocked the wallet while this one
      // was in flight: just send it again.
      final unlocked = generation != _unlockGeneration || await requestUnlock();
      if (!unlocked) {
        throw WalletLockedException(e as DioException);
      }
    }

    try {
      return await request();
    } catch (e) {
      if (isLockedWalletResponse(e)) {
        throw WalletLockedException(e as DioException);
      }
      rethrow;
    }
  }
}
