import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/toast.dart';
import '../services/privacy_service.dart';
import 'shielded_balance_provider.dart';

class PrivacyActionsNotifier extends StateNotifier<bool> {
  final Ref ref;

  PrivacyActionsNotifier(this.ref) : super(false);

  bool get isLoading => state;

  Future<bool> shield({
    required String fromAddress,
    required double amount,
    required String recipientZfxAddress,
  }) async {
    state = true;
    try {
      final result = await PrivacyService().shieldVfx(
        fromAddress: fromAddress,
        amount: amount,
        recipientZfxAddress: recipientZfxAddress,
      );

      if (result != null) {
        Toast.message("Shield transaction broadcast successfully");
        ref.read(shieldedBalanceProvider.notifier).fetch();
        return true;
      }

      Toast.error("Shield transaction failed");
      return false;
    } catch (e) {
      Toast.error("Shield error: $e");
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
    state = true;
    try {
      final result = await PrivacyService().unshieldVfx(
        zfxAddress: zfxAddress,
        toAddress: toAddress,
        amount: amount,
      );

      if (result != null) {
        Toast.message("Unshield transaction broadcast successfully");
        ref.read(shieldedBalanceProvider.notifier).fetch();
        return true;
      }

      Toast.error("Unshield transaction failed");
      return false;
    } catch (e) {
      Toast.error("Unshield error: $e");
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
    state = true;
    try {
      final result = await PrivacyService().privateTransferVfx(
        zfxAddress: zfxAddress,
        recipientZfxAddress: recipientZfxAddress,
        amount: amount,
      );

      if (result != null) {
        Toast.message("Private transfer broadcast successfully");
        ref.read(shieldedBalanceProvider.notifier).fetch();
        return true;
      }

      Toast.error("Private transfer failed");
      return false;
    } catch (e) {
      Toast.error("Private transfer error: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> consolidate({
    required String zfxAddress,
  }) async {
    state = true;
    try {
      final result = await PrivacyService().consolidateVfx(
        zfxAddress: zfxAddress,
      );

      if (result != null) {
        Toast.message("Consolidation broadcast successfully");
        ref.read(shieldedBalanceProvider.notifier).fetch();
        return true;
      }

      Toast.error("Consolidation failed");
      return false;
    } catch (e) {
      Toast.error("Consolidation error: $e");
      return false;
    } finally {
      state = false;
    }
  }
}

final privacyActionsProvider = StateNotifierProvider<PrivacyActionsNotifier, bool>((ref) {
  return PrivacyActionsNotifier(ref);
});
