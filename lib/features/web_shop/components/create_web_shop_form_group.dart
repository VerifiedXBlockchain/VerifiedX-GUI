import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../utils/validation.dart';
import '../../smart_contracts/components/sc_creator/common/form_group_container.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../providers/web_shop_form_provider.dart';

class CreateWebShopFormGroup extends BaseComponent {
  const CreateWebShopFormGroup({Key? key}) : super(key: key);

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(webShopFormProvider.notifier);
    final model = ref.watch(webShopFormProvider);
    return FormGroupContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: provider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: _DecShopName(),
                  ),
                  Flexible(
                    child: _DecShopDescription(),
                  ),
                  if (model.isNew)
                    Flexible(
                      child: _DecUrl(),
                    ),
                  SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<String?> chooseAddress(BuildContext context, WidgetRef ref, WebShopFormProvider formProvider) async {
    final wallets = ref.read(walletListProvider);

    final address = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Choose an Address"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white60),
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
                        style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                  .toList(),
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
    final provider = ref.read(webShopFormProvider.notifier);
    return TextFormField(
      controller: provider.nameController,
      onChanged: provider.updateName,
      validator: (value) => formValidatorNotEmpty(value, "Shop Name"),
      decoration: InputDecoration(
        label: const Text(
          "Shop Name",
          style: TextStyle(color: Colors.white),
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
    final provider = ref.read(webShopFormProvider.notifier);
    return TextFormField(
      maxLength: 62,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      controller: provider.urlController,
      onChanged: provider.updateUrl,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("^[A-Za-z][a-zA-Z0-9-.]{0,62}")),
      ],
      validator: (value) => formValidatorNotEmpty(value, "Shop Identifier"),
      decoration: InputDecoration(
        label: const Text(
          "Shop Identifier",
          style: TextStyle(color: Colors.white),
        ),
        hintText: "MyNewShop",
        prefixText: "vfx://",
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
    final provider = ref.read(webShopFormProvider.notifier);
    return TextFormField(
      controller: provider.descriptionController,
      onChanged: provider.updateDescription,
      validator: (value) => formValidatorNotEmpty(value, "Shop Description"),
      maxLines: 3,
      decoration: InputDecoration(
        label: const Text(
          "Shop Description",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
