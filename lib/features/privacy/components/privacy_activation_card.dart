import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../../core/dialogs.dart';
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
                  color: AppColors.getPrism(),
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
    final wallet = ref.read(sessionProvider).currentWallet;
    if (wallet == null) {
      Toast.error("No account selected");
      return;
    }

    // Prompt for a new password
    final password = await _promptNewPassword();
    if (password == null) return;

    setState(() => _isLoading = true);
    try {
      final address = await ref.read(shieldedAddressProvider.notifier).generate(wallet.address, password);
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

  Future<String?> _promptNewPassword() async {
    final password = await PromptModal.show(
      contextOverride: rootNavigatorKey.currentContext!,
      title: "Create Privacy Password",
      labelText: "Password",
      body: "Create a password to secure your shielded wallet's spending key. You'll need this password to unshield, transfer, or consolidate funds.",
      validator: (value) => formValidatorNotEmpty(value, "Password"),
      obscureText: true,
      revealObscure: true,
      lines: 1,
    );

    if (password == null) return null;

    // Confirm
    final confirm = await PromptModal.show(
      contextOverride: rootNavigatorKey.currentContext!,
      title: "Confirm Password",
      labelText: "Confirm Password",
      validator: (value) {
        if (value != password) return "Passwords do not match";
        return null;
      },
      obscureText: true,
      lines: 1,
    );

    if (confirm != password) {
      Toast.error("Password confirmation failed");
      return null;
    }

    return password;
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _isLoading ? "Activating..." : "Activate Privacy Wallet",
      icon: Icons.shield,
      variant: AppColorVariant.Prism,
      processing: _isLoading,
      onPressed: _isLoading ? null : _activate,
    );
  }
}
