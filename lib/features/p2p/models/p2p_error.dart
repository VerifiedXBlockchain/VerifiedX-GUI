/// A refusal from the P2P API, `{"error": {"code", "message", "fields"}}`
/// with status 400, 401, 403, 404 or 409, or a request that got no usable
/// answer ([status] null, [code] one of [unreachable] or [badResponse]).
/// A refused sign-in is [signInRefused].
class P2pError implements Exception {
  // Client-side codes: the API never sends these.
  static const String unreachable = 'unreachable';
  static const String badResponse = 'bad_response';

  /// `/api/auth/sign-token/` refused the sign-in (a stale or reused message,
  /// or a signature that is not the address's).
  static const String signInRefused = 'sign_in_refused';

  // 401.
  static const String notAuthenticated = 'not_authenticated';
  static const String tokenInvalid = 'token_invalid';
  static const String tokenExpired = 'token_expired';

  /// The HTTP status, or null when no answer arrived.
  final int? status;

  /// The contract's code (`bid_too_low`, `listing_not_live`, ...). An open
  /// set: a code this build does not know is worded by [message].
  final String code;

  /// The server's own words for the refusal, in English.
  final String message;

  /// Per-field messages: a field (Core's names inside `data`, such as
  /// `data.DecShop.Name`) to one message.
  final Map<String, String> fields;

  const P2pError({
    required this.status,
    required this.code,
    this.message = '',
    this.fields = const {},
  });

  /// The error a response with [status] and decoded JSON [body] carries.
  /// Read leniently: a missing code falls back to one for the status, and a
  /// field's value may be a string or a list of strings.
  factory P2pError.fromResponse(int? status, dynamic body) {
    final error = body is Map ? body['error'] : null;
    String code = _defaultCode(status);
    String message = '';
    final fields = <String, String>{};
    if (error is Map) {
      final rawCode = error['code'];
      if (rawCode is String && rawCode.isNotEmpty) {
        code = rawCode;
      }
      final rawMessage = error['message'];
      if (rawMessage is String) {
        message = rawMessage;
      }
      final rawFields = error['fields'];
      if (rawFields is Map) {
        rawFields.forEach((key, value) {
          final text = value is List ? value.whereType<String>().join(' ') : (value is String ? value : '');
          if (text.isNotEmpty) {
            fields[key.toString()] = text;
          }
        });
      }
    }
    return P2pError(status: status, code: code, message: message, fields: fields);
  }

  static String _defaultCode(int? status) {
    if (status == null) {
      return unreachable;
    }
    if (status >= 500) {
      return 'server_error';
    }
    switch (status) {
      case 401:
        return notAuthenticated;
      case 403:
        return 'forbidden';
      case 404:
        return 'not_found';
      case 409:
        return 'conflict';
      case 429:
        return 'throttled';
      default:
        return 'invalid';
    }
  }

  /// A 401: the sign-in token is missing, unknown or expired.
  bool get isUnauthorized => status == 401;

  bool get isNotFound => status == 404;

  @override
  String toString() => "P2pError($status, $code${message.isEmpty ? '' : ': $message'})";
}
