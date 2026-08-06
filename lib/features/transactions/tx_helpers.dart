import '../../l10n/l10n_helper.dart';
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
    final l10n = globalL10n;
    switch (type) {
      case 0:
        return l10n.r3cTypeTx;
      case 1:
        return l10n.r3cTypeNode;
      case 2:
        return l10n.r3cTypeNftMint;
      case 3:
        return l10n.r3cTypeNftTx;
      case 4:
        return l10n.r3cTypeNftBurn;
      case 5:
        return l10n.r3cTypeNftSale;
      case 6:
        return l10n.r3cTypeAdnr;
      case 7:
        return l10n.r3cTypeDstRegistration;
      case 8:
        return l10n.r3cTypeTopicCreate;
      case 9:
        return l10n.r3cTypeTopicVote;
      case 10:
        return l10n.r3cTypeVault;
      case 11:
        return l10n.r3cTypeSmartContractMint;
      case 12:
        return l10n.r3cTypeSmartContractTx;
      case 13:
        return l10n.r3cTypeSmartContractBurn;
      case 14:
        return l10n.r3cTypeFungibleMint;
      case 15:
        return l10n.r3cTypeFungibleTx;
      case 16:
        return l10n.r3cTypeFungibleBurn;
      case 17:
        return l10n.r3cTypeVbtcMint;
      case 18:
        return l10n.r3cTypeVbtcTx;
      case 19:
        return l10n.r3cTypeVbtcBurn;
      case 20:
        return l10n.r3cTypeVbtcWithdrawalArb;
      case 21:
        return l10n.r3cTypeVbtcWithdrawalOwner;
      case 22:
        return l10n.r3cTypeVbtcValidatorRegister;
      case 23:
        return l10n.r3cTypeVbtcValidatorHeartbeat;
      case 24:
        return l10n.r3cTypeVbtcValidatorExit;
      case 25:
        return l10n.r3cTypeVbtcContractCreate;
      case 26:
        return l10n.r3cTypeVbtcTransfer;
      case 27:
        return l10n.r3cTypeVbtcWithdrawalRequest;
      case 28:
        return l10n.r3cTypeVbtcWithdrawalComplete;
      case 29:
        return l10n.r3cTypeVbtcWithdrawalCancel;
      case 30:
        return l10n.r3cTypeVbtcWithdrawalVote;
      case 31:
        return l10n.r3cTypeVfxShield;
      case 32:
        return l10n.r3cTypeVfxUnshield;
      case 33:
        return l10n.r3cTypeVfxPrivateTransfer;
      case 34:
        return l10n.r3cTypeVbtcShield;
      case 35:
        return l10n.r3cTypeVbtcUnshield;
      case 36:
        return l10n.r3cTypeVbtcPrivateTransfer;
      case 37:
        return l10n.r3cTypeVbtcBridgeLock;
      case 38:
        return l10n.r3cTypeVbtcBridgeUnlock;
      default:
        return type.toString();
    }
  }
}
