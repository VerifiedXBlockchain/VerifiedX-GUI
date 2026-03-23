import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../models/withdrawal_result.dart';
import '../services/vbtc_v2_service.dart';
import '../../transactions/services/local_transaction_service.dart';

const _tag = '[vBTC-V2] WithdrawalDialog';

class WithdrawalProcessingDialog extends StatefulWidget {
  final String scUid;
  final String requestHash;
  final String? ownerAddress;

  /// When true, the dialog will poll for the request tx to be confirmed
  /// in a block before calling completeWithdrawal.
  final bool waitForConfirmation;

  const WithdrawalProcessingDialog({
    super.key,
    required this.scUid,
    required this.requestHash,
    this.ownerAddress,
    this.waitForConfirmation = false,
  });

  /// Show the dialog and begin the completeWithdrawal call immediately.
  static Future<WithdrawalResult?> show({
    required String scUid,
    required String requestHash,
    String? ownerAddress,
    bool waitForConfirmation = false,
    BuildContext? context,
  }) {
    return showDialog<WithdrawalResult>(
      context: context ?? rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => WithdrawalProcessingDialog(
        scUid: scUid,
        requestHash: requestHash,
        ownerAddress: ownerAddress,
        waitForConfirmation: waitForConfirmation,
      ),
    );
  }

  @override
  State<WithdrawalProcessingDialog> createState() => _WithdrawalProcessingDialogState();
}

enum _DialogState { waitingForBlock, processing, success, failure }

