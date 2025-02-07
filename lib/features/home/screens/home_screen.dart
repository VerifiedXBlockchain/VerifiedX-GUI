import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/features/moonpay/services/moonpay_service.dart';
import 'package:rbx_wallet/features/payment/components/payment_disclaimer.dart';
import 'package:rbx_wallet/features/wallet/utils.dart';
import '../../../core/base_component.dart';
import '../../../core/breakpoints.dart';
import '../../../core/theme/components.dart';
import '../../payment/components/payment_iframe_container.dart';
import '../components/home_buttons.dart';
import '../../smart_contracts/components/sc_creator/common/modal_container.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/app_constants.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';

import '../../payment/payment_utils.dart';
import '../../../core/env.dart';

import 'package:rbx_wallet/features/keygen/components/keygen_cta.dart'
    if (dart.library.io) 'package:rbx_wallet/features/keygen/components/keygen_cta_mock.dart';
import 'package:rbx_wallet/features/wallet/components/wallet_selector.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';

import '../../../core/base_screen.dart';
import '../../../core/providers/session_provider.dart';

import '../components/log_window.dart';
import '../components/transaction_window.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({Key? key})
      : super(
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final address = ref.watch(sessionProvider.select((v) => v.currentWallet?.address));
    return AppBar(
      title: const Text("Dashboard"),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      leadingWidth: address == null || !ALLOW_PAYMENT ? null : 180,
      centerTitle: true,
      // leading: IconButton(
      //   onPressed: () {
      //     ref.read(walletInfoProvider.notifier).infoLoop(false);
      //     ref.read(sessionProvider.notifier).mainLoop(false);
      //     ref.read(sessionProvider.notifier).smartContractLoop(false);
      //   },
      //   icon: const Icon(Icons.refresh),
      // ),
      leading: address == null || !ALLOW_PAYMENT
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: GetVfxButton(address: address),
            ),
      actions: const [WalletSelector()],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (kIsWeb)
                Text(
                  "Keys",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              if (kIsWeb) const Divider(),
              if (kIsWeb) const KeygenCta(),
              if (!kIsWeb) const Divider(),
              if (!kIsWeb)
                HomeButtons(
                  includeRestoreHd: ref.watch(walletListProvider.select((v) => v.isEmpty)),
                ),
              const Divider(),
              const LogWindow(),
              const Divider(),
              const TransactionWindow(),
            ],
          ),
        ),
      ),
    );
  }
}

class GetVfxButton extends BaseComponent {
  final String address;
  final bool vfxOnly;

  const GetVfxButton({
    super.key,
    required this.address,
    this.vfxOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      onPressed: () async {
        AccountUtils.getCoin(context, ref, vfxOnly ? VfxOrBtcOption.vfx : null);
      },
      label: vfxOnly ? "Get \$VFX" : "Get \$VFX/\$BTC Now",
      variant: AppColorVariant.Success,
    );
  }
}
