import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/generated/app_localizations.dart';

enum PaymentGateway {
  banxa(
      "Banxa",
      "www.banxa.com",
      "https://banxa.com/terms-of-use",
      "https://banxa.com/privacy-and-cookies-policy",
      "https://support.banxa.com",
      true),
  moonpay(
      "MoonPay",
      "www.moonpay.com",
      "https://www.moonpay.com/legal",
      "https://www.moonpay.com/legal/privacy_policy",
      "https://support.moonpay.com/",
      true),
  cryptoDotCom(
      "Crypto.com",
      "www.crypto.com",
      "https://crypto.com/advanced/document/tnc",
      "https://crypto.com/advanced/document/privacy",
      "https://help.crypto.com/en/",
      true),
  testnetFaucet("Testnet Faucet", "", "", "", "", false),
  stripe("Stripe", "www.stripe.com", "https://stripe.com/legal/ssa",
      "https://stripe.com/privacy", "https://support.stripe.com/", true),
  ;

  final String name;
  final String website;
  final String termsUrl;
  final String privacyUrl;
  final String supportUrl;
  final bool hasTerms;

  const PaymentGateway(this.name, this.website, this.termsUrl, this.privacyUrl,
      this.supportUrl, this.hasTerms);
}

class PaymentDisclaimer extends StatelessWidget {
  final PaymentGateway paymentGateway;
  const PaymentDisclaimer({
    required this.paymentGateway,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (paymentGateway == PaymentGateway.testnetFaucet) {
      return Text(l10n.txpTestnetFaucetNoTerms);
    }

    final textStyle = TextStyle(fontSize: 14, color: Colors.white);

    final boldStyle = TextStyle(
        fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700);

    final linkStyle = TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.secondary,
        decoration: TextDecoration.underline);

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: l10n.txpDisclaimerIntro(paymentGateway.name)),
          TextSpan(
            text: paymentGateway.website,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse("https://${paymentGateway.website}"));
              },
          ),
          TextSpan(text: l10n.txpDisclaimerMiddle(paymentGateway.name)),
          TextSpan(
            text: l10n.txpTermsOfUse,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(paymentGateway.termsUrl));
              },
          ),
          TextSpan(text: l10n.txpDisclaimerAnd),
          TextSpan(
            text: l10n.txpPrivacyPolicy,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(paymentGateway.privacyUrl));
              },
          ),
          TextSpan(text: l10n.txpDisclaimerOutro(paymentGateway.name)),
          TextSpan(
            text: paymentGateway.supportUrl,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(paymentGateway.supportUrl));
              },
          ),
          TextSpan(text: "."),
        ],
      ),
    );
  }
}
