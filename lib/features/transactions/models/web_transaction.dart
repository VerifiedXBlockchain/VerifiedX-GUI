import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../web/models/web_recovery_details.dart';
import 'transaction.dart';

part 'web_transaction.freezed.dart';
part 'web_transaction.g.dart';

double? stringToDouble(String val) => double.tryParse(val);

@freezed
class WebTransaction with _$WebTransaction {
  const WebTransaction._();

  factory WebTransaction({
    required String hash,
    @JsonKey(name: 'to_address') required String toAddress,
    @JsonKey(name: 'from_address') required String fromAddress,
    required int type,
    @JsonKey(name: "total_amount") required double? amount,
    @JsonKey(name: "total_fee") required double? fee,
    @JsonKey(name: 'date_crafted') required DateTime date,
    @JsonKey(name: 'unlock_time') DateTime? unlockTime,
    @Default(false) bool isPending,
    // required int nonce,
    // required int timestamp,
    String? data,
    // required String signature,
    required int height,
    @JsonKey(name: "callback_details") WebTransaction? callbackDetails,
    @JsonKey(name: "recovery_details") WebRecoveryDetails? recoveryDetails,
  }) = _WebTransaction;

  factory WebTransaction.fromJson(Map<String, dynamic> json) => _$WebTransactionFromJson(json);

  Transaction toNative() {
    return Transaction(
      hash: hash,
      toAddress: toAddress,
      fromAddress: fromAddress,
      type: type,
      amount: amount ?? 0,
      nonce: 0,
      fee: fee ?? 0,
      timestamp: (date.millisecondsSinceEpoch / 1000).round(),
      nftData: data,
      height: height,
    );
  }

  String get parseTimeStamp {
    //TODO: fix this;
    return "-";
    // var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    // var d12 = DateFormat('MM-dd-yyyy hh:mm a').format(date);
    // return d12;
  }

  List<dynamic>? get subTxs {
    if (nftDataValue('Function') == "Sale_Complete()") {
      if (nftDataValue('Transactions') != null) {
        return nftDataValueList('Transactions');
      }
    }

    return null;
  }

  double? get subTxAmount {
    if (subTxs != null) {
      double amount = 0;
      for (final s in subTxs!) {
        amount += s['Amount'];
      }
      return amount;
    }

    return null;
  }

  String? get callbackHash {
    if (type != 10) {
      return null;
    }

    if (nftDataValue('Function') == "CallBack()") {
      return nftDataValue("Hash");
    }

    return null;
  }

