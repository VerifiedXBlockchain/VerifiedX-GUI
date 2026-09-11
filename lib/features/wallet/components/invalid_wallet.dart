import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'wallet_selector.dart';

class InvalidWallet extends StatelessWidget {
  final String message;
  const InvalidWallet({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(),
          Text(
            AppLocalizations.of(context).walletChangeAccount,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          WalletSelector(
            truncatedLabel: false,
            withOptions: false,
          )
        ],
      ),
    );
  }
}
