import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../components/privacy_activation_card.dart';
import '../components/privacy_dashboard.dart';
import '../providers/plonk_status_provider.dart';
import '../providers/shielded_address_provider.dart';

class PrivacyScreen extends BaseScreen {
  const PrivacyScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.prvScreenTitle),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plonkStatus = ref.watch(plonkStatusNotifierProvider);
    final shieldedAddress = ref.watch(shieldedAddressProvider);

    if (plonkStatus == null || !plonkStatus.isPrivacyEnabled) {
      // Trigger a fresh check whenever the user lands here and privacy isn't enabled
      Future.microtask(() => ref.read(plonkStatusNotifierProvider.notifier).refresh());
    }

    if (plonkStatus == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.prvCheckingStatus,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (!plonkStatus.isPrivacyEnabled) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 48, color: AppColors.getPrism()),
            const SizedBox(height: 24),
            Text(
              l10n.prvLayerStartingUp,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.prvPlonkInitializing,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    if (shieldedAddress == null) {
      return const PrivacyActivationCard();
    }

    return PrivacyDashboard(address: shieldedAddress);
  }
}
