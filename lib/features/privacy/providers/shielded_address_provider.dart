import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/singletons.dart';
import '../../../core/storage.dart';
import '../models/shielded_address.dart';
import '../services/privacy_service.dart';
import 'shielded_balance_provider.dart';
import 'shielded_vbtc_balance_provider.dart';

const _storageKey = "PRISM_ZFX_ADDRESS";

class ShieldedAddressNotifier extends StateNotifier<ShieldedAddress?> {
  final Ref ref;
  String? _walletPassword;
  Timer? _lockTimer;

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
      _setPasswordAndStartTimer(password);
      state = address;
      singleton<Storage>().setString(_storageKey, address.zfxAddress);
      ref.read(shieldedBalanceProvider.notifier).start(address.zfxAddress);
      // The node starts the wallet at block 0 without scanning, so notes sent to
      // this address earlier (a re-activation) stay hidden until a rescan.
      unawaited(PrivacyService().resyncShieldedWallet(zfxAddress: address.zfxAddress));
    }
    return address;
  }

  /// Called on app restart. Loads from local storage — does NOT call the
  /// create endpoint (which would overwrite scanned data on the node). When the
  /// node does not hold that wallet (a new or reset data folder), the stored
  /// address is dropped so the user is sent to activation instead of a
  /// dashboard that accepts shields and reads 0.
  Future<void> load(String transparentAddress) async {
    final saved = singleton<Storage>().getString(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      state = ShieldedAddress(
        zfxAddress: saved,
        transparentSourceAddress: transparentAddress,
      );
      ref.read(shieldedBalanceProvider.notifier).start(saved);
      final held = await PrivacyService().nodeHoldsShieldedWallet(saved);
      if (held == false && state?.zfxAddress == saved) {
        clear();
      }
    }
  }

  /// Set the password for the current session (e.g. after user enters it on restart).
  void setPassword(String password) {
    _setPasswordAndStartTimer(password);
  }

  /// Resets the inactivity timer. Call this when the password is used for an operation.
  void resetLockTimer() {
    _startLockTimer();
  }

  /// Locks the privacy wallet — clears the password but preserves wallet state.
  void lock() {
    _lockTimer?.cancel();
    _lockTimer = null;
    _walletPassword = null;
    ref.read(privacyUnlockedProvider.notifier).state = false;
  }

  /// Clears everything — password, wallet state, and local storage.
  void clear() {
    lock();
    state = null;
    singleton<Storage>().remove(_storageKey);
    ref.read(shieldedBalanceProvider.notifier).stop();
    ref.read(shieldedVbtcBalanceProvider.notifier).stopAll();
  }

  void _setPasswordAndStartTimer(String password) {
    _walletPassword = password;
    ref.read(privacyUnlockedProvider.notifier).state = true;
    _startLockTimer();
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(
      const Duration(minutes: IDLE_TIMEOUT_MINUTES),
      lock,
    );
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
}

final shieldedAddressProvider = StateNotifierProvider<ShieldedAddressNotifier, ShieldedAddress?>((ref) {
  return ShieldedAddressNotifier(ref);
});

/// Tracks whether the privacy wallet is unlocked for spending this session.
final privacyUnlockedProvider = StateProvider<bool>((ref) => false);
