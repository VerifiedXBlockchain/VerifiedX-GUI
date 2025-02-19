// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:rbx_wallet/core/env.dart';
// import 'package:rbx_wallet/features/keygen/bip32/bip32.dart' as bip32;
import 'package:bip32/bip32.dart' as bip32;
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';

class KeygenService {
  static Future<Keypair> importPrivateKey(
    String privateKey, [
    String? mneumonic,
  ]) async {
    final String response = await js.context.callMethod('importPrivateKey', [privateKey, Env.isTestNet]);

    final a = response.split(":");
    final address = a[0];
    final public = a[1];
    final private = a[2];

    return Keypair(
      address: address,
      public: public,
      private: private,
      mneumonic: mneumonic,
    );
  }

  static Future<RaKeypair> importReserveAccountPrivateKey(String privateKey) async {
    try {
      final String response = await js.context.callMethod('generateReserveAccountRestoreCode', [privateKey, Env.isTestNet]);

      print(response);

      final a = response.split("|");

      final primary = a[0].split(":");
      final recovery = a[1].split(":");
      final restoreCode = a[2];

      return RaKeypair(
        address: primary[0],
        public: primary[1],
        private: primary[2],
        recoveryAddress: recovery[0],
        recoveryPublic: recovery[1],
        recoveryPrivate: recovery[2],
        restoreCode: restoreCode,
      );
    } catch (e) {
      print("Error in importReserveAccountPrivateKey");
      rethrow;
    }
  }

  static Future<String> addressFromPrivateKey(String privateKey) async {
    final String response = await js.context.callMethod('addressFromPrivateKey', [privateKey, Env.isTestNet]);
    return response;
  }

  static Future<Keypair?> _mneumonicToKeypair(
    String mnemonic,
    int index,
  ) async {
    final isValid = bip39.validateMnemonic(mnemonic);

    if (!isValid) {
      return null;
    }

    final Uint8List seed = bip39.mnemonicToSeed(mnemonic);

    final bip32.BIP32 root = bip32.BIP32.fromSeed(seed);

    final bip32.BIP32 child = root.derivePath("m/0'/0'/$index'");

    final String privateKey = child.privateKey!.toList().map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    final keypair = await KeygenService.importPrivateKey(
      privateKey,
      mnemonic,
    );
    return keypair;
  }

  static Future<Keypair?> seedToKeypair(String seed) async {
    final String privateKeyHex = await js.context.callMethod('seedToPrivate', [seed]);

    final keypair = await KeygenService.importPrivateKey(privateKeyHex);
    return keypair;
  }

  // static Future<RaKeypair?> seedToRaKeypair(String seed) async {
  //   final String privateKeyHex = await js.context.callMethod('seedToPrivate', [seed]);

  //   final keypair = await KeygenService.importReserveAccountPrivateKey(privateKeyHex);
  //   return keypair;
  // }

  static Future<Keypair?> generate([int index = 0]) async {
    final mnemonic = bip39.generateMnemonic();

    return _mneumonicToKeypair(mnemonic, index);
  }

  static Future<Keypair?> recover(String mnemonic, [int index = 0]) async {
    return _mneumonicToKeypair(mnemonic, index);
  }
}
