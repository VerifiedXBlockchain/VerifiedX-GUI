import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_screen.dart';
import '../components/butterfly_link_form.dart';

class ButterflyScreen extends BaseScreen {
  final String walletAddress;
  final Future<String?> Function(double amount, String toAddress)
      sendTransaction;

  const ButterflyScreen({
    Key? key,
    required this.walletAddress,
    required this.sendTransaction,
  }) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Payment Link'),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ButterflyLinkForm(
        walletAddress: walletAddress,
        sendTransaction: sendTransaction,
      ),
    );
  }
}
