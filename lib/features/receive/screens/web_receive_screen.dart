import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/base_component.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/features/web/components/web_no_wallet.dart';
import 'package:rbx_wallet/utils/toast.dart';
import 'package:rbx_wallet/utils/validation.dart';

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
    return AppBar(
      title: const Text("Receive"),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  Future<void> copyToClipboard(String value, [String? message]) async {
    await Clipboard.setData(ClipboardData(text: value));
    Toast.message(message ?? "'$value' Copied to clipboard");
  }

  Future<void> copyLink(String address, double amount) async {
    final url = html.window.location.href.replaceAll("/receive", "/send/$address/$amount");
    await copyToClipboard(url, "Request funds link copied to clipboard");
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final address = ref.read(webSessionProvider).keypair?.public;

    if (address == null) {
      return const WebNotWallet();
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: TextFormField(
                      initialValue: address,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: Text("Your Address"),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            copyToClipboard(address);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This is the address the sender needs to send funds to.",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Divider(),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          AppButton(
            label: "Request Funds",
            icon: Icons.link,
            onPressed: () async {
              await PromptModal.show(
                  contextOverride: context,
                  tightPadding: true,
                  title: "Request Funds",
                  body: "Generate a URL to send to another user.",
                  labelText: "Amount to request",
                  validator: (value) => formValidatorNumber(value, "Amount"),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
                  confirmText: "Generate Link",
                  onValidSubmission: (val) {
                    if (double.tryParse(val) != null) {
                      copyLink(address, double.parse(val));
                    } else {
                      Toast.error("Invalid amount");
                    }
                  });
            },
            variant: AppColorVariant.Light,
          )
        ],
      ),
    );
  }
}