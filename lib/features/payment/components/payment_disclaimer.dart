import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentGateway {
  banxa(
      "Banxa", "www.banxa.com", "https://banxa.com/terms-of-use", "https://banxa.com/privacy-and-cookies-policy", "https://support.banxa.com", true),
  moonpay("MoonPay", "www.moonpay.com", "https://www.moonpay.com/legal", "https://www.moonpay.com/legal/privacy_policy",
      "https://support.moonpay.com/", true),
  testnetFaucet("Testnet Faucet", "", "", "", "", false),
  ;

  final String name;
  final String website;
  final String termsUrl;
  final String privacyUrl;
  final String supportUrl;
  final bool hasTerms;

  const PaymentGateway(this.name, this.website, this.termsUrl, this.privacyUrl, this.supportUrl, this.hasTerms);
}

class PaymentDisclaimer extends StatelessWidget {
  final PaymentGateway paymentGateway;
  const PaymentDisclaimer({
    required this.paymentGateway,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (paymentGateway == PaymentGateway.testnetFaucet) {
      return Text("Testnet Faucet does not have any terms. Have fun!");
    }

    final textStyle = TextStyle(fontSize: 14, color: Colors.white);

    final boldStyle = TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700);

    final linkStyle = TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline);

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: "I understand that I will now be purchasing VFX or BTC native coin directly through ${paymentGateway.name} ("),
          TextSpan(
            text: paymentGateway.website,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse("https://${paymentGateway.website}"));
              },
          ),
          TextSpan(
              text:
                  "), which is a third-party services platform. By proceeding and procuring services from ${paymentGateway.name}, you acknowledge that you have read and agreed to ${paymentGateway.name}’s "),
          TextSpan(
            text: "Terms of Use",
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(paymentGateway.termsUrl));
              },
          ),
          TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(paymentGateway.privacyUrl));
              },
          ),
          TextSpan(
              text:
                  ". You additionally understand that the VerifiedX VFX Network is an autonomous and decentralized ecosystem and does not share in any fees whatsoever by you utilizing ${paymentGateway.name}’s services and does not take any responsibility for any issues that may affect your transaction with any third-party service provider at anytime. For any questions related to ${paymentGateway.name}’s services, please contact ${paymentGateway.name} at "),
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
