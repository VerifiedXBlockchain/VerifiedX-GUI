import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/wallet/models/private_key_export.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';

const _address = 'xAbc123';
const _key = '0f4b2a6c9d8e7f1029384756abcdef0123456789abcdef0123456789abcdef01';

Wallet _wallet(String address) => Wallet(
      id: 1,
      publicKey: 'pub-$address',
      address: address,
      balance: 0,
      isValidating: false,
    );

void main() {
  group('PrivateKeyExport.fromResponse', () {
    test('reads the key from a successful export', () {
      final export = PrivateKeyExport.fromResponse(
        _address,
        '{"Success":true,"Address":"$_address","PrivateKey":" $_key "}',
      );

      expect(export.isExported, isTrue);
      expect(export.privateKey, _key);
      expect(export.message, isNull);
    });

    test('carries the node message when the export is refused', () {
      final export = PrivateKeyExport.fromResponse(
        _address,
        '{"Success":false,"Message":"Key export requires an encrypted wallet or an API token/password."}',
      );

      expect(export.isExported, isFalse);
      expect(export.privateKey, isNull);
      expect(export.message, 'Key export requires an encrypted wallet or an API token/password.');
    });

    test('treats a success reply without a key as refused', () {
      final export = PrivateKeyExport.fromResponse(_address, '{"Success":true,"PrivateKey":null}');

      expect(export.isExported, isFalse);
      expect(export.message, isNull);
    });

    test('keeps a plain-text reply as the message', () {
      final export = PrivateKeyExport.fromResponse(_address, 'Command not recognized.');

      expect(export.isExported, isFalse);
      expect(export.message, 'Command not recognized.');
    });
  });

  group('vfxKeyBackupText', () {
    test('writes exported keys and never the word null', () {
      final wallets = [_wallet('xOne'), _wallet('xTwo')];
      final text = vfxKeyBackupText(wallets, {
        'xOne': PrivateKeyExport.fromResponse('xOne', '{"Success":true,"PrivateKey":"$_key"}'),
        'xTwo': const PrivateKeyExport.refused('xTwo', null),
      });

      expect(text, isNot(contains('null')));
      expect(text, contains('Private Key:\n$_key'));
      expect(text, contains('Not exported: the node did not return a key'));
    });

    test('lists only exported keys in the bulk import block', () {
      final wallets = [_wallet('xOne'), _wallet('xTwo')];
      final text = vfxKeyBackupText(wallets, {
        'xOne': PrivateKeyExport.fromResponse('xOne', '{"Success":true,"PrivateKey":"$_key"}'),
        'xTwo': const PrivateKeyExport.refused('xTwo', 'Account not found.'),
      });

      final bulk = text.split('FOR BULK IMPORT:\n\n')[1].split('\n===')[0];
      expect(bulk.trim().split('\n'), [_key]);
      expect(text, contains('Not exported: Account not found.'));
    });
  });
}
