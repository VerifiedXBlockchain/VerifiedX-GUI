import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../components/sc_wizard_card.dart';
import '../providers/sc_wizard_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardEditItemScreen extends BaseScreen {
  final String title;
  final int index;
  const ScWizardEditItemScreen({
    Key? key,
    required this.title,
    required this.index,
  }) : super(
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      leading: const SizedBox.shrink(),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(child: Center(child: ScWizedCard(index))),
        Container(
          color: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                  label: l10n.actionDelete,
                  variant: AppColorVariant.Danger,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      title: l10n.r3aDeleteInstanceTitle,
                      body: l10n.r3aDeleteInstanceConfirm,
                      confirmText: l10n.actionDelete,
                      destructive: true,
                    );
                    if (confirmed == true) {
                      ref.read(scWizardProvider.notifier).removeAt(index, delay: 300);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                AppButton(
                  label: l10n.r3aSaveClose,
                  onPressed: () async {
                    final item = ref.read(scWizardProvider.notifier).itemAtIndex(index);
                    if (item == null) {
                      Toast.error();
                      return;
                    }

                    final entry = item.entry;
                    final List<String> errors = [];

                    if (entry.name.isEmpty) {
                      errors.add("- ${l10n.r3aNameIsRequired}");
                    }

                    if (entry.creatorName.isEmpty) {
                      errors.add("- ${l10n.r3aMinterNameIsRequired}");
                    }

                    if (entry.description.isEmpty) {
                      errors.add("- ${l10n.r3aDescriptionIsRequired}");
                    }

                    if (entry.primaryAsset == null) {
                      errors.add("- ${l10n.r3aPrimaryAssetIsRequired}");
                    }

                    if (errors.isNotEmpty) {
                      InfoDialog.show(
                        title: l10n.r3aInvalidSmartContract,
                        body: errors.join("\n"),
                        closeText: l10n.walletOkay,
                      );

                      return;
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
