import 'dart:convert';

import 'package:dio/dio.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_helper.dart';
import '../services/locked_wallet_gate.dart';

const _maxDetailLength = 400;

/// Turns an error from a node / Spyglass call into text for a toast or dialog.
///
/// - [WalletLockedException]: the translated "wallet is locked" message.
/// - [DioException] with a response body: the node's own text (plain body, or
///   the `Message` / `message` / `detail` / `error` field of a JSON body).
/// - [DioException] without a usable body: a translated "could not reach the
///   server" (connection problems, timeouts) or [fallback] / a translated
///   generic error. Never the DioException dump.
/// - `Exception('x')` or a thrown String: `x`.
/// - Anything else: [fallback] or the translated generic error.
///
/// Node text isn't localized, so with [withLeadIn] it is wrapped in the
/// translated `errNodeReason` lead-in (empty in English). Pass
/// `withLeadIn: false` when the result goes into an already translated
/// wrapper such as "Withdrawal request failed: {error}".
String userErrorMessage(Object error, {String? fallback, bool withLeadIn = true}) {
  final l10n = globalL10n;

  if (error is WalletLockedException) {
    return l10n.errWalletLocked;
  }

  String? detail;
  if (error is DioException) {
    detail = nodeErrorText(error.response?.data);
    if (detail == null) {
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return l10n.errNodeUnreachable;
        default:
          return fallback ?? l10n.errRequestFailed;
      }
    }
  } else if (error is String) {
    detail = _clean(error);
  } else if (error is Exception) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      detail = _clean(text.substring('Exception: '.length));
    }
  }

  // An exception that merely wraps another's toString can still carry a Dio
  // dump; that is never shown.
  if (detail == null || detail.contains('DioException') || detail.contains('DioError')) {
    return fallback ?? l10n.errRequestFailed;
  }
  return withLeadIn ? l10n.errNodeReason(detail) : detail;
}

/// Text for a node refusal that arrives in a successful (2xx) reply, such as
/// `{"Success": false, "Message": "..."}`. Same treatment as
/// [userErrorMessage] gives error replies: the node's reason with the
/// translated `errNodeReason` lead-in, or [fallback] when there is no readable
/// reason. [data] is the decoded body or the message string itself. Widgets
/// pass their own [l10n]; services use the global one.
String nodeRefusalMessage(
  dynamic data, {
  required String fallback,
  bool withLeadIn = true,
  AppLocalizations? l10n,
}) {
  final detail = nodeErrorText(data);
  if (detail == null || detail.contains('DioException') || detail.contains('DioError')) {
    return fallback;
  }
  return withLeadIn ? (l10n ?? globalL10n).errNodeReason(detail) : detail;
}

/// Extracts the readable reason from a node / Spyglass response body, or null
/// when there is none (empty body, HTML error page, JSON without a message).
String? nodeErrorText(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is Map) {
    for (final key in const ['Message', 'message', 'detail', 'error', 'title']) {
      final value = data[key];
      if (value is String) {
        final cleaned = _clean(value);
        if (cleaned != null) {
          return cleaned;
        }
      }
    }
    return null;
  }
  if (data is String) {
    final text = data.trim();
    if (text.isEmpty || text.startsWith('<')) {
      return null;
    }
    if (text.startsWith('{') || text.startsWith('"')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) {
          return nodeErrorText(decoded);
        }
        if (decoded is String) {
          return _clean(decoded);
        }
      } catch (_) {
        // Not JSON after all: fall through to the raw text.
      }
    }
    return _clean(text);
  }
  return null;
}

String? _clean(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length > _maxDetailLength) {
    return "${trimmed.substring(0, _maxDetailLength)}…";
  }
  return trimmed;
}
