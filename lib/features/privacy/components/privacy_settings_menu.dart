import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../services/privacy_service.dart';
import '../providers/shielded_address_provider.dart';
import '../../btc/providers/tokenized_bitcoin_list_provider.dart';

class PrivacySettingsMenu extends ConsumerWidget {
  const PrivacySettingsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings, color: Colors.white54, size: 20),
      tooltip: l10n.prvSettingsTooltip,
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
              Text(l10n.prvExportViewingKey),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'import_viewing_key',
          child: Row(
            children: [
              const Icon(Icons.download, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text(l10n.prvImportViewingKey),
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
              Text(l10n.prvResyncWallet, style: const TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'resync_vbtc',
          child: Row(
            children: [
              Icon(Icons.sync, size: 18, color: AppColors.getBtc()),
              const SizedBox(width: 8),
              Text(l10n.prvResyncVbtcWallet, style: TextStyle(color: AppColors.getBtc())),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(Icons.delete_forever, size: 18, color: Colors.red.shade300),
              const SizedBox(width: 8),
              Text(l10n.prvResetPrivacyWallet, style: TextStyle(color: Colors.red.shade300)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportViewingKey(WidgetRef ref) async {
    final l10n = globalL10n;
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error(l10n.prvNoShieldedAddress);
      return;
    }

    final result = await PrivacyService().exportViewingKey(zfxAddress: zfxAddress);
    if (result != null && result['ViewingKeyBase64'] != null) {
      final key = result['ViewingKeyBase64'] as String;
      await InfoDialog.show(
        title: l10n.prvViewingKeyTitle,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.prvExportViewingKeyBody,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                        Toast.message(l10n.prvViewingKeyCopied);
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
      Toast.error(l10n.prvFailedExportViewingKey);
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
    final l10n = globalL10n;
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error(l10n.prvNoShieldedAddress);
      return;
    }

    final confirmed = await ConfirmDialog.show(
      title: l10n.prvResyncShieldedWalletTitle,
      body: l10n.prvResyncShieldedWalletBody,
      confirmText: l10n.prvResyncAction,
      cancelText: l10n.actionCancel,
      destructive: true,
    );

    if (confirmed == true) {
      Toast.message(l10n.prvResyncStarted);
      final success = await PrivacyService().resyncShieldedWallet(
        zfxAddress: zfxAddress,
        fromHeight: 0,
        toHeight: 0,
      );
      if (success) {
        Toast.message(l10n.prvResyncComplete);
      } else {
        Toast.error(l10n.prvResyncFailed);
      }
    }
  }

  Future<void> _resyncVbtcWallet(WidgetRef ref) async {
    final l10n = globalL10n;
    final zfxAddress = ref.read(shieldedAddressProvider)?.zfxAddress;
    if (zfxAddress == null) {
      Toast.error(l10n.prvNoShieldedAddress);
      return;
    }

    final allTokens = ref.read(tokenizedBitcoinListProvider);
    final vbtcTokens = allTokens.where((t) => t.version == 2).toList();

    if (vbtcTokens.isEmpty) {
      Toast.error(l10n.prvNoVbtcTokens);
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
          title: Text(l10n.prvSelectVbtcContract),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.prvChooseVbtcContract,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
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
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      );

      if (picked == null) return;
      selectedUid = vbtcTokens[picked].smartContractUid;
      selectedName = vbtcTokens[picked].tokenName;
    }

    final confirmed = await ConfirmDialog.show(
      title: l10n.prvResyncVbtcWallet,
      body: l10n.prvResyncVbtcBody(selectedName),
      confirmText: l10n.prvResyncAction,
      cancelText: l10n.actionCancel,
      destructive: true,
    );

    if (confirmed == true) {
      Toast.message(l10n.prvVbtcResyncStarted);
      final success = await PrivacyService().resyncShieldedVbtc(
        zfxAddress: zfxAddress,
        vbtcContractUid: selectedUid,
      );
      if (success) {
        Toast.message(l10n.prvVbtcResyncComplete);
      } else {
        Toast.error(l10n.prvVbtcResyncFailed);
      }
    }
  }

  Future<void> _resetWallet(WidgetRef ref) async {
    final l10n = globalL10n;
    final confirmed = await ConfirmDialog.show(
      title: l10n.prvResetPrivacyWallet,
      body: l10n.prvResetWalletBody,
      confirmText: l10n.prvResetAction,
      cancelText: l10n.actionCancel,
      destructive: true,
    );

    if (confirmed == true) {
      ref.read(shieldedAddressProvider.notifier).clear();
      Toast.message(l10n.prvWalletReset);
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
      Toast.error(globalL10n.prvEnterValidZfxAddress);
      return;
    }

    final key = _keyController.text.trim();
    if (key.isEmpty) {
      Toast.error(globalL10n.prvEnterViewingKey);
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
        Toast.message(globalL10n.prvViewingKeyImported);
        Navigator.of(context).pop();
      } else {
        Toast.error(globalL10n.prvFailedImportViewingKey);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.prvImportViewingKey),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.prvImportViewingKeyBody,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.prvZfxAddressLabel,
                hintText: "zfx_...",
                border: const OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: l10n.prvViewingKeyBase64Label,
                hintText: l10n.prvPasteBase64Hint,
                border: const OutlineInputBorder(),
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
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.prvImportAction),
        ),
      ],
    );
  }
}
