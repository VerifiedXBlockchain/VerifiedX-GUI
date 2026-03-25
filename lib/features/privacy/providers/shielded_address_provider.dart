import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../models/shielded_address.dart';
import '../services/privacy_service.dart';
import 'shielded_balance_provider.dart';

const _storageKey = "PRISM_ZFX_ADDRESS";

class ShieldedAddressNotifier extends StateNotifier<ShieldedAddress?> {
  final Ref ref;
  String? _walletPassword;

  ShieldedAddressNotifier(this.ref) : super(null);

  String? get walletPassword => _walletPassword;

  /// Called on first-time activation. Creates the shielded address on the node
  /// and persists the zfx_ address locally.
  Future<ShieldedAddress?> generate(String transparentAddress, String password) async {
    final address = await PrivacyService().createShieldedAddressFromAccount(
      transparentAddress: transparentAddress,
      walletPassword: password,
    );
    if (address != null) {
      _walletPassword = password;
      ref.read(privacyUnlockedProvider.notifier).state = true;
      state = address;
      singleton<Storage>().setString(_storageKey, address.zfxAddress);
      ref.read(shieldedBalanceProvider.notifier).start(address.zfxAddress);
    }
    return address;
  }

  /// Called on app restart. Loads from local storage — does NOT call the
  /// create endpoint (which would overwrite scanned data on the node).
  Future<void> load(String transparentAddress) async {
    final saved = singleton<Storage>().getString(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      state = ShieldedAddress(
        zfxAddress: saved,
        transparentSourceAddress: transparentAddress,
      );
      ref.read(shieldedBalanceProvider.notifier).start(saved);
    }
  }

  /// Set the password for the current session (e.g. after user enters it on restart).
  void setPassword(String password) {
    _walletPassword = password;
    ref.read(privacyUnlockedProvider.notifier).state = true;
  }

  void clear() {
    state = null;
    _walletPassword = null;
    ref.read(privacyUnlockedProvider.notifier).state = false;
    singleton<Storage>().remove(_storageKey);
    ref.read(shieldedBalanceProvider.notifier).stop();
  }
}

final shieldedAddressProvider = StateNotifierProvider<ShieldedAddressNotifier, ShieldedAddress?>((ref) {
  return ShieldedAddressNotifier(ref);
});

/// Tracks whether the privacy wallet is unlocked for spending this session.
final privacyUnlockedProvider = StateProvider<bool>((ref) => false);
