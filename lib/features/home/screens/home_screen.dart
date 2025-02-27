import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class GetVfxButton extends StatelessWidget {
  final String address;
  final bool vfxOnly;

  const GetVfxButton({
    super.key,
    required this.address,
    this.vfxOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () async {
        String? type = vfxOnly ? 'vfx' : null;

        if (!vfxOnly) {
          type = await showModalBottomSheet(
              context: context,
              builder: (context) {
                return ModalContainer(
                  withDecor: false,
                  children: [
                    Container(
                      decoration: BoxDecoration(boxShadow: glowingBox),
                      child: Card(
                        color: Colors.black,
                        child: ListTile(
                          title: Text("Get \$VFX Now"),
                          onTap: () {
                            Navigator.of(context).pop("vfx");
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(boxShadow: glowingBoxBtc),
                      child: Card(
                        color: Colors.black,
                        child: ListTile(
                          title: Text("Get \$BTC Now"),
                          onTap: () {
                            Navigator.of(context).pop("btc");
                          },
                        ),
                      ),
                    )
                  ],
                );
              });
        }

        if (type == "vfx") {
          if (Env.isTestNet) {
            launchUrlString("https://testnet.rbx.network/faucet");
            return;
          }

          final agreed = await PaymentTermsDialog.show(context);

          if (agreed != true) {
            return;
          }

          final url = paymentUrl(amount: 5000, walletAddress: address, currency: "VFX");
          if (url != null) {
            launchUrl(Uri.parse(url));
          }
        } else if (type == "btc") {
          if (Env.btcIsTestNet) {
            launchUrlString("https://mempool.space/testnet4/faucet");
            return;
          }

          final agreed = await PaymentTermsDialog.show(context);

          if (agreed != true) {
            return;
          }

          final url = paymentUrl(amount: 5000, walletAddress: address, currency: "BTC");
          if (url != null) {
            launchUrl(Uri.parse(url));
          }
        }
      },
      label: vfxOnly ? "Get \$VFX" : "Get \$VFX/\$BTC Now",
      variant: AppColorVariant.Success,
    );
  }
}
