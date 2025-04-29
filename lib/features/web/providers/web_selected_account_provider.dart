import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/web/providers/web_currency_segmented_button_provider.dart';

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

class WebSelectedAccountProvider extends StateNotifier<WebSelectedAccount?> {
  WebSelectedAccountProvider() : super(null);

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
