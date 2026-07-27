import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../transactions/models/transaction_notification.dart';
import '../../transactions/providers/transaction_notification_provider.dart';
import '../components/bridge_format.dart';
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
/// stop condition rather than hard-coding a status list — so new terminal
/// statuses (like `Expired`) added to the model are honored automatically.
///
/// Also fires a one-shot toast/notification (via [transactionNotificationProvider])
/// the first time we observe a transition from non-terminal → terminal. The
/// guard prevents re-firing if the user re-opens an already-terminal record
/// from history.
class BridgeOperationNotifier extends StateNotifier<BridgeLockRecord?> {
  BridgeOperationNotifier(this.ref, this.lockId) : super(null) {
    _bootstrap();
  }

  final Ref ref;
  final String lockId;
  Timer? _pollingTimer;
  bool _isFetching = false;

  /// True once we've already surfaced a terminal-state notification for this
  /// lock. Prevents duplicate toasts if a poll happens to land on the same
  /// terminal state more than once (e.g. retry → fail → poll → poll).
  bool _firedTerminalNotification = false;

  /// True if the very first fetch observed a terminal record. In that case
  /// the user is just looking at history — don't notify them about an
  /// already-finished bridge.
  bool _firstFetchSawTerminal = false;

  /// Consecutive polls that came back null after we had successfully fetched
  /// at least one record. The service swallows transport errors and returns
  /// null on failure; tracking this distinguishes "lock disappeared" from
  /// "we briefly lost connectivity." See [isReconnecting].
  int _consecutiveFailures = 0;

  /// True once the polling has hit ≥2 consecutive null responses after the
  /// initial successful fetch. Surfaced by `BridgeProgress` as a small
  /// "Reconnecting…" banner (UX § 6 — "Network drops during polling").
  bool get isReconnecting => state != null && _consecutiveFailures >= 2;

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
      final wasTerminal = state?.isTerminal == true;
      final record = await VbtcBridgeService().getStatus(lockId);
      if (!mounted) return null;
      if (record != null) {
        if (initial && record.isTerminal) {
          _firstFetchSawTerminal = true;
        }
        _consecutiveFailures = 0;
        state = record;
        _maybeFireTerminalNotification(wasTerminal: wasTerminal, record: record);
      } else if (state != null) {
        // We had a record before and now we don't — almost certainly a
        // transport blip rather than the lock disappearing. Count toward
        // the reconnecting threshold and re-emit state with a new
        // identity so widgets watching the notifier re-render and see
        // the updated `isReconnecting` value.
        _consecutiveFailures++;
        debugPrint('$_tag $lockId poll returned null (failures: $_consecutiveFailures)');
        final current = state;
        if (current != null) {
          state = current.copyWith();
        }
      }
      return record;
    } finally {
      _isFetching = false;
    }
  }

  void _maybeFireTerminalNotification({
    required bool wasTerminal,
    required BridgeLockRecord record,
  }) {
    if (_firedTerminalNotification) return;
    if (!record.isTerminal) return;
    if (_firstFetchSawTerminal && !wasTerminal) {
      // Edge: first fetch landed on terminal — don't notify; user is
      // viewing history.
      _firedTerminalNotification = true;
      return;
    }
    if (wasTerminal) {
      // Already in a terminal state; this happens if the user retries and
      // we poll again into a terminal state. Don't double-notify.
      _firedTerminalNotification = true;
      return;
    }

    _firedTerminalNotification = true;

    final notification = record.isSuccessful
        ? TransactionNotification(
            identifier: "bridge_${record.lockId}_minted",
            title: "Bridge complete",
            body: "${formatVbtc(record.amount)} vBTC.b minted on Base.",
            icon: Icons.check_circle,
            color: AppColorVariant.Success,
          )
        : TransactionNotification(
            identifier: "bridge_${record.lockId}_failed",
            title: "Bridge failed",
            body: record.errorMessage ?? "Open Bridge History for details.",
            icon: Icons.error_outline,
            color: AppColorVariant.Danger,
          );
    ref.read(transactionNotificationProvider.notifier).add(notification);
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
  (ref, lockId) => BridgeOperationNotifier(ref, lockId),
);
