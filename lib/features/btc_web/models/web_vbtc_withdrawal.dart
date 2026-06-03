import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_vbtc_withdrawal.freezed.dart';
part 'web_vbtc_withdrawal.g.dart';

@freezed
class WebVbtcWithdrawal with _$WebVbtcWithdrawal {
  const WebVbtcWithdrawal._();

  factory WebVbtcWithdrawal({
    @JsonKey(name: 'requestor_address') required String requestorAddress,
    @JsonKey(name: 'btc_address') required String btcAddress,
    required String amount,
    @JsonKey(name: 'fee_rate') required String feeRate,
    @JsonKey(name: 'btc_transaction_hash') String? btcTransactionHash,
    required String status,
    @JsonKey(name: 'request_transaction_hash') required String requestTransactionHash,
    @JsonKey(name: 'completion_transaction_hash') String? completionTransactionHash,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _WebVbtcWithdrawal;

  factory WebVbtcWithdrawal.fromJson(Map<String, dynamic> json) => _$WebVbtcWithdrawalFromJson(json);
}
