import 'dart:convert';
import 'dart:io';

/// The decoded body of `test/features/p2p/fixtures/[name].json`.
Map<String, dynamic> p2pFixture(String name) {
  return jsonDecode(File('test/features/p2p/fixtures/$name.json').readAsStringSync()) as Map<String, dynamic>;
}

class P2pRecordedRequest {
  final String method;
  final Uri uri;
  final String? authorization;
  final dynamic body;

  P2pRecordedRequest(this.method, this.uri, this.authorization, this.body);

  String get path => uri.path;
}

class P2pCannedResponse {
  final int status;
  final Object? body;

  const P2pCannedResponse(this.status, [this.body]);
}

/// A loopback HTTP server standing in for Spyglass. Each request is recorded
/// and answered by [respond].
class P2pTestServer {
  final HttpServer _server;
  final List<P2pRecordedRequest> requests = [];
  P2pCannedResponse Function(P2pRecordedRequest request) respond;

  P2pTestServer._(this._server, this.respond);

  static Future<P2pTestServer> start([P2pCannedResponse Function(P2pRecordedRequest request)? respond]) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = P2pTestServer._(server, respond ?? (_) => const P2pCannedResponse(200, {}));
    server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();
      final recorded = P2pRecordedRequest(
        request.method,
        request.uri,
        request.headers.value(HttpHeaders.authorizationHeader),
        raw.isEmpty ? null : jsonDecode(raw),
      );
      fake.requests.add(recorded);
      final answer = fake.respond(recorded);
      request.response.statusCode = answer.status;
      if (answer.body is String) {
        request.response.headers.contentType = ContentType.html;
        request.response.write(answer.body);
      } else if (answer.body != null) {
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(answer.body));
      }
      await request.response.close();
    });
    return fake;
  }

  /// Answers every request with [status] and [body].
  void always(int status, [Object? body]) {
    respond = (_) => P2pCannedResponse(status, body);
  }

  String get host => 'http://${_server.address.host}:${_server.port}';

  Future<void> close() => _server.close(force: true);
}
