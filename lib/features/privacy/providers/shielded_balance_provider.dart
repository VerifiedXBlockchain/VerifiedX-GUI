import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shielded_balance.dart';
import '../services/privacy_service.dart';

class ShieldedBalanceNotifier extends StateNotifier<ShieldedBalance?> {
  Timer? _timer;
  String? _zfxAddress;
  DateTime? _optimisticUntil;

  ShieldedBalanceNotifier() : super(null);

  void start(String zfxAddress) {
    _zfxAddress = zfxAddress;
    fetch();
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetch(),
    );
  }

  Future<void> fetch() async {
    if (_zfxAddress == null) return;
    final balance = await PrivacyService().getShieldedBalance(
      _zfxAddress!,
      includeCommitments: true,
    );
    if (balance != null) {
      // If we recently applied an optimistic adjustment, don't overwrite with
      // a transient intermediate balance (the CLI marks inputs as spent before
      // the change output confirms, producing a temporarily lower value).
      if (_optimisticUntil != null && DateTime.now().isBefore(_optimisticUntil!)) {
        final optimisticVfx = state?.vfxBalance ?? 0;
        if (balance.vfxBalance < optimisticVfx) {
          return; // Still processing — keep the optimistic value
        }
        // Balance recovered to at least the optimistic value — clear the guard.
        _optimisticUntil = null;
      }
      state = balance;
    }
  }

  /// Optimistically adjusts the displayed VFX balance by [delta] (negative for
  /// sends, positive for shields). Prevents the next few fetches from
  /// overwriting with a transient zero.
  void optimisticAdjust(double delta) {
    if (state == null) return;
    final currentVfx = state!.vfxBalance;
    final newVfx = (currentVfx + delta).clamp(0.0, double.infinity);
    final updatedBalances = Map<String, double>.from(state!.shieldedBalances);
    updatedBalances['VFX'] = newVfx;
    state = state!.copyWith(shieldedBalances: updatedBalances);
    _optimisticUntil = DateTime.now().add(const Duration(seconds: 90));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _zfxAddress = null;
    _optimisticUntil = null;
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final shieldedBalanceProvider = StateNotifierProvider<ShieldedBalanceNotifier, ShieldedBalance?>((ref) {
  return ShieldedBalanceNotifier();
});
