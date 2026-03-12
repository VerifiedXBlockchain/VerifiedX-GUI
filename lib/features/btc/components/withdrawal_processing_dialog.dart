import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../models/withdrawal_result.dart';
import '../services/vbtc_v2_service.dart';

class WithdrawalProcessingDialog extends StatefulWidget {
  final String scUid;
  final String requestHash;
  final String? ownerAddress;

  const WithdrawalProcessingDialog({
    super.key,
    required this.scUid,
    required this.requestHash,
    this.ownerAddress,
  });

  /// Show the dialog and begin the completeWithdrawal call immediately.
  static Future<WithdrawalResult?> show({
    required String scUid,
    required String requestHash,
    String? ownerAddress,
    BuildContext? context,
  }) {
    return showDialog<WithdrawalResult>(
      context: context ?? rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => WithdrawalProcessingDialog(
        scUid: scUid,
        requestHash: requestHash,
        ownerAddress: ownerAddress,
      ),
    );
  }

  @override
  State<WithdrawalProcessingDialog> createState() => _WithdrawalProcessingDialogState();
}

enum _DialogState { processing, success, failure }

class _WithdrawalProcessingDialogState extends State<WithdrawalProcessingDialog> {
  _DialogState _state = _DialogState.processing;
  WithdrawalResult? _result;

  @override
  void initState() {
    super.initState();
    _runCompleteWithdrawal();
  }

  Future<void> _runCompleteWithdrawal() async {
    setState(() => _state = _DialogState.processing);

    final result = await VbtcV2Service().completeWithdrawal(
      scUid: widget.scUid,
      withdrawalRequestHash: widget.requestHash,
    );

    if (!mounted) return;

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
          if (_state != _DialogState.processing)
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
      case _DialogState.processing:
        return "Processing Withdrawal";
      case _DialogState.success:
        return "Withdrawal Complete";
      case _DialogState.failure:
        return "Withdrawal Failed";
    }
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
          _buildHashRow("VFX Transaction:", _result!.vfxTransactionHash!),
        ],
        if (_result?.btcTransactionHash != null) ...[
          const SizedBox(height: 12),
          _buildHashRow("BTC Transaction:", _result!.btcTransactionHash!),
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

  Widget _buildHashRow(String label, String hash) {
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
          ],
        ),
      ],
    );
  }

  Future<void> _cancelWithdrawal() async {
    if (widget.ownerAddress == null || _result?.btcTransactionHash == null) return;

    setState(() => _state = _DialogState.processing);

    final success = await VbtcV2Service().cancelWithdrawal(
      scUid: widget.scUid,
      ownerAddress: widget.ownerAddress!,
      withdrawalRequestHash: widget.requestHash,
      btcTxHash: _result!.btcTransactionHash!,
      failureProof: "Withdrawal failed — cancelled by user via GUI.",
    );

    if (!mounted) return;

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
