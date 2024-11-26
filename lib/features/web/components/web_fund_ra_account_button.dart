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
import '../../../utils/toast.dart';

class WebFundRaAccountButton extends BaseComponent {
  const WebFundRaAccountButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raKeypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));
    final vfxKeypair = ref.watch(webSessionProvider.select((v) => v.keypair));
    final hasFunded = ref.watch(webRaPendingFundingProvider).contains(raKeypair?.address);

    if (raKeypair == null || vfxKeypair == null) {
      return SizedBox();
    }

    return AppButton(
      label: "Fund Account",
      icon: Icons.money_outlined,
      disabled: hasFunded,
      onPressed: () async {
        final confirmed = await ConfirmDialog.show(
          title: "Fund Your Vault Account",
          body: "Would you like to send 5 VFX from ${vfxKeypair.address}?",
          confirmText: "Send",
          cancelText: "Cancel",
        );

        final shouldActivate = await ConfirmDialog.show(
          title: "Automatically Activate?",
          body: "Would you like to activate the account automatically once the funding is complete?",
          confirmText: "Yes",
          cancelText: "No",
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
              Toast.message("5 VFX sent to ${ref.read(webSessionProvider).raKeypair!.address}");
              ref.read(globalLoadingProvider.notifier).complete();
              ref.read(webRaPendingFundingProvider.notifier).addAddress(raKeypair.address);
              print("SUCCESS TX:");
              print(tx);

              if (shouldActivate == true) {
                final hash = tx["Hash"];
                print("HASH: ---$hash---");
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
