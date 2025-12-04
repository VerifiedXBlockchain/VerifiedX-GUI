// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'butterfly_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ButterflyLink _$ButterflyLinkFromJson(Map<String, dynamic> json) {
  return _ButterflyLink.fromJson(json);
}

/// @nodoc
mixin _$ButterflyLink {
  @JsonKey(name: 'link_id')
  String get linkId => throw _privateConstructorUsedError;
  @JsonKey(name: 'short_url')
  String get shortUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_url')
  String get fullUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'escrow_address')
  String get escrowAddress => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'claim_amount')
  double get claimAmount => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  ButterflyIcon get icon => throw _privateConstructorUsedError;
  ButterflyLinkStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_address')
  String get senderAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'tx_hash')
  String? get txHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'claimed_at')
  DateTime? get claimedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ButterflyLinkCopyWith<ButterflyLink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ButterflyLinkCopyWith<$Res> {
  factory $ButterflyLinkCopyWith(
          ButterflyLink value, $Res Function(ButterflyLink) then) =
      _$ButterflyLinkCopyWithImpl<$Res, ButterflyLink>;
  @useResult
  $Res call(
      {@JsonKey(name: 'link_id') String linkId,
      @JsonKey(name: 'short_url') String shortUrl,
      @JsonKey(name: 'full_url') String fullUrl,
      @JsonKey(name: 'escrow_address') String escrowAddress,
      double amount,
      @JsonKey(name: 'claim_amount') double claimAmount,
      String message,
      ButterflyIcon icon,
      ButterflyLinkStatus status,
      @JsonKey(name: 'sender_address') String senderAddress,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'tx_hash') String? txHash,
      @JsonKey(name: 'claimed_at') DateTime? claimedAt});
}

/// @nodoc
class _$ButterflyLinkCopyWithImpl<$Res, $Val extends ButterflyLink>
    implements $ButterflyLinkCopyWith<$Res> {
  _$ButterflyLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linkId = null,
    Object? shortUrl = null,
    Object? fullUrl = null,
    Object? escrowAddress = null,
    Object? amount = null,
    Object? claimAmount = null,
    Object? message = null,
    Object? icon = null,
    Object? status = null,
    Object? senderAddress = null,
    Object? createdAt = null,
    Object? txHash = freezed,
    Object? claimedAt = freezed,
  }) {
    return _then(_value.copyWith(
      linkId: null == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      shortUrl: null == shortUrl
          ? _value.shortUrl
          : shortUrl // ignore: cast_nullable_to_non_nullable
              as String,
      fullUrl: null == fullUrl
          ? _value.fullUrl
          : fullUrl // ignore: cast_nullable_to_non_nullable
              as String,
      escrowAddress: null == escrowAddress
          ? _value.escrowAddress
          : escrowAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      claimAmount: null == claimAmount
          ? _value.claimAmount
          : claimAmount // ignore: cast_nullable_to_non_nullable
              as double,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as ButterflyIcon,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ButterflyLinkStatus,
      senderAddress: null == senderAddress
          ? _value.senderAddress
          : senderAddress // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      txHash: freezed == txHash
          ? _value.txHash
          : txHash // ignore: cast_nullable_to_non_nullable
              as String?,
      claimedAt: freezed == claimedAt
          ? _value.claimedAt
          : claimedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ButterflyLinkCopyWith<$Res>
    implements $ButterflyLinkCopyWith<$Res> {
  factory _$$_ButterflyLinkCopyWith(
          _$_ButterflyLink value, $Res Function(_$_ButterflyLink) then) =
      __$$_ButterflyLinkCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'link_id') String linkId,
      @JsonKey(name: 'short_url') String shortUrl,
      @JsonKey(name: 'full_url') String fullUrl,
      @JsonKey(name: 'escrow_address') String escrowAddress,
      double amount,
      @JsonKey(name: 'claim_amount') double claimAmount,
      String message,
      ButterflyIcon icon,
      ButterflyLinkStatus status,
      @JsonKey(name: 'sender_address') String senderAddress,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'tx_hash') String? txHash,
      @JsonKey(name: 'claimed_at') DateTime? claimedAt});
}

