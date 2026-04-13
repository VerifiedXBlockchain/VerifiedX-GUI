import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../utils/toast.dart';
import '../services/privacy_service.dart';
import 'shielded_address_provider.dart';
import 'shielded_balance_provider.dart';
import 'shielded_vbtc_balance_provider.dart';

class VbtcPrivacyActionsNotifier extends StateNotifier<bool> {
  final Ref ref;

  VbtcPrivacyActionsNotifier(this.ref) : super(false);

  bool get isLoading => state;

  String? get _password => ref.read(shieldedAddressProvider.notifier).walletPassword;

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
      await PrivacyService().shieldVbtc(
        fromAddress: fromAddress,
        vbtcContractUid: vbtcContractUid,
        vbtcAmount: vbtcAmount,
        recipientZfxAddress: recipientZfxAddress,
      );

      Toast.message("vBTC shield transaction broadcast successfully");
      await ref.read(shieldedVbtcBalanceProvider.notifier).fetch(vbtcContractUid);
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
    state = true;
    try {
      await PrivacyService().unshieldVbtc(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
        vbtcContractUid: vbtcContractUid,
        toAddress: toAddress,
        vbtcAmount: vbtcAmount,
      );

      Toast.message("vBTC unshield transaction broadcast successfully");
      await Future.wait([
        ref.read(shieldedVbtcBalanceProvider.notifier).fetch(vbtcContractUid),
        ref.read(shieldedBalanceProvider.notifier).fetch(),
      ]);
      return true;
    } catch (e) {
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
    state = true;
    try {
      await PrivacyService().privateTransferVbtc(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
        vbtcContractUid: vbtcContractUid,
        recipientZfxAddress: recipientZfxAddress,
        amount: amount,
      );

      Toast.message("vBTC private transfer broadcast successfully");
      await Future.wait([
        ref.read(shieldedVbtcBalanceProvider.notifier).fetch(vbtcContractUid),
        ref.read(shieldedBalanceProvider.notifier).fetch(),
      ]);
      return true;
    } catch (e) {
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
    state = true;
    try {
      await PrivacyService().consolidateVbtc(
        zfxAddress: zfxAddress,
        walletPassword: _password!,
        vbtcContractUid: vbtcContractUid,
      );

      Toast.message("vBTC consolidation broadcast successfully");
      await Future.wait([
        ref.read(shieldedVbtcBalanceProvider.notifier).fetch(vbtcContractUid),
        ref.read(shieldedBalanceProvider.notifier).fetch(),
      ]);
      return true;
    } catch (e) {
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
