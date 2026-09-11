import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/components/buttons.dart';
import '../../../core/web_router.gr.dart';
import '../../../l10n/generated/app_localizations.dart';

class WebNotWallet extends StatelessWidget {
  const WebNotWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.hnavNoWalletDetected),
          const SizedBox(
            height: 8,
          ),
          AppButton(
            label: l10n.webSetupWallet,
            onPressed: () {
              AutoRouter.of(context).replace(const WebAuthRouter());
            },
          )
        ],
      ),
    );
  }
}
