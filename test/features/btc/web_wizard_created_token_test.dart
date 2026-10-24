import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/providers/web_tokenized_btc_onboard_provider.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_vbtc_token.dart';
import 'package:rbx_wallet/features/nft/models/web_nft.dart';

const _owner = 'xOwner';

BtcWebVbtcToken _vault(String scIdentifier, String deposit, {double balance = 0}) => BtcWebVbtcToken(
      name: scIdentifier,
      description: '',
      addresses: const {},
      address: _owner,
      scIdentifier: scIdentifier,
      ownerAddress: _owner,
      imageUrl: '',
      depositAddress: deposit,
      globalBalance: balance,
      createdAt: DateTime.utc(2026, 10, 23),
      nft: WebNft.empty(),
      version: 2,
    );

void main() {
  // The account already owns an older (legacy after 9.0) vault, listed first,
  // when the web wizard creates a new one.
  final legacy = _vault('legacy:1', 'bc1qlegacy', balance: 0.0005);
  final created = _vault('new:1', 'bc1pnewvault');

  test("an account that already owns a vault gets the wizard's new vault, not its first one", () {
    expect(webWizardCreatedToken([legacy, created], scIdentifier: 'new:1'), created);
  });

  test('the new vault not yet listed: keep waiting rather than take the old one', () {
    expect(webWizardCreatedToken([legacy], scIdentifier: 'new:1'), isNull);
  });

  test('an unknown created UID never matches another vault', () {
    expect(webWizardCreatedToken([legacy, created], scIdentifier: null), isNull);
    expect(webWizardCreatedToken([legacy, created], scIdentifier: ''), isNull);
  });
}
