import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shielded_balance.dart';
import '../services/privacy_service.dart';

class ShieldedVbtcBalanceManager extends StateNotifier<Map<String, ShieldedBalance?>> {
  final Map<String, Timer> _timers = {};
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
      state = {...state, contractUid: balance};
    }
  }

  void stop(String contractUid) {
    _timers[contractUid]?.cancel();
    _timers.remove(contractUid);
    final updated = Map<String, ShieldedBalance?>.from(state);
    updated.remove(contractUid);
    state = updated;
  }

  void stopAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
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
