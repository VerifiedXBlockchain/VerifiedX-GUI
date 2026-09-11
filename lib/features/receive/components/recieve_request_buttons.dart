import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

import '../../../core/dialogs.dart';
import '../../../core/theme/components.dart';
import '../../../core/theme/pretty_icons.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';
import '../../nft/components/nft_qr_code.dart';

String generateLink(String currency, String address, double amount) {
  final baseUrl = Env.isTestNet
      ? "https://wallet-testnet.verifiedx.io"
      : "https://wallet.verifiedx.io";

  return "$baseUrl/#dashboard/send/$currency/$address/$amount";
}

Future<void> copyToClipboard(String value, [String? message]) async {
  await Clipboard.setData(ClipboardData(text: value));
  Toast.message(message ?? "'$value' Copied to clipboard");
}

Future<void> showRequestPrompt({
  required BuildContext context,
  required String address,
  required Function(String str) onValidSubmission,
}) async {
  final l10n = AppLocalizations.of(context);
  PromptModal.show(
    contextOverride: context,
    tightPadding: true,
    title: l10n.webRequestFunds,
    body: l10n.webRequestFundsBody,
    labelText: l10n.webAmountToRequest,
    validator: (value) => formValidatorNumber(value, l10n.labelAmount),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    confirmText: l10n.webGenerateLink,
    onValidSubmission: onValidSubmission,
  );
}

class RecieveCopyLinkButton extends StatelessWidget {
  final String address;
  final String? domain;
  final String currency;
  const RecieveCopyLinkButton({
    super.key,
    required this.address,
    required this.currency,
    this.domain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppVerticalIconButton(
      label: l10n.webCopyLink,
      icon: Icons.link,
      prettyIconType: PrettyIconType.custom,
      onPressed: () async {
        showRequestPrompt(
            context: context,
            address: address,
            onValidSubmission: (amount) async {
              if (double.tryParse(amount) != null) {
                final value =
                    domain != null && domain!.isNotEmpty ? domain! : address;
                final url = generateLink(currency, value, double.parse(amount));

                await copyToClipboard(url, l10n.webRequestLinkCopied);
              } else {
                Toast.error(l10n.webInvalidAmount);
              }
            });
      },
    );
  }
}

class RecieveGenerateQrCode extends StatelessWidget {
  final String address;
  final String? domain;
  final String currency;

  const RecieveGenerateQrCode({
    super.key,
    required this.address,
    required this.currency,
    this.domain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppVerticalIconButton(
      label: l10n.webQrCode,
      icon: Icons.qr_code_rounded,
      prettyIconType: PrettyIconType.custom,
      onPressed: () async {
        showRequestPrompt(
            context: context,
            address: address,
            onValidSubmission: (amount) async {
              if (double.tryParse(amount) != null) {
                final value =
                    domain != null && domain!.isNotEmpty ? domain! : address;
                final url = generateLink(currency, value, double.parse(amount));

                showDialog(
                    context: context,
                    builder: (context) {
                      return Center(
                        child: NftQrCode(
                          data: url,
                          withClose: true,
                          center: true,
                        ),
                      );
                    });
              } else {
                Toast.error(l10n.webInvalidAmount);
              }
            });
      },
    );
  }
}
