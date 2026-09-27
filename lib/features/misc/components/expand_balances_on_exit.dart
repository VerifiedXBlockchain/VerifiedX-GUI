import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/global_balances_expanded_provider.dart';

/// Re-expands the global balance cards when [child] leaves the tree, so a
/// screen that collapses them restores them however it is left (its own
/// back button, the side nav popping the tab to its root, a browser back).
class ExpandBalancesOnExit extends ConsumerStatefulWidget {
  const ExpandBalancesOnExit({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ExpandBalancesOnExit> createState() => _ExpandBalancesOnExitState();
}

class _ExpandBalancesOnExitState extends ConsumerState<ExpandBalancesOnExit> {
  late final GlobalBalancesExpanded _balancesExpanded;

  @override
  void initState() {
    super.initState();
    _balancesExpanded = ref.read(globalBalancesExpandedProvider.notifier);
  }

  @override
  void dispose() {
    // Provider listeners rebuild widgets, which is not allowed while the tree
    // is being finalized, so the update waits for the current frame to end.
    final balancesExpanded = _balancesExpanded;
    Future.microtask(balancesExpanded.expand);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
