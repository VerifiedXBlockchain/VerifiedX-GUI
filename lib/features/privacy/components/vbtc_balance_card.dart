import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../models/shielded_balance.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/shielded_vbtc_balance_provider.dart';

class VbtcBalanceCard extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;
  final VoidCallback onShield;
  final VoidCallback onUnshield;
  final VoidCallback onTransfer;
  final VoidCallback onConsolidate;

  const VbtcBalanceCard({
    super.key,
    required this.token,
    required this.onShield,
    required this.onUnshield,
    required this.onTransfer,
    required this.onConsolidate,
  });

  @override
  ConsumerState<VbtcBalanceCard> createState() => _VbtcBalanceCardState();
}

class _VbtcBalanceCardState extends ConsumerState<VbtcBalanceCard> {
  @override
  void initState() {
    super.initState();
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress != null) {
      ref.read(shieldedVbtcBalanceProvider.notifier).start(
            zfxAddress,
            widget.token.smartContractUid,
          );
    }
  }

  @override
  void dispose() {
    ref.read(shieldedVbtcBalanceProvider.notifier).stop(widget.token.smartContractUid);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanceMap = ref.watch(shieldedVbtcBalanceProvider);
    final balance = balanceMap[widget.token.smartContractUid];

    return Card(
      color: AppColors.getGray(ColorShade.s200),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceRow(balance),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(ShieldedBalance? balance) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.token.tokenName.replaceAll(RegExp(r'\s*[Vv]2\s*'), ' ').trim(),
                style: TextStyle(
                  color: AppColors.getBtc(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.token.smartContractUid,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontFamily: 'monospace',
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
                      "${balance.vbtcBalance(widget.token.smartContractUid)} vBTC",
                      style: TextStyle(
                        color: AppColors.getBtc(),
                        fontSize: 22,
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
                "${balance.unspentCommitments} note${balance.unspentCommitments == 1 ? '' : 's'}",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Block ${balance.lastScannedBlock}",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: "Shield",
            icon: Icons.arrow_downward,
            variant: AppColorVariant.Success,
            onPressed: widget.onShield,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            label: "Unshield",
            icon: Icons.arrow_upward,
            variant: AppColorVariant.Warning,
            onPressed: widget.onUnshield,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            label: "Transfer",
            icon: Icons.send,
            variant: AppColorVariant.Prism,
            onPressed: widget.onTransfer,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            label: "Consolidate",
            icon: Icons.compress,
            variant: AppColorVariant.Info,
            onPressed: widget.onConsolidate,
          ),
        ),
      ],
    );
  }
}
