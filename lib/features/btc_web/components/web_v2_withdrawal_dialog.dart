import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/env.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../token/providers/web_token_actions_manager.dart';

enum _DialogStep { broadcasting, waitingForBlock, frostSigning, success, failure }

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

  @override
  void initState() {
    super.initState();
    if (widget.existingRequestHash != null) {
      _requestHash = widget.existingRequestHash;
      _step = _DialogStep.frostSigning;
      Future(_runFrostSigning);
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
      setState(() {
        _step = _DialogStep.failure;
        _errorMessage = result['message'] ?? AppLocalizations.of(context).bw2FailedBroadcastWithdrawal;
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

  Future<void> _runFrostSigning() async {
    setState(() => _step = _DialogStep.frostSigning);

    final manager = ref.read(webTokenActionsManager);
    final result = await manager.completeV2Withdrawal(
      scIdentifier: widget.scIdentifier,
      requestHash: _requestHash!,
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      setState(() {
        _step = _DialogStep.success;
        _btcTxHash = result['btc_transaction_hash'];
      });
    } else {
      setState(() {
        _step = _DialogStep.failure;
        _errorMessage = result?['message'] ?? AppLocalizations.of(context).bw2FrostFailedOrTimedOut;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForStep(l10n),
            style: const TextStyle(color: Colors.white),
          ),
          if (_step == _DialogStep.success || _step == _DialogStep.failure)
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
            if (_step == _DialogStep.broadcasting) _buildBroadcastingSection(l10n),
            if (_step == _DialogStep.waitingForBlock) _buildWaitingSection(l10n),
            if (_step == _DialogStep.frostSigning) _buildFrostSigningSection(l10n),
            if (_step == _DialogStep.success) _buildSuccessSection(l10n),
            if (_step == _DialogStep.failure) _buildFailureSection(l10n),
          ],
        ),
      ),
    );
  }

  String _titleForStep(AppLocalizations l10n) {
    switch (_step) {
      case _DialogStep.broadcasting:
        return l10n.bw2BroadcastingRequest;
      case _DialogStep.waitingForBlock:
        return l10n.bw2WaitingForConfirmation;
      case _DialogStep.frostSigning:
        return l10n.bw2FrostSigning;
      case _DialogStep.success:
        return l10n.bw2WithdrawalComplete;
      case _DialogStep.failure:
        return l10n.bw2WithdrawalFailed;
    }
  }

  Widget _buildBroadcastingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(l10n.bw2BroadcastingWithdrawal, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(l10n.bw2SubmittingTxVfx, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildWaitingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(l10n.bw2WaitingBlockConfirmation, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(l10n.bw2FrostConfirmHintWeb, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildFrostSigningSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(l10n.bw2FrostSigningInProgress, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(l10n.bw2FrostValidatorsSigning, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildSuccessSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF43ae52), size: 20),
            const SizedBox(width: 8),
            Text(l10n.bw2WithdrawalCompletedSuccess, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        if (_btcTxHash != null) ...[
          const SizedBox(height: 16),
          _buildHashRow(
            l10n.bw2BtcTransactionLabel,
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
            label: l10n.actionDone,
            variant: AppColorVariant.Success,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureSection(AppLocalizations l10n) {
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
                _errorMessage ?? l10n.bw2WithdrawalError,
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
              label: l10n.tkbDismiss,
              variant: AppColorVariant.Light,
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (_requestHash != null) ...[
              const SizedBox(width: 8),
              AppButton(
                label: l10n.bw2RetrySigning,
                variant: AppColorVariant.Warning,
                onPressed: _runFrostSigning,
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
