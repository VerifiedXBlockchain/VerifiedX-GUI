import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/create_listing_form_group.dart';
import '../providers/collection_form_provider.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/listing_form_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class CreateListingContainerScreen extends BaseScreen {
  final int collectionId;
  const CreateListingContainerScreen(@PathParam("collectionId") this.collectionId, {Key? key})
      : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final provider = ref.read(listingFormProvider.notifier);
    final model = ref.watch(listingFormProvider);
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(model.id == 0 ? l10n.shopCreateListing : l10n.mktEditListing),
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: model.id != 0 ? l10n.r3dCloseListingEditingConfirm : l10n.r3dCloseListingCreationConfirm,
            body: l10n.configCloseDialogBody,
            cancelText: l10n.actionCancel,
            confirmText: l10n.actionContinue,
          );

          if (confirmed == true) {
            AutoRouter.of(context).pop();
            provider.clear();
            ref.invalidate(listingFormProvider);
          }
        },
        icon: const Icon(Icons.close),
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(listingFormProvider.notifier);
    final model = ref.watch(listingFormProvider);
    final l10n = AppLocalizations.of(context);
    bool isCreating = model.id == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const CreateListingFormGroup(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    label: isCreating ? l10n.dstDiscardChanges : l10n.mktDeleteListing,
                    variant: AppColorVariant.Danger,
                    icon: isCreating ? null : Icons.delete,
                    onPressed: () async {
                      if (isCreating) {
                        final confirmed = await ConfirmDialog.show(
                          title: l10n.r3dConfirmDiscardListing,
                          body: l10n.configCloseDialogBody,
                          cancelText: l10n.actionCancel,
                          confirmText: l10n.actionContinue,
                        );

                        if (confirmed == true) {
                          AutoRouter.of(context).pop();
                          provider.clear();
                          ref.invalidate(storeFormProvider);
                        }
                      } else {
                        provider.delete(context, collectionId, model);
                      }
                    },
                  ),
                  AppButton(
                    label: isCreating ? l10n.r3dCreate : l10n.svcActionUpdate,
                    variant: AppColorVariant.Success,
                    onPressed: () async {
                      await provider.complete(context, collectionId);
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }
}
