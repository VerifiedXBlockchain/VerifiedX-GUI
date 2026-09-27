import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../metrics/models/network_metrics.dart';

import '../../../core/env.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/launched_cli.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../utils/cli_exit.dart';
import '../../wallet/models/private_key_export.dart';
import '../../block/block.dart';
import '../../genesis/models/genesis_block.dart';
import '../../node/models/node.dart';
import '../../node/models/node_info.dart';
import '../../send/send_amount.dart';

class BridgeService extends BaseService {
  Future<dynamic> status() async {
    return await getText('/CheckStatus');
  }

  Future<bool> startupPasswordRequired() async {
    try {
      final value = await getText("/CheckPasswordNeeded");
      return value == "true";
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfEncrypted() async {
    try {
      final value = await getText("/GetIsWalletEncrypted");
      return value == "true";
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfPasswordIsNeeded() async {
    final value = await getText("/GetIsEncryptedPasswordStored");
    return value == "false";
  }

  Future<String?> encryptWallet(String password) async {
    try {
      final data = await getText("/GetEncryptWallet/$password", cleanPath: false, timeout: 0);
      final response = jsonDecode(data);
      if (response['Result'] != null && response['Result'] == "Success") {
        return null;
      }
      if (response['Message'] != null) {
        return response['Message'];
      }

      return globalL10n.mktProblemOccurredToast;
    } catch (e) {
      print("Unlock Account Error");
      print(e);
      return "$e";
    }
  }

  Future<bool> unlockWallet(String password) async {
    try {
      // The first unlock after the upgrade re-wraps every legacy keystore
      // record with 600,000-iteration PBKDF2 before the node replies, which
      // can outlast the default timeout on a wallet with many addresses.
      final data = await getText("/GetDecryptWallet/$password", cleanPath: false, timeout: 0);
      final response = jsonDecode(data);

      if (response['Result'] != null && response['Result'] == "Success") {
        return true;
      }
      return false;
    } catch (e) {
      print("Unlock Account Error");
      print(e);
      return false;
    }
  }

  Future<bool> lockWallet() async {
    try {
      final data = await getText("/GetEncryptLock", cleanPath: false);
      final response = jsonDecode(data);

      if (response['Result'] != null && response['Result'] == "Success") {
        return true;
      }
      return false;
    } catch (e) {
      print("Lock Account Error");
      print(e);
      return false;
    }
  }

  Future<String> getCliVersion() async {
    return await getText("/GetCLIVersion");
  }

  Future<Map<String, dynamic>> walletInfo() async {
    try {
      final d = await getText('/GetWalletInfo');
      final a = jsonDecode(d);
      return a[0];
    } catch (e) {
      return {};
    }
  }

  Future<String> wallets() async {
    return await getText('/GetAllAddresses');
  }

  Future<String> validators() async {
    return await getText('/GetValidatorAddresses');
  }

  Future<GenesisBlock?> genesisBlock() async {
    try {
      final response = await getText("/getgenesisblock");
      final data = jsonDecode(response);
      return GenesisBlock.fromJson(data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> importPrivateKey(String key, [bool rescan = false]) async {
    final response = await getText("/ImportPrivateKey/${key.trim()}/${rescan ? 'true' : 'false'}");
    if (response == "NAC") {
      return null;
    }

    return jsonDecode(response);
  }

  Future<bool> rescanAddress(String address) async {
    try {
      final response = await getText("/RescanForTx/$address");

      final data = jsonDecode(response);
      if (data['Success'] == true) {
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Exports the VFX private key for one local [address]. The node refuses
  /// while an encrypted wallet is locked, and on an unencrypted wallet unless
  /// the API is protected by a token or password.
  Future<PrivateKeyExport> getPrivateKey(String address) async {
    try {
      final response = await getText("/GetPrivateKey/$address", cleanPath: false);
      return PrivateKeyExport.fromResponse(address, response);
    } on DioException catch (e) {
      final body = e.response?.data;
      return PrivateKeyExport.refused(address, body is String && body.trim().isNotEmpty ? body.trim() : null);
    }
  }

  /// Creates a VFX address and returns the node's JSON reply, or null after
  /// showing why the node created none.
  Future<String?> newAddress() async {
    final String response;
    try {
      response = await getText("/GetNewAddress");
    } catch (e) {
      print("GetNewAddress failed: $e");
      Toast.error();
      return null;
    }
    final refusal = newAddressRefusal(response);
    if (refusal != null) {
      Toast.error(refusal.isEmpty ? null : refusal);
      return null;
    }
    return response;
  }

  /// The reason the node gave for creating no address, or null when [response]
  /// is not a refusal. The node answers "Fail" or, since the remediation,
  /// "Fail. No address was created: <reason>"; an empty string means it gave
  /// no reason.
  static String? newAddressRefusal(String response) {
    final trimmed = response.trim();
    if (!trimmed.startsWith("Fail")) {
      return null;
    }
    return trimmed.substring("Fail".length).replaceFirst(RegExp(r'^[.:\s]+'), '').trim();
  }

  /// Extracts the tx hash from a /SendTransaction response. The CLI returns
  /// JSON ({"Result": "Success", ..., "Hash": "..."}) once broadcast; plain-
  /// text errors ("Insufficient Funds...", "FAIL...") carry no hash. Returns
  /// null when the send did not broadcast.
  static String? txHashFromResponse(String? message) {
    if (message == null) return null;
    try {
      final data = jsonDecode(message);
      if (data is Map && data['Result'] == 'Success' && data['Hash'] is String) {
        return data['Hash'];
      }
    } catch (_) {
      // Not JSON — fall through to the legacy format check.
    }
    if (message.startsWith("Success! TxId: ")) {
      return message.replaceFirst("Success! TxId: ", "").trim();
    }
    return null;
  }

  Future<String?> sendFunds({
    required double amount,
    required String to,
    required String from,
  }) async {
    final response = await getText("/SendTransaction/$from/$to/${formatSendAmount(amount)}", timeout: 0);

    if (response == "FAIL") {
      Toast.error();

      return null;
    }

    if (response == "This is not a valid VFX address to send to. Please verify again.") {
      Toast.error(response);
      return null;
    }

    return response;
  }

  Future<String> startValidating(String address, String username) async {
    return await getText("/StartValidating/$address/$username");
  }

  Future<String?> turnOnValidator(String id) async {
    final message = await getText("/TurnOnValidator/$id");

    if (message == "No Validator account has been found. Please create one.") {
      return null;
    }

    return message;
  }

  Future<bool> turnOffValidator(String id) async {
    try {
      await getText("/TurnOffValidator/$id");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getValidatorInfo(String address) async {
    try {
      final name = await getText("/GetValidatorInfo/$address");
      return name;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Block?> blockInfo(int height, Block? fallback) async {
    final response = await getText("/SendBlock/$height", cleanPath: false);
    try {
      if (response == "NNB") {
        return fallback;
      }
      final data = jsonDecode(response);
      return Block.fromJson(data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Node>> getMasterNodes() async {
    final response = await getText("/GetMasternodes");
    try {
      final items = jsonDecode(response);
      final List<Node> nodes = [];
      for (final item in items) {
        nodes.add(Node.fromJson(item));
      }
      return nodes;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<NodeInfo>> getPeerInfo() async {
    final response = await getText("/GetPeerInfo");
    try {
      final items = jsonDecode(response);
      final List<NodeInfo> nodeInfos = [];
      for (final item in items) {
        nodeInfos.add(NodeInfo.fromJson(item));
      }
      return nodeInfos;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> getDebugInfo() async {
    return await getText("/GetDebugInfo");
  }

  Future<String?> getMempool() async {
    final data = await getText("/GetMemPool");
    return data == 'null' ? null : data;
  }

  Future<bool> rollback(String id) async {
    try {
      await getText("/GetRollbackBlocks/$id");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Asks the CLI to exit and waits until it has actually gone, so the CLI
  /// gets to record a clean shutdown before the GUI terminates. If the node
  /// refuses the exit request, the CLI this session launched is terminated.
  /// Returns false if the CLI was still answering when [maxWait] ran out.
  Future<bool> killCli({Duration maxWait = const Duration(seconds: 15)}) async {
    if (!Env.launchCli) {
      return true;
    }
    return exitCli(
      sendExit: () => getText("/SendExit"),
      stillAnswering: _cliStillAnswering,
      terminateLaunchedCli: LaunchedCli.terminate,
      maxWait: maxWait,
    );
  }

  /// A credential refusal (401 while locked, 403 on a token mismatch) is an
  /// answer, so the CLI is still running; any other failure means it is gone.
  Future<bool> _cliStillAnswering() async {
    try {
      await getText("/SendExitComplete", timeout: 1000);
      return true;
    } catch (error) {
      return isCredentialRefusal(error);
    }
  }

  Future<bool> clearLog() async {
    try {
      await getText("/ClearRBXLog");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> renameValidator(String name) async {
    try {
      await getText("/ChangeValidatorName/${name.trim()}");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getHdWallet([int strength = 24]) async {
    try {
      final response = await getText("/GetHDWallet/$strength", cleanPath: false);
      final data = jsonDecode(response);
      print(data);
      if (data != null && data['Result'] != null) {
        if (data['Result'] == true) {
          if (data['Message'] != null) {
            return data['Message'];
          }
          return null;
        } else {
          if (data['Message'] != null) {
            Toast.error(data['Message']);
            return null;
          }
          Toast.error();
          return null;
        }
      }
      Toast.error();
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Restores an HD wallet from [mnumonic]. Returns null on success, or the
  /// node's reason (empty when it gave none).
  Future<String?> restoreHd(String mnumonic) async {
    try {
      final response = await getText("/GetRestoreHDWallet/${mnumonic.trim()}", cleanPath: false);
      return hdRestoreFailure(response);
    } catch (e) {
      print(e);
      return "";
    }
  }

  /// The node's reason for not restoring an HD wallet, or null when it did.
  /// It replies {Result: "<text>"}: "Mnemonic Restored..." on success, or the
  /// refusal ("HD Wallet Already Exist", "Invalid Mnemonic Entered...", the
  /// encrypted-wallet refusal), and plain "ERROR! Message: ..." on an error.
  static String? hdRestoreFailure(String response) {
    Object? data;
    try {
      data = jsonDecode(response);
    } on FormatException {
      return response.trim();
    }
    final result = data is Map<String, dynamic> ? data['Result'] : null;
    if (result is String && result.startsWith("Mnemonic Restored")) {
      return null;
    }
    return result is String ? result.trim() : "";
  }

  Future<bool> validateSendToAddress(String address) async {
    try {
      final response = await getText("/ValidateAddress/$address", cleanPath: false);

      print("---------_$response----");
      if (response.toLowerCase() == "true") {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool?> isValidating() async {
    try {
      final data = await getText("/IsValidating");
      return data.toString().toLowerCase() == 'true';
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getLatestCliFiles() async {
    try {
      final data = await getJson('/GetLatestReleaseFiles', cleanPath: false);
      if (data.containsKey('Result') && data['Result'] == "Success") {
        if (data.containsKey("Message")) {
          print(data['Message']);
          final filenames = jsonDecode(data['Message'].toString()) as List<dynamic>;
          return filenames.map((e) => e.toString()).toList();
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool?> updateCli(bool execute) async {
    if (kIsWeb) {
      return null;
    }

    final filenames = await getLatestCliFiles();
    if (filenames == null) {
      return null;
    }

    print(filenames);

    String osVersion = Platform.version;
    print("OS Version:");
    print(osVersion);
    print("********");

    String? filename;
    if (Platform.isMacOS) {
      if (osVersion.contains("macos_x64")) {
        filename = "vfx-corecli-mac-intel.zip";
      } else {
        filename = "vfx-corecli-mac-arm.zip";
      }
    } else if (Platform.isWindows) {
      filename = "vfx-corecli-win7-x64.zip";
    }

    if (filename == null) {
      return null;
    }

    if (!filenames.contains(filename)) {
      return null;
    }

    final Map<String, dynamic> data;
    try {
      // The background check (execute false) must not pop a password prompt.
      data = await getJson(
        '/GetLatestRelease/${execute ? 'true' : 'false'}/$filename',
        cleanPath: false,
        unlockIfLocked: execute,
      );
    } catch (e) {
      // The node refuses this route (401) while an encrypted wallet is locked.
      print("CLI update check failed: $e");
      return null;
    }
    if (data.containsKey('Result') && data['Result'] == "Success") {
      if (data.containsKey("Message")) {
        final message = data['Message'];
        if (message == "CLI is up to date.") {
          return false;
        }
        if (message == "Update was not successful.") {
          return false;
        }
        if (message == "Update was successful. Please Restart CLI.") {
          return true;
        }
      }
    }
    return null;
  }

  Future<NetworkMetrics?> networkMetrics() async {
    try {
      final data = await getJson("/NetworkMetrics");
      return NetworkMetrics.fromJson(data);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
