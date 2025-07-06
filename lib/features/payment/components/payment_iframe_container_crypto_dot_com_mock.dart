import 'package:flutter/material.dart';

class WebPaymentIFrameContainerCryptoDotCom extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const WebPaymentIFrameContainerCryptoDotCom({
    super.key,
    required this.url,
    this.width = 400,
    this.height = 400,
  });

  @override
  State<WebPaymentIFrameContainerCryptoDotCom> createState() =>
      _WebPaymentIFrameContainerCryptoDotComState();
}

class _WebPaymentIFrameContainerCryptoDotComState
    extends State<WebPaymentIFrameContainerCryptoDotCom> {
  @override
  Widget build(BuildContext context) {
    return Text("Not available on this platform");
  }
}
