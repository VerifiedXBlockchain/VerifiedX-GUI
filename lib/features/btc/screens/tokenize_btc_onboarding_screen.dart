import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/btc_address_type.dart';
import '../models/btc_fee_rate_preset.dart';
import '../models/btc_recommended_fees.dart';
import '../providers/btc_account_list_provider.dart';
import 'tokenize_btc_screen.dart';
import '../utils.dart';
import '../../home/screens/home_screen.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import 'package:collection/collection.dart';

import '../providers/tokenized_btc_onboard_provider.dart';

part './tokenize_btc_onboarding_steps.dart';

class TokenizeBtcOnboardingScreen extends BaseScreen {
  const TokenizeBtcOnboardingScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(l10n.btcVbtcOnboardTitle),
      leadingWidth: 100,
      leading: IconButton(
        icon: Icon(
          Icons.navigate_before,
          size: 32,
        ),
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: l10n.btcExitOnboardingTitle,
            body: l10n.btcExitOnboardingBody,
            confirmText: l10n.actionYes,
            cancelText: l10n.actionNo,
            destructive: true,
          );
          if (confirmed == true) {
            Navigator.of(context).pop(null);
          }
        },
      ),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(vBtcOnboardProvider.notifier);
    final state = ref.watch(vBtcOnboardProvider);

    final l10n = AppLocalizations.of(context);
    if (state.completed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.btcDoneExclamation,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.btcOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(l10n.btcVbtcReady),
            SizedBox(
              height: 24,
            ),
            AppButton(
              label: l10n.btcViewToken,
              variant: AppColorVariant.Btc,
              onPressed: () {
                final token = state.tokenizedBtc;
                if (token == null) {
                  Toast.error(l10n.btcTokenNotFoundToast);
                  return;
                }

                Navigator.of(context).pop(token);
              },
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Step ${state.stepNumber}/6: ",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    state.stepTitle,
                    style: TextStyle(
                      fontSize: 22,
                      color: state.stepIsBtc ? Theme.of(context).colorScheme.btcOrange : Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.stepDetails,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              if (state.processingState == VBtcProcessingState.ready)
                Builder(
                  builder: (context) {
                    switch (state.step) {
                      case VBtcOnboardStep.createVfxWallet:
                        return _CreateOrImportVfxWalletStep();
                      case VBtcOnboardStep.faucetWithdrawl:
                        return _FaucetWithdrawlStep();
                      case VBtcOnboardStep.createOrImportBtcAccount:
                        return _CreateOrImportBtcAccountStep();
                      case VBtcOnboardStep.transferBtc:
                        return _TransferBtcStep();

                      case VBtcOnboardStep.tokenize:
                        return _TokenizeBtcStep();
                      case VBtcOnboardStep.transferBtcToVbtc:
                        return _TransferBtcToVbtcStep();
                    }
                  },
                ),
              Builder(
                builder: (context) {
                  switch (state.processingState) {
                    case VBtcProcessingState.ready:
                      return SizedBox.shrink();
                    default:
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CenteredLoader(),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            state.processingStateMessage,
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
