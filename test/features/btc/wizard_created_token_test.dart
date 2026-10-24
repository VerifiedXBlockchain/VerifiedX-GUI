import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/tokenized_bitcoin.dart';
import 'package:rbx_wallet/features/btc/providers/tokenized_btc_onboard_provider.dart';

TokenizedBitcoin _vault(String uid, String deposit, {double balance = 0, int version = 2}) => TokenizedBitcoin(
      id: 0,
      smartContractUid: uid,
      rbxAddress: 'xA',
      btcAddress: deposit,
      balance: balance,
      tokenName: uid,
      tokenDescription: '',
      smartContractMainId: 0,
      isPublished: true,
      version: version,
    );

void main() {
  // TC-BTC-025 / #363: account A already owns m1 (funded) and m2 when the
  // wizard creates a third vault for it.
  final m1 = _vault('m1', 'tb1pe73cu2z9', balance: 0.0001);
  final m2 = _vault('m2', 'tb1pm2deposit');
  final created = _vault('fr-wiz', 'tb1p2qeckjxs');

  test("an account that already owns vaults gets the wizard's new vault, not its first one", () {
    expect(wizardCreatedToken([m1, m2, created], depositAddress: 'tb1p2qeckjxs'), created);
  });

  test('a legacy first vault is passed over the same way', () {
    final legacy = _vault('legacy', 'bc1qlegacy', balance: 0.5, version: 1);
    expect(wizardCreatedToken([legacy, created], depositAddress: 'tb1p2qeckjxs'), created);
  });

  test('nothing matches until the new contract is listed', () {
    expect(wizardCreatedToken([m1, m2], depositAddress: 'tb1p2qeckjxs'), isNull);
  });

  test('without the ceremony deposit address no vault is guessed', () {
    expect(wizardCreatedToken([m1, m2, created], depositAddress: null), isNull);
  });
}
