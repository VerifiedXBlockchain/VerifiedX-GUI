import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../utils/toast.dart';
import '../models/shielded_address.dart';
import '../models/shielded_balance.dart';
import '../providers/shielded_balance_provider.dart';
import 'commitment_list.dart';

class PrivacyDashboard extends BaseComponent {
  final ShieldedAddress address;

  const PrivacyDashboard({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(shieldedBalanceProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddressCard(address: address),
          const SizedBox(height: 16),
          _BalanceCard(balance: balance),
          const SizedBox(height: 16),
          _ActionButtons(),
          const SizedBox(height: 16),
          if (balance != null) CommitmentList(balance: balance),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final ShieldedAddress address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.getGray(ColorShade.s200),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.shield, color: AppColors.getBlue(), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shielded Address",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.zfxAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              color: Colors.white54,
              tooltip: "Copy address",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address.zfxAddress));
                Toast.message("Address copied to clipboard");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final ShieldedBalance? balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.getGray(ColorShade.s200),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shielded Balance",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  balance == null
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          "${balance!.vfxBalance} VFX",
                          style: TextStyle(
                            color: AppColors.getBlue(),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
            if (balance != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${balance!.unspentCommitments} note${balance!.unspentCommitments == 1 ? '' : 's'}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Block ${balance!.lastScannedBlock}",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  if (balance!.isViewOnly)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "VIEW ONLY",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.getGray(ColorShade.s200),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: "Shield",
                icon: Icons.arrow_downward,
                variant: AppColorVariant.Success,
                onPressed: () {
                  Toast.message("Shield dialog coming in Phase 5");
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: "Unshield",
                icon: Icons.arrow_upward,
                variant: AppColorVariant.Warning,
                onPressed: () {
                  Toast.message("Unshield dialog coming in Phase 5");
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: "Transfer",
                icon: Icons.send,
                variant: AppColorVariant.Primary,
                onPressed: () {
                  Toast.message("Transfer dialog coming in Phase 5");
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: "Consolidate",
                icon: Icons.compress,
                variant: AppColorVariant.Info,
                onPressed: () {
                  Toast.message("Consolidate dialog coming in Phase 5");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
