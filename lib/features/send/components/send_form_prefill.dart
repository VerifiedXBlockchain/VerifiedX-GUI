import 'package:flutter/material.dart';

/// Writes a send link's recipient and amount into the form controllers once,
/// when this widget is first mounted. Rebuilds of the surrounding screen (a
/// balance refresh, a wallet switch) leave whatever the user has typed alone.
class SendFormPrefill extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController amountController;
  final String address;
  final String amount;
  final Widget child;

  const SendFormPrefill({
    Key? key,
    required this.addressController,
    required this.amountController,
    required this.address,
    required this.amount,
    required this.child,
  }) : super(key: key);

  @override
  State<SendFormPrefill> createState() => _SendFormPrefillState();
}

class _SendFormPrefillState extends State<SendFormPrefill> {
  @override
  void initState() {
    super.initState();
    // The controllers notify the send form provider, which may not change
    // while the tree is building, so the prefill lands after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.addressController.text = widget.address;
      widget.amountController.text = widget.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
