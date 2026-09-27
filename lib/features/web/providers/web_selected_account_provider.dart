import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/web/providers/web_currency_segmented_button_provider.dart';

import '../../../core/models/web_session_model.dart';
import '../../btc_web/models/btc_web_account.dart';
import '../../keygen/models/ra_keypair.dart';

class WebSelectedAccount {
  final String address;
  final String privateKey;
  final String publicKey;
  final WebCurrencyType type;
  final double balance;
  final double lockedBalance;
  final double totalBalance;
  final String? domain;

  WebSelectedAccount({
    required this.address,
    required this.privateKey,
    required this.publicKey,
    required this.type,
    required this.balance,
    required this.lockedBalance,
    required this.totalBalance,
    this.domain,
  });

  WebSelectedAccount copyWithBalances({
    required double balance,
    required double lockedBalance,
    required double totalBalance,
  }) {
    return WebSelectedAccount(
      address: address,
      privateKey: privateKey,
      publicKey: publicKey,
      type: type,
      balance: balance,
      lockedBalance: lockedBalance,
      totalBalance: totalBalance,
      domain: domain,
    );
  }

  Color get color {
    switch (type) {
      case WebCurrencyType.any:
        return Colors.white;

      case WebCurrencyType.vfx:
        return AppColors.getBlue();
      case WebCurrencyType.vault:
        return AppColors.getReserve();
      case WebCurrencyType.btc:
        return AppColors.getBtc();
    }
  }
}

/// [account] with the balances [session] now holds for its address, or null
/// when the session has no newer balances for it (not loaded yet, unchanged,
/// or the account is no longer one of the session's).
WebSelectedAccount? selectedAccountWithSessionBalances(WebSelectedAccount account, WebSessionModel session) {
  double? balance;
  double? lockedBalance;
  double? totalBalance;

  if (account.type == WebCurrencyType.btc) {
    final btcBalance = session.btcBalanceInfo?.btcBalance;
    if (session.btcKeypair?.address == account.address && btcBalance != null) {
      balance = btcBalance;
      lockedBalance = 0;
      totalBalance = btcBalance;
    }
  } else if (session.keypair?.address == account.address && session.balance != null) {
    balance = session.balance;
    lockedBalance = session.balanceLocked ?? 0;
    totalBalance = session.balanceTotal ?? 0;
  } else if (session.raKeypair?.address == account.address && session.raBalance != null) {
    balance = session.raBalance;
    lockedBalance = session.raBalanceLocked ?? 0;
    totalBalance = session.raBalanceTotal ?? 0;
  }

  if (balance == null || lockedBalance == null || totalBalance == null) {
    return null;
  }
  if (balance == account.balance && lockedBalance == account.lockedBalance && totalBalance == account.totalBalance) {
    return null;
  }
  return account.copyWithBalances(balance: balance, lockedBalance: lockedBalance, totalBalance: totalBalance);
}

class WebSelectedAccountProvider extends StateNotifier<WebSelectedAccount?> {
  WebSelectedAccountProvider() : super(null);

  /// Keeps the selected account's balances in step with the session's
  /// periodic refresh. The send form validates against them, so a stale
  /// value lets an amount over the current balance through.
  void syncBalances(WebSessionModel session) {
    final account = state;
    if (account == null) {
      return;
    }
    final updated = selectedAccountWithSessionBalances(account, session);
    if (updated != null) {
      state = updated;
    }
  }

  set({
    required String address,
    required String privateKey,
    required String publicKey,
    required WebCurrencyType type,
    required double balance,
    required double lockedBalance,
    required double totalBalance,
    String? domain,
  }) {
    state = WebSelectedAccount(
      address: address,
      privateKey: privateKey,
      publicKey: publicKey,
      type: type,
      balance: balance,
      lockedBalance: lockedBalance,
      totalBalance: totalBalance,
      domain: domain,
    );
  }

  setVfx(Keypair keypair, double balance, double lockedBalance, double totalBalance, String? domain) {
    set(
      address: keypair.address,
      privateKey: keypair.privateCorrected,
      publicKey: keypair.public,
      type: WebCurrencyType.vfx,
      balance: balance,
      lockedBalance: lockedBalance,
      totalBalance: totalBalance,
      domain: domain,
    );
  }

  setVault(
    RaKeypair raKeypair,
    double balance,
    double lockedBalance,
    double totalBalance,
  ) {
    set(
      address: raKeypair.address,
      privateKey: raKeypair.privateCorrected,
      publicKey: raKeypair.public,
      type: WebCurrencyType.vault,
      lockedBalance: lockedBalance,
      totalBalance: totalBalance,
      balance: balance,
    );
  }

  setBtc(BtcWebAccount keypair, double balance) {
    set(
      address: keypair.address,
      privateKey: keypair.privateKey,
      publicKey: keypair.publicKey,
      type: WebCurrencyType.btc,
      balance: balance,
      lockedBalance: 0,
      totalBalance: balance,
      domain: keypair.adnr,
    );
  }
}

final webSelectedAccountProvider = StateNotifierProvider<WebSelectedAccountProvider, WebSelectedAccount?>((ref) {
  return WebSelectedAccountProvider();
});
