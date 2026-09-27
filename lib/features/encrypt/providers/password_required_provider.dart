import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bridge/services/bridge_service.dart';

class PasswordRequiredProvider extends StateNotifier<bool> {
  PasswordRequiredProvider() : super(false) {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      check();
    });
    check();
  }

  Future<bool> check() async {
    final isEncrypted = await BridgeService().checkIfEncrypted();

    if (!isEncrypted) {
      state = false;
      return false;
    }

    final isNeeded = await BridgeService().checkIfPasswordIsNeeded();

    if (isNeeded) {
      state = true;
      return true;
    }

    state = false;
    return false;
  }

  /// The node refused a call because the wallet is locked: reflect that
  /// right away instead of waiting for the next 10 s check.
  void markRequired() {
    state = true;
  }

  Future<bool> unlock(String password) async {
    final unlocked = await BridgeService().unlockWallet(password);
    if (unlocked) {
      state = false;
      return true;
    }

    state = true;

    return false;
  }

  Future<bool> lock() async {
    final locked = await BridgeService().lockWallet();
    if (locked) {
      state = true;
      return true;
    }

    state = false;

    return false;
  }
}

final passwordRequiredProvider = StateNotifierProvider<PasswordRequiredProvider, bool>((ref) {
  return PasswordRequiredProvider();
});
