import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/app_constants.dart';
import '../../../utils/toast.dart';
import '../providers/privacy_actions_provider.dart';
import '../providers/shielded_address_provider.dart';

class PrivateTransferDialog extends ConsumerStatefulWidget {
  const PrivateTransferDialog({super.key});

  static Future<void> show() async {
    await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => const PrivateTransferDialog(),
    );
  }

  @override
  ConsumerState<PrivateTransferDialog> createState() => _PrivateTransferDialogState();
}

// Base58 alphabet (no 0, O, I, l)
const _base58Chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

bool _isValidZfxAddress(String address) {
  if (!address.startsWith('zfx_')) return false;
  final body = address.substring(4);
  // Base58Check of 39 bytes (2 version + 33 key + 4 checksum) produces ~53 chars
  if (body.length < 40) return false;
  return body.split('').every((c) => _base58Chars.contains(c));
}

class _PrivateTransferDialogState extends ConsumerState<PrivateTransferDialog> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final recipient = _recipientController.text.trim();
    if (!_isValidZfxAddress(recipient)) {
      Toast.error("Recipient must be a valid zfx_ address");
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

    final success = await ref.read(privacyActionsProvider.notifier).transfer(
          zfxAddress: zfxAddress,
          recipientZfxAddress: recipient,
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
      title: const Text("Private Transfer"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transfer shielded VFX to another zfx_ address. Fully private.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: "Recipient (zfx_ address)",
                hintText: "zfx_...",
                border: OutlineInputBorder(),
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
              : const Text("Transfer"),
        ),
      ],
    );
  }
}
