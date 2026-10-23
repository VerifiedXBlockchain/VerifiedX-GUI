import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_transaction.dart';

const me = 'tb1qg8d0w2gsu8qdwrfvxjge3wrvum4efj8lhq45a2';
const sender = 'tb1qz86xnncwrec67emcdgh5kxaxaqryhmnqxyzkeh';
const sendersChange = 'tb1q6qchgu4t35jueddq49a59ezsvfu7x9rhlsvznz';
const vault = 'tb1p4w5kwf2mh7vv2h3hwv6npnq9mq32djvj07kt5y45uk0xqkwexaysfzzns8';

BtcWebVout _out(String address, int value) =>
    BtcWebVout(scriptpubkey: '00', scriptpubkeyAsm: 'OP_0', scriptpubkeyType: 'v0_p2wpkh', scriptpubkeyAddress: address, value: value);

BtcWebTransaction _tx({required String from, required int input, required List<BtcWebVout> outputs, int fee = 282}) => BtcWebTransaction(
      txid: 'tx',
      vin: [BtcWebVin(txid: 'prev', vout: 0, prevout: _out(from, input), sequence: 0)],
      vout: outputs,
      size: 140,
      weight: 560,
      fee: fee,
      status: const BtcWebTxStatus(confirmed: true),
    );

void main() {
  group('BtcWebTransaction.amountFor', () {
    test('an incoming payment whose sender keeps its change at a fresh address is what I received', () {
      // TC-BTC-017: 0.002 to me, 1.49599436 change to the sender's new address.
      final tx = _tx(from: sender, input: 149799718, outputs: [_out(me, 200000), _out(sendersChange, 149599436)]);

      expect(tx.amount(), 149799436);
      expect(tx.amountFor(me), 200000);
    });

    test('a send of mine is what went to others, without my change', () {
      final tx = _tx(from: me, input: 200000, outputs: [_out(sender, 2000), _out(me, 197718)]);

      expect(tx.amountFor(me), 2000);
    });

    test('a vault deposit from me is the deposit', () {
      final tx = _tx(from: me, input: 200000, outputs: [_out(vault, 10000), _out(me, 189718)]);

      expect(tx.amountFor(me), 10000);
    });

    test('a vault payout to me is the payout', () {
      final tx = _tx(from: vault, input: 10000, outputs: [_out(me, 768), _out(vault, 8000)], fee: 1232);

      expect(tx.amountFor(me), 768);
    });

    test('with no address of mine in it, or no address known, it is the old figure', () {
      final tx = _tx(from: vault, input: 10000, outputs: [_out(sender, 768), _out(vault, 8000)], fee: 1232);

      expect(tx.amountFor(me), tx.amount());
      expect(tx.amountFor(null), tx.amount());
    });
  });
}