  String get typeLabel {
    switch (type) {
      case 0:
        return "Tx";
      case 1:
        return "Node";
      case 2:
        if (nftDataValue('Function') == "TokenDeploy()") {
          return "NFT Mint (Tokenized)";
        }

        return "NFT Mint";

      case 3:
        if (nftDataValue('Function') == "Transfer()") {
          return "NFT Transfer";
        } else if (["ChangeEvolveStateSpecific()", "Evolve()", "Devolve()"].contains(nftDataValue('Function'))) {
          return "NFT Evolution";
        }

        return "NFT Tx";

      case 4:
        return "NFT Burn";
      case 5:
        if (nftDataValue('Function') == "Sale_Start()") {
          return "NFT Sale Start";
        } else if (nftDataValue('Function') == "M_Sale_start()()") {
          return "NFT Sale Start (Manual)";
        } else if (nftDataValue('Function') == "M_Sale_Complete()") {
          return "NFT Sale Complete (Manual)";
        } else if (nftDataValue('Function') == "Sale_Complete()") {
          return "NFT Sale (Complete)";
        }

        return "NFT Sale";

      case 6:
        if (nftDataValue('Function') == "AdnrCreate()") {
          return "ADNR Create";
        } else if (nftDataValue('Function') == "AdnrTransfer()") {
          return "ADNR Transfer";
        } else if (nftDataValue('Function') == "AdnrDelete()") {
          return "ADNR Delete";
        } else if (nftDataValue('Function') == "BTCAdnrCreate()") {
          return "BTC ADNR Create";
        } else if (nftDataValue('Function') == "BTCAdnrTransfer()") {
          return "BTC ADNR Transfer";
        } else if (nftDataValue('Function') == "BTCAdnrDelete()") {
          return "BTC ADNR Delete";
        }

        return "ADNR";
      case 7:
        if (nftDataValue('Function') == "DecShopCreate()") {
          return "P2P Auction House (Create)";
        } else if (nftDataValue('Function') == "DecShopUpdate()") {
          return "P2P Auction House (Update)";
        } else if (nftDataValue('Function') == "DecShopDelete()") {
          return "P2P Auction House (Delete)";
        }
        return "DST Registration";
      case 8:
        return "Topic Create";
      case 9:
        return "Topic Vote";

      case 10:
        if (nftDataValue('Function') == "CallBack()") {
          return "Vault (Callback)";
        } else if (nftDataValue('Function') == "Register()") {
          return "Vault (Register)";
        } else if (nftDataValue('Function') == "Recover()") {
          return "Vault (Recover)";
        }
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
        final amount = nftDataValue('Amount');
        final ticker = nftDataValue('TokenTicker');
        if (nftDataValue('Function') == "TokenMint()") {
          return "Fungible Token Mint${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }
        if (nftDataValue('Function') == "TokenBurn()") {
          return "Fungible Token Burn${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }

        if (nftDataValue('Function') == "TokenTransfer()") {
          return "Fungible Token Transfer${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }

        if (nftDataValue('Function') == "TokenBurn()") {
          return "Fungible Token Burn${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }

        if (nftDataValue('Function') == "TokenContractOwnerChange()") {
          return "Fungible Token Ownership Change${ticker != null ? ' ($ticker)' : ''}";
        }
        if (nftDataValue('Function') == "TokenPause()") {
          final isPause = nftDataValue('Pause') == "true";
          return "Fungible Token ${isPause ? 'Pause' : 'Resume'}${ticker != null ? ' ($ticker)' : ''}";
        }

        if (nftDataValue('Function') == "TokenBanAddress()") {
          return "Fungible Token Ban Address${ticker != null ? ' ($ticker)' : ''}";
        }

        if (nftDataValue('Function') == "TokenVoteTopicCast()") {
          return "Fungible Token Vote Cast${ticker != null ? ' ($ticker)' : ''}";
        }
        if (nftDataValue('Function') == "TokenVoteTopicCreate()") {
          return "Fungible Token Topic Created${ticker != null ? ' ($ticker)' : ''}";
        }

        return "Fungible Token TX";
      case 16:
        final amount = nftDataValue('Amount');
        final ticker = nftDataValue('TokenTicker');
        if (nftDataValue('Function') == "TokenBurn()") {
          return "Fungible Token Burn${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }
        return "Fungible Token Burn";
      case 17:
        if (data != null) {
          if (nftDataValue('Function') == "TokenDeploy()") {
            return "Fungible Token Deploy";
          }
        }

        return "Tokenization Mint";
      case 18:
        final function = nftDataValue('Function');
        final amount = nftDataValue('Amount');
        if (function == "TransferCoin()") {
          return "vBTC Transfer Coin ($amount vBTC)";
        }

        if (function == "Transfer()") {
          return "vBTC Token Ownership Transfer";
        }
        return "Tokenization TX";
      case 19:
        return "Tokenization Burn";
      case 20:
        return "Tokenization Withdrawal Request";
      case 21:
        return "Tokenization Withdrawal Complete";
      case 22:
        return "Validator Registration";
      case 23:
        return "Validator Heartbeat";
      case 24:
        return "Validator Exit";
      case 25:
        return "vBTC Contract Mint";
      case 26:
        return "vBTC Transfer";
      case 27:
        return "vBTC Withdrawal Request";
      case 28:
        return "vBTC Withdrawal Complete";
      case 29:
        return "vBTC Withdrawal Cancel";
      case 30:
        return "vBTC Withdrawal Vote";
      case 31:
        return "VFX Shield";
      case 32:
        return "VFX Unshield";
      case 33:
        return "VFX Private Transfer";
      case 34:
        return "vBTC Shield";
      case 35:
        return "vBTC Unshield";
      case 36:
        return "vBTC Private Transfer";
      case 37:
        return "vBTC Bridge Lock";
      case 38:
        return "vBTC Bridge Unlock";
      case 39:
        return "vBTC Bridge Pool Unlock";
      case 40:
        return "vBTC Bridge Exit to BTC";
      case 41:
        return "vBTC Bridge Exit to BTC Complete";
      case 42:
        return "vBTC Bridge Exit to BTC Failed";
      default:
        return type.toString();
    }
  }

  bool get isVbtcTx {
    if (type == 17) {
      final data = parseNftData();
      if (data != null) {
        if (nftDataValue('MD5List') != null) {
          return true;
        }

        if (nftDataValue('Function') == "TokenDeploy()") {
          return false;
        }

        if (nftDataValue('Function') == "Mint()") {
          return false;
        }
      }
      return true;
    }

    if (type == 18) {
      final data = parseNftData();
      if (data != null) {
        final function = nftDataValue('Function');

        if (function == "TransferCoin()") {
          return true;
        }

        if (function == "Transfer()") {
          return true;
        }
      }
    }

    // V2 vBTC transaction types (mint, transfer, withdrawal, cancel, vote, bridge)
    if (type >= 25 && type <= 30) return true;
    if (type == 37 || type == 38) return true;

    return false;
  }

  Map<String, dynamic>? parseNftData() {
    try {
      if (data == null) {
        return null;
      }

      final d = jsonDecode(data!);
      if (d is Map) {
        return d as Map<String, dynamic>;
      }

      if (d == null || d.isEmpty) {
        return null;
      }

      if (d[0] == null) {
        return null;
      }

      final Map<String, dynamic> response = d[0];

      return response;
    } catch (e, st) {
      print("Problem parsing NFT data on TX $hash");
      print(e);
      print(st);
      return null;
    }
  }

  String? nftDataValue(String key) {
    final d = parseNftData();
    if (d == null) {
      return null;
    }

    return d.containsKey(key) ? d[key].toString() : null;
  }

  double? nftDataValueDouble(String key) {
    final d = parseNftData();
    if (d == null) {
      return null;
    }

    return d.containsKey(key) && d[key] is num ? d[key] as double : null;
  }

  List<dynamic>? nftDataValueList(String key) {
    final d = parseNftData();
    if (d == null) {
      return null;
    }

    return d.containsKey(key) && d[key] is List ? d[key] as List<dynamic> : null;
  }

  bool get isPendingSettlement {
    if (unlockTime == null) {
      return false;
    }

    return unlockTime!.isAfter(DateTime.now());
  }
}
