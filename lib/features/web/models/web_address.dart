import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/json_converters.dart';

part 'web_address.freezed.dart';
part 'web_address.g.dart';

@freezed
abstract class WebAddress with _$WebAddress {
  const WebAddress._();

  factory WebAddress({
    required String address,
    @NumOrStringDoubleConverter() required double balance,
    @JsonKey(name: "balance_total") @NumOrStringDoubleConverter() @Default(0) double balanceTotal,
    @JsonKey(name: "balance_locked") @NumOrStringDoubleConverter() @Default(0) double balanceLocked,
    String? adnr,
    @Default(false) bool activated,
    @Default(false) bool deactivated,
  }) = _WebAddress;

  factory WebAddress.fromJson(Map<String, dynamic> json) =>
      _$WebAddressFromJson(json);
}
