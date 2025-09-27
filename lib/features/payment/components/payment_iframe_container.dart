import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/env.dart';

class WebPaymentIFrameContainer extends StatefulWidget {
  final String fiatType;
  final double coinAmount;
  final String walletAddress;
  final double width;
  final double height;
  final String coinType;

  const WebPaymentIFrameContainer({
    super.key,
    this.fiatType = "USD",
    required this.coinAmount,
    required this.walletAddress,
    this.width = 400,
    this.height = 400,
    required this.coinType,
  });

  @override
  State<WebPaymentIFrameContainer> createState() =>
      _WebPaymentIFrameContainerState();
}

class _WebPaymentIFrameContainerState extends State<WebPaymentIFrameContainer> {
  late Widget iframeWidget;
  late String viewType;

  IFrameElement? iframeElement;

  String? error;

  @override
  void initState() {
    super.initState();
    viewType = 'payment-iframe-${DateTime.now().millisecondsSinceEpoch}';
    load();
  }

  load() {
    if (Env.banxaPaymentDomain == null) {
      print("Payment not available in this environment");
      setState(() {
        error = "Payment not available in this environment";
      });
      return;
    }

    iframeElement = IFrameElement();
    iframeElement!.height = '${widget.width}';
    iframeElement!.width = '${widget.height}';
    iframeElement!.src = kDebugMode
        ? "/assets/html/payment.html"
        : "/assets/assets/html/payment.html";
    iframeElement!.style.border = 'none';
    iframeElement!.style.width = '${widget.width}px';
    iframeElement!.style.height = '${widget.height}px';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframeElement!,
    );

    iframeWidget = HtmlElementView(
      key: UniqueKey(),
      viewType: viewType,
    );

    iframeElement!.onLoad.listen((event) {
      final payload = {
        "width": widget.width,
        "height": widget.height,
        "fiatType": widget.fiatType,
        "coinType": widget.coinType,
        "coinAmount": widget.coinAmount,
        "walletAddress": widget.walletAddress,
      };

      Future.delayed(Duration(milliseconds: 500)).then((value) {
        iframeElement!.contentWindow?.postMessage(jsonEncode(payload), "*");
      });
    });
  }

  @override
  void dispose() {
    iframeElement?.remove();
    iframeElement = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: Colors.black),
      child: error != null ? Center(child: Text(error!)) : iframeWidget,
    );
  }
}
