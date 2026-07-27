import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/services/base_service.dart';
import '../../../l10n/l10n_helper.dart';
import '../models/bridge_lock_record.dart';
import '../models/bridge_lock_request.dart';
import '../models/bridge_preflight.dart';

const _tag = '[vBTC-Bridge]';

void _log(String method, String message, [Map<String, dynamic>? json]) {
  final prefix = '$_tag $method';
  if (json != null) {
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('$prefix $message:\n${encoder.convert(json)}');
  } else {
    debugPrint('$prefix $message');
  }
}

/// Endpoints for the vBTC → Base bridge.
///
/// The CLI exposes these on two different controllers:
/// - Wallet-style endpoints under `/wallet/api/vbtc/bridge/...`
///   (preflight, toBase, status, retry, base-balance)
/// - `GetBridgeLocksByOwner` lives on `VBTCController` at
///   `/vbtcapi/vbtc/GetBridgeLocksByOwner/{owner}` — proxied via the
///   nested [_VbtcControllerProxy] below.
///
/// Note: the spec called this class `BridgeService`, but that name is already
/// taken by `lib/features/bridge/services/bridge_service.dart` (the generic
/// CLI wrapper used in 30+ places across the app). Renamed to
/// `VbtcBridgeService` to avoid the collision.
class VbtcBridgeService extends BaseService {
  VbtcBridgeService() : super(apiBasePathOverride: "/wallet/api/vbtc/bridge");

  final _VbtcControllerProxy _vbtcController = _VbtcControllerProxy();

  /// `GET /wallet/api/vbtc/bridge/preflight/{ownerAddress}/{scUID}`
  ///
  /// Returns the gas / balance / network preflight data the dialog needs to
  /// render the form. Returns `null` on transport or parse failure so the UI
  /// can show its "retry" state. Throws on connection errors.
  Future<BridgePreflight?> preflight(String ownerAddress, String scUid) async {
    const method = 'preflight';
    _log(method, 'GET /preflight/$ownerAddress/$scUid');

    try {
      final data = await getJson(
        "/preflight/$ownerAddress/$scUid",
        cleanPath: false,
      );

      _log(method, 'RESPONSE', data);

      final preflight = BridgePreflight.fromJson(data);
      if (!preflight.success) {
        _log(method, 'FAILED: ${preflight.message ?? "preflight returned success=false"}');
      }
      return preflight;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      rethrow;
    }
  }

  /// `POST /wallet/api/vbtc/bridge/toBase`
  ///
  /// Initiates the lock on VFX. The endpoint returns only `{success, lockId,
  /// ...}` so we immediately call [getStatus] to fetch the full
  /// [BridgeLockRecord] for the caller. Returns `null` on any failure (toast
  /// already shown — caller can surface error via UI state).
  Future<BridgeLockRecord?> initiateLock(BridgeLockRequest req) async {
    const method = 'initiateLock';
    final params = req.toJson();
    _log(method, 'POST /toBase', params);

    try {
      final response = await postJson(
        "/toBase",
        params: params,
        cleanPath: false,
      );

      // postJson wraps the decoded body under `data`.
      final raw = response['data'];
      final Map<String, dynamic> data =
          raw is Map<String, dynamic> ? raw : (raw is String ? jsonDecode(raw) : {});
      _log(method, 'RESPONSE', data);

      if (data['success'] != true) {
        _log(method, 'FAILED: ${data['message']}');
        return null;
      }

      final lockId = data['lockId'] as String?;
      if (lockId == null || lockId.isEmpty) {
        _log(method, 'FAILED: response missing lockId');
        return null;
      }

      // Fetch the full record so the caller has the same shape as
      // subsequent polls.
      return await getStatus(lockId);
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      return null;
    }
  }

  /// `GET /wallet/api/vbtc/bridge/status/{lockId}`
  Future<BridgeLockRecord?> getStatus(String lockId) async {
    const method = 'getStatus';

    try {
      final data = await getJson(
        "/status/$lockId",
        cleanPath: false,
      );

      // Trim noise from status polls — only log misses.
      if (data['success'] != true) {
        _log(method, 'FAILED for $lockId: ${data['message']}', data);
        return null;
      }

      return BridgeLockRecord.fromUnifiedJson(data);
    } catch (e, st) {
      _log(method, 'EXCEPTION for $lockId: $e\n$st');
      return null;
    }
  }

