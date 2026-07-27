import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../providers/privacy_actions_provider.dart';
import '../providers/shielded_address_provider.dart';
import '../utils/vfx_fee_guard.dart';

class UnshieldDialog extends ConsumerStatefulWidget {
  const UnshieldDialog({super.key});

  static Future<void> show() async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => const UnshieldDialog(),
    );
  }

  @override
  ConsumerState<UnshieldDialog> createState() => _UnshieldDialogState();
}

class _UnshieldDialogState extends ConsumerState<UnshieldDialog> {
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddressPicker() {
    final wallets = ref.read(walletListProvider);
    if (wallets.isEmpty) {
      Toast.error("No accounts found");
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => ModalContainer(
        title: "Select Account",
        withClose: true,
        children: wallets.map((wallet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tileColor: Colors.white.withOpacity(0.03),
              leading: const Icon(Icons.account_balance_wallet, size: 18, color: Colors.white54),
              title: Text(
                wallet.adnr != null ? "${wallet.adnr}.vfx" : wallet.address,
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: wallet.adnr != null
                  ? Text(wallet.address, style: const TextStyle(fontSize: 11, color: Colors.white38, fontFamily: 'monospace'))
                  : null,
              trailing: Text(
                "${wallet.balance} VFX",
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              onTap: () {
                _toAddressController.text = wallet.address;
                Navigator.of(context).pop();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _submit() async {
    if (!await VfxFeeGuard.check(ref)) return;

    final toAddress = _toAddressController.text.trim();
    if (!isValidRbxAddress(toAddress)) {
      Toast.error("Please enter a valid VFX address");
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Toast.error("Please enter a valid amount");
      return;
    }

    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(privacyActionsProvider.notifier).unshield(
          zfxAddress: zfxAddress,
          toAddress: toAddress,
          amount: amount,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unshield VFX"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Move VFX from the shielded pool back to a transparent address.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toAddressController,
              decoration: InputDecoration(
                labelText: "To Address (transparent)",
                hintText: "Enter VFX address",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.account_balance_wallet, size: 20),
                  tooltip: "Select from my accounts",
                  onPressed: _isSubmitting ? null : () => _showAddressPicker(),
                ),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount (VFX)",
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 8),
            Text(
              "$PRIVACY_TX_FIXED_FEE_LABEL fee deducted from shielded balance.",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Unshield", style: TextStyle(color: Theme.of(context).colorScheme.warning)),
        ),
      ],
    );
  }
}
