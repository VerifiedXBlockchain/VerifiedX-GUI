import 'package:freezed_annotation/freezed_annotation.dart';

part 'p2p_collection.freezed.dart';
part 'p2p_collection.g.dart';

/// A shop's collection in the P2P registry (`GET /p2p/collections/{id}/`).
@freezed
class P2pCollection with _$P2pCollection {
  const P2pCollection._();

  factory P2pCollection({
    required int id,
    @JsonKey(name: 'shop_url') required String shopUrl,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'is_live') @Default(true) bool isLive,
    // Every shop gets a default collection, "Main", when it is registered.
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'listing_count') @Default(0) int listingCount,
  }) = _P2pCollection;

  factory P2pCollection.fromJson(Map<String, dynamic> json) => _$P2pCollectionFromJson(json);
}
