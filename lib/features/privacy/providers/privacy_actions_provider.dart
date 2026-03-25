import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/toast.dart';
import '../services/privacy_service.dart';
import 'shielded_address_provider.dart';
import 'shielded_balance_provider.dart';

class PrivacyActionsNotifier extends StateNotifier<bool> {
  final Ref ref;

  PrivacyActionsNotifier(this.ref) : super(false);

  bool get isLoading => state;

  String? get _password => ref.read(shieldedAddressProvider.notifier).walletPassword;

  Future<bool> shield({
    required String fromAddress,
    required double amount,
    required String recipientZfxAddress,
  }) async {
    state = true;
    try {
      await PrivacyService().shieldVfx(
        fromAddress: fromAddress,
        amount: amount,
        recipientZfxAddress: recipientZfxAddress,
      );

      Toast.message("Shield transaction broadcast successfully");
      await ref.read(shieldedBalanceProvider.notifier).fetch();
      return true;
    } catch (e) {
      Toast.error("Shield failed: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> unshield({
    required String zfxAddress,
    required String toAddress,
    required double amount,
  }) async {
    if (_password == null) {
      Toast.error("Privacy wallet password required. Please unlock first.");
      return false;
    }
    state = true;
    try {
      await PrivacyService().unshieldVfx(
        zfxAddress: zfxAddress,
        toAddress: toAddress,
        amount: amount,
        walletPassword: _password!,
      );

      Toast.message("Unshield transaction broadcast successfully");
      await ref.read(shieldedBalanceProvider.notifier).fetch();
      return true;
    } catch (e) {
      Toast.error("Unshield failed: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> transfer({
    required String zfxAddress,
    required String recipientZfxAddress,
    required double amount,
  }) async {
    if (_password == null) {
      Toast.error("Privacy wallet password required. Please unlock first.");
      return false;
    }
    state = true;
    try {
      await PrivacyService().privateTransferVfx(
        zfxAddress: zfxAddress,
        recipientZfxAddress: recipientZfxAddress,
        amount: amount,
        walletPassword: _password!,
      );

      Toast.message("Private transfer broadcast successfully");
      await ref.read(shieldedBalanceProvider.notifier).fetch();
      return true;
    } catch (e) {
      Toast.error("Private transfer failed: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> consolidate({
    required String zfxAddress,
  }) async {
    if (_password == null) {
      Toast.error("Privacy wallet password required. Please unlock first.");
      return false;
    }
    state = true;
    try {
      await PrivacyService().consolidateVfx(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
      );

      Toast.message("Consolidation broadcast successfully");
      await ref.read(shieldedBalanceProvider.notifier).fetch();
      return true;
    } catch (e) {
      Toast.error("Consolidation failed: $e");
      return false;
    } finally {
      state = false;
    }
  }
}

final privacyActionsProvider = StateNotifierProvider<PrivacyActionsNotifier, bool>((ref) {
  return PrivacyActionsNotifier(ref);
});
