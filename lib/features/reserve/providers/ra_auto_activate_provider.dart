import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../../wallet/models/wallet.dart';
import '../services/reserve_account_service.dart';
import 'pending_activation_provider.dart';

/// Balance a Vault needs before it can be activated.
const double VAULT_ACTIVATION_AMOUNT = 5.0;

/// A queued auto-activation whose Vault never gets funded is dropped after
/// this long, so the Vault falls back to the manual "Activate Now" path.
const Duration AUTO_ACTIVATE_EXPIRY = Duration(minutes: 30);

class ReserveAccountAutoActivateProvider extends StateNotifier<Map<String, dynamic>> {
  final DateTime Function() _now;

  ReserveAccountAutoActivateProvider({DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super({});

  add(String txHash, String address, String password) {
    final data = {
      'address': address,
      'password': password,
      'queuedAt': _now(),
    };
    state = {...state, txHash: data};
  }

  remove(String txHash) {
    state = {...state}..remove(txHash);
  }

  Set<String> get queuedAddresses {
    return state.values.whereType<Map>().map((data) => data['address']).whereType<String>().toSet();
  }

  /// Sorts the queue against the current Vault list and drops the stale
  /// entries. Returns the hashes that are due; the caller removes each one
  /// before publishing it.
  List<String> sweep(List<Wallet> vaults) {
    final result = sweepAutoActivations(state, vaults, now: _now());
    for (final txHash in result.stale) {
      remove(txHash);
    }
    return result.due;
  }
}

/// What to do with the queued auto-activations given the current Vault list.
class AutoActivationSweep {
  /// Hashes whose Vault already holds the activation amount: publish these.
  final List<String> due;

  /// Hashes whose Vault is already activated, or was not funded within
  /// [AUTO_ACTIVATE_EXPIRY]: drop these without publishing.
  final List<String> stale;

  const AutoActivationSweep({required this.due, required this.stale});
}

/// Decides which queued auto-activations can run from the Vault balances.
///
/// The funding transaction's signal only fires once per hash, and the hash is
/// queued after the funding dialogs, so a transaction that confirmed before
/// it was queued is never matched. Checking the Vault balance on every wallet
/// refresh activates those Vaults anyway.
AutoActivationSweep sweepAutoActivations(
  Map<String, dynamic> queued,
  List<Wallet> vaults, {
  required DateTime now,
}) {
  final List<String> due = [];
  final List<String> stale = [];

  queued.forEach((txHash, data) {
    final address = data is Map ? data['address'] : null;
    final queuedAt = data is Map ? data['queuedAt'] : null;

    final matches = vaults.where((w) => w.address == address);
    final vault = matches.isEmpty ? null : matches.first;

    if (vault != null && vault.isNetworkProtected) {
      stale.add(txHash);
      return;
    }

    // A Vault missing from this refresh (not loaded yet) waits like an
    // unfunded one.
    if (vault != null && vault.availableBalance >= VAULT_ACTIVATION_AMOUNT) {
      due.add(txHash);
      return;
    }

    if (queuedAt is DateTime && now.difference(queuedAt) > AUTO_ACTIVATE_EXPIRY) {
      stale.add(txHash);
    }
  });

  return AutoActivationSweep(due: due, stale: stale);
}

/// Publishes the queued desktop activation for [txHash]. The entry is removed
/// before the call so the balance sweep and the transaction signal cannot
/// both send it. A failed publish clears the pending badge so the manual
/// "Activate Now" button comes back.
Future<void> publishQueuedAutoActivation(Ref ref, String txHash) async {
  final data = ref.read(reserveAccountAutoActivateProvider)[txHash];
  if (data is! Map) {
    return;
  }
  ref.read(reserveAccountAutoActivateProvider.notifier).remove(txHash);

  final address = data['address'];
  final password = data['password'];
  if (address is! String || password is! String) {
    return;
  }

  final success = await ReserveAccountService().publish(address: address, password: password);
  if (success) {
    // Restart the pending window from the publish, not from when it was queued.
    ref.read(pendingActivationProvider.notifier).addId(address);
    Toast.message(globalL10n.svcVaultAutoActivationInitiated);
  } else {
    ref.read(pendingActivationProvider.notifier).removeId(address);
  }
}

final reserveAccountAutoActivateProvider =StateNotifierProvider<ReserveAccountAutoActivateProvider, Map<String, dynamic>>((ref) {
  return ReserveAccountAutoActivateProvider();
});
