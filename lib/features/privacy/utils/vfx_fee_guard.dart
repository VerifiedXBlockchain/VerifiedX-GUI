import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../l10n/l10n_helper.dart';
import '../providers/shielded_balance_provider.dart';
import '../components/shield_dialog.dart';

class VfxFeeGuard {
  /// Checks if the user has enough shielded VFX for the privacy tx fee.
  /// If insufficient, shows an info dialog and returns false.
  /// If sufficient, returns true.
  static Future<bool> check(WidgetRef ref) async {
    final l10n = globalL10n;
    final vfxBalance = ref.read(shieldedBalanceProvider)?.vfxBalance ?? 0.0;
    if (vfxBalance >= PRIVACY_TX_FIXED_FEE) return true;

    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(l10n.prvShieldedVfxRequiredTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.prvShieldedVfxRequiredBody(vfxBalance.toString(), PRIVACY_TX_FIXED_FEE_LABEL),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ShieldDialog.show();
            },
            child: Text(l10n.prvShieldVfxTitle),
          ),
        ],
      ),
    );
    return false;
  }
}