  /// `GET /vbtcapi/vbtc/GetBridgeLocksByOwner/{ownerAddress}`
  ///
  /// Returns all locks for an owner across every contract. Caller filters by
  /// `scUID` when needed.
  ///
  /// **Throws** [BridgeServiceException] on transport errors or when the CLI
  /// reports `Success: false`. Returns an empty list only when the CLI
  /// genuinely has no locks for the owner. This lets [BridgeLockListNotifier]
  /// distinguish "loaded and empty" from "couldn't load."
  ///
  /// Note: this endpoint lives on `VBTCController`, not the wallet API used by
  /// the other bridge methods — see [_VbtcControllerProxy].
  Future<List<BridgeLockRecord>> getLocksByOwner(String ownerAddress) async {
    const method = 'getLocksByOwner';
    _log(method, 'GET /vbtcapi/vbtc/GetBridgeLocksByOwner/$ownerAddress');

    final Map<String, dynamic> data;
    try {
      data = await _vbtcController.getJson(
        "/GetBridgeLocksByOwner/$ownerAddress",
        cleanPath: false,
      );
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      throw BridgeServiceException(globalL10n.r3fBridgeUnreachable, cause: e);
    }

    if (data['Success'] != true) {
      final msg = data['Message']?.toString() ?? globalL10n.r3fBridgeHistoryUnavailable;
      _log(method, 'FAILED: $msg');
      throw BridgeServiceException(msg);
    }

    final rawLocks = data['Locks'];
    if (rawLocks is! List) {
      _log(method, 'No Locks array in response');
      return [];
    }

    final locks = <BridgeLockRecord>[];
    for (final item in rawLocks) {
      if (item is Map<String, dynamic>) {
        try {
          locks.add(BridgeLockRecord.fromUnifiedJson(item));
        } catch (e) {
          _log(method, 'Failed to parse lock entry: $e');
        }
      }
    }
    _log(method, 'Parsed ${locks.length} locks');
    return locks;
  }

  /// `POST /wallet/api/vbtc/bridge/retry/{lockId}/{ownerAddress}`
  ///
  /// Retries a failed or stuck mint. Returns true when the CLI reports
  /// `success: true`.
  Future<bool> retryMint(String lockId, String ownerAddress) async {
    const method = 'retryMint';
    _log(method, 'POST /retry/$lockId/$ownerAddress');

    try {
      final response = await postJson(
        "/retry/$lockId/$ownerAddress",
        cleanPath: false,
      );

      final raw = response['data'];
      final Map<String, dynamic> data =
          raw is Map<String, dynamic> ? raw : (raw is String ? jsonDecode(raw) : {});
      _log(method, 'RESPONSE', data);

      if (data['success'] == true) return true;

      _log(method, 'FAILED: ${data['message']}');
      return false;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      return false;
    }
  }

  /// `GET /wallet/api/vbtc/bridge/base-balance/{evmAddress}`
  ///
  /// Returns the vBTC.b balance for a Base EVM address, or null on failure.
  Future<double?> getBaseBalance(String evmAddress) async {
    const method = 'getBaseBalance';
    _log(method, 'GET /base-balance/$evmAddress');

    try {
      final data = await getJson(
        "/base-balance/$evmAddress",
        cleanPath: false,
      );

      if (data['success'] != true) {
        _log(method, 'FAILED: ${data['message']}');
        return null;
      }

      // The wallet endpoint sends balance as a culture-invariant string.
      final raw = data['balance'];
      if (raw == null) return null;
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw);
      return null;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      return null;
    }
  }
}

/// Internal proxy for the one bridge endpoint that lives on `VBTCController`
/// instead of the wallet API. Same pattern as `VbtcV2Service` — points at the
/// `/vbtcapi/vbtc` route prefix.
class _VbtcControllerProxy extends BaseService {
  _VbtcControllerProxy() : super(apiBasePathOverride: "/vbtcapi/vbtc");
}

/// Surfaced by [VbtcBridgeService.getLocksByOwner] when the CLI is
/// unreachable or returns a failure response. Provider/UI layers catch this
/// to distinguish "real error" from "successfully fetched, empty list."
class BridgeServiceException implements Exception {
  final String message;
  final Object? cause;

  BridgeServiceException(this.message, {this.cause});

  @override
  String toString() =>
      cause == null ? 'BridgeServiceException: $message' : 'BridgeServiceException: $message ($cause)';
}
