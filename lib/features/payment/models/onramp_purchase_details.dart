import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../l10n/l10n_helper.dart';

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
        return globalL10n.r3dStatusInitialized;

      case OnrampPurchaseStatus.canceled:
        return globalL10n.bw2Cancelled;

      case OnrampPurchaseStatus.quoted:
        return globalL10n.r3dStatusQuoted;

      case OnrampPurchaseStatus.paymentIntended:
        return globalL10n.r3dAwaitingPayment;

      case OnrampPurchaseStatus.paymentProcessed:
        return globalL10n.r3dPaymentProcessed;

      case OnrampPurchaseStatus.paymentCaptured:
        return globalL10n.r3dPaymentCaptured;

      case OnrampPurchaseStatus.transactionSent:
        return globalL10n.txpTransactionSent;

      case OnrampPurchaseStatus.transactionSettled:
        return globalL10n.r3dTransactionSettled;
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
