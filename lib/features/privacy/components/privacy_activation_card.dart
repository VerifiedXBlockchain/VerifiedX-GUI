import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/theme/colors.dart';
import '../../../utils/toast.dart';
import '../providers/shielded_address_provider.dart';

class PrivacyActivationCard extends BaseComponent {
  const PrivacyActivationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: AppColors.getGray(ColorShade.s200),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppColors.getBlue(),
                ),
                const SizedBox(height: 24),
                const Text(
                  "PRISM Privacy Layer",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Activate your privacy wallet to shield VFX using zero-knowledge proofs. "
                  "Shielded funds are hidden from the public ledger and can be transferred privately.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _ActivateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivateButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ActivateButton> createState() => _ActivateButtonState();
}

class _ActivateButtonState extends ConsumerState<_ActivateButton> {
  bool _isLoading = false;

  Future<void> _activate() async {
    setState(() => _isLoading = true);
    try {
      final address = await ref.read(shieldedAddressProvider.notifier).generate();
      if (address != null) {
        Toast.message("Privacy wallet activated: ${address.zfxAddress}");
      } else {
        Toast.error("Failed to generate shielded address");
      }
    } catch (e) {
      Toast.error("Error activating privacy wallet: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _activate,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.shield),
        label: Text(_isLoading ? "Activating..." : "Activate Privacy Wallet"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getBlue(),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
