import 'models/transaction.dart';
import 'models/web_transaction.dart';

class TxHelper {
  final Transaction? tx;
  final WebTransaction? webTx;

  late final int type;

  TxHelper({this.tx, this.webTx}) {
    if (tx != null) {
      type = tx!.type;
    } else if (webTx != null) {
      type = webTx!.type;
    }
  }

  static List<TxHelper> getAllTypes() {
    final List<Transaction> types = [];
    for (var i = 0; i <= 38; i++) {
      types.add(
        Transaction(hash: "", toAddress: "", fromAddress: "", type: i, amount: 0, nonce: 0, fee: 0, timestamp: 0, nftData: null, height: 0),
      );
    }
    return types.map((t) => TxHelper(tx: t)).toList();
  }

  String get typeName {
    switch (type) {
      case 0:
        return "Tx";
      case 1:
        return "Node";
      case 2:
        return "NFT Mint";
      case 3:
        return "NFT Tx";
      case 4:
        return "NFT Burn";
      case 5:
        return "NFT Sale";
      case 6:
        return "ADNR";
      case 7:
        return "DST Registration";
      case 8:
        return "Topic Create";
      case 9:
        return "Topic Vote";
      case 10:
        return "Vault";
      case 11:
        return "Smart Contract Mint";
      case 12:
        return "Smart Contract TX";
      case 13:
        return "Smart Contract Burn";
      case 14:
        return "Fungible Token Mint";
      case 15:
        return "Fungible Token TX";
      case 16:
        return "Fungible Token Burn";
      case 17:
        return "vBTC Mint";
      case 18:
        return "vBTC TX";
      case 19:
        return "vBTC Burn";
      case 20:
        return "vBTC Withdrawal (Arb)";
      case 21:
        return "vBTC Withdrawal (Owner)";
      case 22:
        return "vBTC V2 Validator Register";
      case 23:
        return "vBTC V2 Validator Heartbeat";
      case 24:
        return "vBTC V2 Validator Exit";
      case 25:
        return "vBTC V2 Contract Create";
      case 26:
        return "vBTC V2 Transfer";
      case 27:
        return "vBTC V2 Withdrawal Request";
      case 28:
        return "vBTC V2 Withdrawal Complete";
      case 29:
        return "vBTC V2 Withdrawal Cancel";
      case 30:
        return "vBTC V2 Withdrawal Vote";
      case 31:
        return "VFX Shield";
      case 32:
        return "VFX Unshield";
      case 33:
        return "VFX Private Transfer";
      case 34:
        return "vBTC V2 Shield";
      case 35:
        return "vBTC V2 Unshield";
      case 36:
        return "vBTC V2 Private Transfer";
      case 37:
        return "vBTC V2 Bridge Lock";
      case 38:
        return "vBTC V2 Bridge Unlock";
      default:
        return type.toString();
    }
  }
}
