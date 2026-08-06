import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/wallet.dart';
import '../providers/wallet_detail_provider.dart';

class WalletContextMenu extends BaseComponent {
  final Wallet wallet;
  const WalletContextMenu(this.wallet, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text(l10n.walletRename),
            onTap: () {
              PromptModal.show(
                title: l10n.walletRenameTitle(wallet.label),
                validator: (_) => null,
                labelText: l10n.walletNameLabel,
                initialValue: wallet.friendlyName ?? "",
                onValidSubmission: (value) {
                  ref.read(walletDetailProvider(wallet).notifier).rename(value);
                },
              );
            },
          ),
          PopupMenuItem(
            textStyle: TextStyle(color: Theme.of(context).colorScheme.danger),
            child: Text(l10n.walletDelete),
            onTap: () {},
          ),
        ];
      },
    );
  }
}
