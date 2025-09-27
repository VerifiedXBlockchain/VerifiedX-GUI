import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../web/components/web_currency_segmented_button.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_qr_scanner.dart';
import '../../web/components/web_wallet_type_switcher.dart';

import '../../../core/base_screen.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../web/components/web_no_wallet.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../components/send_form.dart';

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
    return null;
    if (BreakPoints.useMobileLayout(context)) {
      return FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return WebQrScanner(
                onQrCodeScanned: (result) {
                  Navigator.of(context).pop();
                  print(result);
                  if (result.isNotEmpty) {
                    launchUrlString("cryptodotcom://pay?address=$result");
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
