import 'package:flutter/material.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/components/centered_loader.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/onramp_quote_response.dart';
import '../services/onramp_service.dart';

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
    final data = await OnrampService()
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
            label: "Pay with Stripe",
            onPressed: () {
              //TODO: iframe embed stuff
              launchUrlString(q.stripeCheckoutUrl);
              Navigator.of(context).pop(true);
            },
          ),
          SizedBox(
            height: 8,
          ),
          AppButton(
            label: "Pay with Crypto.com",
            onPressed: () {
              //TODO: iframe embed stuff

              launchUrlString(q.cryptoDotComCheckoutUrl);
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    }

    return Text("An error occurred");
  }
}
