import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shielded_balance.dart';
import '../services/privacy_service.dart';

class ShieldedBalanceNotifier extends StateNotifier<ShieldedBalance?> {
  Timer? _timer;
  String? _zfxAddress;

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
      state = balance;
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _zfxAddress = null;
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
