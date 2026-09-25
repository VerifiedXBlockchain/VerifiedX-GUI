import 'package:flutter/material.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../keygen/utils/private_key_text.dart';
import '../services/imported_key_accounts.dart';

/// Asks which Vault and Bitcoin pair to restore when an imported key's text
/// forms lead to more than one pair with activity, or when activity could not
/// be checked. Returns null when the user closes the dialog.
Future<DerivedAccounts?> chooseImportedKeyAccounts(
  BuildContext context,
  ImportedKeyAccountOptions accountOptions,
) {
  return showDialog<DerivedAccounts>(
    context: context,
    builder: (context) => _ImportedKeyAccountsDialog(accountOptions: accountOptions),
  );
}

class _ImportedKeyAccountsDialog extends StatelessWidget {
  final ImportedKeyAccountOptions accountOptions;

  const _ImportedKeyAccountsDialog({required this.accountOptions});

  String _historyLabel(AppLocalizations l10n, DerivedAccountsHistory history) {
    switch (history) {
      case DerivedAccountsHistory.found:
        return l10n.keyImportActivityFound;
      case DerivedAccountsHistory.none:
        return l10n.keyImportNoActivity;
      case DerivedAccountsHistory.unknown:
        return l10n.keyImportActivityUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = accountOptions.options;

    return AlertDialog(
      title: Text(l10n.keyImportChooseAccountsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.keyImportChooseAccountsBody),
              const SizedBox(height: 12),
              for (var i = 0; i < options.length; i++)
                Card(
                  child: ListTile(
                    title: Text(i == 0 ? l10n.keyImportStandardForm : l10n.keyImportEarlierForm),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.keyImportVaultLine(options[i].reserveKeypair.address)),
                        if (options[i].btcAccount != null) Text(l10n.keyImportBitcoinLine(options[i].btcAccount!.address)),
                        Text(
                          _historyLabel(l10n, accountOptions.histories[i]),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: accountOptions.histories[i] == DerivedAccountsHistory.found
                                ? Theme.of(context).colorScheme.success
                                : null,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(options[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppColorVariant.Light,
          type: AppButtonType.Text,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
