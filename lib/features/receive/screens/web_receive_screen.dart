import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/breakpoints.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/components.dart';
import '../../web/components/new_web_wallet_selector.dart';
import '../../web/components/web_currency_segmented_button.dart';
import '../../web/components/web_mobile_drawer_button.dart';
import '../../web/components/web_wallet_type_switcher.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/html_helpers.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../nft/components/nft_qr_code.dart';
import '../../web/components/web_no_wallet.dart';
import '../../web/providers/web_selected_account_provider.dart';

class WebReceiveScreen extends BaseScreen {
  const WebReceiveScreen({Key? key})
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

    final isBtc = ref.watch(webSessionProvider.select((v) => v.usingBtc));
    return AppBar(
      title: isBtc ? Text("Receive BTC") : Text("Receive VFX"),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
      leading: isMobile ? WebMobileDrawerButton() : null,
    );
  }

  Future<void> copyToClipboard(String value, [String? message]) async {
    await Clipboard.setData(ClipboardData(text: value));
    Toast.message(message ?? "'$value' Copied to clipboard");
  }

  String generateLink(String address, double amount) {
    return HtmlHelpers().getUrl().replaceAll("/receive", "/send/$address/$amount");
  }

  Future<void> showRequestPrompt({
    required BuildContext context,
    required String address,
    required Function(String str) onValidSubmission,
  }) async {
    PromptModal.show(
      contextOverride: context,
      tightPadding: true,
      title: "Request Funds",
      body: "Generate a URL to send to another user.",
      labelText: "Amount to request",
      validator: (value) => formValidatorNumber(value, "Amount"),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      confirmText: "Generate Link",
      onValidSubmission: onValidSubmission,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    // final address = ref.watch(webSessionProvider.select((v) => v.currentWallet?.address));
    // final usingRa = ref.watch(webSessionProvider.select((v) => v.usingRa));
    // final usingBtc = ref.watch(webSessionProvider.select((v) => v.usingBtc));
    // final adnr = ref.watch(webSessionProvider.select((v) => v.adnr));

    final selectedAccount = ref.watch(webSelectedAccountProvider);

    if (selectedAccount == null) {
      return const WebNotWallet();
    }

    // if (usingBtc) {
    //   return Center(
    //     child: ConstrainedBox(
    //       constraints: BoxConstraints(maxWidth: 600),
    //       child: AppCard(
    //         padding: 16,
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             AppCard(
    //               padding: 0,
    //               color: AppColors.getGray(ColorShade.s300),
    //               child: ListTile(
    //                 title: SelectableText(
    //                   address,
    //                   style: TextStyle(color: AppColors.getBtc()),
    //                 ),
    //                 subtitle: Text("Your Address"),
    //                 leading: Icon(Icons.wallet),
    //                 trailing: IconButton(
    //                   icon: const Icon(Icons.copy),
    //                   onPressed: () {
    //                     copyToClipboard(address);
    //                   },
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebCurrencySegementedButton(withAny: false),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AppCard(
                  padding: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppCard(
                        padding: 0,
                        color: AppColors.getGray(ColorShade.s300),
                        child: ListTile(
                          title: SelectableText(
                            selectedAccount.address,
                            style: TextStyle(color: selectedAccount.color),
                          ),
                          subtitle: Text("Your Address"),
                          leading: Icon(Icons.wallet),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              copyToClipboard(selectedAccount.address);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedAccount.domain != null && selectedAccount.domain!.isNotEmpty) ...[
                        AppCard(
                          padding: 0,
                          color: AppColors.getGray(ColorShade.s300),
                          child: ListTile(
                            title: SelectableText(
                              selectedAccount.domain!,
                              style: TextStyle(color: selectedAccount.color),
                            ),
                            subtitle: Text("Your Domain"),
                            leading: Icon(Icons.link),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                copyToClipboard(selectedAccount.domain!);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Divider(),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppVerticalIconButton(
                            label: "Copy\nLink",
                            icon: Icons.link,
                            prettyIconType: PrettyIconType.custom,
                            onPressed: () async {
                              showRequestPrompt(
                                  context: context,
                                  address: selectedAccount.address,
                                  onValidSubmission: (amount) async {
                                    if (double.tryParse(amount) != null) {
                                      final value = selectedAccount.domain != null && selectedAccount.domain!.isNotEmpty
                                          ? selectedAccount.domain!
                                          : selectedAccount.address;
                                      final url = generateLink(value, double.parse(amount));

                                      await copyToClipboard(url, "Request funds link copied to clipboard");
                                    } else {
                                      Toast.error("Invalid amount");
                                    }
                                  });
                            },
                          ),
                          const SizedBox(width: 6),
                          AppVerticalIconButton(
                            label: "QR\nCode",
                            icon: Icons.qr_code_rounded,
                            prettyIconType: PrettyIconType.custom,
                            onPressed: () async {
                              showRequestPrompt(
                                  context: context,
                                  address: selectedAccount.address,
                                  onValidSubmission: (amount) async {
                                    if (double.tryParse(amount) != null) {
                                      final value = selectedAccount.domain != null && selectedAccount.domain!.isNotEmpty
                                          ? selectedAccount.domain!
                                          : selectedAccount.address;
                                      final url = generateLink(value, double.parse(amount));

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Center(
                                              child: NftQrCode(
                                                data: url,
                                                withClose: true,
                                              ),
                                            );
                                          });
                                    } else {
                                      Toast.error("Invalid amount");
                                    }
                                  });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
