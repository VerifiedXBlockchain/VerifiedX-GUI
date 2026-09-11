import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/guards.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../../core/dialogs.dart';
import '../providers/shielded_address_provider.dart';

class PrivacyActivationCard extends BaseComponent {
  const PrivacyActivationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
                Text(
                  l10n.prvPrismLayerTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.prvActivationDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
    if (!widgetGuardWalletIsSynced(ref)) return;

    final wallet = ref.read(sessionProvider).currentWallet;
    if (wallet == null) {
      Toast.error(globalL10n.messageNoAccountSelected);
      return;
    }

    // Prompt for a new password
    final password = await _promptNewPassword();
    if (password == null) return;

    setState(() => _isLoading = true);
    try {
      final address = await ref.read(shieldedAddressProvider.notifier).generate(wallet.address, password);
      if (address != null) {
        Toast.message(globalL10n.prvWalletActivated(address.zfxAddress));
      } else {
        Toast.error(globalL10n.prvFailedGenerateShieldedAddress);
      }
    } catch (e) {
      Toast.error(globalL10n.prvErrorActivatingWallet(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _promptNewPassword() async {
    final l10n = globalL10n;
    final password = await PromptModal.show(
      contextOverride: rootNavigatorKey.currentContext!,
      title: l10n.prvCreatePasswordTitle,
      labelText: l10n.prvPasswordLabel,
      body: l10n.prvCreatePasswordBody,
      validator: (value) => formValidatorNotEmpty(value, l10n.prvPasswordLabel),
      obscureText: true,
      revealObscure: true,
      lines: 1,
    );

    if (password == null) return null;

    // Confirm
    final confirm = await PromptModal.show(
      contextOverride: rootNavigatorKey.currentContext!,
      title: l10n.prvConfirmPasswordTitle,
      labelText: l10n.prvConfirmPasswordLabel,
      validator: (value) {
        if (value != password) return l10n.prvPasswordsDoNotMatch;
        return null;
      },
      obscureText: true,
      lines: 1,
    );

    if (confirm != password) {
      Toast.error(l10n.prvPasswordConfirmationFailed);
      return null;
    }

    return password;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: _isLoading ? l10n.prvActivating : l10n.prvActivateWallet,
      icon: Icons.shield,
      variant: AppColorVariant.Prism,
      processing: _isLoading,
      onPressed: _isLoading ? null : _activate,
    );
  }
}
