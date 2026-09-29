import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../utils/html_helpers.dart';
import '../env.dart';

/// Calls [attempt] until it returns true, waiting [delay] between tries, and
/// gives up after [maxAttempts]. Returns whether an attempt succeeded.
Future<bool> retryUntilTrue(
  bool Function() attempt, {
  int maxAttempts = 10,
  Duration delay = const Duration(milliseconds: 300),
}) async {
  for (var attemptNumber = 1; attemptNumber <= maxAttempts; attemptNumber++) {
    if (attempt()) {
      return true;
    }
    if (attemptNumber < maxAttempts) {
      await Future.delayed(delay);
    }
  }
  return false;
}

/// In an automation web build, turns the engine's semantics tree on after the
/// first frame by clicking the hidden "Enable accessibility" placeholder.
/// Flutter 3.7.12 ignores `setSemanticsEnabled(true)` on web, so this is the
/// only way to get `flt-semantics` nodes without a user click.
///
/// Does nothing on desktop or in a build without `AUTOMATION=true`.
void enableWebSemanticsForAutomation() {
  if (!kIsWeb || !Env.isAutomation) {
    return;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _clickSemanticsPlaceholder();
  });
}

Future<void> _clickSemanticsPlaceholder() async {
  final clicked = await retryUntilTrue(HtmlHelpers().enableSemantics);
  print(clicked
      ? '[automation] semantics placeholder clicked'
      : '[automation] flt-semantics-placeholder not found; semantics stay off');
}
