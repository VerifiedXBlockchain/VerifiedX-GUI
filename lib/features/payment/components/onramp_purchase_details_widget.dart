import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/components/centered_loader.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/features/payment/models/onramp_purchase_details.dart';
import 'package:rbx_wallet/features/payment/services/butterfly_service.dart';

class OnrampPurchaseDetailsWidget extends ConsumerStatefulWidget {
  final String purchaseUuid;
  final double targetBalance;

  const OnrampPurchaseDetailsWidget({
    super.key,
    required this.purchaseUuid,
    required this.targetBalance,
  });

  @override
  ConsumerState<OnrampPurchaseDetailsWidget> createState() =>
      _OnrampPurchaseDetailsWidgetState();
}

class _OnrampPurchaseDetailsWidgetState
    extends ConsumerState<OnrampPurchaseDetailsWidget> {
  OnrampPurchaseDetails? purchase;

  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    final p =
        await ButterflyService().retrievePurchaseDetails(widget.purchaseUuid);

    setState(() {
      purchase = p;
    });

    if (p?.status == OnrampPurchaseStatus.canceled) {
      Navigator.of(context).pop(false);
      return;
    }
    if (p?.status == OnrampPurchaseStatus.transactionSettled) {
      final balance = kIsWeb
          ? ref.read(webSessionProvider).currentWallet?.balance
          : ref.read(sessionProvider).currentWallet?.balance;

      if (balance != null && balance >= widget.targetBalance) {
        Navigator.of(context).pop(true);
        return;
      }
    }

    await Future.delayed(Duration(seconds: 5));
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (purchase == null) {
      return SizedBox(height: 64, child: CenteredLoader());
    }

    final p = purchase!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (p.statusIcon != null)
          Icon(p.statusIcon!)
        else
          SizedBox(height: 64, child: CenteredLoader()),
        SizedBox(
          height: 8,
        ),
        Text("Status: ${p.statusLabel}"),
      ],
    );
  }
}
