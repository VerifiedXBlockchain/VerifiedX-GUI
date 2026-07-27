import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../models/bridge_lock_record.dart';
import '../providers/bridge_operation_provider.dart';
import 'bridge_explorer_links.dart';
import 'bridge_format.dart';

/// Step 3 of the bridge flow — and the read-only progress view re-used by
/// Phase 5's history detail.
///
/// Watches [bridgeOperationProvider] keyed by `lockId`. The provider handles
/// polling and stops on terminal status. This widget just renders the
/// stepper based on the latest record.
///
/// When [readOnly] is true:
/// - the "safe to close" copy and Cancel guidance are suppressed
/// - terminal-state transitions don't auto-advance the parent (no
///   [onTerminal] is called)
class BridgeProgress extends ConsumerStatefulWidget {
  final String lockId;
  final bool readOnly;

  /// Optional seed record. When provided, the widget renders this record
  /// immediately while the live `bridgeOperationProvider` fetches the latest
  /// status in the background. Prevents the dialog from showing an empty
  /// spinner when we already have the data (e.g. opening a history row).
  final BridgeLockRecord? seedRecord;

  /// Called once when the record first reaches a terminal state. The dialog
  /// uses this to transition to the result step. Ignored when [readOnly] is
  /// true.
  final ValueChanged<BridgeLockRecord>? onTerminal;

  const BridgeProgress({
    super.key,
    required this.lockId,
    this.readOnly = false,
    this.seedRecord,
    this.onTerminal,
  });

  @override
  ConsumerState<BridgeProgress> createState() => _BridgeProgressState();
}

class _BridgeProgressState extends ConsumerState<BridgeProgress> {
  bool _firedTerminal = false;

