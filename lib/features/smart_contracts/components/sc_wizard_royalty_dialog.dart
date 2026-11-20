import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/base_component.dart';
import '../../../core/providers/web_session_provider.dart';
import 'sc_creator/common/help_button.dart';
import '../features/royalty/royalty.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../utils/validation.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardRoyaltyDialog extends BaseComponent {
  ScWizardRoyaltyDialog({
    Key? key,
  }) : super(key: key);

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  Future<String?> chooseAddress(BuildContext context, WidgetRef ref) async {
    final wallets = ref.read(walletListProvider);

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).scwChooseAnAddress),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(
                AppLocalizations.of(context).actionCancel,
                style: const TextStyle(color: Colors.white60),
              ),
            )
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: wallets
                .map(
                  (w) => TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(w.address);
                    },
                    child: Text(
                      w.fullLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Builder(builder: (context) {
      return Form(
        key: formKey,
        child: AlertDialog(
          title: Text(l10n.scwAddRoyalty),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                              label: Text(l10n.labelAmount),
                              labelStyle: const TextStyle(color: Colors.white),
                              suffix: const Text("%"),
                              prefixIcon: const HelpButton(
                                  HelpType.royaltyPercent,
                                  subtle: true)),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                          ],
                          validator: formPercentValidator),
                    ),
                  ],
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    label: Text(l10n.labelAddress),
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: kIsWeb
                        ? IconButton(
                            color: Colors.white,
                            onPressed: () {
                              final address =
                                  ref.read(webSessionProvider).keypair?.address;

                              if (address != null) {
                                addressController.text = address;
                              }
                            },
                            tooltip: l10n.scwUseMyAddress,
                            icon: const Icon(Icons.wallet))
                        : IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.folderOpen,
                              size: 16,
                              color: Colors.white,
                            ),
                            tooltip: l10n.scwChooseAnAddress,
                            onPressed: () async {
                              final address = await chooseAddress(context, ref);
                              print(address);
                              if (address != null) {
                                addressController.text = address;
                              }
                            },
                          ),
                    prefixIcon: const HelpButton(
                      HelpType.royaltyAddress,
                      subtle: true,
                      mini: true,
                    ),
                  ),
                  validator: (value) => formValidatorRbxAddress(value),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(
                l10n.actionCancel,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final r = Royalty(
                  type: RoyaltyType.percent,
                  amount: double.parse(amountController.text) / 100,
                  address: addressController.text,
                );

                Navigator.of(context).pop(r);
              },
              child: Text(
                l10n.scwAddRoyalty,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    });
  }
}
