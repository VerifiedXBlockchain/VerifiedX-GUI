import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/dec_shop_provider.dart';
import '../providers/dst_tx_pending_provider.dart';
import '../services/dst_service.dart';
import '../../../utils/toast.dart';

import '../../../core/providers/session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class DecPublishShopButton extends BaseComponent {
  const DecPublishShopButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(decShopProvider);
    final l10n = AppLocalizations.of(context);

    return data.when(
      loading: () => SizedBox(),
      error: (_, __) => SizedBox(),
      data: (shop) {
        if (shop == null) {
          return SizedBox.shrink();
        }

        if (ref.watch(dstTxPendingProvider)) {
          return AppButton(
            label: l10n.statusPending,
            processing: true,
          );
        }

        if (shop.isPublished) {
          if (shop.needsPublishToNetwork || shop.ipIsDifferent) {
            return AppButton(
              variant: shop.ipIsDifferent
                  ? AppColorVariant.Danger
                  : AppColorVariant.Warning,
              label:
                  shop.ipIsDifferent ? l10n.r3dPublishIpChange : l10n.r3dPublishChanges,
              icon: shop.ipIsDifferent ? Icons.error : Icons.publish,
              onPressed: () async {
                if (shop.updateWillCost) {
                  if (ref.read(sessionProvider).currentWallet!.balance < 10) {
                    Toast.error(l10n.r3dInsufficientBalanceUpdate);
                    return;
                  }
                  final confirm = await ConfirmDialog.show(
                    title: l10n.shopPublishShopTitle,
                    body: l10n.r3dPublishUpdateCostBody(SHOP_UPDATE_COST.toString()),
                    confirmText: l10n.r3dPublishChanges,
                    cancelText: l10n.actionCancel,
                  );

                  if (confirm != true) {
                    return;
                  }
                }
                ref.read(dstTxPendingProvider.notifier).set(true);

                if (shop.ipIsDifferent) {
                  await DstService().saveDecShop(shop);
                  await Future.delayed(Duration(milliseconds: 500));
                }

                final success = await DstService().updateShop();
                if (success) {
                  ref.invalidate(decShopProvider);
                  ref.read(dstTxPendingProvider.notifier).set(true);

                  Toast.message(l10n.r3dPublishTransactionSent);
                  ref.invalidate(decShopProvider);
                } else {
                  ref.read(dstTxPendingProvider.notifier).set(false);

                  Toast.error();
                }
              },
            );
          }
          return AppButton(
            label: l10n.shopPublished,
            icon: Icons.check,
          );
        }

        return AppButton(
          label: l10n.shopPublishShop,
          variant: AppColorVariant.Light,
          onPressed: () async {
            if (ref.read(sessionProvider).currentWallet!.balance < 10) {
              Toast.error(l10n.r3dInsufficientBalancePublish);
              return;
            }

            final confirm = await ConfirmDialog.show(
              title: l10n.shopPublishShopTitle,
              body: l10n.r3dPublishShopCostBody(SHOP_PUBLISH_COST.toString()),
              confirmText: l10n.r3dPublish,
              cancelText: l10n.actionCancel,
            );

            if (confirm == true) {
              final success = await DstService().publishShop();

              if (success) {
                Toast.message(l10n.r3dPublishTransactionSent);

                ref.invalidate(decShopProvider);
                ref.read(dstTxPendingProvider.notifier).set(true);
                final confirmed = await ConfirmDialog.show(
                  title: l10n.dstCliRestartTitle,
                  body: l10n.r3dCliRestartBody,
                  confirmText: l10n.validatorRestartCliConfirm,
                  cancelText: l10n.actionCancel,
                  destructive: true,
                );

                if (confirmed == true) {
                  ref.read(sessionProvider.notifier).restartCli();
                }
              } else {
                Toast.error();
              }
            }
          },
        );
      },
    );
  }
}
