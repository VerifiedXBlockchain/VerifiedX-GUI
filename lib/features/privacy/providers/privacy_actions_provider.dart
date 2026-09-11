import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/utils/tx_refresh.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../services/privacy_service.dart';
import 'shielded_address_provider.dart';
import 'shielded_balance_provider.dart';

/// Heuristic: does this error message suggest a wrong password?
bool _isAuthError(Object e) {
  final msg = e.toString().toLowerCase();
  return msg.contains('password') || msg.contains('unauthorized') || msg.contains('authentication');
}

class PrivacyActionsNotifier extends StateNotifier<bool> {
  final Ref ref;

  PrivacyActionsNotifier(this.ref) : super(false);

  bool get isLoading => state;

  String? get _password => ref.read(shieldedAddressProvider.notifier).walletPassword;

  void _resetTimer() => ref.read(shieldedAddressProvider.notifier).resetLockTimer();

  void _handleAuthError(Object e) {
    if (_isAuthError(e)) {
      ref.read(shieldedAddressProvider.notifier).lock();
    }
  }

  void _refreshTxList() => notifyTransactionSubmitted();

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

      Toast.message(globalL10n.prvShieldBroadcastSuccess);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(amount);
      _refreshTxList();
      return true;
    } catch (e) {
      Toast.error(globalL10n.prvShieldFailed(e.toString()));
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
      Toast.error(globalL10n.prvPasswordRequired);
      return false;
    }
    _resetTimer();
    state = true;
    try {
      await PrivacyService().unshieldVfx(
        zfxAddress: zfxAddress,
        toAddress: toAddress,
        amount: amount,
        walletPassword: _password!,
      );

      Toast.message(globalL10n.prvUnshieldBroadcastSuccess);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-(amount + PRIVACY_TX_FIXED_FEE));
      _refreshTxList();
      return true;
    } catch (e) {
      _handleAuthError(e);
      Toast.error(globalL10n.prvUnshieldFailed(e.toString()));
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
      Toast.error(globalL10n.prvPasswordRequired);
      return false;
    }
    _resetTimer();
    state = true;
    try {
      await PrivacyService().privateTransferVfx(
        zfxAddress: zfxAddress,
        recipientZfxAddress: recipientZfxAddress,
        amount: amount,
        walletPassword: _password!,
      );

      Toast.message(globalL10n.prvTransferBroadcastSuccess);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-(amount + PRIVACY_TX_FIXED_FEE));
      _refreshTxList();
      return true;
    } catch (e) {
      _handleAuthError(e);
      Toast.error(globalL10n.prvTransferFailed(e.toString()));
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> consolidate({
    required String zfxAddress,
  }) async {
    if (_password == null) {
      Toast.error(globalL10n.prvPasswordRequired);
      return false;
    }
    _resetTimer();
    state = true;
    try {
      await PrivacyService().consolidateVfx(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
      );

      Toast.message(globalL10n.prvConsolidationBroadcastSuccess);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(0);
      _refreshTxList();
      return true;
    } catch (e) {
      _handleAuthError(e);
      Toast.error(globalL10n.prvConsolidationFailed(e.toString()));
      return false;
    } finally {
      state = false;
    }
  }
}

final privacyActionsProvider = StateNotifierProvider<PrivacyActionsNotifier, bool>((ref) {
  return PrivacyActionsNotifier(ref);
});