  @override
  Widget build(BuildContext context) {
    final liveRecord = ref.watch(bridgeOperationProvider(widget.lockId));
    final isReconnecting =
        ref.watch(bridgeOperationProvider(widget.lockId).notifier).isReconnecting;

    // Prefer the live record once it arrives; fall back to the seed (cached
    // history record) until then so the dialog never appears empty.
    final record = liveRecord ?? widget.seedRecord;

    if (record != null &&
        liveRecord != null &&
        record.isTerminal &&
        !_firedTerminal &&
        !widget.readOnly &&
        widget.onTerminal != null) {
      _firedTerminal = true;
      // Defer until after build so the parent setState doesn't fire mid-build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTerminal!(record);
      });
    }

    if (record == null) {
      return const _ProgressLoading();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(record: record),
            const SizedBox(height: 16),
            _Stepper(record: record),
            if (isReconnecting && !record.isTerminal) ...[
              const SizedBox(height: 12),
              const _ReconnectingBanner(),
            ],
            if (record.isStalled()) ...[
              const SizedBox(height: 12),
              const _StalledWarning(),
            ],
            if (!widget.readOnly) ...[
              const SizedBox(height: 16),
              const _SafeToCloseNote(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when polling has failed at least twice in a row but we still have a
/// last-known record on screen (UX § 6 — "Pause polling; show 'Reconnecting…'
/// banner; resume on recovery"). The provider keeps polling on its normal
/// cadence; this is purely visual.
class _ReconnectingBanner extends StatelessWidget {
  const _ReconnectingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context).prvBridgeReconnecting,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Surfaced when a non-terminal record is older than 5 minutes (UX § 6).
/// Polling keeps running — this is just a heads-up so users don't think
/// the app has hung. "Continue waiting" is implicit: the polling continues
/// regardless; this banner just informs.
class _StalledWarning extends StatelessWidget {
  const _StalledWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        border: Border.all(color: Colors.amber.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, color: Colors.amberAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).prvBridgeStalled,
              style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BridgeLockRecord record;
  const _Header({required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.prvBridgeAmountToDest(formatVbtc(record.amount), _shortDest(record.evmDestination)),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.prvBridgeLockId(record.lockId),
          style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  String _shortDest(String address) {
    if (address.length < 12) return address;
    return "${address.substring(0, 6)}…${address.substring(address.length - 4)}";
  }
}

/// Stage index → which point in the visible stepper a status corresponds to.
enum _StageState { done, inProgress, pending, failed }

class _Stepper extends StatelessWidget {
  final BridgeLockRecord record;
  const _Stepper({required this.record});

  _StageState _stage(int index) {
    final status = record.status;
    if (record.isFailed) {
      // Stage that was in progress at failure shows failed; earlier stages
      // remain done. Use the same progression as the success path but
      // clamp the in-progress slot to "failed".
      final inProgress = _inProgressIndexAtFailure();
      if (index < inProgress) return _StageState.done;
      if (index == inProgress) return _StageState.failed;
      return _StageState.pending;
    }

    switch (status) {
      case BridgeLockStatus.locked:
        if (record.vfxLockConfirmedOnChain) {
          // Lock confirmed, waiting for attestations.
          if (index == 0) return _StageState.done;
          if (index == 1) return _StageState.done;
          if (index == 2) return _StageState.inProgress;
          return _StageState.pending;
        }
        if (index == 0) return _StageState.done; // submitted
        if (index == 1) return _StageState.inProgress; // confirming
        return _StageState.pending;
      case BridgeLockStatus.attestationPending:
        if (index <= 1) return _StageState.done;
        if (index == 2) return _StageState.inProgress;
        return _StageState.pending;
      case BridgeLockStatus.attestationReady:
        if (index <= 2) return _StageState.done;
        if (index == 3) return _StageState.inProgress;
        return _StageState.pending;
      case BridgeLockStatus.proofSubmitted:
        if (index <= 2) return _StageState.done;
        if (index == 3) return _StageState.inProgress;
        if (index == 4) return _StageState.inProgress;
        return _StageState.pending;
      case BridgeLockStatus.minted:
      case BridgeLockStatus.mintedOnBase:
        return _StageState.done;
      default:
        // Unknown / post-mint states: treat everything up to current as done.
        if (index == 0) return _StageState.done;
        return _StageState.pending;
    }
  }

  /// Which stage was active when the record entered `Failed`. We don't know
  /// for certain, so we use the populated tx hashes / signature count as
  /// hints.
  int _inProgressIndexAtFailure() {
    if ((record.baseTxHash ?? '').isNotEmpty) return 4;
    if (record.signaturesCollected > 0 || record.requiredSignatures > 0) return 2;
    if (record.vfxLockConfirmedOnChain) return 2;
    if ((record.vfxLockTxHash ?? '').isNotEmpty) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _StageRow(
          state: _stage(0),
          title: l10n.prvBridgeStageLockSubmitted,
          subtitle: (record.vfxLockTxHash ?? '').isNotEmpty
              ? _TxRow(
                  label: l10n.prvBridgeTxLabel,
                  hash: record.vfxLockTxHash!,
                  explorerUrl: BridgeExplorerLinks.vfxTx(record.vfxLockTxHash!),
                )
              : null,
        ),
        _StageRow(
          state: _stage(1),
          title: l10n.prvBridgeStageConfirmed,
          subtitle: record.vfxLockBlockHeight > 0
              ? Text(
                  l10n.prvBridgeBlockHeight(record.vfxLockBlockHeight.toString()),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                )
              : null,
        ),
        _StageRow(
          state: _stage(2),
          title: _stage(2) == _StageState.inProgress
              ? l10n.prvBridgeStageCollectingSigs
              : l10n.prvBridgeStageSigsCollected,
          subtitle: record.requiredSignatures > 0
              ? Text(
                  l10n.prvBridgeSigsProgress(record.signaturesCollected, record.requiredSignatures),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                )
              : null,
        ),
        _StageRow(
          state: _stage(3),
          title: l10n.prvBridgeStageSubmittingMint,
          subtitle: (record.baseTxHash ?? '').isNotEmpty
              ? _TxRow(
                  label: l10n.prvBridgeTxLabel,
                  hash: record.baseTxHash!,
                  explorerUrl: BridgeExplorerLinks.baseTx(record.baseTxHash!),
                )
              : null,
        ),
        _StageRow(
          state: _stage(4),
          title: l10n.prvBridgeStageMinted,
        ),
        if (record.isFailed) ...[
          const SizedBox(height: 12),
          _FailureBox(record: record),
        ],
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  final _StageState state;
  final String title;
  final Widget? subtitle;
  const _StageRow({required this.state, required this.title, this.subtitle});

  IconData get _icon {
    switch (state) {
      case _StageState.done:
        return Icons.check_circle;
      case _StageState.inProgress:
        return Icons.radio_button_checked;
      case _StageState.pending:
        return Icons.radio_button_unchecked;
      case _StageState.failed:
        return Icons.cancel;
    }
  }

  Color get _color {
    switch (state) {
      case _StageState.done:
        return Colors.greenAccent;
      case _StageState.inProgress:
        return Colors.amberAccent;
      case _StageState.pending:
        return Colors.white38;
      case _StageState.failed:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, size: 18, color: _color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: state == _StageState.pending ? Colors.white38 : Colors.white,
                    fontSize: 13,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  subtitle!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final String label;
  final String hash;
  final String explorerUrl;
  const _TxRow({required this.label, required this.hash, required this.explorerUrl});

  String get _short {
    if (hash.length < 12) return hash;
    return "${hash.substring(0, 6)}…${hash.substring(hash.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Use baseline alignment so the default-font label and the monospace hash
    // share the same text baseline instead of floating at slightly different
    // vertical positions (monospace fonts have different x-height metrics).
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text("$label: ", style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(
          _short,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: hash));
            Toast.message(l10n.messageCopiedToClipboard);
          },
          child: const Icon(Icons.copy, size: 12, color: Colors.white54),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: () => launchUrlString(explorerUrl),
          child: const Icon(Icons.open_in_new, size: 12, color: Colors.white54),
        ),
      ],
    );
  }
}

class _FailureBox extends StatelessWidget {
  final BridgeLockRecord record;
  const _FailureBox({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              record.errorMessage ?? AppLocalizations.of(context).prvBridgeFailedFallback,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeToCloseNote extends StatelessWidget {
  const _SafeToCloseNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).prvBridgeSafeToClose,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLoading extends StatelessWidget {
  const _ProgressLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).prvBridgeLoadingStatus, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
