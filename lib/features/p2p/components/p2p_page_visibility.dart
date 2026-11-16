import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../core/app_router.gr.dart';

/// Whether the page [context] is part of is the one in view: not covered by
/// another route and in the root tab that is showing. A page under another,
/// or in a tab the person has left, stays built, so anything it does on a
/// timer has to ask this first.
///
/// With [watch], the caller's dependencies change when the answer may have
/// (call it from `didChangeDependencies`).
bool p2pPageIsVisible(BuildContext context, {bool watch = false}) {
  // Off under an opaque route above it, in any navigator up the tree.
  if (!TickerMode.of(context)) {
    return false;
  }
  // The top route of its own navigator.
  if (ModalRoute.of(context)?.isCurrent == false) {
    return false;
  }
  // The root tabs keep every tab's pages built; only one is showing.
  final tabs = TabsRouterScope.of(context, watch: watch)?.controller;
  if (tabs != null && tabs.current.name != P2pTabRouter.name) {
    return false;
  }
  return true;
}
