import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../web/models/web_recovery_details.dart';
import '../../../l10n/l10n_helper.dart';
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
    final l10n = globalL10n;
    switch (type) {
      case 0:
        return l10n.r3cTypeTx;
      case 1:
        return l10n.r3cTypeNode;
      case 2:
        if (nftDataValue('Function') == "TokenDeploy()") {
          return l10n.r3cTypeNftMintTokenized;
        }

        return l10n.r3cTypeNftMint;

      case 3:
        if (nftDataValue('Function') == "Transfer()") {
          return l10n.r3cTypeNftTransfer;
        } else if (["ChangeEvolveStateSpecific()", "Evolve()", "Devolve()"].contains(nftDataValue('Function'))) {
          return l10n.r3cTypeNftEvolution;
        }

        return l10n.r3cTypeNftTx;

      case 4:
        return l10n.r3cTypeNftBurn;
      case 5:
        if (nftDataValue('Function') == "Sale_Start()") {
          return l10n.r3cTypeNftSaleStart;
        } else if (nftDataValue('Function') == "M_Sale_start()()") {
          return l10n.r3cTypeNftSaleStartManual;
        } else if (nftDataValue('Function') == "M_Sale_Complete()") {
          return l10n.r3cTypeNftSaleCompleteManual;
        } else if (nftDataValue('Function') == "Sale_Complete()") {
          return l10n.r3cTypeNftSaleCompleteParen;
        }

        return l10n.r3cTypeNftSale;

      case 6:
        if (nftDataValue('Function') == "AdnrCreate()") {
          return l10n.r3cTypeAdnrCreate;
        } else if (nftDataValue('Function') == "AdnrTransfer()") {
          return l10n.r3cTypeAdnrTransfer;
        } else if (nftDataValue('Function') == "AdnrDelete()") {
          return l10n.r3cTypeAdnrDelete;
        } else if (nftDataValue('Function') == "BTCAdnrCreate()") {
          return l10n.r3cTypeBtcAdnrCreate;
        } else if (nftDataValue('Function') == "BTCAdnrTransfer()") {
          return l10n.r3cTypeBtcAdnrTransfer;
        } else if (nftDataValue('Function') == "BTCAdnrDelete()") {
          return l10n.r3cTypeBtcAdnrDelete;
        }

        return l10n.r3cTypeAdnr;
      case 7:
        if (nftDataValue('Function') == "DecShopCreate()") {
          return l10n.r3cTypeAuctionHouseCreate;
        } else if (nftDataValue('Function') == "DecShopUpdate()") {
          return l10n.r3cTypeAuctionHouseUpdate;
        } else if (nftDataValue('Function') == "DecShopDelete()") {
          return l10n.r3cTypeAuctionHouseDelete;
        }
        return l10n.r3cTypeDstRegistration;
      case 8:
        return l10n.r3cTypeTopicCreate;
      case 9:
        return l10n.r3cTypeTopicVote;

      case 10:
        if (nftDataValue('Function') == "CallBack()") {
          return l10n.r3cTypeVaultCallback;
        } else if (nftDataValue('Function') == "Register()") {
          return l10n.r3cTypeVaultRegister;
        } else if (nftDataValue('Function') == "Recover()") {
          return l10n.r3cTypeVaultRecover;
        }
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
        final amount = nftDataValue('Amount');
        final ticker = nftDataValue('TokenTicker');
        if (nftDataValue('Function') == "TokenMint()") {
          return "${l10n.r3cTypeFungibleMint}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }
        if (nftDataValue('Function') == "TokenBurn()") {
          return "${l10n.r3cTypeFungibleBurn}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }

        if (nftDataValue('Function') == "TokenTransfer()") {
          return "${l10n.r3cTypeFungibleTransfer}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }

        if (nftDataValue('Function') == "TokenBurn()") {
          return "${l10n.r3cTypeFungibleBurn}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }

        if (nftDataValue('Function') == "TokenContractOwnerChange()") {
          return "${l10n.r3cTypeFungibleOwnershipChange}${ticker != null ? ' ($ticker)' : ''}";
        }
        if (nftDataValue('Function') == "TokenPause()") {
          final isPause = nftDataValue('Pause') == "true";
          return "${isPause ? l10n.r3cTypeFungiblePause : l10n.r3cTypeFungibleResume}${ticker != null ? ' ($ticker)' : ''}";
        }

        if (nftDataValue('Function') == "TokenBanAddress()") {
          return "${l10n.r3cTypeFungibleBanAddress}${ticker != null ? ' ($ticker)' : ''}";
        }

        if (nftDataValue('Function') == "TokenVoteTopicCast()") {
          return "${l10n.r3cTypeFungibleVoteCast}${ticker != null ? ' ($ticker)' : ''}";
        }
        if (nftDataValue('Function') == "TokenVoteTopicCreate()") {
          return "${l10n.r3cTypeFungibleTopicCreated}${ticker != null ? ' ($ticker)' : ''}";
        }

        return l10n.r3cTypeFungibleTx;
      case 16:
        final amount = nftDataValue('Amount');
        final ticker = nftDataValue('TokenTicker');
        if (nftDataValue('Function') == "TokenBurn()") {
          return "${l10n.r3cTypeFungibleBurn}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
        }
        return l10n.r3cTypeFungibleBurn;
      case 17:
        if (data != null) {
          if (nftDataValue('Function') == "TokenDeploy()") {
            return l10n.r3cTypeFungibleDeploy;
          }
        }

        return l10n.r3cTypeTokenizationMint;
      case 18:
        final function = nftDataValue('Function');
        final amount = nftDataValue('Amount');
        if (function == "TransferCoin()") {
          return "${l10n.r3cTypeVbtcTransferCoin} ($amount vBTC)";
        }

        if (function == "Transfer()") {
          return l10n.r3cTypeVbtcTokenOwnershipTransfer;
        }
        return l10n.r3cTypeTokenizationTx;
      case 19:
        return l10n.r3cTypeTokenizationBurn;
      case 20:
        return l10n.r3cTypeTokenizationWithdrawalRequest;
      case 21:
        return l10n.r3cTypeTokenizationWithdrawalComplete;
      case 22:
        return l10n.r3cTypeValidatorRegistration;
      case 23:
        return l10n.r3cTypeValidatorHeartbeat;
      case 24:
        return l10n.r3cTypeValidatorExit;
      case 25:
        return l10n.r3cTypeVbtcContractMint;
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
      case 39:
        return l10n.r3cTypeVbtcBridgePoolUnlock;
      case 40:
        return l10n.r3cTypeVbtcBridgeExitToBtc;
      case 41:
        return l10n.r3cTypeVbtcBridgeExitToBtcComplete;
      case 42:
        return l10n.r3cTypeVbtcBridgeExitToBtcFailed;
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
