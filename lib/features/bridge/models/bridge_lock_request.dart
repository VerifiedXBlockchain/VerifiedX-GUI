import 'package:freezed_annotation/freezed_annotation.dart';

part 'bridge_lock_request.freezed.dart';
part 'bridge_lock_request.g.dart';

/// Request body for `POST /wallet/api/vbtc/bridge/toBase`.
///
/// Mirrors `VBTCBridgeToBaseRequest` on the CLI — note that `amount` is
/// transmitted as a string (matching the existing wallet API convention for
/// vBTC operations).
@freezed
class BridgeLockRequest with _$BridgeLockRequest {
  const BridgeLockRequest._();

  factory BridgeLockRequest({
    @JsonKey(name: "scUID") required String scUid,
    @JsonKey(name: "ownerAddress") required String ownerAddress,
    @JsonKey(name: "amount") required String amount,
    @JsonKey(name: "evmDestination") required String evmDestination,
  }) = _BridgeLockRequest;

  /// Convenience constructor that accepts a numeric amount and formats it for
  /// the wire. Uses [double.toString] which produces a culture-invariant
  /// representation that the CLI's `decimal.TryParse(..., InvariantCulture)`
  /// can read.
  factory BridgeLockRequest.fromValues({
    required String scUid,
    required String ownerAddress,
    required double amount,
    required String evmDestination,
  }) {
    return BridgeLockRequest(
      scUid: scUid,
      ownerAddress: ownerAddress,
      amount: amount.toString(),
      evmDestination: evmDestination,
    );
  }

  factory BridgeLockRequest.fromJson(Map<String, dynamic> json) =>
      _$BridgeLockRequestFromJson(json);
}
