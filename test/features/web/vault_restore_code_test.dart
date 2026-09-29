import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/web/components/web_restore_ra_button.dart';

void main() {
  String encode(String data) => base64.encode(utf8.encode(data));

  test('decodes the primary and recovery keys', () {
    final keys = decodeVaultRestoreCode(encode('primaryKey//recoveryKey'));
    expect(keys, isNotNull);
    expect(keys!.primary, 'primaryKey');
    expect(keys.recovery, 'recoveryKey');
  });

  test('tolerates surrounding whitespace from a paste', () {
    final keys = decodeVaultRestoreCode('  ${encode('a//b')}\n');
    expect(keys?.primary, 'a');
    expect(keys?.recovery, 'b');
  });

  test('returns null for text that is not base64', () {
    expect(decodeVaultRestoreCode('not a restore code!'), isNull);
  });

  test('returns null for a truncated code', () {
    final code = encode('primaryKey//recoveryKey');
    expect(decodeVaultRestoreCode(code.substring(0, code.length - 3)), isNull);
  });

  test('returns null when the separator or a key is missing', () {
    expect(decodeVaultRestoreCode(encode('onlyOneKey')), isNull);
    expect(decodeVaultRestoreCode(encode('primaryKey//')), isNull);
    expect(decodeVaultRestoreCode(encode('//recoveryKey')), isNull);
  });

  test('returns null for bytes that are not UTF-8', () {
    expect(decodeVaultRestoreCode(base64.encode([0xff, 0xfe, 0xfd])), isNull);
  });
}
