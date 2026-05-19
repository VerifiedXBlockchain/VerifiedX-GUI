import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bridge_lock_record.dart';
import '../services/vbtc_bridge_service.dart';

const _tag = '[vBTC-Bridge] LockList';

/// Auto-refresh cadence while any record in the list is still in flight.
@visibleForTesting
const kBridgeListRefreshInterval = Duration(seconds: 30);

/// History list of every bridge lock for a single owner address, newest first.
///
/// Behavior:
///   - loads on construction
///   - auto-refreshes every 30s while at least one record is non-terminal
///   - timer pauses itself once every record is terminal, restarts on next
///     `refresh()` if new in-flight records appear
///   - public `refresh()` for pull-to-refresh / manual button
///   - sorts results by `createdAtUtc` descending so the most recent bridge
///     is the first item — Phase 5's history view can render directly without
///     extra ordering logic
class BridgeLockListNotifier extends StateNotifier<List<BridgeLockRecord>> {
  BridgeLockListNotifier(this.ownerAddress) : super(const []) {
    _bootstrap();
  }

  final String ownerAddress;
  Timer? _refreshTimer;
  bool _isFetching = false;
  bool _hasLoaded = false;
  Object? _error;

  /// True once the initial fetch (or any subsequent fetch) has completed —
  /// either successfully or with an error captured in [error].
  /// Lets callers distinguish "still loading the first batch" from
  /// "loaded and the list really is empty" — both look the same in `state`.
  bool get hasLoaded => _hasLoaded;

  /// Non-null when the last fetch failed. Cleared on the next successful
  /// fetch. Lets the UI render a dedicated error state with a Retry button
  /// instead of mistaking a transport failure for an empty history.
  Object? get error => _error;

  Future<void> _bootstrap() async {
    await _fetchOnce();
    _maybeScheduleAutoRefresh();
  }

  /// Public manual refresh. Always re-fetches and re-arms the auto-refresh
  /// timer if any newly-fetched record is non-terminal.
  Future<List<BridgeLockRecord>> refresh() async {
    final list = await _fetchOnce();
    _maybeScheduleAutoRefresh();
    return list;
  }

  Future<List<BridgeLockRecord>> _fetchOnce() async {
    if (!mounted) return state;
    if (_isFetching) return state;
    _isFetching = true;
    try {
      debugPrint('$_tag $ownerAddress fetch');
      final list = await VbtcBridgeService().getLocksByOwner(ownerAddress);
      if (!mounted) return state;
      final sorted = [...list]
        ..sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
      // Clear any prior error and re-emit state. Even if `sorted` equals the
      // current state, we want to notify so widgets that watch `error`
      // re-render with the cleared value.
      _error = null;
      state = sorted;
      _hasLoaded = true;
      return sorted;
    } catch (e, st) {
      debugPrint('$_tag $ownerAddress fetch FAILED: $e\n$st');
      if (!mounted) return state;
      _error = e;
      _hasLoaded = true;
      // Force a state-notification so widgets reading `error` (which only
      // re-render when state changes) pick up the new error. Re-assigning
      // the same list isn't enough — Riverpod's StateNotifier uses
      // identity, and `state = state` doesn't notify. Use a fresh copy.
      state = List<BridgeLockRecord>.from(state);
      return state;
    } finally {
      _isFetching = false;
    }
  }

  void _maybeScheduleAutoRefresh() {
    final hasInFlight = state.any((r) => !r.isTerminal);
    if (!hasInFlight) {
      if (_refreshTimer != null) {
        debugPrint('$_tag $ownerAddress all terminal — auto-refresh paused');
      }
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }
    _refreshTimer ??= Timer.periodic(kBridgeListRefreshInterval, (_) async {
      if (!mounted) return;
      await _fetchOnce();
      if (mounted && !state.any((r) => !r.isTerminal)) {
        debugPrint('$_tag $ownerAddress drained — auto-refresh stopped');
        _refreshTimer?.cancel();
        _refreshTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }
}

/// All bridge locks for a given owner, newest first.
final bridgeLockListProvider =
    StateNotifierProvider.family<BridgeLockListNotifier, List<BridgeLockRecord>, String>(
  (ref, ownerAddress) => BridgeLockListNotifier(ownerAddress),
);