class _WithdrawalProcessingDialogState extends State<WithdrawalProcessingDialog> {
  _DialogState _state = _DialogState.processing;
  WithdrawalResult? _result;
  Timer? _confirmationTimer;
  int _confirmationPollCount = 0;
  static const _maxConfirmationPolls = 60; // 60 * 5s = 5 minutes max
  static const _confirmationPollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    if (widget.waitForConfirmation) {
      _waitForRequestConfirmation();
    } else {
      _runCompleteWithdrawal();
    }
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    super.dispose();
  }

  Future<void> _waitForRequestConfirmation() async {
    debugPrint('$_tag Waiting for request tx to be confirmed in a block — hash: ${widget.requestHash}');
    setState(() => _state = _DialogState.waitingForBlock);
    _confirmationPollCount = 0;

    _confirmationTimer = Timer.periodic(_confirmationPollInterval, (timer) async {
      _confirmationPollCount++;
      debugPrint('$_tag Confirmation poll #$_confirmationPollCount for ${widget.requestHash}');

      if (_confirmationPollCount > _maxConfirmationPolls) {
        timer.cancel();
        if (!mounted) return;
        debugPrint('$_tag Confirmation poll timed out after $_maxConfirmationPolls attempts');
        setState(() {
          _result = const WithdrawalResult(
            success: false,
            message: "Timed out waiting for withdrawal request to be confirmed. You can retry later.",
          );
          _state = _DialogState.failure;
        });
        return;
      }

      try {
        final transactions = await LocalTransactionService().transactionsAll();
        final match = transactions.where(
          (tx) => tx.hash == widget.requestHash && tx.height > 0,
        );

        if (match.isNotEmpty) {
          timer.cancel();
          debugPrint('$_tag Request tx confirmed in block ${match.first.height} — proceeding to completeWithdrawal');
          if (!mounted) return;
          _runCompleteWithdrawal();
        }
      } catch (e) {
        debugPrint('$_tag Confirmation poll error: $e');
      }
    });
  }

  Future<void> _runCompleteWithdrawal() async {
    debugPrint('$_tag Calling completeWithdrawal — scUid: ${widget.scUid}, requestHash: ${widget.requestHash}');
    setState(() => _state = _DialogState.processing);

    final result = await VbtcV2Service().completeWithdrawal(
      scUid: widget.scUid,
      withdrawalRequestHash: widget.requestHash,
    );

    if (!mounted) return;

    debugPrint('$_tag completeWithdrawal result — success: ${result.success}, vfxTx: ${result.vfxTransactionHash}, btcTx: ${result.btcTransactionHash}, message: ${result.message}');

    setState(() {
      _result = result;
      _state = result.success ? _DialogState.success : _DialogState.failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForState(),
            style: const TextStyle(color: Colors.white),
          ),
          if (_state != _DialogState.processing && _state != _DialogState.waitingForBlock)
            IconButton(
              onPressed: () => Navigator.of(context).pop(_result),
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
            if (_state == _DialogState.waitingForBlock) _buildWaitingForBlockSection(),
            if (_state == _DialogState.processing) _buildProcessingSection(),
            if (_state == _DialogState.success) _buildSuccessSection(),
            if (_state == _DialogState.failure) _buildFailureSection(),
          ],
        ),
      ),
    );
  }

  String _titleForState() {
    switch (_state) {
      case _DialogState.waitingForBlock:
        return "Waiting for Confirmation";
      case _DialogState.processing:
        return "Processing Withdrawal";
      case _DialogState.success:
        return "Withdrawal Complete";
      case _DialogState.failure:
        return "Withdrawal Failed";
    }
  }

  Widget _buildWaitingForBlockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Waiting for the withdrawal request to be confirmed in a block...",
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        Text(
          "This typically takes 10-20 seconds. The FROST signing will begin automatically once confirmed.",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProcessingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Validators are signing the Bitcoin transaction...",
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        Text(
          "This may take a minute. Please do not close the application.",
          style: TextStyle(color: Colors.white38, fontSize: 12),
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
            Icon(Icons.check_circle, color: _successColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Withdrawal completed successfully!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (_result?.vfxTransactionHash != null) ...[
          const SizedBox(height: 16),
          _buildHashRow(
            "VFX Transaction:",
            _result!.vfxTransactionHash!,
            explorerUrl: "${Env.baseExplorerUrl}/transaction/${_result!.vfxTransactionHash!}",
          ),
        ],
        if (_result?.btcTransactionHash != null) ...[
          const SizedBox(height: 12),
          _buildHashRow(
            "BTC Transaction:",
            _result!.btcTransactionHash!,
            explorerUrl: Env.isTestNet
                ? "https://mempool.space/testnet4/tx/${_result!.btcTransactionHash!}"
                : "https://mempool.space/tx/${_result!.btcTransactionHash!}",
          ),
        ],
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: "Done",
            variant: AppColorVariant.Success,
            onPressed: () => Navigator.of(context).pop(_result),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureSection() {
    final canCancel = widget.ownerAddress != null && _result?.btcTransactionHash != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: _dangerColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _result?.message ?? "An error occurred during withdrawal.",
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
              label: "Dismiss",
              variant: AppColorVariant.Light,
              onPressed: () => Navigator.of(context).pop(_result),
            ),
            const SizedBox(width: 8),
            if (canCancel) ...[
              AppButton(
                label: "Cancel Withdrawal",
                variant: AppColorVariant.Danger,
                onPressed: _cancelWithdrawal,
              ),
              const SizedBox(width: 8),
            ],
            AppButton(
              label: "Retry",
              variant: AppColorVariant.Warning,
              onPressed: _runCompleteWithdrawal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHashRow(String label, String hash, {String? explorerUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                hash,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: hash));
                Toast.message("Copied to clipboard");
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

  Future<void> _cancelWithdrawal() async {
    if (widget.ownerAddress == null || _result?.btcTransactionHash == null) return;

    debugPrint('$_tag Cancelling withdrawal — scUid: ${widget.scUid}, requestHash: ${widget.requestHash}, btcTx: ${_result!.btcTransactionHash}');
    setState(() => _state = _DialogState.processing);

    final success = await VbtcV2Service().cancelWithdrawal(
      scUid: widget.scUid,
      ownerAddress: widget.ownerAddress!,
      withdrawalRequestHash: widget.requestHash,
      btcTxHash: _result!.btcTransactionHash!,
      failureProof: "Withdrawal failed — cancelled by user via GUI.",
    );

    if (!mounted) return;

    debugPrint('$_tag Cancel result — success: $success');
    if (success) {
      Toast.message("Cancellation request submitted. Awaiting validator votes.");
      Navigator.of(context).pop(null);
    } else {
      setState(() => _state = _DialogState.failure);
    }
  }
}

const _successColor = Color(0xFF43ae52);
const _dangerColor = Color(0xFFBA2121);
