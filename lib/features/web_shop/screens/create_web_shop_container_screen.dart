import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dst/components/publish_shop_button.dart';
import '../../dst/components/shop_online_button.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../components/create_web_shop_form_group.dart';
import '../providers/web_shop_form_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class CreateWebShopContainerScreen extends BaseScreen {
  const CreateWebShopContainerScreen({Key? key}) : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(webShopFormProvider.notifier);
    final model = ref.read(webShopFormProvider);

    return AppBar(
      backgroundColor: Colors.black,
      title: Text(model.id != 0 ? l10n.r3bEditAuctionHouse : l10n.r3bCreateAuctionHouse),
      leading: IconButton(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: l10n.r3bCloseShopConfirm(model.id != 0 ? l10n.r3bActionEditing : l10n.r3bActionCreation),
            body: l10n.configCloseDialogBody,
            cancelText: l10n.actionCancel,
            confirmText: l10n.actionContinue,
          );

          if (confirmed == true) {
            AutoRouter.of(context).pop();
            provider.clear();
            ref.invalidate(webShopFormProvider);
          }
        },
        icon: const Icon(Icons.close),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ShopOnlineButton(),
        )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(webShopFormProvider.notifier);
    final model = ref.read(webShopFormProvider);

    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreateWebShopFormGroup(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  label: l10n.dstDiscardChanges,
                  variant: AppColorVariant.Danger,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      title: l10n.r3bCloseShopConfirm(model.id != 0 ? l10n.r3bActionEditing : l10n.r3bActionCreation),
                      body: l10n.configCloseDialogBody,
                      cancelText: l10n.actionCancel,
                      confirmText: l10n.actionContinue,
                    );

                    if (confirmed == true) {
                      AutoRouter.of(context).pop();
                      provider.clear();
                      ref.invalidate(webShopFormProvider);
                    }
                  },
                ),
                if (model.id != 0) DecPublishShopButton(),
                AppButton(
                  label: model.id != 0 ? l10n.r3bSaveChanges : l10n.txpCreate,
                  variant: AppColorVariant.Success,
                  onPressed: () {
                    provider.complete(context);
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
