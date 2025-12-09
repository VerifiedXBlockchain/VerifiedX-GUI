import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';

class AuthTypeModal extends StatelessWidget {
  final Function() handleMnemonic;
  final Function() handleUsername;
  final Function(BuildContext context)? handlePrivateKey;
  final Function(BuildContext context)? handleBtcPrivateKey;
  final Function(BuildContext context)? handleExtension;

  const AuthTypeModal({
    Key? key,
    required this.handleUsername,
    required this.handleMnemonic,
    this.handlePrivateKey,
    this.handleBtcPrivateKey,
    this.handleExtension,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      withDecor: false,
      withClose: false,
      padding: 16.0,
      // color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      children: [
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text(
            "Email & Password",
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 32,
          ),
          onTap: handleUsername,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(FontAwesomeIcons.paragraph),
          title: const Text(
            "Mnemonic (HD account)",
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 32,
          ),
          onTap: handleMnemonic,
        ),
        if (handlePrivateKey != null) const Divider(height: 1),
        if (handlePrivateKey != null)
          ListTile(
            leading: const Icon(FontAwesomeIcons.key),
            title: const Text(
              "VFX Private Key",
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 32,
            ),
            onTap: () {
              handlePrivateKey!(context);
            },
          ),
        if (handleBtcPrivateKey != null) const Divider(height: 1),
        if (handleBtcPrivateKey != null)
          ListTile(
            leading: const Icon(FontAwesomeIcons.bitcoin),
            title: const Text(
              "Bitcoin Private Key / WIF Key",
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 32,
            ),
            onTap: () {
              handleBtcPrivateKey!(context);
            },
          ),
        if (handleExtension != null) const Divider(height: 1),
        if (handleExtension != null)
          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text(
              "VFX Extension",
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 32,
            ),
            onTap: () {
              handleExtension!(context);
            },
          ),
      ],
    );
  }
}
