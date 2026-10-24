import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';

import '../../../core/base_screen.dart';
import '../../../core/web_router.gr.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../web/providers/web_currency_segmented_button_provider.dart';
import '../../web/providers/web_selected_account_provider.dart';
import '../components/send_form_prefill.dart';
import '../providers/send_form_provider.dart';
import '../utils.dart';
import '../../../l10n/generated/app_localizations.dart';

class WebPrefilledSendScreen extends BaseScreen {
  final String currency;
  final String toAddress;
  /// Raw path segment; parsed with [prefilledSendAmountText] so a link with a
  /// non-numeric amount opens the form instead of failing in the router.
  final String amount;

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
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: isBtc
          ? Text(l10n.sendAppBarTitle('BTC'))
          : Text(l10n.sendAppBarTitle('VFX')),
      shadowColor: Colors.transparent,
      backgroundColor: Colors.black,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final sendForm = ref.read(sendFormProvider.notifier);
    // The link is handed to the Send tab's own form underneath this screen
    // rather than shown in a second SendForm: both would use the send form's
    // GlobalKey, so the one that rebuilt last took the fields and this page
    // could render blank.
    return SendFormPrefill(
      addressController: sendForm.addressController,
      amountController: sendForm.amountController,
      address: toAddress,
      amount: prefilledSendAmountText(amount),
      // Selecting the currency clears the send form, so it runs first.
      beforeFill: () => ref
          .read(webCurrencySegementedButtonProvider.notifier)
          .set(currency == 'btc' ? WebCurrencyType.btc : WebCurrencyType.vfx),
      afterFill: () => _showSendForm(context),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSendForm(BuildContext context) {
    final router = AutoRouter.of(context);
    if (router.stack.length > 1) {
      router.popUntilRoot();
    } else {
      router.replace(const WebSendScreenRoute());
    }
  }
}
