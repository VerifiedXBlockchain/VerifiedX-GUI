import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../providers/privacy_actions_provider.dart';
import '../providers/shielded_address_provider.dart';
import '../providers/shielded_balance_provider.dart';
import '../utils/vfx_fee_guard.dart';

class ConsolidateDialog extends ConsumerStatefulWidget {
  const ConsolidateDialog({super.key});

  static Future<void> show() async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => const ConsolidateDialog(),
    );
  }

  @override
  ConsumerState<ConsolidateDialog> createState() => _ConsolidateDialogState();
}

class _ConsolidateDialogState extends ConsumerState<ConsolidateDialog> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!await VfxFeeGuard.check(ref)) return;

    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error(globalL10n.prvNoShieldedAddress);
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(privacyActionsProvider.notifier).consolidate(
          zfxAddress: zfxAddress,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = ref.watch(shieldedBalanceProvider);
    final noteCount = balance?.unspentCommitments ?? 0;
    final canConsolidate = noteCount >= 2;

    return AlertDialog(
      title: Text(l10n.prvConsolidateNotesTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.prvConsolidateNotesBody,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.prvCurrentNotes(noteCount),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.prvFeeDeductedFromShielded(PRIVACY_TX_FIXED_FEE_LABEL),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            if (!canConsolidate) ...[
              const SizedBox(height: 12),
              Text(
                l10n.prvConsolidateMinNotes,
                style: TextStyle(color: Theme.of(context).colorScheme.danger, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _isSubmitting || !canConsolidate ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  l10n.prvConsolidateAction,
                  style: TextStyle(
                    color: canConsolidate ? Theme.of(context).colorScheme.info : Colors.white38,
                  ),
                ),
        ),
      ],
    );
  }
}
