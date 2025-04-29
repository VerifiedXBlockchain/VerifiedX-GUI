import 'package:rbx_wallet/core/utils.dart';

class VBtcInput {
  final String scId;
  final String vfxFromAddress;
  final String vfxToAddress;
  final double amount;
  // late String signature;

  VBtcInput({
    required this.scId,
    required this.vfxFromAddress,
    required this.vfxToAddress,
    required this.amount,
  }) {
    // signature = "${generateRandomString(8)}$vfxToAddress$vfxFromAddress";
  }

  VBtcInput updateAmount(double amount) {
    return VBtcInput(
      scId: scId,
      vfxFromAddress: vfxFromAddress,
      vfxToAddress: vfxToAddress,
      amount: amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "scuid": scId,
      "fromAddress": vfxFromAddress,
      "amount": amount,
      // "signature": signature,
    };
  }
}