/// @nodoc
class __$$_ButterflyLinkCopyWithImpl<$Res>
    extends _$ButterflyLinkCopyWithImpl<$Res, _$_ButterflyLink>
    implements _$$_ButterflyLinkCopyWith<$Res> {
  __$$_ButterflyLinkCopyWithImpl(
      _$_ButterflyLink _value, $Res Function(_$_ButterflyLink) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linkId = null,
    Object? shortUrl = null,
    Object? fullUrl = null,
    Object? escrowAddress = null,
    Object? amount = null,
    Object? claimAmount = null,
    Object? message = null,
    Object? icon = null,
    Object? status = null,
    Object? senderAddress = null,
    Object? createdAt = null,
    Object? txHash = freezed,
    Object? claimedAt = freezed,
  }) {
    return _then(_$_ButterflyLink(
      linkId: null == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      shortUrl: null == shortUrl
          ? _value.shortUrl
          : shortUrl // ignore: cast_nullable_to_non_nullable
              as String,
      fullUrl: null == fullUrl
          ? _value.fullUrl
          : fullUrl // ignore: cast_nullable_to_non_nullable
              as String,
      escrowAddress: null == escrowAddress
          ? _value.escrowAddress
          : escrowAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      claimAmount: null == claimAmount
          ? _value.claimAmount
          : claimAmount // ignore: cast_nullable_to_non_nullable
              as double,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as ButterflyIcon,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ButterflyLinkStatus,
      senderAddress: null == senderAddress
          ? _value.senderAddress
          : senderAddress // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      txHash: freezed == txHash
          ? _value.txHash
          : txHash // ignore: cast_nullable_to_non_nullable
              as String?,
      claimedAt: freezed == claimedAt
          ? _value.claimedAt
          : claimedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ButterflyLink extends _ButterflyLink {
  const _$_ButterflyLink(
      {@JsonKey(name: 'link_id') required this.linkId,
      @JsonKey(name: 'short_url') required this.shortUrl,
      @JsonKey(name: 'full_url') required this.fullUrl,
      @JsonKey(name: 'escrow_address') required this.escrowAddress,
      required this.amount,
      @JsonKey(name: 'claim_amount') required this.claimAmount,
      required this.message,
      required this.icon,
      required this.status,
      @JsonKey(name: 'sender_address') required this.senderAddress,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'tx_hash') this.txHash,
      @JsonKey(name: 'claimed_at') this.claimedAt})
      : super._();

  factory _$_ButterflyLink.fromJson(Map<String, dynamic> json) =>
      _$$_ButterflyLinkFromJson(json);

  @override
  @JsonKey(name: 'link_id')
  final String linkId;
  @override
  @JsonKey(name: 'short_url')
  final String shortUrl;
  @override
  @JsonKey(name: 'full_url')
  final String fullUrl;
  @override
  @JsonKey(name: 'escrow_address')
  final String escrowAddress;
  @override
  final double amount;
  @override
  @JsonKey(name: 'claim_amount')
  final double claimAmount;
  @override
  final String message;
  @override
  final ButterflyIcon icon;
  @override
  final ButterflyLinkStatus status;
  @override
  @JsonKey(name: 'sender_address')
  final String senderAddress;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'tx_hash')
  final String? txHash;
  @override
  @JsonKey(name: 'claimed_at')
  final DateTime? claimedAt;

  @override
  String toString() {
    return 'ButterflyLink(linkId: $linkId, shortUrl: $shortUrl, fullUrl: $fullUrl, escrowAddress: $escrowAddress, amount: $amount, claimAmount: $claimAmount, message: $message, icon: $icon, status: $status, senderAddress: $senderAddress, createdAt: $createdAt, txHash: $txHash, claimedAt: $claimedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ButterflyLink &&
            (identical(other.linkId, linkId) || other.linkId == linkId) &&
            (identical(other.shortUrl, shortUrl) ||
                other.shortUrl == shortUrl) &&
            (identical(other.fullUrl, fullUrl) || other.fullUrl == fullUrl) &&
            (identical(other.escrowAddress, escrowAddress) ||
                other.escrowAddress == escrowAddress) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.claimAmount, claimAmount) ||
                other.claimAmount == claimAmount) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.senderAddress, senderAddress) ||
                other.senderAddress == senderAddress) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.claimedAt, claimedAt) ||
                other.claimedAt == claimedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      linkId,
      shortUrl,
      fullUrl,
      escrowAddress,
      amount,
      claimAmount,
      message,
      icon,
      status,
      senderAddress,
      createdAt,
      txHash,
      claimedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ButterflyLinkCopyWith<_$_ButterflyLink> get copyWith =>
      __$$_ButterflyLinkCopyWithImpl<_$_ButterflyLink>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ButterflyLinkToJson(
      this,
    );
  }
}

abstract class _ButterflyLink extends ButterflyLink {
  const factory _ButterflyLink(
          {@JsonKey(name: 'link_id') required final String linkId,
          @JsonKey(name: 'short_url') required final String shortUrl,
          @JsonKey(name: 'full_url') required final String fullUrl,
          @JsonKey(name: 'escrow_address') required final String escrowAddress,
          required final double amount,
          @JsonKey(name: 'claim_amount') required final double claimAmount,
          required final String message,
          required final ButterflyIcon icon,
          required final ButterflyLinkStatus status,
          @JsonKey(name: 'sender_address') required final String senderAddress,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'tx_hash') final String? txHash,
          @JsonKey(name: 'claimed_at') final DateTime? claimedAt}) =
      _$_ButterflyLink;
  const _ButterflyLink._() : super._();

  factory _ButterflyLink.fromJson(Map<String, dynamic> json) =
      _$_ButterflyLink.fromJson;

  @override
  @JsonKey(name: 'link_id')
  String get linkId;
  @override
  @JsonKey(name: 'short_url')
  String get shortUrl;
  @override
  @JsonKey(name: 'full_url')
  String get fullUrl;
  @override
  @JsonKey(name: 'escrow_address')
  String get escrowAddress;
  @override
  double get amount;
  @override
  @JsonKey(name: 'claim_amount')
  double get claimAmount;
  @override
  String get message;
  @override
  ButterflyIcon get icon;
  @override
  ButterflyLinkStatus get status;
  @override
  @JsonKey(name: 'sender_address')
  String get senderAddress;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'tx_hash')
  String? get txHash;
  @override
  @JsonKey(name: 'claimed_at')
  DateTime? get claimedAt;
  @override
  @JsonKey(ignore: true)
  _$$_ButterflyLinkCopyWith<_$_ButterflyLink> get copyWith =>
      throw _privateConstructorUsedError;
}
