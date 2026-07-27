import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shielded_balance.dart';
import '../services/privacy_service.dart';

class ShieldedVbtcBalanceManager extends StateNotifier<Map<String, ShieldedBalance?>> {
  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _optimisticUntil = {};
  String? _zfxAddress;

  ShieldedVbtcBalanceManager() : super({});

  void start(String zfxAddress, String contractUid) {
    _zfxAddress = zfxAddress;
    fetch(contractUid);
    _timers[contractUid]?.cancel();
    _timers[contractUid] = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetch(contractUid),
    );
  }

  Future<void> fetch(String contractUid) async {
    if (_zfxAddress == null) return;
    final balance = await PrivacyService().getShieldedVbtcBalance(
      _zfxAddress!,
      contractUid,
      includeCommitments: true,
    );
    if (balance != null) {
      final guard = _optimisticUntil[contractUid];
      if (guard != null && DateTime.now().isBefore(guard)) {
        final currentBalance = state[contractUid];
        if (balance.vbtcBalance(contractUid) <= 0 &&
            (currentBalance?.vbtcBalance(contractUid) ?? 0) > 0) {
          return;
        }
        _optimisticUntil.remove(contractUid);
      }
      state = {...state, contractUid: balance};
    }
  }

  /// Optimistically adjusts the displayed vBTC balance for [contractUid] by
  /// [delta]. Prevents the next few fetches from overwriting with a transient zero.
  void optimisticAdjust(String contractUid, double delta) {
    final current = state[contractUid];
    if (current == null) return;
    final currentVbtc = current.vbtcBalance(contractUid);
    final newVbtc = (currentVbtc + delta).clamp(0.0, double.infinity);
    final updatedBalances = Map<String, double>.from(current.shieldedBalances);
    // Write to the same key format the CLI uses (try prefixed first, fall back to raw).
    final key = updatedBalances.containsKey('VBTC:$contractUid') ? 'VBTC:$contractUid' : contractUid;
    updatedBalances[key] = newVbtc;
    state = {...state, contractUid: current.copyWith(shieldedBalances: updatedBalances)};
    _optimisticUntil[contractUid] = DateTime.now().add(const Duration(seconds: 90));
  }

  void stop(String contractUid) {
    _timers[contractUid]?.cancel();
    _timers.remove(contractUid);
    _optimisticUntil.remove(contractUid);
    final updated = Map<String, ShieldedBalance?>.from(state);
    updated.remove(contractUid);
    state = updated;
  }

  void stopAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _optimisticUntil.clear();
    _zfxAddress = null;
    state = {};
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}

final shieldedVbtcBalanceProvider =
    StateNotifierProvider<ShieldedVbtcBalanceManager, Map<String, ShieldedBalance?>>((ref) {
  return ShieldedVbtcBalanceManager();
});
