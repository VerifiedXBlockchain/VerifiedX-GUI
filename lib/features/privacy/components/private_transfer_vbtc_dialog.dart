import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../btc/models/tokenized_bitcoin.dart';

class PrivateTransferVbtcDialog extends StatelessWidget {
  final TokenizedBitcoin token;

  const PrivateTransferVbtcDialog({super.key, required this.token});

  static void show(TokenizedBitcoin token) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => PrivateTransferVbtcDialog(token: token),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stub — full implementation in Phase 5
    return const SizedBox.shrink();
  }
}
