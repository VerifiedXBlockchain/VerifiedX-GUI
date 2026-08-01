import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/toast.dart';
import '../../../core/services/base_service.dart';
import '../models/tokenized_bitcoin.dart';
import '../models/withdrawal_result.dart';

const _tag = '[vBTC-V2]';

void _log(String method, String message, [Map<String, dynamic>? json]) {
  final prefix = '$_tag $method';
  if (json != null) {
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('$prefix $message:\n${encoder.convert(json)}');
  } else {
    debugPrint('$prefix $message');
  }
}

class VbtcV2Service extends BaseService {
  VbtcV2Service() : super(apiBasePathOverride: "/vbtcapi/vbtc");

  /// FROST signing is budgeted 180s on the web wallet. Anything shorter here
  /// times out the client while the CLI is still legitimately signing, which
  /// surfaces a successful withdrawal as a failure.
  static const _completeWithdrawalTimeoutMs = 180000;

  /// Fetch V2 contracts from the CLI endpoint.
  /// Returns them as [TokenizedBitcoin] with version=2 so the UI
  /// can merge them into the unified token list.
  Future<List<TokenizedBitcoin>> getContractList({String? address}) async {
    const method = 'GetContractList';
    final path = address != null ? '/GetContractList/$address' : '/GetContractList';

    try {
      final result = await getJson(
        path,
        cleanPath: false,
      );

      if (result['Success'] != true) {
        _log(method, 'FAILED: ${result['Message']}');
        return [];
      }

      final rawList = result['Contracts'] ?? result['ContractList'] ?? result['Result'];
      if (rawList == null || rawList is! List) {
        return [];
      }

      final List<Map<String, dynamic>> parsed = [];
      for (final c in rawList) {
        try {
          parsed.add(Map<String, dynamic>.from(c));
        } catch (e) {
          _log(method, 'Failed to parse V2 contract: $e');
        }
      }

      // GetContractList carries no per-address figure, so spendable balances
      // are fetched alongside it. One request per contract against the local
      // node.
      //
      // Only ever for the address the caller named. Falling back to the
      // contract's OwnerAddress would put the OWNER's spendable figure in
      // `myBalance`, which is the current wallet's field — the same wrong-holder
      // balance this lookup exists to fix, just sourced differently. With no
      // address there is nothing correct to show, so it stays 0.
      final List<double?> spendable = address == null
          ? List<double?>.filled(parsed.length, null)
          : await Future.wait(
              parsed.map(
                (c) => getSpendableBalance(
                  address: address,
                  scUid: c['SmartContractUID'] ?? c['SmartContractUid'] ?? '',
                ),
              ),
            );

      final List<TokenizedBitcoin> tokens = [];
      for (int i = 0; i < parsed.length; i++) {
        final c = parsed[i];
        try {
          final token = TokenizedBitcoin(
            id: (c['Id'] ?? 0).toDouble(),
            smartContractUid: c['SmartContractUID'] ?? c['SmartContractUid'] ?? '',
            rbxAddress: c['OwnerAddress'] ?? c['RBXAddress'] ?? '',
            btcAddress: c['DepositAddress'],
            balance: (c['Balance'] ?? 0).toDouble(),
            // 0 rather than the contract balance when the lookup failed:
            // blocking a transfer is recoverable, offering a balance that is
            // not there is not.
            myBalance: spendable[i] ?? 0,
            tokenName: c['Name'] ?? c['TokenName'] ?? 'vBTC',
            tokenDescription: c['Description'] ?? c['TokenDescription'] ?? '',
            smartContractMainId: (c['SmartContractMainId'] ?? 0).toDouble(),
            isPublished: c['IsPublished'] ?? true,
            version: 2,
            activeWithdrawalRequestHash: c['ActiveWithdrawalRequestHash'],
            activeWithdrawalBtcDestination: c['ActiveWithdrawalBTCDestination'],
            activeWithdrawalAmount: (c['ActiveWithdrawalAmount'] as num?)?.toDouble(),
            withdrawalStatus: c['WithdrawalStatus'] ?? 0,
          );
          tokens.add(token);
        } catch (e) {
          _log(method, 'Failed to parse V2 contract: $e');
        }
      }

      return tokens;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      return [];
    }
  }

  /// What [address] can actually spend of [scUid], or null if it could not be
  /// determined.
  ///
  /// `GetContractList` reports only `Balance` — the confirmed BTC sitting in
  /// the contract's Taproot deposit address. That is a property of the
  /// contract, not of any one holder: it ignores the owner's own vBTC ledger
  /// entries, counts nothing for a non-owner who was transferred vBTC, and
  /// includes amounts already committed to a withdrawal in flight.
  /// `GetVBTCBalance` is the endpoint that resolves all three per address.
  Future<double?> getSpendableBalance({
    required String address,
    required String scUid,
  }) async {
    const method = 'GetVBTCBalance';

    if (address.isEmpty || scUid.isEmpty) {
      _log(method, 'Skipped: address or scUid missing');
      return null;
    }

    try {
      final result = await getJson(
        "/GetVBTCBalance/$address/$scUid",
        cleanPath: false,
      );

      if (result['Success'] != true) {
        _log(method, 'FAILED for $address / $scUid: ${result['Message']}');
        return null;
      }

      // AvailableBalance is the total less anything locked in an incomplete
      // withdrawal request for this address.
      final available = (result['AvailableBalance'] as num?)?.toDouble();
      if (available == null) {
        _log(method, 'No AvailableBalance in response for $address / $scUid');
        return null;
      }

      return available;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      return null;
    }
  }

