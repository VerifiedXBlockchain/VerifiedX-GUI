import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_component.dart';

import '../../../core/theme/colors.dart';
import '../providers/web_currency_segmented_button_provider.dart';

class WebCurrencySegementedButton extends BaseComponent {
  final bool withAny;
  const WebCurrencySegementedButton({super.key, this.withAny = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(webCurrencySegementedButtonProvider.notifier);
    final state = ref.watch(webCurrencySegementedButtonProvider);
    return SegmentedButton<WebCurrencyType>(
      multiSelectionEnabled: false,
      selectedIcon: null,
      showSelectedIcon: false,
      selected: {!withAny && state == WebCurrencyType.any ? WebCurrencyType.vfx : state},
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(
            width: 1,
            color: Colors.white54,
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              switch (state) {
                case WebCurrencyType.any:
                  return Colors.white;
                case WebCurrencyType.vault:
                  return AppColors.getReserve();
                case WebCurrencyType.vfx:
                  return AppColors.getBlue();
                case WebCurrencyType.btc:
                  return AppColors.getBtc();
              }
            }
            return Colors.black;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Colors.white;
          },
        ),
      ),
      onSelectionChanged: (value) {
        provider.set(value.first);
      },
      segments: [
        if (withAny)
          ButtonSegment(
            value: WebCurrencyType.any,
            label: Text("All"),
          ),
        ButtonSegment(
          value: WebCurrencyType.vfx,
          label: Text("VFX"),
        ),
        ButtonSegment(
          value: WebCurrencyType.vault,
          label: Text("Vault"),
        ),
        ButtonSegment(
          value: WebCurrencyType.btc,
          label: Text("BTC"),
        ),
      ],
    );
  }
}
