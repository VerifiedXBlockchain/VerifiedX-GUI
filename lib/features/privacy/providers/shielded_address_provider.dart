import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shielded_address.dart';
import '../services/privacy_service.dart';
import 'shielded_balance_provider.dart';

class ShieldedAddressNotifier extends StateNotifier<ShieldedAddress?> {
  final Ref ref;

  ShieldedAddressNotifier(this.ref) : super(null);

  Future<ShieldedAddress?> generate() async {
    final address = await PrivacyService().generateShieldedAddress();
    if (address != null) {
      state = address;
      ref.read(shieldedBalanceProvider.notifier).start(address.zfxAddress);
    }
    return address;
  }

  Future<void> load() async {
    final address = await PrivacyService().generateShieldedAddress();
    if (address != null) {
      state = address;
      ref.read(shieldedBalanceProvider.notifier).start(address.zfxAddress);
    }
  }

  void clear() {
    state = null;
    ref.read(shieldedBalanceProvider.notifier).stop();
  }
}

final shieldedAddressProvider = StateNotifierProvider<ShieldedAddressNotifier, ShieldedAddress?>((ref) {
  return ShieldedAddressNotifier(ref);
});
