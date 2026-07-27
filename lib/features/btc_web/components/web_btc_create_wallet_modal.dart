import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';

enum NewBtcWalletOption {
  generate,
  import,
}

class WebCreateBtcWalletModal extends StatelessWidget {
  const WebCreateBtcWalletModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModalContainer(
      withClose: true,
      withDecor: false,
      children: [
        Text(
          l10n.btcAddBtcAccount,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: glowingBoxBtc,
            ),
            child: Card(
              color: Colors.black,
              child: ListTile(
                title: Text(l10n.btcGenerateKeypair),
                subtitle: Text(l10n.btcGenerateKeypairSubtitle),
                trailing: Icon(Icons.chevron_right),
                leading: Icon(FontAwesomeIcons.diceD6),
                onTap: () async {
                  Navigator.of(context).pop(NewBtcWalletOption.generate);
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: glowingBoxBtc,
            ),
            child: Card(
              color: Colors.black,
              child: ListTile(
                title: Text(l10n.btcImportWifTitle),
                subtitle: Text(l10n.btcImportWifSubtitle),
                trailing: Icon(Icons.chevron_right),
                leading: Icon(Icons.upload),
                onTap: () async {
                  Navigator.of(context).pop(NewBtcWalletOption.import);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
