import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../app.dart';
import '../services/withdrawal_in_progress_notice.dart';
import '../../../core/components/buttons.dart';
import '../../../core/env.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../token/providers/web_token_actions_manager.dart';
import '../services/pending_withdrawal_completion_service.dart';

enum _DialogStep {
  broadcasting,
  waitingForBlock,
  frostSigning,
  recordingCompletion,
  success,
  /// BTC sent, but the Type 28 completion TX is not on chain yet. Retriable
  /// without touching Bitcoin again.
  completionPending,
  failure,
}

class WebV2WithdrawalDialog extends ConsumerStatefulWidget {
  final String scIdentifier;
  final String requestorAddress;
  final String btcAddress;
  final double amount;
  final int feeRate;
  final String? ownerAddress;

  /// If provided, skips the broadcast step and goes directly to FROST signing.
  final String? existingRequestHash;

  const WebV2WithdrawalDialog({
    super.key,
    required this.scIdentifier,
    required this.requestorAddress,
    required this.btcAddress,
    required this.amount,
    required this.feeRate,
    this.ownerAddress,
    this.existingRequestHash,
  });

  static Future<void> show({
    required String scIdentifier,
    required String requestorAddress,
    required String btcAddress,
    required double amount,
    required int feeRate,
    String? ownerAddress,
    String? existingRequestHash,
  }) {
    return showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => WebV2WithdrawalDialog(
        scIdentifier: scIdentifier,
        requestorAddress: requestorAddress,
        btcAddress: btcAddress,
        amount: amount,
        feeRate: feeRate,
        ownerAddress: ownerAddress,
        existingRequestHash: existingRequestHash,
      ),
    );
  }

  @override
  ConsumerState<WebV2WithdrawalDialog> createState() => _WebV2WithdrawalDialogState();
}

class _WebV2WithdrawalDialogState extends ConsumerState<WebV2WithdrawalDialog> {
  _DialogStep _step = _DialogStep.broadcasting;
  String? _requestHash;
  String? _btcTxHash;
  String? _errorMessage;
  Timer? _pollTimer;
  int _pollCount = 0;
  static const _maxPollAttempts = 60; // 5 minutes at 5s intervals

  /// Guards the retry buttons so a double tap cannot start two FROST sessions
  /// or two completion sends.
  bool _busy = false;

  /// Set when the BTC broadcast returned no txid — retrying would re-sign
  /// against spent inputs, so no retry is offered.
  bool _btcBroadcastUnconfirmed = false;

  /// Set when the explorer says this withdrawal was already signed elsewhere.
  /// Same reason to withhold retry: signing again can pay the withdrawal twice.
  bool _signingAlreadyStarted = false;

  /// The broadcast this dialog is trying to settle, held in memory so a retry
  /// never depends on storage — which may be the thing that failed.
  PendingWithdrawalCompletion? _pendingCompletion;

