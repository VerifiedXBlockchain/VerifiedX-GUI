import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/base_screen.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../payment/components/butterfly_logo_lockup.dart';
import '../../payment/screens/butterfly_screen.dart';
import '../../raw/raw_service.dart';
import '../../web/components/web_currency_segmented_button.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_no_wallet.dart';
import '../../web/components/web_qr_scanner.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../../web/utils/raw_transaction.dart';
import '../components/send_form.dart';
import '../utils.dart';

class WebSendScreen extends BaseScreen {
  const WebSendScreen({Key? key})
      : super(
          key: key,
          includeWebDrawer: true,
          backgroundColor: Colors.black87,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);
    final isBtc =
        ref.watch(webCurrencySegementedButtonProvider) == WebCurrencyType.btc;

    return AppBar(
      leading: isMobile ? WebMobileDrawerButton() : null,
      title: isBtc ? Text("Send BTC") : Text("Send VFX"),
      shadowColor: Colors.transparent,
      backgroundColor: Colors.black,
    );
  }

  @override
  FloatingActionButton? floatingActionButton(
      BuildContext context, WidgetRef ref) {
    if (BreakPoints.useMobileLayout(context)) {
      return FloatingActionButton.extended(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return WebQrScanner(
                onQrCodeScanned: (result) {
                  Navigator.of(context).pop();
                  if (result.isNotEmpty) {
                    handleQrScan(context, ref, result);
                  }
                },
                onClose: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
        backgroundColor: AppColors.getBlue(),
        label: Text("Scan & Pay"),
        icon: Icon(Icons.qr_code_scanner),
      );
    }
    return null;
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final keypair = ref.watch(webSessionProvider.select((v) => v.keypair));
    final raKeypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));
    final wallet = ref.watch(webSessionProvider.select((v) => v.currentWallet));
    final btcWebAccount =
        ref.watch(webSessionProvider.select((v) => v.btcKeypair));
    final isBtc =
        ref.watch(webCurrencySegementedButtonProvider) == WebCurrencyType.btc;

    if (keypair == null && raKeypair == null && btcWebAccount == null) {
      return const Center(child: WebNotWallet());
    }

    return Center(
      key: Key(keypair!.address),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WebCurrencySegementedButton(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: SendForm(
                  keypair: keypair,
                  wallet: wallet,
                  raKeypair: raKeypair,
                  btcWebAccount: btcWebAccount,
                ),
              ),
              // Show Payment Link button only for VFX
              if (BUTTERFLY_ENABLED && !isBtc)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    ButterflyLogoLockup(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppButton(
                        label: 'Create Payment Link',
                        variant: AppColorVariant.Secondary,
                        type: AppButtonType.Outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ButterflyScreen(
                                walletAddress:
                                    wallet?.address ?? keypair.address,
                                sendTransaction: (amount, toAddress) async {
                                  try {
                                    final txData =
                                        await RawTransaction.generate(
                                      keypair: keypair,
                                      amount: amount,
                                      toAddress: toAddress,
                                      txType: TxType.rbxTransfer,
                                    );

                                    if (txData == null) {
                                      return null;
                                    }

                                    final result =
                                        await RawService().sendTransaction(
                                      transactionData: txData,
                                      execute: true,
                                      widgetRef: ref,
                                    );

                                    if (result != null &&
                                        result['Result'] == 'Success') {
                                      return result['Hash'] as String?;
                                    }
                                    return null;
                                  } catch (e) {
                                    print('Error sending transaction: $e');
                                    return null;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
