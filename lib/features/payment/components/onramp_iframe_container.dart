import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:js_util' as js_util;

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
  late Widget iframeWidget;
  late String viewType;

  IFrameElement? iframeElement;

  String? error;
  StreamSubscription<MessageEvent>? msgSub;

  @override
  void initState() {
    super.initState();
    viewType = 'onramp-iframe-${DateTime.now().millisecondsSinceEpoch}';
    load();
    setupMessageListener();
  }

  load() {
    iframeElement = IFrameElement();
    iframeElement!.height = '${widget.width}';
    iframeElement!.width = '${widget.height}';
    iframeElement!.src = widget.url;
    iframeElement!.style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframeElement!,
    );

    iframeWidget = HtmlElementView(
      key: UniqueKey(),
      viewType: viewType,
    );

    iframeElement!.onLoad.listen((event) {});
  }

  void setupMessageListener() {
    msgSub = window.onMessage.listen((MessageEvent event) {
      // 1) Security: verify origin (adjust to your iframe app's origin)
      // const expectedOrigin = 'http://localhost:8000'; // <- change this
      // if (event.origin != expectedOrigin) return;

      // // 2) Ensure the message came from THIS iframe (not another frame on the page)
      // if (event.source != iframeElement?.contentWindow) return;

      // 3) Extract the data (supports objects or JSON strings)
      final raw = event.data;
      Map<String, dynamic>? data;

      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) data = decoded;
        } catch (_) {/* ignore */}
      } else {
        final converted = js_util.dartify(raw);
        if (converted is Map) {
          data = converted.map((k, v) => MapEntry(k.toString(), v));
        }
      }
      print(data);
      if (data == null) return;

      print(data['type']);

      // 4) Handle your custom event
      if (data['type'] == 'paymentComplete') {
        final payload = data['payload'];

        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    msgSub?.cancel();
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
