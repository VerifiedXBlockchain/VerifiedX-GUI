import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dart_bip66/dart_bip66.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';
import 'package:rbx_wallet/features/web/utils/raw_transaction.dart';

class _Vector {
  final String privateKey;
  final String message;
  final String publicKey;
  final String derBase64;

  const _Vector(this.privateKey, this.message, this.publicKey, this.derBase64);
}

/// Expected signatures come from @noble/curves 1.9.7, the SDK's signer:
/// `secp256k1.sign(sha256(utf8(message)), key, { lowS: true, prehash: false }).toDERRawBytes()`.
/// The set covers r with and without the top bit set, and r and s shorter than
/// 32 bytes, so every DER length the encoder can meet is exercised.
const _vectors = [
  _Vector('0000000000000000000000000000000000000000000000000000000000000001', 'vfx-test-message-0', '0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
      'MEUCIQDd29XRmV9LU1VBJ5CYP9H2N9QKsiWG+GUUYRDp4XEdvAIgBhwZel4Yl0wpLYpOjoYzEGo1s7pWGnwePev3fc/95CA='),
  _Vector('0000000000000000000000000000000000000000000000000000000000000001', 'vfx-test-message-4', '0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
      'MEQCIFZc4uhqvLlXQyl4JNsNeXYOMsF7L1l+HDBuxJvCSH3JAiBACTbcXGdUCOJZskvGNJXoIp4l6EPHq7+OP6HXsECzhQ=='),
  _Vector('0000000000000000000000000000000000000000000000000000000000000001', 'vfx-test-message-58', '0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
      'MEMCIEBRBVtYYwvRcJ6TXgA3bPYKucqxLok0lwlLT8++Id11Ah9thCza0mSgD58lqxUHlUjaTYm4/BhFACb5m8JPONJG'),
  _Vector('0000000000000000000000000000000000000000000000000000000000000001', 'vfx-test-message-173', '0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
      'MEQCIAD5UM4S+LPyGGgwcRwurtbxKnhEeRemVAjZN8cgkhGMAiBKZKnNfkYmwCpGjjT53njxpvkUOQFHAEmUs326QgjO8A=='),
  _Vector('c90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b14e5c9', 'vfx-test-message-0', '04dd308afec5777e13121fa72b9cc1b7cc0139715309b086c960e18fd969774eb8f594bb5f72b37faae396a4259ea64ed5e6fdeb2a51c6467582b275925fab1394',
      'MEUCIQCibxkTIEDlbSLk3yveD8Pe2vrOBpTLkJK5/EetyHnRTgIgOAhWDiXryE97HRNYp5H5ow7p8FSA6o/kl3TIVDHGtLA='),
  _Vector('c90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b14e5c9', 'vfx-test-message-4', '04dd308afec5777e13121fa72b9cc1b7cc0139715309b086c960e18fd969774eb8f594bb5f72b37faae396a4259ea64ed5e6fdeb2a51c6467582b275925fab1394',
      'MEQCID5cO89TYs+p9CiZmfzK7Gt1QZENzmq75VapUHCONB+IAiAlvQSD8unjLZM+E3caQH4GcLh3O7qSXHQM1XDLBKuUkg=='),
  _Vector('c90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b14e5c9', 'vfx-test-message-25', '04dd308afec5777e13121fa72b9cc1b7cc0139715309b086c960e18fd969774eb8f594bb5f72b37faae396a4259ea64ed5e6fdeb2a51c6467582b275925fab1394',
      'MEMCIBDpg4dwLCPQ0hfVlEy4vP0O1/fNfuTJ/8qX1Dq4S2NhAh8UQtuCeC9FH0G16j/s+/tTuqanph4sctzuxmhOcmvF'),
  _Vector('c90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b14e5c9', 'vfx-test-message-230', '04dd308afec5777e13121fa72b9cc1b7cc0139715309b086c960e18fd969774eb8f594bb5f72b37faae396a4259ea64ed5e6fdeb2a51c6467582b275925fab1394',
      'MEQCIAD04gcGzXSPimbOc+hwuqlgh8nglVg/674CoXkefsP2AiA7btxxjcWRKNeRW2WrpcJ/5qMYH6glotbW4kF/y/0DYQ=='),
  _Vector('00f1e2d3c4b5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff', 'vfx-test-message-0', '04a35106941dfcedd8bd45568dd96cb45a32bed0e700730fb01ab04232a5af681f8c25869178e09bed57ed27f4192325ad15fdf3a782ca8b87604c6f8aab3fdbaf',
      'MEUCIQC9UzPFMQZz8OIB2NZhlFVbk9oMjDwxowERY50hijpckAIgAORnDlGoICXr6eZ9BljcxkEqYTfS1I3q/Cs9CQKPNY8='),
  _Vector('00f1e2d3c4b5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff', 'vfx-test-message-1', '04a35106941dfcedd8bd45568dd96cb45a32bed0e700730fb01ab04232a5af681f8c25869178e09bed57ed27f4192325ad15fdf3a782ca8b87604c6f8aab3fdbaf',
      'MEUCIQC1Dl3DqMSYI3cui/2xEhkY8Ov00ZJqt3m8ZIYvdTYphAIgckyu+xIweEpn/NBRBxDSl01VPLUZFVaCXFxp7wOEOlk='),
  _Vector('00f1e2d3c4b5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff', 'vfx-test-message-2', '04a35106941dfcedd8bd45568dd96cb45a32bed0e700730fb01ab04232a5af681f8c25869178e09bed57ed27f4192325ad15fdf3a782ca8b87604c6f8aab3fdbaf',
      'MEQCIA8qGPvc9QjPEYmq8mJinjViwweWN0OFfLlf+NTUfEIiAiAb46ONCDsh5/vLu5pfDTyha3QXtvGps7QUubkZTrjvhA=='),
  _Vector('00f1e2d3c4b5a69788796a5b4c3d2e1f00112233445566778899aabbccddeeff', 'vfx-test-message-81', '04a35106941dfcedd8bd45568dd96cb45a32bed0e700730fb01ab04232a5af681f8c25869178e09bed57ed27f4192325ad15fdf3a782ca8b87604c6f8aab3fdbaf',
      'MEMCH1qhn2LBJJfWyLRZFKOUoyq1ozP8xSAm7XGjdPEA3NcCICeRXl4e49cprCcGQuxh1l44WK+HzArABgMQH444dKW1'),
];

