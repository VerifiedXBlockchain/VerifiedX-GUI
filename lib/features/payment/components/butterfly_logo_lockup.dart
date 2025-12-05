import 'package:flutter/material.dart';

class ButterflyLogoLockup extends StatelessWidget {
  const ButterflyLogoLockup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          "assets/images/butterfly_icon.png",
          width: 64,
          height: 64,
        ),
        Image.asset(
          "assets/images/butterfly_wordmark.png",
          height: 72,
        ),
      ],
    );
  }
}
