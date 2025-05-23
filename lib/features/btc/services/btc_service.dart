import 'dart:convert';

import '../../../core/app_constants.dart';
import '../models/tokenized_bitcoin.dart';
import '../../smart_contracts/models/multi_asset.dart';
import '../../../utils/toast.dart';

import '../../../core/services/base_service.dart';
import '../models/btc_account.dart';
import '../models/btc_account_sync_info.dart';
import '../models/btc_address_type.dart';
import 'package:collection/collection.dart';
import '../models/btc_send_tx_result.dart';
import '../models/btc_transaction.dart';
import '../models/btc_utxo.dart';
import '../models/vbtc_input.dart';

class BtcService extends BaseService {
  BtcService() : super(apiBasePathOverride: "/btcapi/BTCV2");

  Future<bool> electrumConnectionState() async {
    try {
      final result = await getJson('/GetElectrumXState');

      if (result.containsKey("IsConnected")) {
        return result['IsConnected'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<BtcAddressType> addressType() async {
    BtcAddressType? type;

    try {
      final result = await getJson("/GetDefaultAddressType");
      if (result['Success'] == true) {
        type = BtcAddressType.values.firstWhereOrNull((t) => t.label == result['AddressType']);
      }
      return type ?? BtcAddressType.segwit;
    } catch (e) {
      print("GetDefaultAddressType");
      print(e);
      return BtcAddressType.segwit;
    }
  }

  Future<BtcAccountSyncInfo?> accountSyncInfo() async {
    try {
      final result = await getJson("/GetLastAccounySync");

      if (result["Success"] == true) {
        return BtcAccountSyncInfo(
          lastSync: DateTime.parse(result['LastChecked']),
          nextSync: DateTime.parse(result['NextCheck']),
        );
      }
      print(result["Message"]);

      return null;
    } catch (e) {
      print("GetLastAccounySync");

      print(e);
      return null;
    }
  }

  Future<BtcAccount?> createAccount() async {
    try {
      final result = await getJson("/GetNewAddress");
      if (result["Success"] == true) {
        return BtcAccount(
          id: 0,
          address: result['Address'] ?? '',
          privateKey: result['PrivateKey'] ?? '',
          wifKey: result['WifKey'] ?? '',
        );
      }
      print(result['Message']);
      return null;
    } catch (e) {
      print("GetNewAddress");

      print(e);
      return null;
    }
  }

  Future<bool> importPrivateKey(String privateKey, BtcAddressType addressType) async {
    try {
      final result = await getJson("/ImportPrivateKey/$privateKey/${addressType.value}");
      if (result["Success"] == true) {
        return true;
      }
      print(result['Message']);
      return false;
    } catch (e) {
      print("ImportPrivateKey");

      print(e);
      return false;
    }
  }

  Future<List<BtcAccount>> listAccounts([bool omitKeys = true]) async {
    try {
      final result = await getJson(
        "/GetBitcoinAccountList/${omitKeys ? 'true' : 'false'}",
        cleanPath: false,
      );
      if (result["Success"] == true) {
        if (result['BitcoinAccounts'] == null) {
          return [];
        }
        final accounts = result['BitcoinAccounts'] as List;

        return accounts.map((json) => BtcAccount.fromJson(json)).toList();
      }
      print(result['Message']);
      return [];
    } catch (e) {
      print("GetBitcoinAccountList");

      print(e);
      return [];
    }
  }

  Future<BtcAccount?> retrieveAccount(String address, {bool omitPrivateKey = true}) async {
    try {
      final result = await getJson("/GetBitcoinAccount/$address/$omitPrivateKey");
      if (result["Success"] == true) {
        return BtcAccount.fromJson(result['BitcoinAccount']);
      }
      return null;
    } catch (e) {
      print("GetBitcoinAccount");
      print(e);

      return null;
    }
  }

  Future<double?> getFee(String fromAddress, String toAddress, double amount, int feeRate) async {
    // if (Env.isTestNet) {
    //   print("Oversupplying the fee since testnet (getFee)");
    //   feeRate = 55;
    // }
    try {
      final result = await getJson("/CalculateFee/$fromAddress/$toAddress/$amount/$feeRate", cleanPath: false, inspect: true);

      if (result["Success"] == true && result['Fee'] != null) {
        final fee = double.tryParse(result['Fee']);

        if (fee != null) {
          return fee;
        }
      }

      Toast.error(result["Message"]);

      return null;
    } catch (e) {
      print("GetLastAccounySync");

      print(e);
      return null;
    }
  }

  Future<BtcSendTxResult> sendTransaction({
    required String fromAddress,
    required String toAddress,
    required double amount,
    required int feeRate,
  }) async {
    try {
      // if (Env.isTestNet) {
      //   print("Oversupplying the fee since testnet");
      //   feeRate = 55;
      // }

      final result = await getJson(
        "/SendTransaction/$fromAddress/$toAddress/$amount/$feeRate/true",
        inspect: true,
        cleanPath: true,
      );

      if (result['Success'] == true) {
        return BtcSendTxResult(
          success: true,
          message: result['Message'],
        );
      }
      return BtcSendTxResult(
        success: false,
        message: result['Message'] ?? "A Problem Occurred",
      );
    } catch (e) {
      print("SendTransaction");
      print(e);
      return BtcSendTxResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<List<BtcUtxo>> listUtxos(String address) async {
    try {
      final result = await getJson("/GetAddressUTXOList/$address", cleanPath: false);

      if (result['Success'] == true) {
        final items = (result['UTXOs'] ?? []) as List;
        return items.map((item) => BtcUtxo.fromJson(item)).toList();
      }

      print(result["Message"]);

      return [];
    } catch (e) {
      print("GetAddressUTXOList");
      print(e);
      return [];
    }
  }

  Future<List<BtcTransaction>> listTransactions(String address) async {
    try {
      final result = await getJson("/GetAddressTXList/$address", cleanPath: false);

      if (result['Success'] == true) {
        final items = (result['TXs'] ?? []) as List;
        return items.map((item) => BtcTransaction.fromJson(item)).toList();
      }

      print(result["Message"]);

      return [];
    } catch (e, st) {
      print("GetAddressTXList");
      print(e);
      return [];
    }
  }

  Future<List<BtcTransaction>> listAllTransactions() async {
    try {
      final result = await getJson("/GetBitcoinTXList/true/", cleanPath: false);

      if (result['Success'] == true) {
        final items = (result['TXs'] ?? []) as List;
        return items.map((item) => BtcTransaction.fromJson(item)).toList();
      }

      print(result["Message"]);

      return [];
    } catch (e, st) {
      print("GetAddressTXList");
      print(e);
      print(st);

      return [];
    }
  }

  Future<String?> createAdnr({
    required String address,
    required String btcAddress,
    required String name,
  }) async {
    try {
      final result = await getJson("/CreateAdnr/$address/$btcAddress/$name", cleanPath: false);

      if (result['Success'] == true) {
        if (result.containsKey('Hash')) {
          return result['Hash'];
        }
      }

      Toast.error(result['Message']);
      return null;
    } catch (e, st) {
      print(e);
      print(st);
      Toast.error();
      return null;
    }
  }

  Future<String?> transferAdnr({
    required String toRbxAddress,
    required String fromBtcAddress,
    required String toBtcAddress,
  }) async {
    try {
      final result = await getJson("/TransferAdnr/$toRbxAddress/$fromBtcAddress/$toBtcAddress", cleanPath: false);
      return null;
    } catch (e, st) {
      print(e);
      print(st);
      Toast.error();
      return null;
    }
  }

  Future<String?> deleteAdnr({
    required String btcAddress,
  }) async {
    try {
      final result = await getJson("/DeleteAdnr/$btcAddress", cleanPath: false);
      return null;
      // if (result['Result'] == "Success") {
      //   if (result.containsKey('Hash')) {
      //     return result['Hash'];
      //   }
      // }

      // Toast.error(result['Message']);
    } catch (e, st) {
      print(e);
      print(st);
      Toast.error();
      return null;
    }
  }

  Future<String?> tokenizeBtc({
    required String rbxAddress,
    String? fileLocation,
    String? name,
    String? description,
    MultiAsset? multiAsset,
  }) async {
    Map<String, dynamic> params = {
      "RBXAddress": rbxAddress,
      "Name": name ?? "vBTC Token",
      "Description": description ?? "vBTC Token",
      "FileLocation": fileLocation ?? "default",
    };

    if (multiAsset != null) {
      final List<Map<String, dynamic>> features = [];
      final f = {'FeatureName': MultiAsset.compilerEnum, 'FeatureFeatures': multiAsset.serializeForCompiler(rbxAddress)};
      features.add(f);

      params['Features'] = features;
    }

    print(jsonEncode(params));

    try {
      final result = await postJson(
        "/TokenizeBitcoin",
        params: params,
        cleanPath: false,
        inspect: true,
        timeout: 0,
      );

      final Map<String, dynamic> data = result['data'];

      print(jsonEncode(data));

      if (data.containsKey('Success') && data['Success'] == true) {
        if (data.containsKey("Hash")) {
          return data["Hash"];
        }
      }

      Toast.error(data['Message']);

      return null;
    } catch (e, st) {
      print(e);
      print(st);
      Toast.error(e.toString());
      return null;
    }
  }

  Future<List<TokenizedBitcoin>> listTokenizedBitcoins() async {
    try {
      final result = await getJson("/GetTokenizedBTCList", cleanPath: false);

      if (result.containsKey("Success") && result['Success'] == true) {
        if (result['TokenizedList'] == 'NULL' || result['TokenizedList'] == null) {
          return [];
        }
        if (result['TokenizedList']["Result"] == null) {
          return [];
        }

        final List<TokenizedBitcoin> tokens = [];

        for (final t in result['TokenizedList']["Result"]) {
          tokens.add(TokenizedBitcoin.fromJson(t));
        }

        return tokens;
      }

      print(result['Message']);

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String?> generateTokenizedBitcoinAddress(String scUid) async {
    try {
      final result = await getJson("/GenerateTokenizedAddress/$scUid", cleanPath: false);

      if (result.containsKey("Success") && result['Success'] == true) {
        return result["Address"];
      }

      print(result['Message']);
      Toast.error(result['Message']);
      return null;
    } catch (e) {
      print(e);
      Toast.error(e.toString());

      return null;
    }
  }

  Future<bool> transferTokenOwnership(String scUid, String toAddress, String? backupUrl) async {
    try {
      final url = backupUrl != null ? "/TransferOwnership/$scUid/$toAddress/$backupUrl" : "/TransferOwnership/$scUid/$toAddress";

      final result = await getJson(url, cleanPath: false);

      if (result.containsKey("Success") && result['Success'] == true) {
        return true;
      }

      Toast.error(result['Message']);
      return false;
    } catch (e) {
      Toast.error(e.toString());
      print(e);
      return false;
    }
  }

  Future<bool> transferTokenShares(String scUid, String toAddress, String fromAddress, double amount) async {
    final params = {
      'SCUID': scUid,
      'ToAddress': toAddress,
      'Amount': amount,
      'FromAddress': fromAddress,
    };
    try {
      final response = await postJson("/TransferCoin", cleanPath: false, params: params);

      final result = response['data'];
      print(result);
      print("---------");

      if (result.containsKey("Success") && result['Success'] == true) {
        return true;
      }

      print(result['Message']);
      Toast.error(result['Message']);
      return false;
    } catch (e) {
      print(e);
      Toast.error(e.toString());

      return false;
    }
  }

  Future<String?> withdrawCoin(String scUid, String toAddress, String fromAddress, double amount, int feeRate) async {
    final params = {
      'SCUID': scUid,
      'ToAddress': toAddress,
      'FromAddress': fromAddress,
      'Amount': amount,
      // 'ChosenFeeRate': feeRate,
      'ChosenFeeRate': BTC_WITHDRAWL_FEE_RATE,
    };

    print(jsonEncode(params));
    // return false;

    try {
      final response = await postJson("/WithdrawalCoin", cleanPath: false, params: params, inspect: true);

      final result = response['data'];
      print(result);

      if (result.containsKey("Success") && result['Success'] == true) {
        final hash = "${result['Message']}".replaceAll("Transaction Success. Hash: ", "");
        return hash;
      }

      print(result['Message']);
      Toast.error(result['Message']);
      return null;
    } catch (e) {
      print(e);
      Toast.error(e.toString());

      return null;
    }
  }

  Future<String?> replaceByFee(String txId, int feeRate) async {
    try {
      final result = await getJson(
        "/ReplaceByFee/$txId/$feeRate",
        cleanPath: false,
      );

      if (result.containsKey("Success") && result['Success'] == true) {
        return result['Hash'];
      }

      print(result['Message']);
      Toast.error(result['Message']);
      return null;
    } catch (e) {
      print(e);
      Toast.error(e.toString());

      return null;
    }
  }

  Future<String?> rebroadcastTx(String txId) async {
    try {
      final result = await getJson(
        "/Rebroadcast/$txId",
        cleanPath: false,
      );

      if (result.containsKey("Success") && result['Success'] == true) {
        return result['Hash'];
      }

      print(result['Message']);
      Toast.error(result['Message']);
      return null;
    } catch (e) {
      print(e);
      Toast.error(e.toString());

      return null;
    }
  }

  Future<String?> defaultImage() async {
    try {
      final result = await getJson("/GetDefaultImageBase");

      if (result["Success"] == true) {
        return result['ImageBase'];
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> transferCoinMulti(String vfxFromAddress, String vfxToAddress, List<VBtcInput> inputs) async {
    final params = {
      'fromAddress': vfxFromAddress,
      'toAddress': vfxToAddress,
      'vBTCInputs': inputs.map((input) => input.toJson()).toList(),
    };

    print("------------");
    print(jsonEncode(params));
    print("------------");

    try {
      final result = await postJson(
        '/TransferCoinMulti',
        params: params,
        cleanPath: false,
      );

      final data = result['data'];
      if (data == null) {
        Toast.error("data was null");
        return null;
      }
      print("------------");
      print(jsonEncode(result));
      print("------------");

      if (data["Success"] == true && data['Hash'] != null) {
        return data['Hash'];
      }

      Toast.error("Error: ${data['Message'] ?? "And error occurred"}");

      return null;
    } catch (e) {
      Toast.error(e.toString());
      return null;
    }
  }
}
