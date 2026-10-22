import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/btc/models/btc_account.dart';
import 'package:rbx_wallet/features/btc/providers/btc_account_list_provider.dart';

const selected = 'tb1qpy9ngm474wy0n5e96ykqevmgf6hdps06t0gntw';
const other = 'tb1qotheraccountaddress0000000000000000000';

/// A session with the BTC account selected while it held nothing, that never
/// launches the CLI.
class StubSession extends SessionProvider {
  StubSession(Ref ref)
      : super(ref, SessionModel(cliStarted: true, btcSelected: true, currentBtcAccount: BtcAccount(address: selected, balance: 0)));

  @override
  Future<void> init(bool inLoop) async {}
}

/// The account list without the CLI; [reload] stands in for a refresh.
class FakeBtcAccountList extends BtcAccountList {
  @override
  List<BtcAccount> build() => [];

  void reload(List<BtcAccount> accounts) => state = accounts;
}

void main() {
  group('btcAccountRefreshedFromList', () {
    test('takes the balance the list now shows for the selected account', () {
      final refreshed = btcAccountRefreshedFromList(BtcAccount(address: selected), [
        BtcAccount(address: other, balance: 1),
        BtcAccount(address: selected, balance: 0.0005),
      ]);
      expect(refreshed!.balance, 0.0005);
    });

    test('keeps the keys the node gave out at creation, which listings omit', () {
      final refreshed = btcAccountRefreshedFromList(
        BtcAccount(address: selected, privateKey: 'priv', wifKey: 'wif'),
        [BtcAccount(address: selected, balance: 0.0005)],
      );
      expect(refreshed!.privateKey, 'priv');
      expect(refreshed.wifKey, 'wif');
    });

    test('nothing to do when nothing changed, nothing is selected, or the account is gone', () {
      expect(btcAccountRefreshedFromList(BtcAccount(address: selected, balance: 1), [BtcAccount(address: selected, balance: 1)]), isNull);
      expect(btcAccountRefreshedFromList(null, [BtcAccount(address: selected)]), isNull);
      expect(btcAccountRefreshedFromList(BtcAccount(address: selected), [BtcAccount(address: other)]), isNull);
    });
  });

  test('the selected BTC account follows the list when its funding confirms', () {
    final container = ProviderContainer(overrides: [
      sessionProvider.overrideWith((ref) => StubSession(ref)),
      btcAccountListProvider.overrideWith(() => FakeBtcAccountList()),
    ]);
    addTearDown(container.dispose);
    expect(container.read(sessionProvider).currentBtcAccount!.balance, 0);

    (container.read(btcAccountListProvider.notifier) as FakeBtcAccountList).reload([BtcAccount(address: selected, balance: 0.0005)]);

    expect(container.read(sessionProvider).currentBtcAccount!.balance, 0.0005);
  });
}
