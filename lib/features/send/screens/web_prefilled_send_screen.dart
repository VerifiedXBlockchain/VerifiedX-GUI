import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';

import '../../../core/base_screen.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../web/components/web_no_wallet.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../../web/providers/web_selected_account_provider.dart';
import '../components/send_form.dart';
import '../providers/send_form_provider.dart';

class WebPrefilledSendScreen extends BaseScreen {
  final String currency;
  final String toAddress;
  final double amount;

  const WebPrefilledSendScreen({
    Key? key,
    @PathParam('currency') required this.currency,
    @PathParam('toAddress') required this.toAddress,
    @PathParam('amount') required this.amount,
  }) : super(
          key: key,
          includeWebDrawer: true,
          backgroundColor: Colors.black87,
          horizontalPadding: 0,
          verticalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isBtc = ref.watch(webSessionProvider.select((v) => v.usingBtc));
    return AppBar(
      title: isBtc ? Text("Send BTC") : Text("Send VFX"),
      shadowColor: Colors.transparent,
      backgroundColor: Colors.black,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    ref.read(sendFormProvider.notifier).addressController.text = toAddress;
    ref.read(sendFormProvider.notifier).amountController.text =
        amount.toString();

    final keypair = ref.watch(webSessionProvider.select((v) => v.keypair));
    if (keypair == null) {
      return const Center(child: WebNotWallet());
    }

    final raKeypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));
    final wallet = ref.watch(webSessionProvider.select((v) => v.currentWallet));
    final btcWebAccount =
        ref.watch(webSessionProvider.select((v) => v.btcKeypair));

    return Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SendForm(
                  keypair: keypair,
                  wallet: wallet,
                  raKeypair: raKeypair,
                  btcWebAccount: btcWebAccount,
                ),
                _SetCurrencyType(currency: currency)
              ],
            )));
  }
}

class _SetCurrencyType extends ConsumerStatefulWidget {
  final String currency;
  const _SetCurrencyType({super.key, required this.currency});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __SetCurrencyTypeState();
}

class __SetCurrencyTypeState extends ConsumerState<_SetCurrencyType> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (widget.currency == 'btc') {
        ref
            .read(webCurrencySegementedButtonProvider.notifier)
            .set(WebCurrencyType.btc);
      } else {
        ref
            .read(webCurrencySegementedButtonProvider.notifier)
            .set(WebCurrencyType.vfx);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
