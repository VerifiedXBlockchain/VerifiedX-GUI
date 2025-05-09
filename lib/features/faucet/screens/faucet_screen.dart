import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/core/theme/components.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../components/faucet_form.dart';

class FaucetScreen extends BaseScreen {
  const FaucetScreen({super.key});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text("VFX Faucet"),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      // actions: const [WalletSelector()],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    // final isBtc = ref.watch(webSessionProvider.select((v) => v.usingBtc));

    final wallet = kIsWeb ? ref.watch(webSessionProvider.select((v) => v.keypair)) : ref.watch(sessionProvider.select((v) => v.currentWallet));

    final showFaucet = wallet != null && (kIsWeb || !ref.watch(sessionProvider.select((v) => v.btcSelected)));

    if (!showFaucet) {
      return Center(
        child: Text("Please choose a VFX account to continue"),
      );
    }
    return FutureBuilder<double>(
        future: _getInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "The community has allocated some VFX to lower the barrier to entry for trying out this feature. In order to prevent abuse, a phone number is required for an SMS authorization. Only a hash of your phone number will be stored.",
                        textAlign: TextAlign.center,
                      ),
                      Divider(),
                      Text(
                        "Max Amount: ${snapshot.data} VFX",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      AppCard(child: FaucetForm()),
                    ],
                  ),
                ),
              ),
            );
          }
          return CenteredLoader();
        });
  }

  Future<double> _getInfo() async {
    return await ExplorerService().faucetInfo();
  }
}