  /// False when the recovery record could not be persisted, so this withdrawal
  /// cannot be resumed after the page closes.
  bool _completionRecoverable = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingRequestHash != null) {
      _requestHash = widget.existingRequestHash;
      _step = PendingWithdrawalCompletionService().get(_requestHash!) != null
          ? _DialogStep.recordingCompletion
          : _DialogStep.frostSigning;
      Future(_startCompletion);
    } else {
      Future(_broadcastRequest);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _broadcastRequest() async {
    setState(() => _step = _DialogStep.broadcasting);

    final manager = ref.read(webTokenActionsManager);
    final result = await manager.requestV2Withdrawal(
      scIdentifier: widget.scIdentifier,
      requestorAddress: widget.requestorAddress,
      btcAddress: widget.btcAddress,
      amount: widget.amount,
      feeRate: widget.feeRate,
    );

    if (!mounted) return;

    if (result['success'] != true || result['hash'] == null) {
      final message = result['message'] as String?;

      // Not a failure — the contract simply has a withdrawal underway, and the
      // holders share one Bitcoin deposit address so they run one at a time.
      // Close out and explain it rather than leaving a red error on screen
      // carrying the node's raw "verification failed" wording.
      if (isWithdrawalAlreadyInProgress(message)) {
        Navigator.of(context).pop();
        await showWithdrawalInProgressNotice();
        return;
      }

      setState(() {
        _step = _DialogStep.failure;
        _errorMessage = message ?? AppLocalizations.of(context).bw2FailedBroadcastWithdrawal;
      });
      return;
    }

    _requestHash = result['hash'] as String;
    _waitForBlockConfirmation();
  }

  void _waitForBlockConfirmation() {
    setState(() => _step = _DialogStep.waitingForBlock);
    _pollCount = 0;

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _pollCount++;

      if (_pollCount > _maxPollAttempts) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _step = _DialogStep.failure;
          _errorMessage = AppLocalizations.of(context).bw2BlockConfirmTimedOut;
        });
        return;
      }

      try {
        final detail = await ExplorerService().getWebVbtcV2TokenDetail(widget.scIdentifier);
        final withdrawals = detail.withdrawalRequests ?? [];
        final match = withdrawals.where(
          (wr) => wr['request_transaction_hash'] == _requestHash,
        );

        if (match.isNotEmpty) {
          timer.cancel();
          if (!mounted) return;
          _runFrostSigning();
        }
      } catch (_) {
        // Keep polling
      }
    });
  }

  /// Resume point for an existing request. If a previous attempt already
  /// broadcast the Bitcoin transaction, only the completion TX is retried —
  /// re-running FROST would sign against spent inputs.
  Future<void> _startCompletion() async {
    final stored = PendingWithdrawalCompletionService().get(_requestHash!);
    if (stored != null) {
      _pendingCompletion = stored;
      await _recordCompletion(stored);
      return;
    }
    await _runFrostSigning();
  }

  Future<void> _runFrostSigning() async {
    if (_busy) return;
    _busy = true;
    setState(() {
      _step = _DialogStep.frostSigning;
      _errorMessage = null;
    });

    final manager = ref.read(webTokenActionsManager);
    final result = await manager.completeV2Withdrawal(
      scIdentifier: widget.scIdentifier,
      requestHash: _requestHash!,
    );

    _busy = false;
    if (!mounted) return;

    if (result != null && result['success'] == true) {
      final btcTxHash = result['btc_transaction_hash'] as String?;

      // Held in memory so Retry Completion works even when the recovery write
      // failed. Storage is the fallback, not the source of truth.
      if (btcTxHash != null) {
        _pendingCompletion = PendingWithdrawalCompletion(
          scIdentifier: widget.scIdentifier,
          requestHash: _requestHash!,
          btcTxHash: btcTxHash,
          amount: (result['withdrawal_amount'] as num?)?.toDouble() ?? widget.amount,
          btcDestination: result['btc_destination'] as String? ?? widget.btcAddress,
          fromAddress: widget.requestorAddress,
          createdAt: DateTime.now(),
        );
      }

      setState(() {
        _btcTxHash = btcTxHash;
        _completionRecoverable = result['completion_recoverable'] != false;
        if (result['completion_recorded'] == true) {
          _step = _DialogStep.success;
        } else {
          _step = _DialogStep.completionPending;
          _errorMessage = result['completion_message'];
        }
      });
      return;
    }

    setState(() {
      _btcBroadcastUnconfirmed = result?['btc_broadcast_unconfirmed'] == true;
      _signingAlreadyStarted = result?['signing_already_started'] == true;
      _step = _DialogStep.failure;
      _errorMessage = result?['message'] ?? AppLocalizations.of(context).bw2FrostFailedOrTimedOut;
    });
  }

  Future<void> _recordCompletion(PendingWithdrawalCompletion pending) async {
    if (_busy) return;
    _busy = true;
    _pendingCompletion = pending;
    setState(() {
      _step = _DialogStep.recordingCompletion;
      _btcTxHash = pending.btcTxHash;
      _errorMessage = null;
    });

    final manager = ref.read(webTokenActionsManager);
    final result = await manager.recordV2WithdrawalCompletion(
      scIdentifier: pending.scIdentifier,
      requestHash: pending.requestHash,
      btcTxHash: pending.btcTxHash,
      amount: pending.amount,
      btcDestination: pending.btcDestination,
    );

    _busy = false;
    if (!mounted) return;

    setState(() {
      if (result['success'] == true) {
        _step = _DialogStep.success;
      } else {
        _step = _DialogStep.completionPending;
        _errorMessage = result['message'];
      }
    });
  }

  Future<void> _retryCompletion() async {
    // Prefer the in-memory broadcast. A missing storage record proves nothing:
    // it means either the completion landed and cleared it, or the recovery
    // write failed in the first place. Treating absence as settlement would
    // report an unsettled withdrawal as complete.
    final pending = _pendingCompletion ??
        PendingWithdrawalCompletionService().get(_requestHash!);

    if (pending == null) {
      setState(() {
        _step = _DialogStep.failure;
        _errorMessage = AppLocalizations.of(context).bw2CompletionUnknownBtcTx;
      });
      return;
    }

    await _recordCompletion(pending);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForStep(),
            style: const TextStyle(color: Colors.white),
          ),
          if (_isTerminal)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 20),
              color: Colors.white38,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, minWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_step == _DialogStep.broadcasting) _buildBroadcastingSection(),
            if (_step == _DialogStep.waitingForBlock) _buildWaitingSection(),
            if (_step == _DialogStep.frostSigning) _buildFrostSigningSection(),
            if (_step == _DialogStep.recordingCompletion) _buildRecordingSection(),
            if (_step == _DialogStep.success) _buildSuccessSection(),
            if (_step == _DialogStep.completionPending) _buildCompletionPendingSection(),
            if (_step == _DialogStep.failure) _buildFailureSection(),
          ],
        ),
      ),
    );
  }

  bool get _isTerminal =>
      _step == _DialogStep.success ||
      _step == _DialogStep.failure ||
      _step == _DialogStep.completionPending;

  String _titleForStep() {
    switch (_step) {
      case _DialogStep.broadcasting:
        return AppLocalizations.of(context).bw2BroadcastingRequest;
      case _DialogStep.waitingForBlock:
        return AppLocalizations.of(context).bw2WaitingForConfirmation;
      case _DialogStep.frostSigning:
        return AppLocalizations.of(context).bw2FrostSigning;
      case _DialogStep.recordingCompletion:
        return AppLocalizations.of(context).bw2RecordingCompletionTitle;
      case _DialogStep.success:
        return AppLocalizations.of(context).bw2WithdrawalComplete;
      case _DialogStep.completionPending:
        return "Action Required";
      case _DialogStep.failure:
        return AppLocalizations.of(context).bw2WithdrawalFailed;
    }
  }

  Widget _buildBroadcastingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).bw2BroadcastingWithdrawal, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context).bw2SubmittingTxVfx, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildWaitingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).bw2WaitingBlockConfirmation, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context).bw2FrostConfirmHintWeb, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildFrostSigningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).bw2FrostSigningInProgress, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context).bw2FrostValidatorsSigning, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).bw2RecordingCompletion, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context).bw2RecordingCompletionHint,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildCompletionPendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE0A32E), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context).bw2CompletionPendingTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _completionRecoverable
              ? AppLocalizations.of(context).bw2CompletionPendingHint
              : AppLocalizations.of(context).bw2CompletionPendingHintUnsaved,
          style: TextStyle(
            color: _completionRecoverable ? Colors.white38 : const Color(0xFFE0A32E),
            fontSize: 12,
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Color(0xFFBA2121), fontSize: 12)),
        ],
        if (_btcTxHash != null) ...[
          const SizedBox(height: 16),
          _buildHashRow(
            AppLocalizations.of(context).bw2BtcTransactionLabel,
            _btcTxHash!,
            explorerUrl: Env.btcIsTestNet
                ? "https://mempool.space/testnet4/tx/$_btcTxHash"
                : "https://mempool.space/tx/$_btcTxHash",
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Deferring is only safe when the withdrawal can be picked up
            // again later, so it is not offered when the record failed to save.
            if (_completionRecoverable) ...[
              AppButton(
                label: AppLocalizations.of(context).beaconLater,
                variant: AppColorVariant.Light,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
            ],
            AppButton(
              label: AppLocalizations.of(context).bw2RetryCompletion,
              variant: AppColorVariant.Warning,
              onPressed: _busy ? null : _retryCompletion,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF43ae52), size: 20),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).bw2WithdrawalCompletedSuccess, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        if (_btcTxHash != null) ...[
          const SizedBox(height: 16),
          _buildHashRow(
            AppLocalizations.of(context).bw2BtcTransactionLabel,
            _btcTxHash!,
            explorerUrl: Env.btcIsTestNet
                ? "https://mempool.space/testnet4/tx/$_btcTxHash"
                : "https://mempool.space/tx/$_btcTxHash",
          ),
        ],
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: AppLocalizations.of(context).actionDone,
            variant: AppColorVariant.Success,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFBA2121), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage ?? AppLocalizations.of(context).bw2WithdrawalError,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              label: AppLocalizations.of(context).tkbDismiss,
              variant: AppColorVariant.Light,
              onPressed: () => Navigator.of(context).pop(),
            ),
            // No retry when signing has already produced a Bitcoin transaction
            // this session cannot account for — whether the broadcast returned
            // no txid, or the explorer says another device signed it. Either
            // way, signing again can send the Bitcoin twice.
            if (_requestHash != null &&
                !_btcBroadcastUnconfirmed &&
                !_signingAlreadyStarted) ...[
              const SizedBox(width: 8),
              AppButton(
                label: AppLocalizations.of(context).bw2RetrySigning,
                variant: AppColorVariant.Warning,
                onPressed: _busy ? null : _runFrostSigning,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHashRow(String label, String hash, {String? explorerUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SelectableText(hash, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: hash));
                Toast.message(AppLocalizations.of(context).messageCopiedToClipboard);
              },
              child: const Icon(Icons.copy, size: 16, color: Colors.white54),
            ),
            if (explorerUrl != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () => launchUrlString(explorerUrl),
                child: const Icon(Icons.open_in_new, size: 16, color: Colors.white54),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
