import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../utils/toast.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/providers/transaction_list_provider.dart';
import '../services/privacy_service.dart';
import 'local_privacy_tx_provider.dart';
import 'shielded_address_provider.dart';
import 'shielded_balance_provider.dart';
import 'shielded_vbtc_balance_provider.dart';

/// Heuristic: does this error message suggest a wrong password?
bool _isAuthError(Object e) {
  final msg = e.toString().toLowerCase();
  return msg.contains('password') || msg.contains('unauthorized') || msg.contains('authentication');
}

class VbtcPrivacyActionsNotifier extends StateNotifier<bool> {
  final Ref ref;

  VbtcPrivacyActionsNotifier(this.ref) : super(false);

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
    ref.read(localPrivacyTxProvider.notifier).add(tx);
    ref.read(transactionListProvider(TransactionListType.All).notifier).set([
      tx,
      ...ref.read(transactionListProvider(TransactionListType.All)),
    ]);
  }

  /// Checks that the user has enough shielded VFX to cover the privacy tx fee.
  /// Returns true if sufficient, false otherwise.
  bool _hasVfxFeeBalance() {
    final vfxBalance = ref.read(shieldedBalanceProvider)?.vfxBalance ?? 0.0;
    if (vfxBalance < PRIVACY_TX_FIXED_FEE) {
      return false;
    }
    return true;
  }

  Future<bool> shieldVbtc({
    required String fromAddress,
    required String vbtcContractUid,
    required double vbtcAmount,
    required String recipientZfxAddress,
  }) async {
    state = true;
    try {
      final result = await PrivacyService().shieldVbtc(
        fromAddress: fromAddress,
        vbtcContractUid: vbtcContractUid,
        vbtcAmount: vbtcAmount,
        recipientZfxAddress: recipientZfxAddress,
      );

      Toast.message("vBTC shield transaction broadcast successfully");
      ref.read(shieldedVbtcBalanceProvider.notifier).optimisticAdjust(vbtcContractUid, vbtcAmount);

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: fromAddress,
          toAddress: recipientZfxAddress,
          amount: vbtcAmount,
          type: TxType.vbtcV2Shield,
        );
      }
      return true;
    } catch (e) {
      Toast.error("vBTC shield failed: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> unshieldVbtc({
    required String zfxAddress,
    required String vbtcContractUid,
    required String toAddress,
    required double vbtcAmount,
  }) async {
    if (_password == null) {
      Toast.error("Privacy wallet password required. Please unlock first.");
      return false;
    }
    if (!_hasVfxFeeBalance()) {
      Toast.error("Insufficient shielded VFX to cover the privacy transaction fee.");
      return false;
    }
    _resetTimer();
    state = true;
    try {
      final result = await PrivacyService().unshieldVbtc(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
        vbtcContractUid: vbtcContractUid,
        toAddress: toAddress,
        vbtcAmount: vbtcAmount,
      );

      Toast.message("vBTC unshield transaction broadcast successfully");
      ref.read(shieldedVbtcBalanceProvider.notifier).optimisticAdjust(vbtcContractUid, -vbtcAmount);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-PRIVACY_TX_FIXED_FEE);

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: zfxAddress,
          toAddress: toAddress,
          amount: vbtcAmount,
          type: TxType.vbtcV2Unshield,
        );
      }
      return true;
    } catch (e) {
      _handleAuthError(e);
      Toast.error("vBTC unshield failed: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> transferVbtc({
    required String zfxAddress,
    required String vbtcContractUid,
    required String recipientZfxAddress,
    required double amount,
  }) async {
    if (_password == null) {
      Toast.error("Privacy wallet password required. Please unlock first.");
      return false;
    }
    if (!_hasVfxFeeBalance()) {
      Toast.error("Insufficient shielded VFX to cover the privacy transaction fee.");
      return false;
    }
    _resetTimer();
    state = true;
    try {
      final result = await PrivacyService().privateTransferVbtc(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
        vbtcContractUid: vbtcContractUid,
        recipientZfxAddress: recipientZfxAddress,
        amount: amount,
      );

      Toast.message("vBTC private transfer broadcast successfully");
      ref.read(shieldedVbtcBalanceProvider.notifier).optimisticAdjust(vbtcContractUid, -amount);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-PRIVACY_TX_FIXED_FEE);

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: zfxAddress,
          toAddress: recipientZfxAddress,
          amount: amount,
          type: TxType.vbtcV2PrivateTransfer,
        );
      }
      return true;
    } catch (e) {
      _handleAuthError(e);
      Toast.error("vBTC private transfer failed: $e");
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> consolidateVbtc({
    required String zfxAddress,
    required String vbtcContractUid,
  }) async {
    if (_password == null) {
      Toast.error("Privacy wallet password required. Please unlock first.");
      return false;
    }
    if (!_hasVfxFeeBalance()) {
      Toast.error("Insufficient shielded VFX to cover the privacy transaction fee.");
      return false;
    }
    _resetTimer();
    state = true;
    try {
      final result = await PrivacyService().consolidateVbtc(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
        vbtcContractUid: vbtcContractUid,
      );

      Toast.message("vBTC consolidation broadcast successfully");
      ref.read(shieldedVbtcBalanceProvider.notifier).optimisticAdjust(vbtcContractUid, 0);
      ref.read(shieldedBalanceProvider.notifier).optimisticAdjust(-PRIVACY_TX_FIXED_FEE);

      final hash = result['Hash'] as String?;
      if (hash != null) {
        _injectLocalTx(
          hash: hash,
          fromAddress: zfxAddress,
          toAddress: zfxAddress,
          amount: 0,
          type: TxType.vbtcV2PrivateTransfer,
        );
      }
      return true;
    } catch (e) {
      _handleAuthError(e);
      Toast.error("vBTC consolidation failed: $e");
      return false;
    } finally {
      state = false;
    }
  }
}

final vbtcPrivacyActionsProvider = StateNotifierProvider<VbtcPrivacyActionsNotifier, bool>((ref) {
  return VbtcPrivacyActionsNotifier(ref);
});
