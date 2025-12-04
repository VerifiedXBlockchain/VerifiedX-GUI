import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../../price/providers/price_detail_providers.dart';
import '../models/butterfly_link.dart';
import '../providers/butterfly_creation_provider.dart';

class ButterflyCreateLinkDialog extends ConsumerStatefulWidget {
  final double amount;
  final String message;
  final ButterflyIcon icon;
  final String walletAddress;
  final Future<String?> Function(double amount, String toAddress) sendTransaction;
  final VoidCallback? onComplete;

  const ButterflyCreateLinkDialog({
    super.key,
    required this.amount,
    required this.message,
    required this.icon,
    required this.walletAddress,
    required this.sendTransaction,
    this.onComplete,
  });

  @override
  ConsumerState<ButterflyCreateLinkDialog> createState() =>
      _ButterflyCreateLinkDialogState();
}

class _ButterflyCreateLinkDialogState
    extends ConsumerState<ButterflyCreateLinkDialog> {
  @override
  void initState() {
    super.initState();
    // Initialize the creation provider with input values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(butterflyCreationProvider.notifier).setInput(
            widget.amount,
            widget.message,
            widget.icon,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(butterflyCreationProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getStepIcon(state.step),
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(state.stepTitle),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: _buildContent(state),
      ),
      actions: _buildActions(state),
    );
  }

  IconData _getStepIcon(ButterflyCreationStep step) {
    switch (step) {
      case ButterflyCreationStep.input:
        return Icons.edit;
      case ButterflyCreationStep.confirm:
        return Icons.check_circle_outline;
      case ButterflyCreationStep.sendingTx:
        return Icons.send;
      case ButterflyCreationStep.waitingForFund:
        return Icons.hourglass_empty;
      case ButterflyCreationStep.complete:
        return Icons.celebration;
      case ButterflyCreationStep.error:
        return Icons.error_outline;
    }
  }

  Widget _buildContent(ButterflyCreationState state) {
    switch (state.step) {
      case ButterflyCreationStep.input:
        return const SizedBox.shrink();

      case ButterflyCreationStep.confirm:
        return _buildConfirmContent(state);

      case ButterflyCreationStep.sendingTx:
        return _buildProcessingContent('Sending VFX to escrow...');

      case ButterflyCreationStep.waitingForFund:
        return _buildProcessingContent(
          'Waiting for deposit confirmation...\nThis may take up to 20 seconds.',
        );

      case ButterflyCreationStep.complete:
        return _buildCompleteContent(state);

      case ButterflyCreationStep.error:
        return _buildErrorContent(state);
    }
  }

  Widget _buildConfirmContent(ButterflyCreationState state) {
    // Calculate fee: $0.01 USD converted to VFX
    final vfxPrice = ref.watch(vfxCurrentPriceDataDetailProvider);
    const feeInUsd = 0.01;
    // If price is available, calculate fee in VFX; otherwise use a fallback
    final estimatedFee = vfxPrice != null && vfxPrice > 0
        ? feeInUsd / vfxPrice
        : 0.01; // Fallback if price not available
  print('vfxPrice:$vfxPrice');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Amount', '${state.amount.toStringAsFixed(8)} VFX'),
        const SizedBox(height: 8),
        _buildDetailRow('Estimated Fee', '~${estimatedFee.toStringAsFixed(8)} VFX (\$$feeInUsd)'),
        const Divider(),
        _buildDetailRow(
          'Total',
          '~${(state.amount + estimatedFee).toStringAsFixed(8)} VFX',
          bold: true,
        ),
        const SizedBox(height: 16),
        if (state.message.isNotEmpty) ...[
          _buildDetailRow('Message', state.message),
          const SizedBox(height: 8),
        ],
        _buildDetailRow('From', _truncateAddress(widget.walletAddress)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The recipient will receive ${state.amount.toStringAsFixed(2)} VFX when they claim the link.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[300],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingContent(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const CenteredLoader(),
        const SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCompleteContent(ButterflyCreationState state) {
    final link = state.completedLink;
    if (link == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Payment link created successfully!',
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                link.shortUrl,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    label: 'Copy Link',
                    type: AppButtonType.Outlined,
                    variant: AppColorVariant.Secondary,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link.fullUrl));
                      Toast.message('Link copied to clipboard!');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Share this link with the recipient. They can claim the VFX without needing a wallet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(ButterflyCreationState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[300],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }

  List<Widget> _buildActions(ButterflyCreationState state) {
    switch (state.step) {
      case ButterflyCreationStep.input:
        return [];

      case ButterflyCreationStep.confirm:
        return [
          TextButton(
            onPressed: () {
              ref.read(butterflyCreationProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Confirm & Send',
            icon: Icons.send,
            onPressed: _onConfirm,
          ),
        ];

      case ButterflyCreationStep.sendingTx:
      case ButterflyCreationStep.waitingForFund:
        return []; // No actions while processing

      case ButterflyCreationStep.complete:
        return [
          AppButton(
            label: 'Done',
            variant: AppColorVariant.Success,
            onPressed: () {
              ref.read(butterflyCreationProvider.notifier).reset();
              widget.onComplete?.call();
              Navigator.of(context).pop();
            },
          ),
        ];

      case ButterflyCreationStep.error:
        return [
          TextButton(
            onPressed: () {
              ref.read(butterflyCreationProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          AppButton(
            label: 'Try Again',
            icon: Icons.refresh,
            onPressed: () {
              ref.read(butterflyCreationProvider.notifier).setInput(
                    widget.amount,
                    widget.message,
                    widget.icon,
                  );
            },
          ),
        ];
    }
  }

  Future<void> _onConfirm() async {
    await ref.read(butterflyCreationProvider.notifier).createAndSend(
          sendTransaction: widget.sendTransaction,
          senderAddress: widget.walletAddress,
        );
  }
}
