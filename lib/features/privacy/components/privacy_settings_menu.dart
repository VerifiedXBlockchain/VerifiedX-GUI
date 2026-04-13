import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/colors.dart';
import '../../../utils/toast.dart';
import '../services/privacy_service.dart';
import '../providers/shielded_address_provider.dart';
import '../../btc/providers/tokenized_bitcoin_list_provider.dart';

class PrivacySettingsMenu extends ConsumerWidget {
  const PrivacySettingsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings, color: Colors.white54, size: 20),
      tooltip: "Privacy settings",
      color: AppColors.getGray(ColorShade.s200),
      onSelected: (value) {
        switch (value) {
          case 'export_viewing_key':
            _exportViewingKey(ref);
            break;
          case 'import_viewing_key':
            _importViewingKey();
            break;
          case 'resync':
            _resyncWallet(ref);
            break;
          case 'resync_vbtc':
            _resyncVbtcWallet(ref);
            break;
          case 'reset':
            _resetWallet(ref);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'export_viewing_key',
          child: Row(
            children: [
              const Icon(Icons.key, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              const Text("Export Viewing Key"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'import_viewing_key',
          child: Row(
            children: [
              const Icon(Icons.download, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              const Text("Import Viewing Key"),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'resync',
          child: Row(
            children: [
              const Icon(Icons.sync, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              const Text("Resync Wallet", style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'resync_vbtc',
          child: Row(
            children: [
              Icon(Icons.sync, size: 18, color: AppColors.getBtc()),
              const SizedBox(width: 8),
              Text("Resync vBTC Wallet", style: TextStyle(color: AppColors.getBtc())),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(Icons.delete_forever, size: 18, color: Colors.red.shade300),
              const SizedBox(width: 8),
              Text("Reset Privacy Wallet", style: TextStyle(color: Colors.red.shade300)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportViewingKey(WidgetRef ref) async {
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    final result = await PrivacyService().exportViewingKey(zfxAddress: zfxAddress);
    if (result != null && result['ViewingKeyBase64'] != null) {
      final key = result['ViewingKeyBase64'] as String;
      await InfoDialog.show(
        title: "Viewing Key",
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Copy this key to import a view-only wallet on another device. This key can see balances but cannot spend.",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        key,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      color: Colors.white54,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: key));
                        Toast.message("Viewing key copied to clipboard");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Toast.error("Failed to export viewing key");
    }
  }

  Future<void> _importViewingKey() async {
    final context = rootNavigatorKey.currentContext!;
    await showDialog(
      context: context,
      builder: (_) => const _ImportViewingKeyDialog(),
    );
  }

  Future<void> _resyncWallet(WidgetRef ref) async {
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    final confirmed = await ConfirmDialog.show(
      title: "Resync Shielded Wallet",
      body: "This will wipe all cached notes and balances, then rescan from the beginning. This may take a while.\n\nContinue?",
      confirmText: "Resync",
      cancelText: "Cancel",
      destructive: true,
    );

    if (confirmed == true) {
      Toast.message("Resync started...");
      final success = await PrivacyService().resyncShieldedWallet(
        zfxAddress: zfxAddress,
        fromHeight: 0,
        toHeight: 0,
      );
      if (success) {
        Toast.message("Resync complete");
      } else {
        Toast.error("Resync failed");
      }
    }
  }

  Future<void> _resyncVbtcWallet(WidgetRef ref) async {
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error("No shielded address found");
      return;
    }

    final allTokens = ref.read(tokenizedBitcoinListProvider);
    final vbtcTokens = allTokens.where((t) => t.version == 2).toList();

    if (vbtcTokens.isEmpty) {
      Toast.error("No vBTC tokens found");
      return;
    }

    final context = rootNavigatorKey.currentContext!;

    // If only one token, skip the picker
    String selectedUid;
    String selectedName;
    if (vbtcTokens.length == 1) {
      selectedUid = vbtcTokens.first.smartContractUid;
      selectedName = vbtcTokens.first.tokenName;
    } else {
      // Show picker dialog
      final picked = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Select vBTC Contract"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose which vBTC contract to resync.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...List.generate(vbtcTokens.length, (i) {
                  final token = vbtcTokens[i];
                  return ListTile(
                    title: Text(token.tokenName, style: TextStyle(color: AppColors.getBtc())),
                    subtitle: Text(
                      token.smartContractUid,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white38),
                    ),
                    onTap: () => Navigator.of(ctx).pop(i),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );

      if (picked == null) return;
      selectedUid = vbtcTokens[picked].smartContractUid;
      selectedName = vbtcTokens[picked].tokenName;
    }

    final confirmed = await ConfirmDialog.show(
      title: "Resync vBTC Wallet",
      body: "This will wipe cached notes and balances for \"$selectedName\" and rescan from the beginning. This may take a while.\n\nContinue?",
      confirmText: "Resync",
      cancelText: "Cancel",
      destructive: true,
    );

    if (confirmed == true) {
      Toast.message("vBTC resync started...");
      final success = await PrivacyService().resyncShieldedVbtc(
        zfxAddress: zfxAddress,
        vbtcContractUid: selectedUid,
      );
      if (success) {
        Toast.message("vBTC resync complete");
      } else {
        Toast.error("vBTC resync failed");
      }
    }
  }

  Future<void> _resetWallet(WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      title: "Reset Privacy Wallet",
      body: "This will clear your local privacy wallet state and return to the activation screen. Your shielded funds on the network are not affected — you can re-activate with the same account to recover them.\n\nContinue?",
      confirmText: "Reset",
      cancelText: "Cancel",
      destructive: true,
    );

    if (confirmed == true) {
      ref.read(shieldedAddressProvider.notifier).clear();
      Toast.message("Privacy wallet reset");
    }
  }
}

class _ImportViewingKeyDialog extends ConsumerStatefulWidget {
  const _ImportViewingKeyDialog();

  @override
  ConsumerState<_ImportViewingKeyDialog> createState() => _ImportViewingKeyDialogState();
}

class _ImportViewingKeyDialogState extends ConsumerState<_ImportViewingKeyDialog> {
  final _addressController = TextEditingController();
  final _keyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final address = _addressController.text.trim();
    if (address.isEmpty || !address.startsWith("zfx_")) {
      Toast.error("Please enter a valid zfx_ address");
      return;
    }

    final key = _keyController.text.trim();
    if (key.isEmpty) {
      Toast.error("Please enter the viewing key");
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await PrivacyService().importViewingKey(
      zfxAddress: address,
      viewingKeyBase64: key,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Toast.message("Viewing key imported successfully");
        Navigator.of(context).pop();
      } else {
        Toast.error("Failed to import viewing key");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Viewing Key"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Import a viewing key to create a view-only wallet. You can see balances but cannot spend.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "zfx_ Address",
                hintText: "zfx_...",
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: "Viewing Key (Base64)",
                hintText: "Paste Base64 key here",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              enabled: !_isSubmitting,
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
              : const Text("Import"),
        ),
      ],
    );
  }
}
