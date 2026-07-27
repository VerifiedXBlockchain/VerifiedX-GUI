import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dst/providers/collection_form_provider.dart';
import '../providers/web_collection_form_provider.dart';
import '../components/web_create_collection_form_group.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class MyCreateCollectionContainerScreen extends BaseScreen {
  const MyCreateCollectionContainerScreen({Key? key}) : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(webCollectionFormProvider.notifier);
    final model = ref.read(webCollectionFormProvider);
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(model.id != 0 ? l10n.mktEditCollection : l10n.r3bCreateNewCollection),
      leading: IconButton(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: l10n.r3bCloseStoreConfirm(model.id != 0 ? l10n.r3bActionEditing : l10n.r3bActionCreation),
            body: l10n.configCloseDialogBody,
            cancelText: l10n.actionCancel,
            confirmText: l10n.actionContinue,
          );

          if (confirmed == true) {
            AutoRouter.of(context).pop();
            provider.clear();
            ref.invalidate(storeFormProvider);
          }
        },
        icon: const Icon(Icons.close),
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(webCollectionFormProvider.notifier);
    final model = ref.read(webCollectionFormProvider);

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
              const WebCreateCollectionFormGroup(),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  label: l10n.dstDiscardChanges,
                  variant: AppColorVariant.Danger,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      title: l10n.r3bCloseCollectionConfirm(model.id != 0 ? l10n.r3bActionEditing : l10n.r3bActionCreation),
                      body: l10n.configCloseDialogBody,
                      cancelText: l10n.actionCancel,
                      confirmText: l10n.actionContinue,
                    );

                    if (confirmed == true) {
                      AutoRouter.of(context).pop();
                      provider.clear();
                      ref.invalidate(storeFormProvider);
                    }
                  },
                ),
                AppButton(
                  label: model.id != 0 ? l10n.actionSave : l10n.txpCreate,
                  variant: AppColorVariant.Success,
                  onPressed: () async {
                    await provider.complete(context);
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
