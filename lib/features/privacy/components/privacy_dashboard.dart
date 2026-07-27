import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../btc/providers/tokenized_bitcoin_list_provider.dart';
import '../models/shielded_address.dart';
import '../models/shielded_balance.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/shielded_balance_provider.dart';
import '../utils/privacy_unlock.dart';
import 'commitment_list.dart';
import 'consolidate_dialog.dart';
import 'consolidate_vbtc_dialog.dart';
import 'privacy_settings_menu.dart';
import 'private_transfer_dialog.dart';
import 'private_transfer_vbtc_dialog.dart';
import 'shield_dialog.dart';
import 'shield_vbtc_dialog.dart';
import 'unshield_dialog.dart';
import 'unshield_vbtc_dialog.dart';
import 'vbtc_balance_card.dart';

class PrivacyDashboard extends ConsumerStatefulWidget {
  final ShieldedAddress address;

  const PrivacyDashboard({
    super.key,
    required this.address,
  });

  @override
  ConsumerState<PrivacyDashboard> createState() => _PrivacyDashboardState();
}

class _PrivacyDashboardState extends ConsumerState<PrivacyDashboard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = ref.watch(shieldedBalanceProvider);
    final isUnlocked = ref.watch(privacyUnlockedProvider);
    final allTokens = ref.watch(tokenizedBitcoinListProvider);
    final vbtcTokens = allTokens.where((t) => t.version == 2).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUnlocked) _UnlockBanner(),
          _AddressCard(address: widget.address),
          const SizedBox(height: 16),
          _BalanceCard(balance: balance),
          const SizedBox(height: 16),
          _ActionButtons(),
          const SizedBox(height: 16),
          if (vbtcTokens.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.prvShieldedVbtcHeading,
                style: TextStyle(
                  color: AppColors.getBtc(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...vbtcTokens.map((token) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VbtcBalanceCard(
                    token: token,
                    onShield: () => ShieldVbtcDialog.show(token),
                    onUnshield: () => requirePrivacyUnlock(ref, () => UnshieldVbtcDialog.show(token)),
                    onTransfer: () => requirePrivacyUnlock(ref, () => PrivateTransferVbtcDialog.show(token)),
                    onConsolidate: () => requirePrivacyUnlock(ref, () => ConsolidateVbtcDialog.show(token)),
                  ),
                )),
            const SizedBox(height: 8),
          ],
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
    final l10n = AppLocalizations.of(context);
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
                  Text(
                    l10n.prvShieldedAddressLabel,
                    style: const TextStyle(
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
              tooltip: l10n.prvCopyAddress,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address.zfxAddress));
                Toast.message(l10n.prvAddressCopied);
              },
            ),
            const PrivacySettingsMenu(),
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
    final l10n = AppLocalizations.of(context);
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
                  Text(
                    l10n.prvShieldedBalanceLabel,
                    style: const TextStyle(
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
                          l10n.prvVfxAmountSuffix(balance!.vfxBalance.toString()),
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
                    l10n.prvNoteCount(balance!.unspentCommitments),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.prvBlockLabel(balance!.lastScannedBlock.toString()),
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
                        child: Text(
                          l10n.prvViewOnly,
                          style: const TextStyle(
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

class _UnlockBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.orange.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.lock, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.prvUnlockBannerText,
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ),
              AppButton(
                label: l10n.prvUnlockAction,
                icon: Icons.lock_open,
                variant: AppColorVariant.Warning,
                onPressed: () => requirePrivacyUnlock(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: AppColors.getGray(ColorShade.s200),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: l10n.prvShieldAction,
                icon: Icons.arrow_downward,
                variant: AppColorVariant.Success,
                onPressed: () => ShieldDialog.show(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: l10n.prvUnshieldAction,
                icon: Icons.arrow_upward,
                variant: AppColorVariant.Warning,
                onPressed: () => requirePrivacyUnlock(ref, () => UnshieldDialog.show()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: l10n.prvTransferAction,
                icon: Icons.send,
                variant: AppColorVariant.Prism,
                onPressed: () => requirePrivacyUnlock(ref, () => PrivateTransferDialog.show()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: l10n.prvConsolidateAction,
                icon: Icons.compress,
                variant: AppColorVariant.Info,
                onPressed: () => requirePrivacyUnlock(ref, () => ConsolidateDialog.show()),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