final _order = BigInt.parse('fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141', radix: 16);

BigInt _toBigInt(Uint8List bytes) => BigInt.parse(HEX.encode(bytes), radix: 16);

void main() {
  group('RawTransaction.getSignature', () {
    test('gives the same signature as the SDK for the same key and message', () async {
      for (final vector in _vectors) {
        final signature = await RawTransaction.getSignature(
          message: vector.message,
          privateKey: vector.privateKey,
          publicKey: vector.publicKey,
        );

        final expectedPublicKey = RawTransaction.base58Encode(HEX.decode(vector.publicKey.substring(2)));
        expect(signature, '${vector.derBase64}.$expectedPublicKey', reason: vector.message);
      }
    });

    test('signing the same message twice gives the same signature', () async {
      final vector = _vectors.first;
      final first = await RawTransaction.getSignature(message: vector.message, privateKey: vector.privateKey, publicKey: vector.publicKey);
      final second = await RawTransaction.getSignature(message: vector.message, privateKey: vector.privateKey, publicKey: vector.publicKey);

      expect(first, isNotNull);
      expect(second, first);
    });

    test('s is never above half the curve order', () async {
      final halfOrder = _order >> 1;
      const privateKey = 'c90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b14e5c9';

      for (var i = 0; i < 64; i++) {
        final digest = Uint8List.fromList(sha256.convert(utf8.encode('low-s-$i')).bytes);
        final signature = RawTransaction.signDigest(digest, privateKey);
        expect(signature.s <= halfOrder, isTrue, reason: 'low-s-$i');

        final decoded = der.decode(RawTransaction.toDer(signature.r, signature.s)!);
        expect(_toBigInt(decoded.r), signature.r, reason: 'low-s-$i');
        expect(_toBigInt(decoded.s), signature.s, reason: 'low-s-$i');
      }
    });
  });
}
