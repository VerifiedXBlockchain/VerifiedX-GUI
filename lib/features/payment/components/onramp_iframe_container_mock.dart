import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class OnrampIframeContainer extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const OnrampIframeContainer({
    super.key,
    required this.url,
    this.width = 400,
    this.height = 400,
  });

  @override
  State<OnrampIframeContainer> createState() => _OnrampIframeContainerState();
}

class _OnrampIframeContainerState extends State<OnrampIframeContainer> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(l10n.txpNotAvailableOnPlatform);
  }
}
