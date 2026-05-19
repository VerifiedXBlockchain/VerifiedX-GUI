import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bridge_lock_record.dart';
import '../services/vbtc_bridge_service.dart';

const _tag = '[vBTC-Bridge] Operation';

/// Polling interval while a bridge operation is still in flight. Exposed for
/// tests; production code should not import this.
@visibleForTesting
const kBridgeOperationPollInterval = Duration(seconds: 5);

/// Live state for a single bridge operation.
///
/// On construction:
///   - immediately fetches the current status
///   - starts polling every 5s while the record is non-terminal
///   - stops polling once `state.isTerminal == true`
///   - cancels the timer on dispose
///
/// The notifier uses `BridgeLockRecord.isTerminal` (the model's helper) for the
/// stop condition rather than hard-coding a status list — that way new terminal
/// statuses (like `Expired`) added to the model are honored automatically.
class BridgeOperationNotifier extends StateNotifier<BridgeLockRecord?> {
  BridgeOperationNotifier(this.lockId) : super(null) {
    _bootstrap();
  }

  final String lockId;
  Timer? _pollingTimer;
  bool _isFetching = false;

  Future<void> _bootstrap() async {
    await _fetchOnce(initial: true);
    _maybeStartPolling();
  }

  /// Public manual refresh — useful after a user-initiated retry so the UI
  /// doesn't have to wait up to 5s for the next scheduled poll.
  Future<BridgeLockRecord?> refresh() async {
    final record = await _fetchOnce(initial: false);
    _maybeStartPolling();
    return record;
  }

  Future<BridgeLockRecord?> _fetchOnce({required bool initial}) async {
    if (!mounted) return null;
    if (_isFetching) return state;
    _isFetching = true;
    try {
      debugPrint('$_tag $lockId ${initial ? "initial fetch" : "poll"}');
      final record = await VbtcBridgeService().getStatus(lockId);
      if (!mounted) return null;
      if (record != null) {
        state = record;
      }
      return record;
    } finally {
      _isFetching = false;
    }
  }

  void _maybeStartPolling() {
    final current = state;
    if (current?.isTerminal == true) {
      debugPrint('$_tag $lockId terminal (${current?.statusRaw}) — polling stopped');
      _pollingTimer?.cancel();
      _pollingTimer = null;
      return;
    }
    _pollingTimer ??= Timer.periodic(kBridgeOperationPollInterval, (_) async {
      final record = await _fetchOnce(initial: false);
      if (record?.isTerminal == true) {
        debugPrint('$_tag $lockId reached terminal — stopping polling');
        _pollingTimer?.cancel();
        _pollingTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    super.dispose();
  }
}

/// Live, polling-backed status for a single bridge operation, keyed by
/// `lockId`. Watch in the UI like:
///
/// ```dart
/// final record = ref.watch(bridgeOperationProvider(lockId));
/// ```
///
/// Returns `null` on the very first frame before the initial fetch completes.
final bridgeOperationProvider =
    StateNotifierProvider.family<BridgeOperationNotifier, BridgeLockRecord?, String>(
  (ref, lockId) => BridgeOperationNotifier(lockId),
);
