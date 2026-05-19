import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/toast.dart';
import '../../btc/models/tokenized_bitcoin.dart';
import '../models/bridge_lock_record.dart';
import '../models/bridge_lock_request.dart';
import '../providers/bridge_lock_list_provider.dart';
import '../services/vbtc_bridge_service.dart';
import 'bridge_confirmation.dart';
import 'bridge_preflight_form.dart';
import 'bridge_progress.dart';
import 'bridge_result.dart';

/// Step machine for the bridge flow. Library-private — only the dialog's
/// internal state references it. Names align with the spec's § 3 wording.
enum _BridgeStep { preflight, confirm, progress, result }

/// The vBTC → Base bridge dialog. A single `AlertDialog` that swaps content
/// across four steps. Static [show] is the only entry point — see Phase 4 for
/// the "Bridge to Base" button that calls it.
class BridgeToBaseDialog extends ConsumerStatefulWidget {
  final TokenizedBitcoin token;
  final String ownerAddress;

  const BridgeToBaseDialog({
    super.key,
    required this.token,
    required this.ownerAddress,
  });

  static Future<void> show(
    BuildContext context,
    TokenizedBitcoin token,
    String ownerAddress,
  ) async {
    await showDialog(
      context: context,
      // Tap-outside-to-dismiss is allowed: bridge operations are safe to
      // close at any time — polling continues server-side and history will
      // surface the result. Step-level UI (X / Cancel) provides the explicit
      // close affordance.
      barrierDismissible: true,
      builder: (_) => BridgeToBaseDialog(token: token, ownerAddress: ownerAddress),
    );
  }

  @override
  ConsumerState<BridgeToBaseDialog> createState() => _BridgeToBaseDialogState();
}

class _BridgeToBaseDialogState extends ConsumerState<BridgeToBaseDialog> {
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();

  _BridgeStep _step = _BridgeStep.preflight;
  double? _reviewedAmount;
  String? _reviewedDestination;
  String? _lockId;
  BridgeLockRecord? _terminalRecord;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _close() {
    if (_isSubmitting) return;
    Navigator.of(context).pop();
  }

  void _handleReview(_, double amount, String destination) {
    setState(() {
      _step = _BridgeStep.confirm;
      _reviewedAmount = amount;
      _reviewedDestination = destination;
    });
  }

  void _handleBackToPreflight() {
    if (_isSubmitting) return;
    setState(() => _step = _BridgeStep.preflight);
  }

  Future<void> _handleConfirm() async {
    if (_reviewedAmount == null || _reviewedDestination == null) return;
    setState(() => _isSubmitting = true);

    final req = BridgeLockRequest.fromValues(
      scUid: widget.token.smartContractUid,
      ownerAddress: widget.ownerAddress,
      amount: _reviewedAmount!,
      evmDestination: _reviewedDestination!,
    );
    final record = await VbtcBridgeService().initiateLock(req);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (record == null || record.lockId.isEmpty) {
      Toast.error("Failed to start bridge. Please try again.");
      return;
    }

    // Nudge the lock list to refresh so the new lock appears in history.
    ref.read(bridgeLockListProvider(widget.ownerAddress).notifier).refresh();

    setState(() {
      _lockId = record.lockId;
      _step = _BridgeStep.progress;
    });
  }

  void _handleTerminal(BridgeLockRecord record) {
    if (!mounted) return;
    setState(() {
      _terminalRecord = record;
      _step = _BridgeStep.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text("Bridge to Base")),
          IconButton(
            tooltip: _isSubmitting ? "Bridging…" : "Close",
            iconSize: 18,
            onPressed: _isSubmitting ? null : _close,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: _content(),
      // Action row is owned by each step (their buttons depend on the step's
      // own state), so we keep this empty to avoid double rows.
      actionsPadding: EdgeInsets.zero,
    );
  }

  Widget _content() {
    switch (_step) {
      case _BridgeStep.preflight:
        return BridgePreflightForm(
          token: widget.token,
          ownerAddress: widget.ownerAddress,
          amountController: _amountController,
          destinationController: _destinationController,
          onReview: _handleReview,
          onCancel: _close,
        );
      case _BridgeStep.confirm:
        return BridgeConfirmation(
          amount: _reviewedAmount ?? 0,
          destination: _reviewedDestination ?? '',
          isSubmitting: _isSubmitting,
          onBack: _handleBackToPreflight,
          onConfirm: _handleConfirm,
        );
      case _BridgeStep.progress:
        if (_lockId == null) {
          return const _MissingLockId();
        }
        return BridgeProgress(
          lockId: _lockId!,
          onTerminal: _handleTerminal,
        );
      case _BridgeStep.result:
        final record = _terminalRecord;
        if (record == null) {
          return const _MissingLockId();
        }
        return BridgeResult(
          record: record,
          onDone: _close,
          // Phase 5 will wire a real "view details" navigation; for now we
          // surface the read-only progress view in a new dialog so users can
          // still get to the tx hashes.
          onViewDetails: record.isFailed
              ? () => _showReadOnlyProgress(record.lockId)
              : null,
        );
    }
  }

  Future<void> _showReadOnlyProgress(String lockId) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Bridge details"),
        content: BridgeProgress(lockId: lockId, readOnly: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class _MissingLockId extends StatelessWidget {
  const _MissingLockId();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Bridge state lost. Close and try again.", style: TextStyle(color: Colors.white)),
    );
  }
}