  Future<String?> initiateCeremony(String ownerAddress) async {
    const method = 'InitiateMPCCeremony';
    _log(method, 'REQUEST POST /InitiateMPCCeremony/$ownerAddress');

    try {
      final result = await postJson(
        "/InitiateMPCCeremony/$ownerAddress",
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = result['data'];
      _log(method, 'RESPONSE', data);

      if (data['Success'] == true) {
        _log(method, 'Ceremony initiated — ceremonyId: ${data['CeremonyId']}');
        return data['CeremonyId'];
      }

      _log(method, 'FAILED: ${data['Message']}');
      Toast.error(data['Message'] ?? "Failed to initiate ceremony.");
      return null;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      Toast.error(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCeremonyStatus(String ceremonyId) async {
    const method = 'GetCeremonyStatus';
    _log(method, 'REQUEST GET /GetCeremonyStatus/$ceremonyId');

    try {
      final result = await getJson(
        "/GetCeremonyStatus/$ceremonyId",
        cleanPath: false,
      );

      _log(method, 'RESPONSE', result);

      if (result['Success'] == true) {
        _log(method, 'Status: ${result['Status']} | Progress: ${result['ProgressPercentage']}%');
        return result;
      }

      _log(method, 'FAILED: ${result['Message']}');
      Toast.error(result['Message'] ?? "Failed to get ceremony status.");
      return null;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
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
    const method = 'CreateVBTCContract';
    final params = {
      'OwnerAddress': ownerAddress,
      'Name': name,
      'Description': description,
      'Ticker': ticker,
      'CeremonyId': ceremonyId,
    };

    _log(method, 'REQUEST POST /CreateVBTCContract', params);

    try {
      final result = await postJson(
        "/CreateVBTCContract",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = result['data'];
      _log(method, 'RESPONSE', data);

      if (data['Success'] == true) {
        final hash = data['TransactionHash'] ?? data['Hash'];
        if (hash != null) {
          _log(method, 'Contract created — hash: $hash | scUid: ${data['SmartContractUID']}');
          return hash;
        }
        _log(method, 'Success but no transaction hash in response');
      }

      _log(method, 'FAILED: ${data['Message']}');
      Toast.error(data['Message'] ?? "Failed to create contract.");
      return null;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
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
    const method = 'TransferVBTC';
    final params = {
      'SmartContractUID': scUid,
      'FromAddress': fromAddress,
      'ToAddress': toAddress,
      'Amount': amount,
    };

    _log(method, 'REQUEST POST /TransferVBTC', params);

    try {
      final response = await postJson(
        "/TransferVBTC",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = response['data'];
      _log(method, 'RESPONSE', data);

      if (data['Success'] == true) {
        _log(method, 'Transfer succeeded — txHash: ${data['TransactionHash']}');
        return data['TransactionHash'];
      }

      _log(method, 'FAILED: ${data['Message']}');
      Toast.error(data['Message'] ?? "Failed to transfer vBTC.");
      return null;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      Toast.error(e.toString());
      return null;
    }
  }

  /// Transfer ownership of a vBTC V2 smart contract to a new address.
  Future<bool> transferOwnership({
    required String scUid,
    required String toAddress,
  }) async {
    const method = 'TransferOwnership';
    _log(method, 'REQUEST GET /TransferOwnership/$scUid/$toAddress');

    try {
      final result = await getJson(
        "/TransferOwnership/$scUid/$toAddress",
        cleanPath: false,
        inspect: true,
      );

      _log(method, 'RESPONSE', result);

      if (result['Success'] == true) {
        _log(method, 'Ownership transfer started');
        return true;
      }

      _log(method, 'FAILED: ${result['Message']}');
      Toast.error(result['Message'] ?? "Failed to transfer ownership.");
      return false;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
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
    const method = 'RequestWithdrawal';
    final params = {
      'SmartContractUID': scUid,
      'RequestorAddress': requestorAddress,
      'BTCAddress': btcAddress,
      'Amount': amount,
      'FeeRate': feeRate,
    };

    _log(method, 'REQUEST POST /RequestWithdrawal', params);

    try {
      final response = await postJson(
        "/RequestWithdrawal",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = response['data'];
      _log(method, 'RESPONSE', data);

      if (data['Success'] == true) {
        _log(method, 'Withdrawal requested — requestHash: ${data['RequestHash']} | status: ${data['Status']}');
        return WithdrawalResult(
          success: true,
          message: data['Message'],
          requestHash: data['RequestHash'],
          status: data['Status'],
        );
      }

      _log(method, 'FAILED: ${data['Message']}');
      return WithdrawalResult(
        success: false,
        message: data['Message'] ?? "Failed to request withdrawal.",
      );
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
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
    const method = 'CompleteWithdrawal';
    final params = {
      'SmartContractUID': scUid,
      'WithdrawalRequestHash': withdrawalRequestHash,
    };

    _log(method, 'REQUEST POST /CompleteWithdrawal (timeout: ${_completeWithdrawalTimeoutMs ~/ 1000}s)', params);

    try {
      final stopwatch = Stopwatch()..start();
      final response = await postJson(
        "/CompleteWithdrawal",
        params: params,
        cleanPath: false,
        inspect: true,
        timeout: _completeWithdrawalTimeoutMs,
      );
      stopwatch.stop();

      final Map<String, dynamic> data = response['data'];
      _log(method, 'RESPONSE (${stopwatch.elapsedMilliseconds}ms)', data);

      if (data['Success'] == true) {
        _log(method, 'Withdrawal complete — vfxTx: ${data['VFXTransactionHash']} | btcTx: ${data['BTCTransactionHash']}');
        return WithdrawalResult(
          success: true,
          message: data['Message'],
          requestHash: withdrawalRequestHash,
          vfxTransactionHash: data['VFXTransactionHash'],
          btcTransactionHash: data['BTCTransactionHash'],
          status: data['Status'],
        );
      }

      _log(method, 'FAILED: ${data['Message']}');
      return WithdrawalResult(
        success: false,
        message: data['Message'] ?? "Failed to complete withdrawal.",
        requestHash: withdrawalRequestHash,
      );
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      final timedOut = _isTimeout(e);
      return WithdrawalResult(
        success: false,
        message: timedOut
            ? "Timed out waiting for the signing ceremony to finish. The withdrawal may still be in progress."
            : e.toString(),
        requestHash: withdrawalRequestHash,
        timedOut: timedOut,
      );
    }
  }

  static bool _isTimeout(Object e) {
    if (e is! DioException) return false;
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  /// Whether [withdrawalRequestHash] is still awaiting settlement.
  ///
  /// Returns null when this particular request's fate could not be
  /// established — callers must not treat that as settled.
  ///
  /// `ActiveWithdrawalRequestHash` alone cannot answer this. It is a single
  /// contract-wide slot that any holder's new request overwrites, and a
  /// cancellation clears it outright, so finding some other hash there says
  /// nothing about this one. Completion is the only event that records the
  /// request hash per request, in `WithdrawalHistory`, so that is what a
  /// "settled" verdict is built on.
  Future<bool?> isWithdrawalStillActive({
    required String scUid,
    required String withdrawalRequestHash,
  }) async {
    const method = 'IsWithdrawalStillActive';

    try {
      final result = await getJson(
        "/GetContractDetails/$scUid",
        cleanPath: false,
      );

      if (result['Success'] != true || result['Contract'] == null) {
        _log(method, 'Could not read contract state for scUid: $scUid — ${result['Message']}');
        return null;
      }

      final contract = Map<String, dynamic>.from(result['Contract']);

      final history = contract['WithdrawalHistory'];
      if (history is List) {
        final completed = history.any(
          (h) => h is Map && h['RequestHash'] == withdrawalRequestHash,
        );
        if (completed) {
          _log(method, 'Request $withdrawalRequestHash is in the withdrawal history — settled');
          return false;
        }
      }

      final active = contract['ActiveWithdrawalRequestHash'];
      if (active is String && active == withdrawalRequestHash) {
        _log(method, 'Request $withdrawalRequestHash is still the active withdrawal');
        return true;
      }

      // Not completed and not the active request: it was cancelled, or another
      // holder's request took the slot. Either way this cannot be called
      // settled, and reporting it as such would tell the user a withdrawal
      // finished when it did not.
      _log(method, 'Fate of $withdrawalRequestHash is unknown — active slot holds: $active');
      return null;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      return null;
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
    const method = 'CancelWithdrawal';
    final params = {
      'SmartContractUID': scUid,
      'OwnerAddress': ownerAddress,
      'WithdrawalRequestHash': withdrawalRequestHash,
      'BTCTxHash': btcTxHash,
      'FailureProof': failureProof,
    };

    _log(method, 'REQUEST POST /CancelWithdrawal', params);

    try {
      final response = await postJson(
        "/CancelWithdrawal",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = response['data'];
      _log(method, 'RESPONSE', data);

      if (data['Success'] == true) {
        _log(method, 'Cancellation submitted');
        return true;
      }

      _log(method, 'FAILED: ${data['Message']}');
      Toast.error(data['Message'] ?? "Failed to cancel withdrawal.");
      return false;
    } catch (e, st) {
      _log(method, 'EXCEPTION: $e\n$st');
      Toast.error(e.toString());
      return false;
    }
  }
}
