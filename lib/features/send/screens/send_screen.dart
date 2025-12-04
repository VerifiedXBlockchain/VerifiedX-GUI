import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/currency_segmented_button.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/guards.dart';
import '../../bridge/services/bridge_service.dart';
import '../../payment/screens/butterfly_screen.dart';
import '../../wallet/components/invalid_wallet.dart';
import '../components/send_form.dart';

class SendScreen extends BaseScreen {
  const SendScreen({Key? key})
      : super(
          key: key,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isBtc = ref.watch(sessionProvider.select((v) => v.btcSelected));

    return AppBar(
      title: Text("Send ${isBtc ? 'BTC' : 'VFX'}"),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      // leading: BackToHomeButton(),
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CurrencySegementedButton(),
        ),
        Builder(builder: (context) {
          final isBtc = ref.watch(sessionProvider.select((v) => v.btcSelected));

          final currentWallet = !isBtc ? ref.watch(sessionProvider.select((v) => v.currentWallet)) : null;
          final currentBtcAccount = isBtc ? ref.watch(sessionProvider.select((v) => v.currentBtcAccount)) : null;
          print(currentWallet?.balance);
          if (currentWallet == null && currentBtcAccount == null) {
            return const InvalidWallet(message: "No account selected");
          }
          return Column(
            children: [
              SendForm(
                wallet: currentWallet,
                btcAccount: currentBtcAccount,
              ),
                  // Show Payment Link button only for VFX
        if (!isBtc && currentWallet != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Create Payment Link',
              variant: AppColorVariant.Secondary,
              type: AppButtonType.Outlined,
              onPressed: () {
                if (!widgetGuardWalletIsSynced(ref)&& !kDebugMode) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ButterflyScreen(
                      walletAddress: currentWallet.address,
                      balance: currentWallet.balance,
                      sendTransaction: (amount, toAddress) async {
                        final result = await BridgeService().sendFunds(
                          amount: amount,
                          to: toAddress,
                          from: currentWallet.address,
                        );
                        if (result == null ||
                            result.toLowerCase().contains('error') ||
                            result.toLowerCase().contains('fail')) {
                          return null;
                        }
                        return result;
                      },
                    ),
                  ),
                );
              },
            ),
          ),
            ],
          );
        }),
        
      ],
    );
  }
}
