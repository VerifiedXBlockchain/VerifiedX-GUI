import 'package:flutter/material.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/bridge_lock_record.dart';
import 'bridge_format.dart';

/// Tiny holder for the status pill's color + label. Records would be cleaner
/// but this project is on Dart 2.19.
class _StatusBadge {
  final Color color;
  final String label;
  const _StatusBadge(this.color, this.label);
}

/// A single row in the bridge history list.
///
/// Purely presentational — the parent decides what tapping does and whether
/// to surface Retry. This keeps the row free of any provider/service wiring
/// so it stays cheap to render and easy to test.
class BridgeHistoryItem extends StatelessWidget {
  final BridgeLockRecord record;
  final VoidCallback onTap;

  /// When non-null, a trailing "Retry" button is rendered. The parent owns
  /// the actual retry call (service, list refresh, toast) — the row just
  /// invokes the callback.
  final VoidCallback? onRetry;

  /// While the parent's retry call is in flight, the parent can force the
  /// Retry button into a `processing` state. The row doesn't track this on
  /// its own to keep it stateless.
  final bool isRetrying;

  const BridgeHistoryItem({
    super.key,
    required this.record,
    required this.onTap,
    this.onRetry,
    this.isRetrying = false,
  });

  static String _shortDestination(String addr) {
    if (addr.length < 12) return addr;
    return "${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}";
  }

  static String _relativeTime(DateTime? createdAt) {
    if (createdAt == null) return "—";
    final now = DateTime.now().toUtc();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "yesterday";
    if (diff.inDays < 30) return "${diff.inDays}d ago";
    return "${(diff.inDays / 30).floor()}mo ago";
  }

  static _StatusBadge _statusBadge(BridgeLockRecord r) {
    if (r.isSuccessful) return _StatusBadge(Colors.greenAccent, r.friendlyStatus);
    if (r.isFailed) return _StatusBadge(Colors.redAccent, r.friendlyStatus);
    if (r.status == BridgeLockStatus.expired) {
      return _StatusBadge(Colors.white38, r.friendlyStatus);
    }
    if (r.status == BridgeLockStatus.unknown) {
      return _StatusBadge(Colors.white38, r.friendlyStatus);
    }
    // Anything else non-terminal — in flight.
    return _StatusBadge(Colors.amberAccent, r.friendlyStatus);
  }

  @override
  Widget build(BuildContext context) {
    final r = record;
    final _StatusBadge badge = _statusBadge(r);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${formatVbtc(r.amount)} vBTC → ${_shortDestination(r.evmDestination)}",
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _relativeTime(r.createdAt),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badge.color.withOpacity(0.12),
                border: Border.all(color: badge.color.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.label,
                style: TextStyle(color: badge.color, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              AppButton(
                label: "Retry",
                type: AppButtonType.Outlined,
                variant: AppColorVariant.Warning,
                size: AppSizeVariant.Sm,
                processing: isRetrying,
                onPressed: isRetrying ? () {} : onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
