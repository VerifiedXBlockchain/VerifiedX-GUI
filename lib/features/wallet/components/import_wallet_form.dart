import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/components/buttons.dart';
import '../../../l10n/generated/app_localizations.dart';

class ImportWalletForm extends StatelessWidget {
  const ImportWalletForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    return Form(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _controller,
            obscureText: true,
            decoration: InputDecoration(label: Text(l10n.walletPrivateKeyLabel)),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            ],
          ),
          AppButton(label: l10n.walletImportLabel)
        ],
      ),
    );
  }
}
