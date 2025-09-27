// Mock implementation for non-web platforms
import 'package:flutter/material.dart';

// Mock CameraController for non-web platforms
class CameraController {
  final bool autoPlay;
  
  CameraController({required this.autoPlay});
  
  void startVideoStream() {
    // No-op for non-web
  }
  
  void stopVideoStream() {
    // No-op for non-web
  }
}

// Mock CameraDirection enum
enum CameraDirection {
  back,
  front,
}

// Mock FlutterWebQrcodeScanner widget for non-web platforms
class FlutterWebQrcodeScanner extends StatelessWidget {
  final CameraController? controller;
  final CameraDirection cameraDirection;
  final bool stopOnFirstResult;
  final Function(String) onGetResult;
  final double? width;
  final double? height;

  const FlutterWebQrcodeScanner({
    Key? key,
    this.controller,
    required this.cameraDirection,
    required this.stopOnFirstResult,
    required this.onGetResult,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 300,
      height: height ?? 300,
      color: Colors.grey[800],
      child: const Center(
        child: Text(
          'QR Scanner not available on this platform',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
