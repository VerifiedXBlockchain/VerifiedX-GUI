import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/base_screen.dart';
import '../../core/components/buttons.dart';
import '../../core/env.dart';
import '../../core/providers/session_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_helper.dart';
import '../../utils/guards.dart';
import '../../utils/toast.dart';
import '../global_loader/global_loading_provider.dart';
import '../health/health_service.dart';
import '../wallet/components/invalid_wallet.dart';
import '../wallet/components/wallet_selector.dart';

class AdjudicatorScreen extends BaseScreen {
  const AdjudicatorScreen({Key? key}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).adjudicatorTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: const [WalletSelector()],
    );
  }

  Future<bool> checkPort([bool withSuccessMessage = true]) async {
    final port = Env.validatorPort;

    final open = await HealthService().pingPort();

    if (open) {
      if (withSuccessMessage) {
        Toast.message(globalL10n.hnavPortOpen(port.toString()));
      }
      return true;
    } else {
      Toast.error(globalL10n.hnavPortNotOpen(port.toString()));
      return false;
    }
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentWallet = ref.watch(sessionProvider.select((v) => v.currentWallet));

    if (currentWallet == null) {
      return InvalidWallet(message: l10n.messageNoAccountSelected);
    }

    // final validator = ref.watch(currentValidatorProvider);

    // if (validator == null) {
    //   return InvalidWallet(
    //     message: "${currentWallet.address} is not eligible to be a validator",
    //   );
    // }
    if (!currentWallet.isValidating) {
      // final port = Env.validatorPort;

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: l10n.hnavStartAdjudicating,
              icon: Icons.star,
              variant: AppColorVariant.Success,
              onPressed: () async {
                if (!widgetGuardWalletIsSynced(ref)) return;
                if (!widgetGuardWalletIsNotResyncing(ref)) return;

                // if (!await checkPort(false)) return;

                ref.read(globalLoadingProvider.notifier).start();

                await Future.delayed(const Duration(milliseconds: 750));

                // final res = await BridgeService().turnOnValidator(currentWallet.address);

                ref.read(globalLoadingProvider.notifier).complete();
              },
            ),
          ],
        ),
      );
    }

    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.hnavIsAdjudicating(currentWallet.labelWithoutTruncation),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white70,
                ),
              )),
        ),
        AppButton(
          label: l10n.hnavStopAdjudicating,
          variant: AppColorVariant.Danger,
          onPressed: () async {
            // ref.read(globalLoadingProvider.notifier).start();

            // final success = await ref.read(currentValidatorProvider.notifier).stopValidating();

            // if (success) {
            //   Toast.message("${currentWallet.label} has stopped validating.");
            //   await ref.read(sessionProvider.notifier).load();
            // } else {
            //   Toast.error();
            // }
            // ref.read(globalLoadingProvider.notifier).complete();
          },
        ),
      ],
    ));
  }
}
