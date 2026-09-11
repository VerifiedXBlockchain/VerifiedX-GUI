import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/features/reserve/providers/ra_auto_activate_provider.dart';
import '../../../core/app_constants.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../raw/raw_service.dart';
import '../providers/web_ra_pending_funding_provider.dart';
import '../utils/raw_transaction.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';

class WebFundRaAccountButton extends BaseComponent {
  const WebFundRaAccountButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final raKeypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));
    final vfxKeypair = ref.watch(webSessionProvider.select((v) => v.keypair));
    final hasFunded = ref.watch(webRaPendingFundingProvider).contains(raKeypair?.address);

    if (raKeypair == null || vfxKeypair == null) {
      return SizedBox();
    }

    return AppButton(
      label: l10n.adnrFundAccountTitle,
      icon: Icons.money_outlined,
      disabled: hasFunded,
      onPressed: () async {
        final confirmed = await ConfirmDialog.show(
          title: l10n.webFundVaultTitle,
          body: l10n.r3fFundConfirmBody(vfxKeypair.address),
          confirmText: l10n.actionSend,
          cancelText: l10n.actionCancel,
        );

        final shouldActivate = await ConfirmDialog.show(
          title: l10n.webAutoActivateTitle,
          body: l10n.r3fAutoActivateBody,
          confirmText: l10n.actionYes,
          cancelText: l10n.actionNo,
        );

        if (confirmed == true) {
          ref.read(globalLoadingProvider.notifier).start();

          final txData = await RawTransaction.generate(
            keypair: ref.read(webSessionProvider).keypair!,
            amount: 5.0,
            toAddress: ref.read(webSessionProvider).raKeypair!.address,
            txType: TxType.rbxTransfer,
          );

          if (txData == null) {
            ref.read(globalLoadingProvider.notifier).complete();
            Toast.error();
            return;
          }

          final tx = await RawService().sendTransaction(transactionData: txData, execute: true, widgetRef: ref);
          if (tx != null) {
            if (tx['Result'] == "Success") {
              Toast.message(l10n.r3fFundSentToast(
                  ref.read(webSessionProvider).raKeypair!.address));
              ref.read(globalLoadingProvider.notifier).complete();
              ref.read(webRaPendingFundingProvider.notifier).addAddress(raKeypair.address);

              if (shouldActivate == true) {
                final hash = tx["Hash"];
                ref.read(reserveAccountAutoActivateProvider.notifier).add(hash, raKeypair.address, "");
              }

              return;
            }
          }

          Toast.error();
          ref.read(globalLoadingProvider.notifier).complete();
        }
      },
    );
  }
}
