import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../utils/toast.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_list_provider.dart';
import '../services/privacy_service.dart';
import 'local_privacy_tx_provider.dart';
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

  void _injectLocalTx({
    required String hash,
    required String fromAddress,
    required String toAddress,
    required double amount,
    required int type,
  }) {
    final tx = Transaction(
      hash: hash,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      type: type,
      status: TransactionStatus.Pending,
      nonce: 0,
      fee: PRIVACY_TX_FIXED_FEE,
      timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      nftData: null,
      height: 0,
    );
    // Persist in the local privacy tx store so it survives list reloads.
    ref.read(localPrivacyTxProvider.notifier).add(tx);
    // Also inject immediately into the current list state for instant feedback.
    ref.read(transactionListProvider(TransactionListType.All).notifier).set([
      tx,
      ...ref.read(transactionListProvider(TransactionListType.All)),
    ]);
  }

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

      Toast.message("Shield transaction broadcast successfully");
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(amount);

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: fromAddress,
          toAddress: recipientZfxAddress,
          amount: amount,
          type: TxType.vfxShield,
        );
      }
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
    _resetTimer();
    state = true;
    try {
      final result = await PrivacyService().unshieldVfx(
        zfxAddress: zfxAddress,
        toAddress: toAddress,
        amount: amount,
        walletPassword: _password!,
      );

      Toast.message("Unshield transaction broadcast successfully");
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-(amount + PRIVACY_TX_FIXED_FEE));

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: zfxAddress,
          toAddress: toAddress,
          amount: amount,
          type: TxType.vfxUnshield,
        );
      }
      return true;
    } catch (e) {
      _handleAuthError(e);
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
    _resetTimer();
    state = true;
    try {
      final result = await PrivacyService().privateTransferVfx(
        zfxAddress: zfxAddress,
        recipientZfxAddress: recipientZfxAddress,
        amount: amount,
        walletPassword: _password!,
      );

      Toast.message("Private transfer broadcast successfully");
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-(amount + PRIVACY_TX_FIXED_FEE));

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: zfxAddress,
          toAddress: recipientZfxAddress,
          amount: amount,
          type: TxType.vfxPrivateTransfer,
        );
      }
      return true;
    } catch (e) {
      _handleAuthError(e);
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
    _resetTimer();
    state = true;
    try {
      await PrivacyService().consolidateVfx(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
      );

      Toast.message("Consolidation broadcast successfully");
      // Balance stays the same during consolidation — just apply a zero delta
      // to activate the optimistic guard against transient zero fetches.
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(0);
      return true;
    } catch (e) {
      _handleAuthError(e);
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
