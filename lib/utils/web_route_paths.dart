import 'html_helpers.dart';

/// Strips the leading slashes from a web route path, so `/dashboard/send`
/// and `dashboard/send` resolve to the same route. The web router emits
/// hashes without a leading slash (`#dashboard/send`), while external links
/// are often written as `#/dashboard/send`. A bare `/` is kept as is.
String normalizeWebRoutePath(String path) {
  var normalized = path;
  while (normalized.length > 1 && normalized.startsWith('/')) {
    normalized = normalized.substring(1);
  }
  return normalized;
}

/// The hash route of [url] when it points at a dashboard page, normalized
/// with [normalizeWebRoutePath], or null otherwise. Accepts both
/// `#dashboard/...` and `#/dashboard/...`.
String? dashboardRedirectPath(String url) {
  final hashIndex = url.indexOf('#');
  if (hashIndex == -1) {
    return null;
  }
  final path = normalizeWebRoutePath(url.substring(hashIndex + 1));
  if (path == 'dashboard' || path.startsWith('dashboard/')) {
    return path;
  }
  return null;
}

/// The page URL as it was when the app started, before the router rewrote
/// the hash. Payment links and reloads on a dashboard page need it to know
/// where to go once the wallet is unlocked.
class InitialWebUrl {
  static String? _url;

  /// Records the current page URL. Call once in `main`, before `runApp`.
  static void capture() {
    _url = HtmlHelpers().getUrl();
  }

  /// Sets the captured URL directly; for tests.
  static void set(String? url) {
    _url = url;
  }

  /// The dashboard route the app was opened on, or null. Returns it only
  /// once, so a later lock does not send the user back to the start page.
  static String? takeDashboardRedirect() {
    final url = _url;
    _url = null;
    if (url == null) {
      return null;
    }
    return dashboardRedirectPath(url);
  }
}
