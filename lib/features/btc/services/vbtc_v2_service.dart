import '../../../utils/toast.dart';
import '../../../core/services/base_service.dart';
import '../models/withdrawal_result.dart';

class VbtcV2Service extends BaseService {
  VbtcV2Service() : super(apiBasePathOverride: "/vbtcapi/vbtc");

  static final _activeWithdrawalPattern = RegExp(r'Request Hash:\s*(0x[a-fA-F0-9]+)');

  Future<String?> initiateCeremony(String ownerAddress) async {
    try {
      final result = await postJson(
        "/InitiateMPCCeremony/$ownerAddress",
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = result['data'];

      if (data['Success'] == true) {
        return data['CeremonyId'];
      }

      Toast.error(data['Message'] ?? "Failed to initiate ceremony.");
      return null;
    } catch (e) {
      print("InitiateMPCCeremony");
      print(e);
      Toast.error(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCeremonyStatus(String ceremonyId) async {
    try {
      final result = await getJson(
        "/GetCeremonyStatus/$ceremonyId",
        cleanPath: false,
      );

      if (result['Success'] == true) {
        return result;
      }

      Toast.error(result['Message'] ?? "Failed to get ceremony status.");
      return null;
    } catch (e) {
      print("GetCeremonyStatus");
      print(e);
      return null;
    }
  }

  Future<String?> createContract({
    required String ownerAddress,
    required String name,
    required String description,
    required String ticker,
    required String ceremonyId,
  }) async {
    final params = {
      'OwnerAddress': ownerAddress,
      'Name': name,
      'Description': description,
      'Ticker': ticker,
      'CeremonyId': ceremonyId,
    };

    try {
      final result = await postJson(
        "/CreateVBTCContract",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = result['data'];

      if (data['Success'] == true) {
        if (data.containsKey('Hash')) {
          return data['Hash'];
        }
      }

      Toast.error(data['Message'] ?? "Failed to create contract.");
      return null;
    } catch (e) {
      print("CreateVBTCContract");
      print(e);
      Toast.error(e.toString());
      return null;
    }
  }

  /// Transfer vBTC balance between VFX addresses.
  /// Returns the transaction hash on success, null on failure.
  Future<String?> transferVbtc({
    required String scUid,
    required String fromAddress,
    required String toAddress,
    required double amount,
  }) async {
    final params = {
      'SmartContractUID': scUid,
      'FromAddress': fromAddress,
      'ToAddress': toAddress,
      'Amount': amount,
    };

    try {
      final response = await postJson(
        "/TransferVBTC",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = response['data'];

      if (data['Success'] == true) {
        return data['TransactionHash'];
      }

      Toast.error(data['Message'] ?? "Failed to transfer vBTC.");
      return null;
    } catch (e) {
      print("TransferVBTC");
      print(e);
      Toast.error(e.toString());
      return null;
    }
  }

  /// Transfer ownership of a vBTC V2 smart contract to a new address.
  Future<bool> transferOwnership({
    required String scUid,
    required String toAddress,
  }) async {
    try {
      final result = await getJson(
        "/TransferOwnership/$scUid/$toAddress",
        cleanPath: false,
        inspect: true,
      );

      if (result['Success'] == true) {
        return true;
      }

      Toast.error(result['Message'] ?? "Failed to transfer ownership.");
      return false;
    } catch (e) {
      print("TransferOwnership");
      print(e);
      Toast.error(e.toString());
      return false;
    }
  }

  /// Request a vBTC V2 withdrawal. Returns a [WithdrawalResult] with
  /// [requestHash] on success.
  Future<WithdrawalResult> requestWithdrawal({
    required String scUid,
    required String requestorAddress,
    required String btcAddress,
    required double amount,
    required int feeRate,
  }) async {
    final params = {
      'SmartContractUID': scUid,
      'RequestorAddress': requestorAddress,
      'BTCAddress': btcAddress,
      'Amount': amount,
      'FeeRate': feeRate,
    };

    try {
      final response = await postJson(
        "/RequestWithdrawal",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = response['data'];

      if (data['Success'] == true) {
        return WithdrawalResult(
          success: true,
          message: data['Message'],
          requestHash: data['RequestHash'],
          status: data['Status'],
        );
      }

      return WithdrawalResult(
        success: false,
        message: data['Message'] ?? "Failed to request withdrawal.",
      );
    } catch (e) {
      print("RequestWithdrawal");
      print(e);
      return WithdrawalResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Complete a pending withdrawal via FROST signing.
  /// Returns a [WithdrawalResult] with both transaction hashes on success.
  Future<WithdrawalResult> completeWithdrawal({
    required String scUid,
    required String withdrawalRequestHash,
  }) async {
    final params = {
      'SmartContractUID': scUid,
      'WithdrawalRequestHash': withdrawalRequestHash,
    };

    try {
      final response = await postJson(
        "/CompleteWithdrawal",
        params: params,
        cleanPath: false,
        inspect: true,
        timeout: 120000,
      );

      final Map<String, dynamic> data = response['data'];

      if (data['Success'] == true) {
        return WithdrawalResult(
          success: true,
          message: data['Message'],
          requestHash: withdrawalRequestHash,
          vfxTransactionHash: data['VFXTransactionHash'],
          btcTransactionHash: data['BTCTransactionHash'],
          status: data['Status'],
        );
      }

      return WithdrawalResult(
        success: false,
        message: data['Message'] ?? "Failed to complete withdrawal.",
        requestHash: withdrawalRequestHash,
      );
    } catch (e) {
      print("CompleteWithdrawal");
      print(e);
      return WithdrawalResult(
        success: false,
        message: e.toString(),
        requestHash: withdrawalRequestHash,
      );
    }
  }

  /// Cancel a stuck withdrawal. Only available to the contract owner
  /// when a BTC transaction hash exists.
  Future<bool> cancelWithdrawal({
    required String scUid,
    required String ownerAddress,
    required String withdrawalRequestHash,
    required String btcTxHash,
    required String failureProof,
  }) async {
    final params = {
      'SmartContractUID': scUid,
      'OwnerAddress': ownerAddress,
      'WithdrawalRequestHash': withdrawalRequestHash,
      'BTCTxHash': btcTxHash,
      'FailureProof': failureProof,
    };

    try {
      final response = await postJson(
        "/CancelWithdrawal",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = response['data'];

      if (data['Success'] == true) {
        return true;
      }

      Toast.error(data['Message'] ?? "Failed to cancel withdrawal.");
      return false;
    } catch (e) {
      print("CancelWithdrawal");
      print(e);
      Toast.error(e.toString());
      return false;
    }
  }

  /// Combined withdraw helper: requests a withdrawal then completes it.
  /// If an active withdrawal already exists, parses the request hash from
  /// the error and proceeds to complete it.
  Future<WithdrawalResult> withdraw({
    required String scUid,
    required String requestorAddress,
    required String btcAddress,
    required double amount,
    required int feeRate,
  }) async {
    // Step 1: Request withdrawal
    final requestResult = await requestWithdrawal(
      scUid: scUid,
      requestorAddress: requestorAddress,
      btcAddress: btcAddress,
      amount: amount,
      feeRate: feeRate,
    );

    String? requestHash = requestResult.requestHash;

    if (!requestResult.success) {
      // Check if there's an existing active withdrawal we can resume
      final message = requestResult.message ?? "";
      final match = _activeWithdrawalPattern.firstMatch(message);
      if (match != null) {
        requestHash = match.group(1);
      } else {
        Toast.error(requestResult.message ?? "Failed to request withdrawal.");
        return requestResult;
      }
    }

    if (requestHash == null) {
      return const WithdrawalResult(
        success: false,
        message: "No request hash returned from withdrawal request.",
      );
    }

    // Step 2: Complete withdrawal via FROST signing
    final completeResult = await completeWithdrawal(
      scUid: scUid,
      withdrawalRequestHash: requestHash,
    );

    // Always include the requestHash in the result for retry support
    return WithdrawalResult(
      success: completeResult.success,
      message: completeResult.message,
      requestHash: requestHash,
      vfxTransactionHash: completeResult.vfxTransactionHash,
      btcTransactionHash: completeResult.btcTransactionHash,
      status: completeResult.status,
    );
  }
}
