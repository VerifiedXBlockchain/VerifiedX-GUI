// ignore_for_file: avoid_web_libraries_in_flutter

@JS()
library verifiedx_extension;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:js/js.dart';

// JS interop declarations for window.verifiedX
@JS('window.verifiedX')
external dynamic get _verifiedX;

@JS('window.verifiedX.isInstalled')
external bool? get _isInstalled;

/// Encrypted key data returned from the VFX browser extension
class ExtensionEncryptedKeyData {
  final List<int> salt;
  final List<int> iv;
  final List<int> cipherText;
  final String address;
  final String publicKey;

  ExtensionEncryptedKeyData({
    required this.salt,
    required this.iv,
    required this.cipherText,
    required this.address,
    required this.publicKey,
  });
}

/// Service for communicating with the VerifiedX browser extension
class VerifiedXExtensionService {
  /// Check if the VerifiedX extension is installed
  static bool isExtensionInstalled() {
    try {
      return _verifiedX != null && _isInstalled == true;
    } catch (e) {
      return false;
    }
  }

  /// Listen for the extension initialization event
  /// The extension fires 'verifiedX#initialized' when ready
  static void onExtensionInitialized(void Function() callback) {
    html.window.addEventListener('verifiedX#initialized', (event) {
      callback();
    });
  }

  /// Request encrypted key from the extension
  /// Returns the encrypted key data if user approves
  /// Throws exception if user rejects, timeout, or wallet is locked
  static Future<ExtensionEncryptedKeyData> requestKey() async {
    if (!isExtensionInstalled()) {
      throw Exception('VerifiedX extension is not installed');
    }

    try {
      // Call window.verifiedX.requestKey() which returns a Promise
      final promise = js_util.callMethod(_verifiedX, 'requestKey', []);

      // Convert promise to future
      final jsResult = await js_util.promiseToFuture(promise);

      if (jsResult == null) {
        throw Exception('No response from extension');
      }

      // Extract the data from the JS object
      final saltJs = js_util.getProperty(jsResult, 'salt');
      final ivJs = js_util.getProperty(jsResult, 'iv');
      final cipherTextJs = js_util.getProperty(jsResult, 'cipherText');
      final addressJs = js_util.getProperty(jsResult, 'address');
      final publicKeyJs = js_util.getProperty(jsResult, 'publicKey');

      // Convert JS arrays to Dart List<int>
      final salt = _jsArrayToIntList(saltJs);
      final iv = _jsArrayToIntList(ivJs);
      final cipherText = _jsArrayToIntList(cipherTextJs);

      return ExtensionEncryptedKeyData(
        salt: salt,
        iv: iv,
        cipherText: cipherText,
        address: addressJs.toString(),
        publicKey: publicKeyJs.toString(),
      );
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('User rejected')) {
        throw Exception('User rejected the request');
      } else if (errorMessage.contains('timed out')) {
        throw Exception('Key request timed out');
      } else if (errorMessage.contains('locked')) {
        throw Exception('Wallet is locked. Please unlock your wallet first.');
      } else {
        // Re-throw with the actual error message for debugging
        throw Exception('Extension error: $errorMessage');
      }
    }
  }

  /// Convert a JS array of numbers to a Dart List<int>
  static List<int> _jsArrayToIntList(dynamic jsArray) {
    final List<int> result = [];
    final length = js_util.getProperty(jsArray, 'length') as int;

    for (int i = 0; i < length; i++) {
      final value = js_util.getProperty(jsArray, i);
      result.add((value as num).toInt());
    }

    return result;
  }
}
