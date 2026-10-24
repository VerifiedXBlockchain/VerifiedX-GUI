import 'package:dio/dio.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/features/debug/debug_logger.dart';
import 'package:rbx_wallet/features/remote_info/models/remote_info.dart';

class RemoteInfoService {
  static Future<RemoteInfo?> fetchInfo() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: Env.explorerApiBaseUrl));

      final response = await dio.get('/applications/');
      return RemoteInfo.fromJson(response.data);
    } catch (e, st) {
      print(e);

      DebugLogger.log(e, st);

      return null;
    }
  }
}
