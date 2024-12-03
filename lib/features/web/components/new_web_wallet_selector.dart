import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/breakpoints.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../utils/toast.dart';
import '../providers/web_currency_segmented_button_provider.dart';
import '../providers/web_selected_account_provider.dart';

class NewWebWalletSelector extends BaseComponent {
  const NewWebWalletSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(webSessionProvider.select((value) => value.keypair?.address));
    return Builder(
        key: Key(address ?? ""),
        builder: (context) {
          final fontSize = BreakPoints.useMobileLayout(context) ? 12.0 : 14.0;

          final currencyType = ref.watch(webCurrencySegementedButtonProvider);
          final selectedAccount = ref.watch(webSelectedAccountProvider);

          if (currencyType != WebCurrencyType.any) {
            if (selectedAccount == null) {
              return Text("Select Account");
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: selectedAccount.address),
                    );
                    Toast.message("${selectedAccount.address} copied to clipboard");
                  },
                  child: Icon(
                    Icons.copy,
                    size: 12,
                    color: selectedAccount.color,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  selectedAccount.address,
                  style: TextStyle(color: selectedAccount.color, fontSize: fontSize),
                )
              ],
            );
          }

          if (selectedAccount == null) {
            return Text("Select Account");
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: selectedAccount.address),
                  );
                  Toast.message("${selectedAccount.address} copied to clipboard");
                },
                child: Icon(
                  Icons.copy,
                  size: 12,
                  color: selectedAccount.color,
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<WebCurrencyType>(
                constraints: const BoxConstraints(
                  minWidth: 2.0 * 56.0,
                  maxWidth: 8.0 * 56.0,
                ),
                color: Color(0xFF080808),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedAccount.address,
                      style: TextStyle(color: selectedAccount.color, fontSize: fontSize),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: selectedAccount.color,
                    ),
                  ],
                ),
                onSelected: (value) {
                  ref.read(webCurrencySegementedButtonProvider.notifier).set(value);
                },
                itemBuilder: (context) {
                  final list = <PopupMenuEntry<WebCurrencyType>>[];

                  final keypair = ref.watch(webSessionProvider.select((v) => v.keypair));
                  final raKeypair = ref.watch(webSessionProvider.select((v) => v.raKeypair));
                  final btcKeypair = ref.watch(webSessionProvider.select((v) => v.btcKeypair));

                  if (keypair != null) {
                    list.add(PopupMenuItem(
                      value: WebCurrencyType.vfx,
                      child: Text(
                        keypair.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getBlue(),
                        ),
                      ),
                    ));
                  }

                  if (raKeypair != null) {
                    list.add(PopupMenuItem(
                      value: WebCurrencyType.vault,
                      child: Text(
                        raKeypair.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getReserve(),
                        ),
                      ),
                    ));
                  }

                  if (btcKeypair != null) {
                    list.add(PopupMenuItem(
                      value: WebCurrencyType.btc,
                      child: Text(
                        btcKeypair.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getBtc(),
                        ),
                      ),
                    ));
                  }

                  return list;
                },
              )
            ],
          );
        });
  }
}
