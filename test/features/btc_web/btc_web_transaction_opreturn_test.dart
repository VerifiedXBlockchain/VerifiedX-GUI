import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc_web/models/btc_web_transaction.dart';

// Real testnet4 transaction (mempool.space /api/address/<addr>/txs) with an
// OP_RETURN output. Before the vout address became nullable this threw
// "type 'Null' is not a subtype of type 'String'" and the wallet showed an
// empty BTC history for any account with one of these in its past.
const opReturnTxJson = r'''{"txid": "63ae7426ef2053cd7fed81b832f329212e076831162c9939f33a58cb009be688", "version": 2, "locktime": 0, "vin": [{"txid": "01a9fb041b70f0f54dbf68164c8740243c69671aa13eb986b5f1f1b1f5838e14", "vout": 1, "prevout": {"scriptpubkey": "0014e889b26bf8723a04b59c8d61377fbe891413ec33", "scriptpubkey_asm": "OP_0 OP_PUSHBYTES_20 e889b26bf8723a04b59c8d61377fbe891413ec33", "scriptpubkey_type": "v0_p2wpkh", "scriptpubkey_address": "tb1qazymy6lcwgaqfdvu34snwla73y2p8mpncrwqc2", "value": 2599469322}, "scriptsig": "", "scriptsig_asm": "", "witness": ["304402206be8f29c154ca2224657514e2f175e7a9cfcce842956b1c7506830924e18933d0220207f6e1ff743c32302682c5e0570f192077f6b6b216e701b0ee3020068a6b90b01", "03858097fb40f557d2e42ea3a74204f0ae4faf817dc2459511416c76b6f4227e19"], "is_coinbase": false, "sequence": 4294967293}], "vout": [{"scriptpubkey": "00140255664f3068c0599e7cef5b4e8354d524e221dc", "scriptpubkey_asm": "OP_0 OP_PUSHBYTES_20 0255664f3068c0599e7cef5b4e8354d524e221dc", "scriptpubkey_type": "v0_p2wpkh", "scriptpubkey_address": "tb1qqf2kvnesdrq9n8nuaad5aq6565jwygwu8gudvv", "value": 2598951822}, {"scriptpubkey": "00147eb5d4f8ffec460dcf17c44bab6792ffd9dd2f83", "scriptpubkey_asm": "OP_0 OP_PUSHBYTES_20 7eb5d4f8ffec460dcf17c44bab6792ffd9dd2f83", "scriptpubkey_type": "v0_p2wpkh", "scriptpubkey_address": "tb1q066af78la3rqmnchc396keujllva6turs52749", "value": 500000}, {"scriptpubkey": "6a176661756365742e746573746e6574342e6465762074786e", "scriptpubkey_asm": "OP_RETURN OP_PUSHBYTES_23 6661756365742e746573746e6574342e6465762074786e", "scriptpubkey_type": "op_return", "value": 0}], "size": 256, "weight": 697, "sigops": 1, "fee": 17500, "status": {"confirmed": true, "block_height": 109021, "block_hash": "000000000000000013bc8faa2cc0ea83d9e9f02f20acf1717ba1ad8e683dacf1", "block_time": 1762335582}}''';

const myAddress = 'tb1q066af78la3rqmnchc396keujllva6turs52749';

void main() {
  group('BtcWebTransaction with an OP_RETURN output', () {
    final tx = BtcWebTransaction.fromJson(jsonDecode(opReturnTxJson) as Map<String, dynamic>);

    test('parses and keeps the address-less output', () {
      expect(tx.vout.length, 3);
      final opReturn = tx.vout.last;
      expect(opReturn.scriptpubkeyType, 'op_return');
      expect(opReturn.scriptpubkeyAddress, isNull);
      expect(opReturn.value, 0);
    });

    test('address lists skip the address-less output', () {
      expect(tx.toAddresses, isNot(contains(null)));
      expect(tx.toAddresses.length, 2);
      expect(tx.toAddresses, contains(myAddress));
    });

    test('amount and direction helpers still work', () {
      expect(tx.voutsToMe(myAddress).length, 1);
      expect(tx.totalValueToMe(myAddress), greaterThan(0));
      expect(tx.fromAddress(), isNotEmpty);
      expect(tx.amount(), greaterThanOrEqualTo(0));
    });
  });
}
