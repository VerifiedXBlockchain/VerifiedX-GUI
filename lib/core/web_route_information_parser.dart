import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'web_router.gr.dart';

/// Route parser for the web wallet. Wraps the router's default parser
/// (with prefix matches, as before) and drops the auth page's prefix match
/// from URLs that resolve to another root route.
///
/// The auth route's path is empty, so with prefix matches every URL also
/// matches it: `dashboard/send` parses to `[WebAuthRouter, dashboard]`. On a
/// URL change inside a running session the root router pops back to that
/// first match, which discards the dashboard's tabs router and its pending
/// child routes, so the page never changes. Parsing to `[dashboard]` alone
/// lets the router update the mounted dashboard in place, as
/// `navigateNamed` does.
class WebRouteInformationParser extends RouteInformationParser<UrlState> {
  final RouteInformationParser<UrlState> _inner;

  WebRouteInformationParser(RootStackRouter router)
      : _inner = router.defaultRouteParser(includePrefixMatches: true);

  @override
  Future<UrlState> parseRouteInformation(RouteInformation routeInformation) {
    // The default parser completes synchronously; `then` on its
    // SynchronousFuture keeps it that way, so the first frame has a route.
    return _inner.parseRouteInformation(routeInformation).then(_dropAuthPrefix);
  }

  UrlState _dropAuthPrefix(UrlState parsed) {
    final segments = parsed.segments;
    if (segments.length > 1 && segments.first.name == WebAuthRouter.name) {
      return UrlState(parsed.uri, segments.sublist(1), shouldReplace: parsed.shouldReplace);
    }
    return parsed;
  }

  @override
  RouteInformation? restoreRouteInformation(UrlState configuration) {
    return _inner.restoreRouteInformation(configuration);
  }
}
