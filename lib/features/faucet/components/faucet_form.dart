import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/faucet_form_provider.dart';

class FaucetForm extends BaseComponent {
  final double? forceAmount;
  const FaucetForm({super.key, this.forceAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(faucetFormProvider.notifier);
    final model = ref.watch(faucetFormProvider);

    final address = kIsWeb
        ? ref.watch(webSessionProvider.select((v) => v.keypair?.address))
        : ref.watch(sessionProvider.select((v) => v.currentWallet?.address));

    if (address == null) {
      return Center(
        child: Text("Please choose a VFX account to continue"),
      );
    }

    if (model.verificationUuid.isNotEmpty) {
      return Form(
        key: provider.verificationFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: provider.verificationController,
                      validator: provider.verificationValidator,
                      decoration:
                          InputDecoration(label: Text("Verification Code")),
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  AppButton(
                    onPressed: () async {
                      final success = await provider.submitVerification();
                      if (success == true) {
                        Navigator.pop(context);
                      }
                    },
                    variant: AppColorVariant.Secondary,
                    label: "Verify",
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Form(
      key: provider.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "VFX Address: $address",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          if (forceAmount != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Amount: $forceAmount VFX"),
            ),
          if (forceAmount == null)
            TextFormField(
              controller: provider.amountController,
              validator: provider.amountValidator,
              decoration: InputDecoration(
                label: Text("Amount"),
              ),
            ),
          TextFormField(
            controller: provider.phoneController,
            validator: provider.phoneValidator,
            decoration: InputDecoration(
              label: Text("Phone Number"),
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                label: "Cancel",
              ),
              AppButton(
                onPressed: () {
                  provider.submitRequest(forceAmount);
                },
                variant: AppColorVariant.Secondary,
                label: "Request VFX",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
