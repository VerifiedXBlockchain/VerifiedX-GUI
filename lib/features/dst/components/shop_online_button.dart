import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/dec_shop_provider.dart';
import '../services/dst_service.dart';
import '../../../l10n/l10n_helper.dart';

class ShopOnlineButton extends BaseComponent {
  const ShopOnlineButton({super.key});

  Future<void> promptForRestart(WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      title: globalL10n.dstCliRestartTitle,
      body: globalL10n.r3dCliRestartBody,
      confirmText: globalL10n.validatorRestartCliConfirm,
      cancelText: globalL10n.actionCancel,
      destructive: true,
    );

    if (confirmed == true) {
      ref.read(sessionProvider.notifier).restartCli();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(decShopProvider);

    return data.when(
      error: (_, __) => SizedBox(),
      loading: () => SizedBox(),
      data: (shop) {
        if (shop == null) {
          return SizedBox();
        }

        if (!shop.isPublished) {
          return SizedBox();
        }

        if (shop.isOffline) {
          return AppButton(
            label: globalL10n.r3dShopOffline,
            variant: AppColorVariant.Danger,
            icon: Icons.offline_bolt_outlined,
            onPressed: () async {
              final confirm = await ConfirmDialog.show(title: globalL10n.r3dSetOnlineTitle, body: globalL10n.r3dSetOnlineBody);
              if (confirm == true) {
                final success = await DstService().toggleOnlineOffline();
                if (success) {
                  ref.invalidate(decShopProvider);
                  promptForRestart(ref);
                }
              }
            },
          );
        } else {
          return AppButton(
            label: globalL10n.r3dShopOnline,
            variant: AppColorVariant.Success,
            icon: Icons.offline_bolt,
            onPressed: () async {
              final confirm = await ConfirmDialog.show(title: globalL10n.r3dSetOfflineTitle, body: globalL10n.r3dSetOfflineBody);
              if (confirm == true) {
                final success = await DstService().toggleOnlineOffline();
                if (success) {
                  ref.invalidate(decShopProvider);
                  promptForRestart(ref);
                }
              }
            },
          );
        }
      },
    );
  }
}
