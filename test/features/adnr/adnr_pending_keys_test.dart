import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/adnr/providers/adnr_pending_provider.dart';

/// Mirrors how the domain sections decide which badge to show.
Map<String, bool> badgesFor(List<String> keys, String address, String? adnr) {
  final domain = adnr ?? 'null';
  return {
    'create': keys.contains("$address.create.$domain"),
    'transfer': keys.contains("$address.transfer.$domain"),
    'delete': keys.contains("$address.delete.$domain") || keys.contains("$address.burn.$domain"),
  };
}

void main() {
  const address = 'tb1qaddress';
  const domain = 'qa20260927awb2.btc';

  test('web delete clears the stale create key (TC-ADNR-023)', () {
    // Create broadcast: domain not named yet.
    var keys = pendingAdnrKeysAfterAdd([], address, "create", "null");
    expect(badgesFor(keys, address, null)['create'], isTrue);

    // Create confirmed: the domain is now set, so the create key no longer matches.
    expect(badgesFor(keys, address, domain).values, everyElement(isFalse));

    // Delete broadcast with the web wallet's "delete" type.
    keys = pendingAdnrKeysAfterAdd(keys, address, "delete", domain);
    expect(badgesFor(keys, address, domain)['delete'], isTrue);

    // Delete confirmed: the domain is gone; nothing may claim a pending create.
    expect(badgesFor(keys, address, null).values, everyElement(isFalse));
  });

  test('desktop burn still clears create and transfer keys', () {
    var keys = pendingAdnrKeysAfterAdd([], address, "create", "null");
    keys = pendingAdnrKeysAfterAdd(keys, address, "transfer", domain);
    keys = pendingAdnrKeysAfterAdd(keys, address, "burn", domain);

    expect(keys, ["$address.burn.$domain"]);
  });

  test('a new create clears an earlier delete of the same address', () {
    var keys = pendingAdnrKeysAfterAdd([], address, "delete", domain);
    keys = pendingAdnrKeysAfterAdd(keys, address, "create", "null");

    expect(keys, ["$address.create.null"]);
    // Re-creating the same name must not bring back "Delete Pending".
    expect(badgesFor(keys, address, domain).values, everyElement(isFalse));
  });

  test('keys of other addresses are left alone and values are not duplicated', () {
    var keys = pendingAdnrKeysAfterAdd([], 'xOther', "create", "null");
    keys = pendingAdnrKeysAfterAdd(keys, address, "delete", domain);
    keys = pendingAdnrKeysAfterAdd(keys, address, "delete", domain);

    expect(keys, ['xOther.create.null', "$address.delete.$domain"]);
  });
}
