import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../features/smart_contracts/components/sc_creator/common/modal_container.dart';
import '../base_component.dart';
import '../env.dart';
import 'buttons.dart';

class OpenExplorerModal extends BaseComponent {
  const OpenExplorerModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModalContainer(
      withClose: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Open Explorer",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppButton(
              label: "VFX Explorer",
              variant: AppColorVariant.Secondary,
              onPressed: () {
                launchUrl(Uri.parse(Env.baseExplorerUrl));
              },
            ),
            AppButton(
              label: "BTC Explorer",
              variant: AppColorVariant.Btc,
              onPressed: () {
                if (Env.isTestNet) {
                  launchUrlString("https://mempool.space/testnet4/");
                } else {
                  launchUrlString("https://mempool.space/");
                }
              },
            )
          ],
        )
      ],
    );
  }
}
