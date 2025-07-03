import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/env.dart';

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
  late Widget iframeWidget;

  final IFrameElement iframeElement = IFrameElement();

  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() {
    iframeElement.height = '${widget.width}';
    iframeElement.width = '${widget.height}';
    iframeElement.src = widget.url;
    iframeElement.style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => iframeElement,
    );

    iframeWidget = HtmlElementView(
      key: UniqueKey(),
      viewType: 'iframeElement',
    );

    iframeElement.onLoad.listen((event) {});
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
