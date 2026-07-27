import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
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
    // Pass the cached record as seed so the detail view renders immediately
    // even if the live status endpoint is slow or down (e.g. during a CLI
    // network upgrade). The provider's poll will refresh it in the background.
    BridgeToBaseDialog.showHistoryDetail(
      context,
      record.lockId,
      seedRecord: record,
    );
  }

  Future<void> _retry(BridgeLockRecord record) async {
    if (_retrying.contains(record.lockId)) return;
    setState(() => _retrying.add(record.lockId));
    final ok = await VbtcBridgeService().retryMint(record.lockId, widget.ownerAddress);
    if (!mounted) return;
    setState(() => _retrying.remove(record.lockId));

    if (ok) {
      Toast.message(globalL10n.prvBridgeRetrySubmitted);
      ref.read(bridgeLockListProvider(widget.ownerAddress).notifier).refresh();
    } else {
      Toast.error(globalL10n.prvBridgeRetryFailedToast);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ownerAddress.isEmpty) {
      return const SizedBox.shrink();
    }

    final all = ref.watch(bridgeLockListProvider(widget.ownerAddress));
    final notifier = ref.watch(bridgeLockListProvider(widget.ownerAddress).notifier);
    final hasLoaded = notifier.hasLoaded;
    final error = notifier.error;
    final scoped = all.where((r) => r.scUid == widget.scUid).toList(growable: false);

    Widget body;
    if (!hasLoaded) {
      body = const _Loading();
    } else if (error != null && scoped.isEmpty) {
      // Only show the dedicated error state when we have no records to fall
      // back on. If a refresh fails but we already have cached records,
      // keep them visible — losing list contents on a transient failure is
      // worse than a stale-but-correct list.
      body = _ErrorState(
        message: _messageFromError(error),
        onRetry: () => notifier.refresh(),
      );
    } else if (scoped.isEmpty) {
      body = const _Empty();
    } else {
      body = _RecordList(
        records: scoped,
        retrying: _retrying,
        onTap: _openDetail,
        onRetry: _retry,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader)
          _Header(onRefresh: () => notifier.refresh()),
        body,
      ],
    );
  }

  static String _messageFromError(Object error) {
    if (error is BridgeServiceException) return error.message;
    return globalL10n.prvBridgeHistoryLoadError;
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.prvBridgeHistoryTitle,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            tooltip: l10n.prvRefresh,
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(
            l10n.prvBridgeHistoryLoading,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            label: AppLocalizations.of(context).prvTryAgain,
            type: AppButtonType.Outlined,
            variant: AppColorVariant.Warning,
            size: AppSizeVariant.Sm,
            onPressed: onRetry,
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
      child: Center(
        child: Text(
          AppLocalizations.of(context).prvBridgeNoOperations,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
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
