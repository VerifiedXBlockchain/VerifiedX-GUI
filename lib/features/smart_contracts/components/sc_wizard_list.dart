import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/breakpoints.dart';
import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import 'sc_wizard_asset_preview.dart';
import '../screens/sc_wizard_edit_item_screen.dart';

import '../../../core/base_component.dart';
import '../providers/sc_wizard_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ScWizardList extends BaseComponent {
  const ScWizardList({Key? key}) : super(key: key);

  void createNew({
    required BuildContext context,
    required ScWizardProvider provider,
    required int index,
    required int x,
    required int y,
    required ScWizardItem item,
  }) {
    provider.insert(
      entry: item.entry.copyWith(),
      index: index,
      y: y,
      x: x,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScWizardEditItemScreen(
          title: AppLocalizations.of(context).r3aCreateInstance,
          index: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(scWizardProvider.notifier);
    final items = ref.watch(scWizardProvider);
    final isMobile = BreakPoints.useMobileLayout(context);
    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Center(
        child: AppButton(
          label: l10n.r3aCreateFirstInstance,
          onPressed: () {
            createNew(context: context, provider: provider, index: 0, x: 0, y: 0, item: ScWizardItem.empty());
          },
          icon: Icons.add,
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final entry = item.entry;

        String description = entry.description;
        if (entry.royalty != null || entry.additionalAssets.isNotEmpty) {
          if (entry.royalty != null) {
            description = "${entry.royalty!.amountWithSuffix} ${l10n.r3aRoyaltyTo} ${entry.royalty!.address}";
            if (entry.additionalAssets.isNotEmpty) {
              description = "$description | ${entry.additionalAssets.length} ${entry.additionalAssets.length == 1 ? l10n.r3aAdditionalAsset : l10n.r3aAdditionalAssets}";
            }
          } else if (entry.additionalAssets.isNotEmpty) {
            description = "${entry.additionalAssets.length} ${entry.additionalAssets.length == 1 ? l10n.r3aAdditionalAsset : l10n.r3aAdditionalAssets}";
          }
        }

        if (item.entry.evolve.phases.isNotEmpty) {
          description = "$description | ${item.entry.evolve.phases.length} ${item.entry.evolve.phases.length == 1 ? l10n.r3aEvolvePhase : l10n.r3aEvolvePhases}";
        }

        if (item.entry.properties.isNotEmpty) {
          description = "$description | ${item.entry.properties.length} ${item.entry.properties.length == 1 ? l10n.r3aProperty : l10n.scwProperties}";
        }

        return Container(
          decoration: BoxDecoration(
            boxShadow: glowingBox,
          ),
          child: Card(
            color: Colors.black,
            child: ListTile(
              title: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: entry.name,
                    ),
                    TextSpan(
                      text: " (x${entry.quantity})",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.success),
                    ),
                  ],
                ),
              ),
              leading: SizedBox(
                width: 32,
                height: 32,
                child: ScWizardAssetPreview(entry: entry, small: true),
              ),
              subtitle: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isMobile
                  ? PopupMenuButton(itemBuilder: ((context) {
                      return [
                        PopupMenuItem(
                            onTap: () {
                              createNew(context: context, provider: provider, index: items.length, x: 0, y: 0, item: item.copyWith());
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              l10n.r3aDuplicate,
                            )),
                        PopupMenuItem(
                            onTap: () {
                              Navigator.of(rootNavigatorKey.currentContext!).push(
                                MaterialPageRoute(
                                  builder: (context) => ScWizardEditItemScreen(
                                    title: l10n.r3aEditInstance,
                                    index: index,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              l10n.scwEdit,
                            )),
                        PopupMenuItem(
                            onTap: () async {
                              final confirmed = await ConfirmDialog.show(
                                title: l10n.r3aDeleteInstanceTitle,
                                body: l10n.r3aDeleteInstanceConfirm,
                                confirmText: l10n.actionDelete,
                                destructive: true,
                              );
                              if (confirmed == true) {
                                ref.read(scWizardProvider.notifier).removeAt(index, delay: 300);
                              }
                            },
                            child: Text(
                              l10n.actionDelete,
                            )),
                      ];
                    }))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          label: l10n.r3aDuplicate,
                          icon: Icons.copy,
                          onPressed: () {
                            createNew(context: context, provider: provider, index: items.length, x: 0, y: 0, item: item.copyWith());
                          },
                          variant: AppColorVariant.Light,
                        ),
                        const SizedBox(width: 6),
                        AppButton(
                          label: l10n.scwEdit,
                          icon: Icons.edit,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ScWizardEditItemScreen(
                                  title: l10n.r3aEditInstance,
                                  index: index,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        AppButton(
                          label: l10n.actionDelete,
                          icon: Icons.delete,
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
                            }
                          },
                        ),
                      ],
                    ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScWizardEditItemScreen(
                      title: l10n.r3aEditInstance,
                      index: index,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
