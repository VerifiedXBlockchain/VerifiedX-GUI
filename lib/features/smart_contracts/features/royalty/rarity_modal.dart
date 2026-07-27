import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../asset/asset.dart';
import '../../components/sc_creator/common/file_selector.dart';
import '../../components/sc_creator/common/form_group_header.dart';
import '../../components/sc_creator/common/modal_container.dart';
import '../../models/rarity.dart';
import '../../providers/create_smart_contract_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';

class RarityModal extends BaseComponent {
  final Rarity? initialRarity;
  const RarityModal({
    Key? key,
    this.initialRarity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _model = ref.watch(createSmartContractProvider);
    final l10n = AppLocalizations.of(context);

    return ModalContainer(
      children: [
        FormGroupHeader(initialRarity == null ? l10n.r3aCreateRarity : l10n.r3aEditRarity),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text(
                        l10n.r3aLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text(
                        l10n.r3aRareness,
                        style: const TextStyle(color: Colors.white),
                      ),
                      suffix: const Text("%"),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text(
                        l10n.btcDetailDescriptionLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    minLines: 3,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.r3aStatsOverride,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.white24, width: 3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _model.stats.length,
                            itemBuilder: (context, index) {
                              final stat = _model.stats[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: TextFormField(
                                  initialValue: stat.value,
                                ),
                                subtitle: Text(stat.label),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FileSelector(
                transparentBackground: true,
                title: l10n.r3aPrimaryAssetOverride,
                onChange: (Asset? asset) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FileSelector(
                transparentBackground: true,
                title: l10n.r3aThumbnailOverride,
                onChange: (Asset? asset) {},
              ),
            )
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              label: l10n.actionCancel,
              type: AppButtonType.Text,
              variant: AppColorVariant.Info,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            AppButton(
              label: l10n.actionSave,
              icon: Icons.check,
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }
}
