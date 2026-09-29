import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../api_token_manager.dart';
import '../singletons.dart';
import '../storage.dart';

import '../../features/inspector/network_inspector.dart';
import '../env.dart';
import 'locked_wallet_gate.dart';

class BaseService {
  /// Set to true during snapshot import to suppress DIO error noise in logs.
  static bool suppressErrors = false;

  final String? hostOverride;
  final String? apiBasePathOverride;
  final bool withWebAuth;

  BaseService({
    this.apiBasePathOverride,
    this.hostOverride,
    this.withWebAuth = false,
  });

  /// The apitoken header for calls to the local CLI. Services that point at
  /// another host (Spyglass, mempool.space, the snapshot fleet) never get it.
  Map<String, String> _apiTokenHeader() {
    if (kIsWeb || hostOverride != null) {
      return {};
    }
    return {'apitoken': singleton<ApiTokenManager>().get()};
  }

  Map<String, dynamic> _headers([bool auth = true, bool json = false]) {
    return json
        ? {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.acceptHeader: "application/json",
            ..._apiTokenHeader(),
            ...withWebAuth && auth ? {'Authorization': "basic ${singleton<Storage>().getString(Storage.WEB_AUTH_TOKEN)}"} : {},
          }
        : {
            ..._apiTokenHeader(),
            ...withWebAuth && auth ? {'Authorization': "basic ${singleton<Storage>().getString(Storage.WEB_AUTH_TOKEN)}"} : {},
          };
  }

  BaseOptions _options({
    bool auth = true,
    bool json = false,
    int timeout = 30000,
    bool Function(int?)? validateStatus,
  }) {
    String host = Env.apiBaseUrl;
    if (hostOverride != null) {
      host = hostOverride!;
    }

    final baseUrl = apiBasePathOverride == null ? host : host.replaceAll("/api/V1", apiBasePathOverride!);
    return BaseOptions(
      baseUrl: baseUrl,
      headers: _headers(auth, json),
      connectTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
      validateStatus: validateStatus,
    );
  }

  /// Test hook: when set, every request goes through this adapter instead of
  /// the network.
  @visibleForTesting
  static HttpClientAdapter? httpClientAdapterOverride;

  Dio _dio(BaseOptions options) {
    final dio = Dio(options);
    final adapterOverride = httpClientAdapterOverride;
    if (adapterOverride != null) {
      dio.httpClientAdapter = adapterOverride;
    } else if (!kIsWeb) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    return dio;
  }

  /// Sends one request. For native calls to the local node, a locked-wallet
  /// 401 prompts for the password and retries once (see [LockedWalletGate]);
  /// web and other hosts (Spyglass, mempool.space, snapshots) are untouched.
  Future<Response<dynamic>> _send(Future<Response<dynamic>> Function() request, bool unlockIfLocked) {
    if (kIsWeb || hostOverride != null) {
      return request();
    }
    return LockedWalletGate.run(request, enabled: unlockIfLocked);
  }

  String _cleanPath(String path) {
    if (!path.endsWith("/")) {
      return "$path/";
    }

    return path;
  }

