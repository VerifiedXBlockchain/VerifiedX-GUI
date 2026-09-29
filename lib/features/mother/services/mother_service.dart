import 'dart:convert';

import '../../../core/services/base_service.dart';
import '../models/mother_child.dart';

class MotherData {
  final String name;

  const MotherData(this.name);

  /// Reads the GetMother reply. The node answers {Id, Name, StartDate} for a
  /// host and {} otherwise; it no longer returns the password (VX-17).
  static MotherData? fromResponse(Map<String, dynamic> data) {
    final name = data['Name'];
    if (name is String) {
      return MotherData(name);
    }
    return null;
  }
}

/// The reason in a StartMother or JoinMother reply ({Result, Message}), or
/// null when the node reports success.
String? motherActionFailure(Map<String, dynamic> data) {
  if (data['Result'] == "Success") {
    return null;
  }
  final message = data['Message'];
  return message is String && message.trim().isNotEmpty ? message.trim() : "";
}

class MotherService extends BaseService {
  Future<MotherData?> getHost() async {
    try {
      final data = await getJson('/GetMother');
      return MotherData.fromResponse(data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<MotherChild>> getChildren() async {
    try {
      final data = await getText('/MothersKids');

      print(data);
      final items = jsonDecode(data);
      final List<MotherChild> children = [];
      for (final item in items) {
        children.add(MotherChild.fromJson(item));
      }
      return children;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Sets this wallet up as a Mother host. Returns null on success, or the
  /// node's reason (empty when it gave none).
  Future<String?> createHost(String name, String password) async {
    final params = {
      'Name': name,
      'Password': password,
    };
    try {
      final response = await postJson('/StartMother', params: params);
      return motherActionFailure(response['data']);
    } catch (e) {
      print(e);
      return "";
    }
  }

  /// Joins a Mother host. Returns null on success, or the node's reason
  /// (empty when it gave none).
  Future<String?> joinHost(String ipAddress, String password) async {
    final params = {
      'IPAddress': ipAddress,
      'Password': password,
    };
    try {
      final response = await postJson('/JoinMother', params: params);
      return motherActionFailure(response['data']);
    } catch (e) {
      print(e);
      return "";
    }
  }

  Future<bool> stopHost() async {
    try {
      await getText('/StopMother');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
