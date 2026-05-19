import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/toast.dart';
import '../models/bridge_lock_record.dart';
import '../providers/bridge_lock_list_provider.dart';
import '../services/vbtc_bridge_service.dart';
import 'bridge_history_item.dart';
import 'bridge_to_base_dialog.dart';

/// Per-contract bridge history list.
///
/// Watches [bridgeLockListProvider] keyed by `ownerAddress` and filters to the
/// records belonging to `scUid`. The provider:
/// - loads on first watch
/// - exposes `hasLoaded` so we can distinguish "loading" from "loaded-empty"
/// - auto-refreshes every 30s while anything is in flight
/// - exposes a `refresh()` method we wire to the manual refresh button
///
/// Per the spec we render a `ListView.builder` and never spawn
/// `bridgeOperationProvider` per row — that would create one persistent 5s
/// timer per history entry. The detail dialog opens an operation provider
/// only on tap.
class BridgeHistoryList extends ConsumerStatefulWidget {
  final String ownerAddress;
  final String scUid;

  /// Whether to render the section header. When this list is placed inside a
  /// container that already provides its own title, pass `false` to avoid
  /// duplicate headings.
  final bool showHeader;

  const BridgeHistoryList({
    super.key,
    required this.ownerAddress,
    required this.scUid,
    this.showHeader = true,
  });

  @override
  ConsumerState<BridgeHistoryList> createState() => _BridgeHistoryListState();
}

class _BridgeHistoryListState extends ConsumerState<BridgeHistoryList> {
  /// Lock IDs whose retry call is currently in flight. Used to render the
  /// row's processing state without spawning per-row stateful widgets.
  final Set<String> _retrying = <String>{};

  void _openDetail(BridgeLockRecord record) {
    BridgeToBaseDialog.showHistoryDetail(context, record.lockId);
  }

  Future<void> _retry(BridgeLockRecord record) async {
    if (_retrying.contains(record.lockId)) return;
    setState(() => _retrying.add(record.lockId));
    final ok = await VbtcBridgeService().retryMint(record.lockId, widget.ownerAddress);
    if (!mounted) return;
    setState(() => _retrying.remove(record.lockId));

    if (ok) {
      Toast.message("Retry submitted. Watching for status updates.");
      ref.read(bridgeLockListProvider(widget.ownerAddress).notifier).refresh();
    } else {
      Toast.error("Retry failed. See history detail for status.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ownerAddress.isEmpty) {
      return const SizedBox.shrink();
    }

    final all = ref.watch(bridgeLockListProvider(widget.ownerAddress));
    final hasLoaded =
        ref.watch(bridgeLockListProvider(widget.ownerAddress).notifier).hasLoaded;
    final scoped = all.where((r) => r.scUid == widget.scUid).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader)
          _Header(
            onRefresh: () => ref
                .read(bridgeLockListProvider(widget.ownerAddress).notifier)
                .refresh(),
          ),
        if (!hasLoaded)
          const _Loading()
        else if (scoped.isEmpty)
          const _Empty()
        else
          _RecordList(
            records: scoped,
            retrying: _retrying,
            onTap: _openDetail,
            onRetry: _retry,
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Bridge History",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            tooltip: "Refresh",
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text(
            "Loading bridge history…",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          "No bridge operations yet.",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}

/// The actual scrollable list. Uses `ListView.builder` per the spec; needs
/// `shrinkWrap: true` + non-scrolling physics because the parent screen is
/// already a `SingleChildScrollView` (see `tokenized_btc_detail_screen.dart`).
class _RecordList extends StatelessWidget {
  final List<BridgeLockRecord> records;
  final Set<String> retrying;
  final ValueChanged<BridgeLockRecord> onTap;
  final ValueChanged<BridgeLockRecord> onRetry;

  const _RecordList({
    required this.records,
    required this.retrying,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: records.length,
        itemBuilder: (_, index) {
          final record = records[index];
          return Column(
            children: [
              if (index > 0)
                const Divider(height: 1, thickness: 1, color: Colors.white12),
              BridgeHistoryItem(
                record: record,
                onTap: () => onTap(record),
                onRetry: record.canRetry ? () => onRetry(record) : null,
                isRetrying: retrying.contains(record.lockId),
              ),
            ],
          );
        },
      ),
    );
  }
}
