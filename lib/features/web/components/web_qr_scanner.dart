import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/core/theme/components.dart';

import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart' if (dart.library.io) 'web_qr_scanner_mock.dart';

class WebQrScanner extends StatefulWidget {
  final Function(String) onQrCodeScanned;
  final VoidCallback onClose;

  const WebQrScanner({
    Key? key,
    required this.onQrCodeScanned,
    required this.onClose,
  }) : super(key: key);

  @override
  State<WebQrScanner> createState() => _WebQrScannerState();
}

class _WebQrScannerState extends State<WebQrScanner> {
  late CameraController _controller;
  bool _isScanning = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(autoPlay: true);
  }

  @override
  void dispose() {
    _controller.stopVideoStream();
    super.dispose();
  }

  void _handleError(String error) {
    setState(() {
      _errorMessage = error;
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // Full screen overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          // QR Scanner container
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isScanning ? AppColors.getBlue() : Colors.red,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isScanning ? AppColors.getBlue() : Colors.red).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _errorMessage != null
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera Error',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _isScanning = true;
                              });
                              _controller.startVideoStream();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.getBlue(),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: 292,
                      height: 292,
                      child: FlutterWebQrcodeScanner(
                        controller: _controller,
                        cameraDirection: CameraDirection.back,
                        stopOnFirstResult: true,
                        onGetResult: (result) =>
                          widget.onQrCodeScanned(result)
                        ,
                        width: 292,
                        height: 292,
                      ),
                    ),
            ),
          ),
          // Close button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isScanning && _errorMessage == null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.getBlue()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Scanning...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _errorMessage != null 
                            ? 'Camera access required to scan QR codes'
                            : 'Position QR code within the frame to scan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebQrScannerButton extends StatelessWidget {
  final Function(String) onQrCodeScanned;

  const WebQrScannerButton({
    Key? key,
    required this.onQrCodeScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () {
        _showQrScanner(context);
      },
      backgroundColor: AppColors.getBlue(),
      child: const Icon(
        Icons.qr_code_scanner,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  void _showQrScanner(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WebQrScanner(
          onQrCodeScanned: (result) {
            Navigator.of(context).pop();
            onQrCodeScanned(result);
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
