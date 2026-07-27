import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/collection_form_provider.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../components/create_collection_form_group .dart';
import '../../../l10n/generated/app_localizations.dart';

class CreateCollectionContainerScreen extends BaseScreen {
  const CreateCollectionContainerScreen({Key? key}) : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final provider = ref.read(storeFormProvider.notifier);
    final model = ref.read(storeFormProvider);
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(model.id != 0 ? l10n.mktEditCollection : l10n.r3dCreateNewCollection),
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: model.id != 0 ? l10n.r3dCloseStoreEditingConfirm : l10n.r3dCloseStoreCreationConfirm,
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
    final provider = ref.read(storeFormProvider.notifier);
    final model = ref.read(storeFormProvider);
    final l10n = AppLocalizations.of(context);

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
              const CreateCollectionFormGroup(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  label: l10n.dstDiscardChanges,
                  variant: AppColorVariant.Danger,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      title: model.id != 0 ? l10n.r3dCloseCollectionEditingConfirm : l10n.r3dCloseCollectionCreationConfirm,
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
                  label: model.id != 0 ? l10n.actionSave : l10n.r3dCreate,
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
