import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/components/centered_loader.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/app_constants.dart';
import '../models/onramp_quote_response.dart';
import '../payment_utils.dart';
import '../services/butterfly_service.dart';

class OnRampInitializer extends StatefulWidget {
  final String walletAddress;
  final double vfxAmount;
  const OnRampInitializer(
      {super.key, required this.walletAddress, required this.vfxAmount});

  @override
  State<OnRampInitializer> createState() => _OnRampInitializerState();
}

class _OnRampInitializerState extends State<OnRampInitializer> {
  bool loading = true;
  OnrampQuoteResponse? quote;

  @override
  void initState() {
    getQuote();
    super.initState();
  }

  Future<void> getQuote() async {
    final data = await ButterflyService()
        .getQuote(vfxAddress: widget.walletAddress, amount: widget.vfxAmount);

    setState(() {
      quote = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(height: 64, child: const CenteredLoader());
    }
    if (quote != null) {
      final q = quote!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${q.amountVfx} VFX for \$${q.amountUsd} USD",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            q.vfxAddress,
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(
            height: 16,
          ),
          AppButton(
            label: "Pay with Crypto.com",
            icon: Icons.token,
            onPressed: () async {
              if (kIsWeb) {
                showCryptoMerchantIframeEmbed(
                    context, q.cryptoDotComCheckoutUrl, q.purchaseUuid);
              } else {
                launchUrlString(q.cryptoDotComCheckoutUrl);
                Navigator.of(context).pop(q.purchaseUuid);
              }
            },
          ),
          if (INCLUDE_STRIPE_INTEGRATION) ...[
            SizedBox(
              height: 8,
            ),
            AppButton(
              label: "Pay with Credit Card",
              icon: Icons.credit_card,
              onPressed: () {
                //Stripe does not allow for iframe embed
                launchUrlString(q.stripeCheckoutUrl);
                Navigator.of(context).pop(q.purchaseUuid);
              },
            ),
          ],
          SizedBox(
            height: 8,
          ),
          AppButton(
            label: "Cancel",
            type: AppButtonType.Text,
            variant: AppColorVariant.Secondary,
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          )
        ],
      );
    }

    return Text("An error occurred");
  }
}
