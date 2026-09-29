import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingTokenPauseProvider extends StateNotifier<List<String>> {
  PendingTokenPauseProvider() : super([]);

  addId(String id) {
    state = [...state, id];
  }

  removeId(String id) {
    state = [...state]..removeWhere((i) => i == id);
  }
}

final pendingTokenPauseProvider = StateNotifierProvider<PendingTokenPauseProvider, List<String>>(
  (_) => PendingTokenPauseProvider(),
);

/// Web counterpart of [pendingTokenPauseProvider]. The web has no transaction
/// signal to clear the entry, so it keeps the paused state each broadcast asked
/// for (keyed by smart contract id) and treats the change as pending until the
/// polled token detail reports that state.
class WebPendingTokenPauseProvider extends StateNotifier<Map<String, bool>> {
  WebPendingTokenPauseProvider() : super({});

  void add(String scId, {required bool requestedPaused}) {
    state = {...state, scId: requestedPaused};
  }

  /// Drops the entry once the chain reports the requested state.
  void resolve(String scId, {required bool isPaused}) {
    if (state[scId] == isPaused) {
      state = {...state}..remove(scId);
    }
  }
}

final webPendingTokenPauseProvider = StateNotifierProvider<WebPendingTokenPauseProvider, Map<String, bool>>(
  (_) => WebPendingTokenPauseProvider(),
);

/// True while a broadcast pause/resume for [scId] has not reached the chain yet.
bool isWebTokenPausePending(Map<String, bool> pending, String scId, {required bool isPaused}) {
  return pending.containsKey(scId) && pending[scId] != isPaused;
}
