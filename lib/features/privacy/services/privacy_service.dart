import '../../../core/services/base_service.dart';
import '../models/plonk_status.dart';
import '../models/shielded_address.dart';
import '../models/shielded_balance.dart';

class PrivacyService extends BaseService {
  PrivacyService() : super(apiBasePathOverride: "/privacyapi/PrivacyV1");

  Future<PlonkStatus?> getPlonkStatus() async {
    try {
      final result = await getJson('/GetPlonkStatus');
      if (result['Success'] == true && result['Result'] != null) {
        return PlonkStatus.fromJson(result['Result']);
      }
      return null;
    } catch (e) {
      print("GetPlonkStatus error: $e");
      return null;
    }
  }

  Future<ShieldedAddress?> createShieldedAddressFromAccount({
    required String transparentAddress,
    required String walletPassword,
  }) async {
    try {
      final result = await postJson(
        '/CreateShieldedAddressFromAccount',
        params: {
          "TransparentAddress": transparentAddress,
          "WalletPassword": walletPassword,
        },
      );

      print("CreateShieldedAddressFromAccount raw response: $result");

      final data = result['data'];
      if (data == null) {
        throw Exception("No response data from server");
      }

      if (data['Success'] != true) {
        final message = data['Message'] ?? 'Unknown error';
        throw Exception(message);
      }

      if (data['Result'] == null) {
        throw Exception("Success but no Result in response");
      }

      return ShieldedAddress.fromJson(data['Result']);
    } catch (e) {
      print("CreateShieldedAddressFromAccount error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> shieldVfx({
    required String fromAddress,
    required double amount,
    required String recipientZfxAddress,
  }) async {
    try {
      final result = await postJson(
        '/ShieldVFX',
        params: {
          "FromAddress": fromAddress,
          "ShieldAmount": amount,
          "RecipientZfxAddress": recipientZfxAddress,
        },
      );

      print("ShieldVFX raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("ShieldVFX error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unshieldVfx({
    required String zfxAddress,
    required String toAddress,
    required double amount,
    required String walletPassword,
  }) async {
    try {
      final result = await postJson(
        '/UnshieldVFX',
        params: {
          "ZfxAddress": zfxAddress,
          "TransparentToAddress": toAddress,
          "TransparentAmount": amount,
          "WalletPassword": walletPassword,
        },
      );

      print("UnshieldVFX raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("UnshieldVFX error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> privateTransferVfx({
    required String zfxAddress,
    required String recipientZfxAddress,
    required double amount,
    required String walletPassword,
  }) async {
    try {
      final result = await postJson(
        '/PrivateTransferVFX',
        params: {
          "ZfxAddress": zfxAddress,
          "RecipientZfxAddress": recipientZfxAddress,
          "PaymentAmount": amount,
          "WalletPassword": walletPassword,
        },
      );

      print("PrivateTransferVFX raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("PrivateTransferVFX error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> consolidateVfx({
    required String zfxAddress,
    required String walletPassword,
  }) async {
    try {
      final result = await postJson(
        '/ConsolidateShieldedVFX',
        params: {
          "ZfxAddress": zfxAddress,
          "WalletPassword": walletPassword,
        },
      );

      print("ConsolidateShieldedVFX raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("ConsolidateShieldedVFX error: $e");
      rethrow;
    }
  }

  Future<ShieldedBalance?> getShieldedBalance(
    String zfxAddress, {
    bool includeCommitments = false,
  }) async {
    try {
      final result = await getJson(
        '/GetShieldedBalance',
        params: {
          "zfxAddress": zfxAddress,
          "includeCommitments": includeCommitments,
        },
        cleanPath: false,
      );

      print("GetShieldedBalance raw response: $result");

      if (result['Success'] == true && result['Result'] != null) {
        return ShieldedBalance.fromJson(result['Result']);
      }
      print("GetShieldedBalance: Success=${result['Success']}, Message=${result['Message']}");
      return null;
    } catch (e) {
      print("GetShieldedBalance error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> exportViewingKey({
    required String zfxAddress,
  }) async {
    try {
      final result = await postJson(
        '/ExportViewingKey',
        params: {
          "ZfxAddress": zfxAddress,
        },
      );

      final data = result['data'];
      if (data != null && data['Success'] == true && data['Result'] != null) {
        return data['Result'];
      }
      return null;
    } catch (e) {
      print("ExportViewingKey error: $e");
      return null;
    }
  }

  Future<bool> importViewingKey({
    required String zfxAddress,
    required String viewingKeyBase64,
    String? transparentAddress,
  }) async {
    try {
      final params = <String, dynamic>{
        "ZfxAddress": zfxAddress,
        "ViewingKeyBase64": viewingKeyBase64,
      };

      if (transparentAddress != null) {
        params["TransparentSourceAddress"] = transparentAddress;
      }

      final result = await postJson(
        '/ImportViewingKey',
        params: params,
      );

      final data = result['data'];
      return data != null && data['Success'] == true;
    } catch (e) {
      print("ImportViewingKey error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> scanShielded({
    required String zfxAddress,
    required int fromHeight,
    required int toHeight,
  }) async {
    try {
      final result = await postJson(
        '/ScanShielded',
        params: {
          "ZfxAddress": zfxAddress,
          "FromHeight": fromHeight,
          "ToHeight": toHeight,
        },
      );

      final data = result['data'];
      if (data != null && data['Success'] == true && data['Result'] != null) {
        return data['Result'];
      }
      return null;
    } catch (e) {
      print("ScanShielded error: $e");
      return null;
    }
  }

  Future<bool> resyncShieldedWallet({
    required String zfxAddress,
    int fromHeight = 0,
    int toHeight = 0,
  }) async {
    try {
      final result = await postJson(
        '/ResyncShieldedWallet',
        params: {
          "ZfxAddress": zfxAddress,
          "FromHeight": fromHeight,
          "ToHeight": toHeight,
        },
      );

      final data = result['data'];
      return data != null && data['Success'] == true;
    } catch (e) {
      print("ResyncShieldedWallet error: $e");
      return false;
    }
  }

  // ── vBTC Shielding Methods ──────────────────────────────────────────

  Future<Map<String, dynamic>> shieldVbtc({
    required String fromAddress,
    required String vbtcContractUid,
    required double vbtcAmount,
    required String recipientZfxAddress,
  }) async {
    try {
      final result = await postJson(
        '/ShieldVBTC',
        params: {
          "FromAddress": fromAddress,
          "VbtcContractUid": vbtcContractUid,
          "VbtcAmount": vbtcAmount,
          "RecipientZfxAddress": recipientZfxAddress,
        },
      );

      print("ShieldVBTC raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("ShieldVBTC error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unshieldVbtc({
    required String zfxAddress,
    required String walletPassword,
    required String vbtcContractUid,
    required String toAddress,
    required double vbtcAmount,
  }) async {
    try {
      final result = await postJson(
        '/UnshieldVBTC',
        params: {
          "ZfxAddress": zfxAddress,
          "WalletPassword": walletPassword,
          "VbtcContractUid": vbtcContractUid,
          "TransparentToAddress": toAddress,
          "VbtcAmount": vbtcAmount,
        },
      );

      print("UnshieldVBTC raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("UnshieldVBTC error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> privateTransferVbtc({
    required String zfxAddress,
    required String walletPassword,
    required String vbtcContractUid,
    required String recipientZfxAddress,
    required double amount,
  }) async {
    try {
      final result = await postJson(
        '/PrivateTransferVBTC',
        params: {
          "ZfxAddress": zfxAddress,
          "WalletPassword": walletPassword,
          "VbtcContractUid": vbtcContractUid,
          "RecipientZfxAddress": recipientZfxAddress,
          "PaymentAmount": amount,
        },
      );

      print("PrivateTransferVBTC raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("PrivateTransferVBTC error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> consolidateVbtc({
    required String zfxAddress,
    required String walletPassword,
    required String vbtcContractUid,
  }) async {
    try {
      final result = await postJson(
        '/ConsolidateShieldedVBTC',
        params: {
          "ZfxAddress": zfxAddress,
          "WalletPassword": walletPassword,
          "VbtcContractUid": vbtcContractUid,
        },
      );

      print("ConsolidateShieldedVBTC raw response: $result");

      final data = result['data'];
      if (data == null) throw Exception("No response data from server");
      if (data['Success'] != true) {
        throw Exception(data['Message'] ?? 'Unknown error');
      }
      return data;
    } catch (e) {
      print("ConsolidateShieldedVBTC error: $e");
      rethrow;
    }
  }

  Future<ShieldedBalance?> getShieldedVbtcBalance(
    String zfxAddress,
    String vbtcContractUid, {
    bool includeCommitments = false,
  }) async {
    try {
      final result = await getJson(
        '/GetShieldedVbtcBalance',
        params: {
          "zfxAddress": zfxAddress,
          "vbtcContractUid": vbtcContractUid,
          "includeCommitments": includeCommitments,
        },
        cleanPath: false,
      );

      print("GetShieldedVbtcBalance raw response: $result");

      if (result['Success'] == true && result['Result'] != null) {
        return ShieldedBalance.fromJson(result['Result']);
      }
      print("GetShieldedVbtcBalance: Success=${result['Success']}, Message=${result['Message']}");
      return null;
    } catch (e) {
      print("GetShieldedVbtcBalance error: $e");
      return null;
    }
  }

  Future<bool> resyncShieldedVbtc({
    required String zfxAddress,
    required String vbtcContractUid,
    int fromHeight = 0,
    int toHeight = 0,
  }) async {
    try {
      final result = await postJson(
        '/ResyncShieldedVBTC',
        params: {
          "ZfxAddress": zfxAddress,
          "VbtcContractUid": vbtcContractUid,
          "FromHeight": fromHeight,
          "ToHeight": toHeight,
        },
      );

      final data = result['data'];
      return data != null && data['Success'] == true;
    } catch (e) {
      print("ResyncShieldedVBTC error: $e");
      return false;
    }
  }
}
