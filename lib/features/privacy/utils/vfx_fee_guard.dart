import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../providers/shielded_balance_provider.dart';
import '../components/shield_dialog.dart';

class VfxFeeGuard {
  /// Checks if the user has enough shielded VFX for the privacy tx fee.
  /// If insufficient, shows an info dialog and returns false.
  /// If sufficient, returns true.
  static Future<bool> check(WidgetRef ref) async {
    final vfxBalance = ref.read(shieldedBalanceProvider)?.vfxBalance ?? 0.0;
    if (vfxBalance >= PRIVACY_TX_FIXED_FEE) return true;

    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text("Shielded VFX Required"),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "vBTC privacy operations require a small fee paid from your shielded VFX balance.\n\n"
                "You currently have $vfxBalance shielded VFX.\n"
                "Please shield at least $PRIVACY_TX_FIXED_FEE_LABEL first.",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ShieldDialog.show();
            },
            child: const Text("Shield VFX"),
          ),
        ],
      ),
    );
    return false;
  }
}
