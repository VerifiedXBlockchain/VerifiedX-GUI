import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/components.dart';

import '../../../core/base_component.dart';
import '../../../utils/validation.dart';
import '../../smart_contracts/components/sc_creator/common/form_group_container.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../providers/dec_shop_form_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class CreateDecShopFormGroup extends BaseComponent {
  const CreateDecShopFormGroup({Key? key}) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(decShopFormProvider.notifier);
    final model = ref.watch(decShopFormProvider);
    return FormGroupContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AppCard(
              child: Form(
                key: provider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (model.id == 0)
                      Center(
                        child: Text(
                          l10n.mktCreateAuctionHouseBody,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Flexible(
                      child: _DecShopName(),
                    ),
                    Flexible(
                      child: _DecShopDescription(),
                    ),
                    Flexible(
                      child: _DecUrl(),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Flexible(
                      child: ListTile(
                        onTap: model.id == 0
                            ? () async {
                                final address = await chooseAddress(context, ref, provider);
                                if (address != null) {
                                  provider.updateAddress(address);
                                }
                              }
                            : null,
                        title: Text(l10n.mktOwnersAddressLabel),
                        subtitle: Text(model.ownerAddress == null || model.ownerAddress!.isEmpty
                            ? l10n.mktSelectOwnerAddressHint
                            : model.ownerAddress!),
                        trailing: model.id == 0 ? Icon(Icons.folder_copy_outlined) : null,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    // Flexible(
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Checkbox(
                    //         value: model.autoUpdateNetworkDns,
                    //         onChanged: (val) {
                    //           if (val != null) {
                    //             provider.updateAutoUpdateNetworkDns(val);
                    //           }
                    //         },
                    //       ),
                    //       SizedBox(
                    //         width: 8,
                    //       ),
                    //       Text("Auto Update on DNS Change")
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<String?> chooseAddress(BuildContext context, WidgetRef ref, DecShopFormProvider formProvider) async {
    final l10n = AppLocalizations.of(context);
    final wallets = ref.read(walletListProvider);

    final address = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.sendChooseAddressTitle),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text(
                  l10n.actionCancel,
                  style: const TextStyle(color: Colors.white60),
                ),
              )
            ],
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
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
                            style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        });
    return address;
  }
}

class _DecShopName extends BaseComponent {
  const _DecShopName({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(decShopFormProvider.notifier);
    return TextFormField(
      controller: provider.nameController,
      onChanged: provider.updateName,
      validator: (value) => formValidatorNotEmpty(value, l10n.mktShopNameLabel),
      decoration: InputDecoration(
        label: Text(
          l10n.mktShopNameLabel,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _DecUrl extends BaseComponent {
  const _DecUrl({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(decShopFormProvider.notifier);
    return TextFormField(
      maxLength: 62,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      controller: provider.urlController,
      onChanged: provider.updateUrl,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("^[A-Za-z][a-zA-Z0-9-.]{0,62}")),
      ],
      validator: (value) => formValidatorNotEmpty(value, l10n.mktShopIdentifierLabel),
      decoration: InputDecoration(
        label: Text(
          l10n.mktShopIdentifierLabel,
          style: const TextStyle(color: Colors.white),
        ),
        prefixText: "vfx://",
        hintText: "MyShop",
      ),
    );
  }
}

class _DecShopDescription extends BaseComponent {
  const _DecShopDescription({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(decShopFormProvider.notifier);
    return TextFormField(
      controller: provider.descriptionController,
      onChanged: provider.updateDescription,
      validator: (value) => formValidatorNotEmpty(value, l10n.mktShopDescriptionLabel),
      maxLines: 3,
      decoration: InputDecoration(
        label: Text(
          l10n.mktShopDescriptionLabel,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
