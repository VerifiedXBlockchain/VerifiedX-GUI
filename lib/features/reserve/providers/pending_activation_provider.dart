import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallet/models/wallet.dart';

/// An activation that was sent but never shows up on chain stops hiding the
/// manual "Activate Now" button after this long.
const Duration PENDING_ACTIVATION_EXPIRY = Duration(minutes: 10);

class PendingActivationProvider extends StateNotifier<List<String>> {
  final DateTime Function() _now;
  final Map<String, DateTime> _addedAt = {};

  PendingActivationProvider({DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super([]);

  addId(String id) {
    _addedAt[id] = _now();
    if (!state.contains(id)) {
      state = [...state, id];
    }
  }

  removeId(String id) {
    _addedAt.remove(id);
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
    }
  }

  /// Clears ids whose Vault is activated, and ids that waited longer than
  /// [PENDING_ACTIVATION_EXPIRY] with no queued auto-activation behind them,
  /// so the manual activate path comes back.
  void prune(List<Wallet> vaults, {Set<String> queuedAddresses = const {}}) {
    final now = _now();
    final remaining = state.where((id) {
      final matches = vaults.where((w) => w.address == id);
      if (matches.isNotEmpty && matches.first.isNetworkProtected) {
        return false;
      }
      if (queuedAddresses.contains(id)) {
        return true;
      }
      final addedAt = _addedAt[id];
      return addedAt != null && now.difference(addedAt) <= PENDING_ACTIVATION_EXPIRY;
    }).toList();

    if (remaining.length != state.length) {
      _addedAt.removeWhere((id, _) => !remaining.contains(id));
      state = remaining;
    }
  }
}

final pendingActivationProvider = StateNotifierProvider<PendingActivationProvider, List<String>>(
  (_) => PendingActivationProvider(),
);
