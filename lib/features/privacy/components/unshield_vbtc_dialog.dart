import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../btc/models/tokenized_bitcoin.dart';

class UnshieldVbtcDialog extends StatelessWidget {
  final TokenizedBitcoin token;

  const UnshieldVbtcDialog({super.key, required this.token});

  static void show(TokenizedBitcoin token) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => UnshieldVbtcDialog(token: token),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stub — full implementation in Phase 5
    return const SizedBox.shrink();
  }
}
