import 'package:flutter/material.dart';

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
    return Text("Not available on this platform");
  }
}
