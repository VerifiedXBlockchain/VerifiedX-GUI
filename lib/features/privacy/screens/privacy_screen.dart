import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../core/theme/colors.dart';
import '../components/privacy_activation_card.dart';
import '../components/privacy_dashboard.dart';
import '../providers/plonk_status_provider.dart';
import '../providers/shielded_address_provider.dart';

class PrivacyScreen extends BaseScreen {
  const PrivacyScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text("PRISM Privacy"),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final plonkStatus = ref.watch(plonkStatusNotifierProvider);
    final shieldedAddress = ref.watch(shieldedAddressProvider);

    if (plonkStatus == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Checking privacy layer status...",
              style: TextStyle(color: Colors.white70),
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
            Icon(Icons.shield_outlined, size: 48, color: AppColors.getBlue()),
            const SizedBox(height: 16),
            const Text(
              "Privacy layer is not available on this node.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "PLONK proof generation and verification are required.",
              style: TextStyle(color: Colors.white38, fontSize: 13),
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
