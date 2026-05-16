import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/models/transaction.dart';

/// Holds privacy transactions that were injected locally (not from the CLI).
/// These survive transaction list reloads until the CLI properly reports them
/// or the app is restarted.
class LocalPrivacyTxNotifier extends StateNotifier<List<Transaction>> {
  LocalPrivacyTxNotifier() : super([]);

  void add(Transaction tx) {
    if (state.any((t) => t.hash == tx.hash)) return;
    state = [tx, ...state];
  }

  /// Remove a transaction once the CLI starts returning it (by hash match).
  void removeIfPresent(Set<String> cliHashes) {
    final updated = state.where((tx) => !cliHashes.contains(tx.hash)).toList();
    if (updated.length != state.length) {
      state = updated;
    }
  }
}

final localPrivacyTxProvider =
    StateNotifierProvider<LocalPrivacyTxNotifier, List<Transaction>>((ref) {
  return LocalPrivacyTxNotifier();
});
