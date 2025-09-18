import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onramp_purchase_details.freezed.dart';
part 'onramp_purchase_details.g.dart';

enum OnrampPurchaseProvider {
  @JsonValue(null)
  none,
  @JsonValue('stripe')
  stripe,
  @JsonValue('crypto_dot_com')
  cryptoDotCom,
}

enum OnrampPurchaseStatus {
  @JsonValue('initialized')
  initialized,
  @JsonValue('canceled')
  canceled,
  @JsonValue('quoted')
  quoted,
  @JsonValue('payment_intended')
  paymentIntended,
  @JsonValue('payment_processed')
  paymentProcessed,
  @JsonValue('payment_captured')
  paymentCaptured,
  @JsonValue('transaction_sent')
  transactionSent,
  @JsonValue('transaction_settled')
  transactionSettled,
}

@freezed
class OnrampPurchaseDetails with _$OnrampPurchaseDetails {
  const OnrampPurchaseDetails._();

  const factory OnrampPurchaseDetails({
    required String uuid,
    OnrampPurchaseProvider? provider,
    @JsonKey(name: 'vfx_address') required String vfxAddress,
    @JsonKey(name: 'vfx_transaction_hash') String? vfxTransactionHash,
    required OnrampPurchaseStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _OnrampPurchaseDetails;

  factory OnrampPurchaseDetails.fromJson(Map<String, dynamic> json) =>
      _$OnrampPurchaseDetailsFromJson(json);

  String get statusLabel {
    switch (status) {
      case OnrampPurchaseStatus.initialized:
        return "Initialized";

      case OnrampPurchaseStatus.canceled:
        return "Cancelled";

      case OnrampPurchaseStatus.quoted:
        return "Quoted";

      case OnrampPurchaseStatus.paymentIntended:
        return "Awaiting Payment";

      case OnrampPurchaseStatus.paymentProcessed:
        return "Payment Processed";

      case OnrampPurchaseStatus.paymentCaptured:
        return "Payment Captured";

      case OnrampPurchaseStatus.transactionSent:
        return "Transaction Sent";

      case OnrampPurchaseStatus.transactionSettled:
        return "Transaction Settled";
    }
  }

  IconData? get statusIcon {
    switch (status) {
      case OnrampPurchaseStatus.transactionSettled:
        return Icons.check;
      case OnrampPurchaseStatus.canceled:
        return Icons.cancel;
      default:
        return null;
    }
  }
}
