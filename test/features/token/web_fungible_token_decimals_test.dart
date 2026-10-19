import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/token/models/web_fungible_token.dart';

Map<String, dynamic> _json([Map<String, dynamic> extra = const {}]) => {
      'sc_identifier': 'sc-1',
      'name': 'Token',
      'ticker': 'TKN',
      'owner_address': 'xOwner',
      'can_mint': true,
      'can_burn': true,
      'can_vote': false,
      'is_paused': false,
      'circulating_supply': '1000.0',
      'initial_supply': '0',
      'banned_addresses': <String>[],
      'created_at': '2026-10-19T00:00:00Z',
      ...extra,
    };

void main() {
  test("reads the token's decimal places from Spyglass", () {
    expect(WebFungibleToken.fromJson(_json({'decimal_places': 2})).decimalPlaces, 2);
  });

  test('is null when Spyglass leaves it out, so the node judges the decimals', () {
    expect(WebFungibleToken.fromJson(_json()).decimalPlaces, isNull);
  });
}
