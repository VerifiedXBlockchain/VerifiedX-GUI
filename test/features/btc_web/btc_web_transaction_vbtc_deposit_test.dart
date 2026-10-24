import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_transaction.dart';

const myAddress = 'tb1qazymy6lcwgaqfdvu34snwla73y2p8mpncrwqc2';
const depositAddress = 'tb1p4w5kwf2mh7vv2h3hwv6npnq9mq32djvj07kt5y45uk0xqkwexaysfzzns8';
const otherDepositAddress = 'tb1pcg0an9m97krr52p28ywmzxf7mnyf8kxh8r6h60vzk6uat0nytdhq4le2lq';

BtcWebVout output(String address, int value) =>
    BtcWebVout(scriptpubkey: '00', scriptpubkeyAsm: 'OP_0', scriptpubkeyType: 'v0_p2wpkh', scriptpubkeyAddress: address, value: value);

/// Pays [to] from the wallet's own address, with change back to it, the way
/// a vBTC Fund does.
BtcWebTransaction payment(String to) => BtcWebTransaction(
      txid: 'tx',
      vin: [BtcWebVin(txid: 'prev', vout: 0, prevout: output(myAddress, 50000), sequence: 0)],
      vout: [output(to, 10000), output(myAddress, 39300)],
      size: 140,
      weight: 560,
      fee: 700,
      status: const BtcWebTxStatus(confirmed: false),
    );

void main() {
  group('BtcWebTransaction.touchesAnyAddress', () {
    test("a deposit into an owned vBTC contract matches its deposit address", () {
      final deposit = payment(depositAddress);
      // What the tile used to compare: the wallet's own outputs and the first input.
      expect(deposit.toAddress([myAddress]), myAddress);
      expect(deposit.fromAddress(), myAddress);

      expect(deposit.touchesAnyAddress([otherDepositAddress, depositAddress]), isTrue);
    });

    test('a spend from a deposit address matches through its input', () {
      final withdrawal = BtcWebTransaction(
        txid: 'tx',
        vin: [BtcWebVin(txid: 'prev', vout: 0, prevout: output(depositAddress, 10000), sequence: 0)],
        vout: [output(myAddress, 9300)],
        size: 140,
        weight: 560,
        fee: 700,
        status: const BtcWebTxStatus(confirmed: true),
      );
      expect(withdrawal.touchesAnyAddress([depositAddress]), isTrue);
    });

    test('a plain BTC send matches no deposit address', () {
      expect(payment('tb1qplainrecipient0000000000000000000000').touchesAnyAddress([depositAddress]), isFalse);
      expect(payment(depositAddress).touchesAnyAddress([]), isFalse);
    });
  });
}
