import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../btc/models/tokenized_bitcoin.dart';

class ShieldVbtcDialog extends StatelessWidget {
  final TokenizedBitcoin token;

  const ShieldVbtcDialog({super.key, required this.token});

  static void show(TokenizedBitcoin token) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (_) => ShieldVbtcDialog(token: token),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stub — full implementation in Phase 5
    return const SizedBox.shrink();
  }
}
