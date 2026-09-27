import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/new_reserve_account.dart';
import '../../../utils/toast.dart';

import '../../../core/services/base_service.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../core/utils/user_error_message.dart';

class ReserveAccountService extends BaseService {
  ReserveAccountService() : super(apiBasePathOverride: "/rsapi/RSV1");

  Future<String> wallets() async {
    return await getText('/GetAllReserveAccounts');
  }

  Future<NewReserveAccount?> create(String password) async {
    if (kIsWeb) {
      //TODO: logic for web
    }

    final payload = {"Password": password, "StoreRecoveryAccount": true};
    final response = await postJson('/NewReserveAddress', params: payload);
    final data = response['data'];
    if (data != null) {
      if (data['Success'] == true) {
        if (data['ReserveAccount'] != null) {
          return NewReserveAccount.fromJson(data['ReserveAccount']);
        }
      }
    }

    Toast.error(data['Message'] ?? globalL10n.mktProblemOccurredToast);

    return null;
  }

  Future<NewReserveAccount?> restore({
    required String restoreCode,
    required String password,
    bool store = true,
    bool rescan = true,
  }) async {
    final payload = {
      "RestoreCode": restoreCode,
      "Password": password,
      "StoreRecoveryAccount": store,
      "RescanForTx": rescan,
      "OnlyRestoreRecovery": false,
    };

    try {
      final response = await postJson('/RestoreReserveAddress', params: payload);
      final data = response['data'];
      final account = restoredReserveAccountFromResponse(data);
      if (account != null) {
        return account;
      }
      Toast.error(reserveResponseErrorMessage(data));
    } catch (e) {
      print("Vault restore failed: $e");
      Toast.error(globalL10n.mktProblemOccurredToast);
    }

    return null;
  }

  // Future<Wallet?> recover({
  //   required String restoreCode,
  //   required String password,
  //   bool store = true,
  //   bool rescan = true,
  // }) async {
  //   final payload = {
  //     "RestoreCode": restoreCode,
  //     "Password": password,
  //     "StoreRecoveryAccount": store,
  //     "RescanForTx": rescan,
  //     "OnlyRestoreRecovery": true,
  //   };

  //   final response = await postJson('/RestoreReserveAddress', params: payload);
  //   print(response);
  //   print("****");
  //   final data = response['data'];
  //   if (data != null) {
  //     print(jsonEncode(data));
  //     if (data['Success'] == true) {
  //       if (data['Account'] != null) {
  //         return Wallet.fromJson(data['Account']);
  //       }
  //     }
  //   }

  //   Toast.error(data['Message'] ?? "A problem occurred.");

  //   return null;
  // }

  Future<bool> publish({required String address, required String password}) async {
    try {
      final response = await getText("/PublishReserveAccount/$address/$password", cleanPath: false);
      final data = jsonDecode(response);
      print(data);
      print("****");
      if (data['Success'] != null && data['Success'] == true) {
        return true;
      }
      OverlayToast.error(data['Message']);
      return false;
    } catch (e) {
      print("Vault activation request failed: ${e.runtimeType}");
      OverlayToast.error(globalL10n.mktProblemOccurredToast);
      return false;
    }
  }

  Future<String?> sendTx({
    required String fromAddress,
    required String toAddress,
    required double amount,
    required String password,
    int unlockDelayHours = 0,
  }) async {
    final params = {
      'FromAddress': fromAddress,
      'ToAddress': toAddress,
      'Amount': amount,
      'DecryptPassword': password,
      'UnlockDelayHours': unlockDelayHours,
    };

    try {
      final response = await postJson("/SendReserveTransaction", params: params);
      final data = response['data'];

      if (data['Success'] != null && data['Success'] == true) {
        return data['Message'];
      }
      Toast.error(data['Message']);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> callBack(String password, String txHash) async {
    try {
      final response = await getText("/CallBackReserveAccountTx/$txHash/$password", cleanPath: false);
      final data = jsonDecode(response);
      if (data['Success'] != null && data["Success"] == true) {
        return data['Hash'];
      }
      Toast.error(data['Message']);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> recoverAccount({
    required String recoveryPhrase,
    required String address,
    required String password,
  }) async {
    try {
      final response = await getText("/RecoverReserveAccountTx/$recoveryPhrase/$address/$password", cleanPath: false);
      final data = jsonDecode(response);
      if (data['Success'] != null && data["Success"] == true) {
        return data['Hash'];
      }

      Toast.error(data['Message']);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> transferFromReserveAccount({
    required String id,
    required String toAddress,
    required String fromAddress,
    required String password,
    required int delayHours,
    String? backupUrl,
  }) async {
    try {
      const url = "/ReserveTransferNFT";
      final params = {
        'FromAddress': fromAddress,
        'ToAddress': toAddress,
        'DecryptPassword': password,
        'UnlockDelayHours': delayHours - 24,
        'SmartContractUID': id,
      };

      if (backupUrl != null && backupUrl.isNotEmpty) {
        params['BackupURL'] = backupUrl;
      }

      final response = await postJson(url, timeout: 0, params: params, cleanPath: false);
      final data = response['data'];

      if (data['Success'] == true) {
        Toast.message(data['Message'] ?? globalL10n.r3dNftTransferStarted);
        return true;
      }

      print(data);

      Toast.error(data['Message']);
      return false;
    } catch (e) {
      print(e);
      Toast.error(userErrorMessage(e));
      return false;
    }
  }

  Future<bool> downloadAssets(String scId, String address, String password) async {
    try {
      final response = await getText("/GetReserveAccountNFTAssets/$scId/$address/$password", cleanPath: false);
      final data = jsonDecode(response);

      if (data['Success'] == true) {
        Toast.message(data['Message']);
        return true;
      }

      Toast.error(data['Message']);
      return false;
    } catch (e) {
      print(e);
      Toast.error(globalL10n.mktProblemOccurredToast);
      return false;
    }
  }

  Future<bool> isUnlockedV2(String address) async {
    try {
      final response = await getText("/UnlockReserveAccount/$address/0/checking", cleanPath: false);
      final data = jsonDecode(response);
      return data['AlreadyUnlocked'] == true;
    } catch (e) {
      print("Reserve unlock check failed: $e");
      return false;
    }
  }

  Future<bool> unlockV2(String address, String password) async {
    try {
      final response = await getText("/UnlockReserveAccount/$address/0/$password", cleanPath: false);
      final data = jsonDecode(response);
      return data['Success'] == true;
    } catch (e) {
      print("Reserve unlock failed: $e");
      return false;
    }
  }
}

/// The restored Vault in a `RestoreReserveAddress` response, or null when the
/// CLI refused. An undecodable restore code gets a bare `[]` instead of the
/// usual `{Success, Message}` map.
NewReserveAccount? restoredReserveAccountFromResponse(dynamic data) {
  if (data is! Map || data['Success'] != true) {
    return null;
  }
  final reserveAccount = data['ReserveAccount'];
  if (reserveAccount is! Map) {
    return null;
  }
  final result = reserveAccount['Result'];
  if (result is! Map<String, dynamic>) {
    return null;
  }
  return NewReserveAccount.fromJson(result);
}

/// The CLI's message from a failed reserve response, falling back to the
/// generic error when there is none or the response is not a map at all.
String reserveResponseErrorMessage(dynamic data) {
  if (data is Map) {
    final message = data['Message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }
  return globalL10n.mktProblemOccurredToast;
}