  Future<String> getText(
    String path, {
    Map<String, dynamic> params = const {},
    bool auth = true,
    bool cleanPath = true,
    int timeout = 30000,
    bool inspect = false,
    bool preventError = false,
    bool unlockIfLocked = true,
  }) async {
    try {
      final dio = _dio(_options(auth: auth, timeout: timeout));

      if (inspect) {
        NetworkInspector.attach(dio);
      }

      final p = cleanPath ? _cleanPath(path) : path;
      var response = await _send(
        () => dio.get(
          p,
          queryParameters: params,
        ),
        unlockIfLocked,
      );

      if (response.data != null) {
        return response.data.toString();
      }

      return response.toString();
    } catch (e, st) {
      if (!suppressErrors) {
        print(e);
        print(st);
      }
      if (!preventError) {
        rethrow;
      }
      return "";
    }
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic> params = const {},
    bool auth = true,
    bool cleanPath = true,
    bool responseIsJson = false,
    int timeout = 30000,
    bool inspect = false,
    bool Function(int?)? validateStatus,
    bool unlockIfLocked = true,
  }) async {
    try {
      final dio = _dio(_options(auth: auth, timeout: timeout, validateStatus: validateStatus));
      if (inspect) {
        NetworkInspector.attach(dio);
      }
      final url = cleanPath ? _cleanPath(path) : path;
      var response = await _send(
        () => dio.get(
          url,
          queryParameters: params,
        ),
        unlockIfLocked,
      );

      if (responseIsJson) {
        return {'data': response.data};
      }

      if (response.statusCode == 204) {
        return {};
      }
      if (response.data == null) {
        return {};
      }
      if (response.data.runtimeType == String) {
        return jsonDecode(response.data);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic> params = const {},
    bool auth = true,
    bool responseIsJson = false,
    int timeout = 30000,
    bool inspect = false,
    bool cleanPath = true,
    bool Function(int?)? validateStatus,
    bool unlockIfLocked = true,
  }) async {
    try {
      final dio = _dio(_options(auth: auth, json: true, timeout: timeout, validateStatus: validateStatus));
      if (inspect) {
        NetworkInspector.attach(dio);
      }
      var response = await _send(
        () => dio.post(
          cleanPath ? _cleanPath(path) : path,
          data: params,
        ),
        unlockIfLocked,
      );

      final data = responseIsJson ? response.data : jsonDecode(response.toString());

      return {'data': data};

      // if (response.statusCode == 204) {
      //   return {};
      // }
      // if (response.data == null) {
      //   return {};
      // }

      // if (response.data.runtimeType == String) {
      //   return {};
      // }
      // return response.data;
    } catch (e) {
      if (!suppressErrors) print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic> params = const {},
    bool auth = true,
    bool responseIsJson = false,
    int timeout = 30000,
    bool inspect = false,
    bool cleanPath = true,
    bool unlockIfLocked = true,
  }) async {
    try {
      final dio = _dio(_options(auth: auth, json: true, timeout: timeout));
      if (inspect) {
        NetworkInspector.attach(dio);
      }
      var response = await _send(
        () => dio.patch(
          cleanPath ? _cleanPath(path) : path,
          data: params,
        ),
        unlockIfLocked,
      );

      final data = responseIsJson ? response.data : jsonDecode(response.toString());

      return {'data': data};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    bool auth = true,
    bool responseIsJson = false,
    int timeout = 30000,
    bool inspect = false,
    bool cleanPath = true,
    bool unlockIfLocked = true,
  }) async {
    try {
      final dio = _dio(_options(auth: auth, json: true, timeout: timeout));
      if (inspect) {
        NetworkInspector.attach(dio);
      }
      var response = await _send(
        () => dio.delete(
          cleanPath ? _cleanPath(path) : path,
        ),
        unlockIfLocked,
      );

      final data = responseIsJson ? response.data : jsonDecode(response.toString());

      return {'data': data};
    } catch (e) {
      rethrow;
    }
  }

  // Future<Map<String, dynamic>> putHttp(
  //   String path, {
  //   Map<String, dynamic> params = const {},
  //   bool auth = true,
  // }) async {
  //   try {
  //     var response = await Dio(_options(auth: auth)).put(
  //       _cleanPath(path),
  //       data: params,
  //     );
  //     if (response.statusCode == 204) {
  //       return {};
  //     }
  //     if (response.data == null) {
  //       return {};
  //     }
  //     if (response.data.runtimeType == String) {
  //       return {};
  //     }
  //     return response.data;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<Map<String, dynamic>> deleteHttp(
  //   String path, {
  //   bool auth = true,
  // }) async {
  //   try {
  //     var response = await Dio(_options(auth: auth)).delete(
  //       _cleanPath(path),
  //     );

  //     if (response.statusCode == 204) {
  //       return {};
  //     }
  //     if (response.data == null) {
  //       return {};
  //     }
  //     if (response.data.runtimeType == String) {
  //       return {};
  //     }

  //     return response.data;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> postFormData(
    String path, {
    required FormData data,
    int timeout = 30000,
  }) async {
    final dio = _dio(_options(json: false, auth: false, timeout: timeout));
    // A FormData body can only be sent once, so this is never retried.
    var response = await dio.post(
      _cleanPath(path),
      data: data,
    );

    if (response.statusCode == 204) {
      return {};
    }
    if (response.data == null) {
      return {};
    }
    if (response.data.runtimeType == String) {
      return jsonDecode(response.data);
    }

    return response.data;
  }
}
