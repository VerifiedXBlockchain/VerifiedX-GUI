import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/butterfly_link.dart';
import '../providers/butterfly_links_provider.dart';
import 'butterfly_creation_dialog.dart';
import 'butterfly_icon_selector.dart';
import 'butterfly_link_card.dart';

class ButterflyForm extends ConsumerStatefulWidget {
  final String walletAddress;
  final double balance;
  final Future<String?> Function(double amount, String toAddress) sendTransaction;

  const ButterflyForm({
    super.key,
    required this.walletAddress,
    required this.balance,
    required this.sendTransaction,
  });

  @override
  ConsumerState<ButterflyForm> createState() => _ButterflyFormState();
}

class _ButterflyFormState extends ConsumerState<ButterflyForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  ButterflyIcon _selectedIcon = ButterflyIcon.defaultIcon;

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    if (amount > widget.balance) {
      return 'Insufficient balance';
    }
    // Minimum amount check (0.01 VFX + fee)
    if (amount < 0.0001) {
      return 'Minimum amount is 0.0001 VFX';
    }
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final message = _messageController.text;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ButterflyCreationDialog(
          amount: amount,
          message: message,
          icon: _selectedIcon,
          walletAddress: widget.walletAddress,
          sendTransaction: widget.sendTransaction,
          onComplete: () {
            _amountController.clear();
            _messageController.clear();
            setState(() {
              _selectedIcon = ButterflyIcon.defaultIcon;
            });
          },
        ),
      );
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Payment Link History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final linksModel = ref.watch(butterflyLinksProvider);
                    final links = linksModel.links;

                    if (links.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link_off,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No payment links yet',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: links.length,
                      itemBuilder: (context, index) {
                        return ButterflyLinkCard(link: links[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linksModel = ref.watch(butterflyLinksProvider);
    final pendingCount = linksModel.links
        .where((l) => l.status == ButterflyLinkStatus.pending ||
            l.status == ButterflyLinkStatus.readyForRedemption)
        .length;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Payment Link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a shareable link to receive VFX. The recipient can claim the funds without needing a wallet.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount (VFX)',
              hintText: 'Enter amount',
              border: const OutlineInputBorder(),
              suffixText: 'VFX',
              helperText: 'Available: ${widget.balance.toStringAsFixed(2)} VFX',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
            ],
            validator: _validateAmount,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message (Optional)',
              hintText: 'What\'s this payment for?',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            maxLength: 100,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          ButterflyIconSelector(
            selectedIcon: _selectedIcon,
            onChanged: (icon) {
              setState(() {
                _selectedIcon = icon;
              });
            },
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Create Payment Link',
            onPressed: _onSubmit,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: pendingCount > 0
                ? 'View History ($pendingCount active)'
                : 'View History',
            type: AppButtonType.Text,
            variant: AppColorVariant.Secondary,
            icon: Icons.history,
            onPressed: _showHistory,
          ),
          const SizedBox(height: 8),
          Text(
            'Note: A small fee (\$0.01 USD in VFX) will be added to cover platform costs.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
