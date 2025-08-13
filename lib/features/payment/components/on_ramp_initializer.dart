import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/components/centered_loader.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/breakpoints.dart';
import '../models/onramp_quote_response.dart';
import '../services/onramp_service.dart';
import 'onramp_iframe_container.dart'
    if (dart.library.io) 'onramp_iframe_container_mock.dart';

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
            label: "Pay with Crypto.com",
            icon: Icons.token,
            onPressed: () async {
              if (kIsWeb) {
                final maxWidth =
                    BreakPoints.useMobileLayout(context) ? 400.0 : 750.0;
                final maxHeight =
                    BreakPoints.useMobileLayout(context) ? 500.0 : 700.0;
                double width = MediaQuery.of(context).size.width - 32;
                double height = MediaQuery.of(context).size.height - 64;

                if (width > maxWidth) {
                  width = maxWidth;
                }

                if (height > maxHeight) {
                  height = maxHeight;
                }
                final value = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        insetPadding: EdgeInsets.zero,
                        actionsPadding: EdgeInsets.zero,
                        buttonPadding: EdgeInsets.zero,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OnrampIframeContainer(
                              url: q.cryptoDotComCheckoutUrl,
                              width: width,
                              height: height,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AppButton(
                                label: "Cancel",
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    });

                print("VALUE $value");
                if (value != null) {
                  Navigator.of(context).pop(q.purchaseUuid);
                }
              } else {
                launchUrlString(q.cryptoDotComCheckoutUrl);
                Navigator.of(context).pop(q.purchaseUuid);
              }
            },
          ),
          SizedBox(
            height: 8,
          ),
          AppButton(
            label: "Pay with Stripe",
            icon: Icons.credit_card,
            onPressed: () {
              if (kIsWeb) {
              } else {
                launchUrlString(q.stripeCheckoutUrl);
                Navigator.of(context).pop(q.purchaseUuid);
              }
            },
          ),
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
