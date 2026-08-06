import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import '../../../core/utils.dart';
import '../../../l10n/l10n_helper.dart';

import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionStatus {
  Pending,
  Success,
  Fail,
  Reserved,
  CalledBack,
  Recovered,
}

statusFromJson(int? status) {
  if (status == null) return null;
  if (status < 0 || status >= TransactionStatus.values.length) return null;
  return TransactionStatus.values[status];
}

@freezed
class Transaction with _$Transaction {
  const Transaction._();

  factory Transaction({
    @JsonKey(name: 'Hash') required String hash,
    @JsonKey(name: 'ToAddress') required String toAddress,
    @JsonKey(name: 'FromAddress') required String fromAddress,
    @JsonKey(name: 'TransactionType') required int type,
    @JsonKey(name: 'TransactionStatus', fromJson: statusFromJson) TransactionStatus? status,
    @JsonKey(name: 'Amount') required double amount,
    @JsonKey(name: 'Nonce') required int nonce,
    @JsonKey(name: 'Fee') required double fee,
    @JsonKey(name: 'Timestamp') required int timestamp,
    @JsonKey(name: 'Data') required dynamic nftData,
    @JsonKey(name: 'Signature') String? signature,
    @JsonKey(name: 'Height') required int height,
    @JsonKey(name: 'UnlockTime') int? unlockTime,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

  String get parseTimeStamp {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var d12 = DateFormat('MM-dd-yyyy hh:mm a').format(date);
    return d12;
  }

  String get typeLabel {
    final l10n = globalL10n;
    switch (type) {
      case 0:
        return l10n.r3cTypeTx;
      case 1:
        return l10n.r3cTypeNode;
      case 2:
        final data = parseNftData(this);
        if (data != null) {
          if (nftDataValue(data, 'Function') == "TokenDeploy()") {
            return l10n.r3cTypeNftMintTokenized;
          }
        }
        return l10n.r3cTypeNftMint;
      case 3:
        final data = parseNftData(this);
        if (data != null) {
          if (nftDataValue(data, 'Function') == "Transfer()") {
            return l10n.r3cTypeNftTransfer;
          }
        }

        return l10n.r3cTypeNftTx;
      case 4:
        return l10n.r3cTypeNftBurn;
      case 5:
        final data = parseNftData(this);
        if (data != null) {
          if (nftDataValue(data, 'Function') == "Sale_Start()") {
            return l10n.r3cTypeNftSaleStart;
          } else if (nftDataValue(data, 'Function') == "M_Sale_Start()") {
            return l10n.r3cTypeNftSaleStartManual;
          } else if (nftDataValue(data, 'Function') == "Sale_Complete()") {
            return l10n.r3cTypeNftSaleComplete;
          } else if (nftDataValue(data, 'Function') == "M_Sale_Complete()") {
            return l10n.r3cTypeNftSaleCompleteManual;
          }
        }
        return l10n.r3cTypeNftSale;
      case 6:
        final data = parseNftData(this);
        if (data != null) {
          if (nftDataValue(data, "Function") == "AdnrCreate()") {
            return l10n.r3cTypeAdnrCreate;
          }
          if (nftDataValue(data, "Function") == "AdnrTransfer()") {
            return l10n.r3cTypeAdnrTransfer;
          }

          if (nftDataValue(data, "Function") == "AdnrDelete()") {
            return l10n.r3cTypeAdnrDelete;
          }

          if (nftDataValue(data, "Function") == "BTCAdnrCreate()") {
            return l10n.r3cTypeBtcAdnrCreate;
          }
          if (nftDataValue(data, "Function") == "BTCAdnrTransfer()") {
            return l10n.r3cTypeBtcAdnrTransfer;
          }

          if (nftDataValue(data, "Function") == "BTCAdnrDelete()") {
            return l10n.r3cTypeBtcAdnrDelete;
          }
        }
        return l10n.r3cTypeAdnr;
      case 7:
        return l10n.r3cTypeDstRegistration;
      case 8:
        return l10n.r3cTypeTopicCreate;
      case 9:
        return l10n.r3cTypeTopicVote;
      case 10:
        final data = parseNftData(this);
        if (data != null) {
          if (nftDataValue(data, 'Function') == "CallBack()") {
            return l10n.r3cTypeVaultCallback;
          } else if (nftDataValue(data, 'Function') == "Register()") {
            return l10n.r3cTypeVaultRegister;
          } else if (nftDataValue(data, 'Function') == "Recover()") {
            return l10n.r3cTypeVaultRecover;
          }
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
        final data = parseNftData(this);
        if (data != null) {
          final amount = nftDataValue(data, 'Amount');
          final ticker = nftDataValue(data, 'TokenTicker');
          if (nftDataValue(data, 'Function') == "TokenMint()") {
            return "${l10n.r3cTypeFungibleMint}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
          }
          if (nftDataValue(data, 'Function') == "TokenBurn()") {
            return "${l10n.r3cTypeFungibleBurn}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
          }

          if (nftDataValue(data, 'Function') == "TokenTransfer()") {
            return "${l10n.r3cTypeFungibleTransfer}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
          }

          if (nftDataValue(data, 'Function') == "TokenBurn()") {
            return "${l10n.r3cTypeFungibleBurn}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
          }

          if (nftDataValue(data, 'Function') == "TokenContractOwnerChange()") {
            return "${l10n.r3cTypeFungibleOwnershipChange}${ticker != null ? ' ($ticker)' : ''}";
          }
          if (nftDataValue(data, 'Function') == "TokenPause()") {
            final isPause = nftDataValue(data, 'Pause') == "true";
            return "${isPause ? l10n.r3cTypeFungiblePause : l10n.r3cTypeFungibleResume}${ticker != null ? ' ($ticker)' : ''}";
          }

          if (nftDataValue(data, 'Function') == "TokenBanAddress()") {
            return "${l10n.r3cTypeFungibleBanAddress}${ticker != null ? ' ($ticker)' : ''}";
          }

          if (nftDataValue(data, 'Function') == "TokenVoteTopicCast()") {
            return "${l10n.r3cTypeFungibleVoteCast}${ticker != null ? ' ($ticker)' : ''}";
          }
          if (nftDataValue(data, 'Function') == "TokenVoteTopicCreate()") {
            return "${l10n.r3cTypeFungibleTopicCreated}${ticker != null ? ' ($ticker)' : ''}";
          }
        }

        return l10n.r3cTypeFungibleTx;

      case 16:
        final data = parseNftData(this);
        if (data != null) {
          final amount = nftDataValue(data, 'Amount');
          final ticker = nftDataValue(data, 'TokenTicker');
          if (nftDataValue(data, 'Function') == "TokenBurn()") {
            return "${l10n.r3cTypeFungibleBurn}${amount != null ? ' ($amount${ticker != null ? ' $ticker' : ''})' : ''}";
          }
        }
        return l10n.r3cTypeFungibleBurn;
      case 17:
        final data = parseNftData(this);
        if (data != null) {
          if (nftDataValue(data, 'Function') == "TokenDeploy()") {
            return l10n.r3cTypeFungibleDeploy;
          }
        }
        return l10n.r3cTypeTokenizationMint;
      case 18:
        final data = parseNftData(this);
        if (data != null) {
          final function = nftDataValue(data, 'Function');
          final amount = nftDataValue(data, 'Amount');
          if (function == "TransferCoin()") {
            return "${l10n.r3cTypeVbtcTransferCoin} ($amount vBTC)";
          }

          if (function == "Transfer()") {
            return l10n.r3cTypeVbtcTokenOwnershipTransfer;
          }

          if (function == "TransferCoinMulti()") {
            if (amount != null) {
              return "${l10n.r3cTypeVbtcBulkTransfer} ($amount vBTC)";
            }
            return l10n.r3cTypeVbtcBulkTransfer;
          }
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
      case 25:
        return l10n.r3cTypeVbtcContractMint;
      case 26:
        final data = parseNftData(this);
        if (data != null) {
          final amount = nftDataValue(data, 'Amount');
          if (amount != null) {
            return "${l10n.r3cTypeVbtcTransfer} ($amount vBTC)";
          }
        }
        return l10n.r3cTypeVbtcTransfer;
      case 27:
        final data = parseNftData(this);
        if (data != null) {
          final amount = nftDataValue(data, 'Amount');
          if (amount != null) {
            return "${l10n.r3cTypeVbtcWithdrawalRequest} ($amount vBTC)";
          }
        }
        return l10n.r3cTypeVbtcWithdrawalRequest;
      case 28:
        final data = parseNftData(this);
        if (data != null) {
          final amount = nftDataValue(data, 'Amount');
          if (amount != null) {
            return "${l10n.r3cTypeVbtcWithdrawalComplete} ($amount vBTC)";
          }
        }
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

  bool get isVbtcTx {
    if (type == 17) {
      final data = parseNftData(this);
      if (data != null) {
        if (nftDataValue(data, 'MD5List') != null) {
          return true;
        }

        if (nftDataValue(data, 'Function') == "TokenDeploy()") {
          return false;
        }

        if (nftDataValue(data, 'Function') == "Mint()") {
          return false;
        }
      }
      return true;
    }

    if (type == 18) {
      final data = parseNftData(this);
      if (data != null) {
        final function = nftDataValue(data, 'Function');

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

  String get statusLabel {
    final l10n = globalL10n;
    switch (status) {
      case TransactionStatus.Success:
        return l10n.statusSuccess;
      case TransactionStatus.Pending:
        return l10n.statusPending;
      case TransactionStatus.Fail:
        return l10n.r3cStatusFail;
      case TransactionStatus.Reserved:
        return l10n.r3cTypeVault;
      case TransactionStatus.CalledBack:
        return l10n.r3cStatusCalledBack;
      case TransactionStatus.Recovered:
        return l10n.r3cStatusRecovered;
      default:
        return "-";
    }
  }

  Color statusColor(BuildContext context) {
    switch (status) {
      case TransactionStatus.Success:
        return Theme.of(context).colorScheme.success;
      case TransactionStatus.Pending:
        return Theme.of(context).colorScheme.warning;

      case TransactionStatus.Fail:
        return Theme.of(context).colorScheme.danger;
      case TransactionStatus.Reserved:
      case TransactionStatus.CalledBack:
      case TransactionStatus.Recovered:
        return Colors.deepPurple.shade200;
      default:
        return Colors.white;
    }
  }

  Uri get explorerUrl {
    return Uri.parse("${Env.explorerWebsiteBaseUrl}/transaction/$hash");
  }

  DateTime? get unlockTimeAsDate {
    if (unlockTime == null) {
      return null;
    }
    if (status != TransactionStatus.Reserved) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(unlockTime! * 1000);
  }

  DateTime? get callbackUntil {
    if (unlockTime == null) {
      return null;
    }
    if (status != TransactionStatus.Reserved) {
      return null;
    }

    final now = DateTime.now();

    if (unlockTimeAsDate!.isBefore(now)) {
      return null;
    }

    return unlockTimeAsDate;
  }

  String get parseUnlockTimeAsDate {
    if (unlockTime == null) {
      return "-";
    }
    if (status != TransactionStatus.Reserved) {
      return "-";
    }

    var date = DateTime.fromMillisecondsSinceEpoch(unlockTime! * 1000);
    var d12 = DateFormat('MM-dd-yyyy hh:mm a').format(date);
    return d12;
  }

  bool get isFromReserveAccount {
    return fromAddress.startsWith("xRBX");
  }

  bool get isToReserveAccount {
    return toAddress.startsWith("xRBX");
  }
}
