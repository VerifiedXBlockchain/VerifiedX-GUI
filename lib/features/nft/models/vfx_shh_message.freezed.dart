// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vfx_shh_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$VfxShhMessage {
  String get recipientAddress => throw _privateConstructorUsedError;
  String get encryptedData => throw _privateConstructorUsedError;
  String get rawMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VfxShhMessageCopyWith<VfxShhMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VfxShhMessageCopyWith<$Res> {
  factory $VfxShhMessageCopyWith(
          VfxShhMessage value, $Res Function(VfxShhMessage) then) =
      _$VfxShhMessageCopyWithImpl<$Res, VfxShhMessage>;
  @useResult
  $Res call({String recipientAddress, String encryptedData, String rawMessage});
}

/// @nodoc
class _$VfxShhMessageCopyWithImpl<$Res, $Val extends VfxShhMessage>
    implements $VfxShhMessageCopyWith<$Res> {
  _$VfxShhMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientAddress = null,
    Object? encryptedData = null,
    Object? rawMessage = null,
  }) {
    return _then(_value.copyWith(
      recipientAddress: null == recipientAddress
          ? _value.recipientAddress
          : recipientAddress // ignore: cast_nullable_to_non_nullable
              as String,
      encryptedData: null == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String,
      rawMessage: null == rawMessage
          ? _value.rawMessage
          : rawMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_VfxShhMessageCopyWith<$Res>
    implements $VfxShhMessageCopyWith<$Res> {
  factory _$$_VfxShhMessageCopyWith(
          _$_VfxShhMessage value, $Res Function(_$_VfxShhMessage) then) =
      __$$_VfxShhMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String recipientAddress, String encryptedData, String rawMessage});
}

/// @nodoc
class __$$_VfxShhMessageCopyWithImpl<$Res>
    extends _$VfxShhMessageCopyWithImpl<$Res, _$_VfxShhMessage>
    implements _$$_VfxShhMessageCopyWith<$Res> {
  __$$_VfxShhMessageCopyWithImpl(
      _$_VfxShhMessage _value, $Res Function(_$_VfxShhMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientAddress = null,
    Object? encryptedData = null,
    Object? rawMessage = null,
  }) {
    return _then(_$_VfxShhMessage(
      recipientAddress: null == recipientAddress
          ? _value.recipientAddress
          : recipientAddress // ignore: cast_nullable_to_non_nullable
              as String,
      encryptedData: null == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String,
      rawMessage: null == rawMessage
          ? _value.rawMessage
          : rawMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_VfxShhMessage extends _VfxShhMessage {
  const _$_VfxShhMessage(
      {required this.recipientAddress,
      required this.encryptedData,
      required this.rawMessage})
      : super._();

  @override
  final String recipientAddress;
  @override
  final String encryptedData;
  @override
  final String rawMessage;

  @override
  String toString() {
    return 'VfxShhMessage(recipientAddress: $recipientAddress, encryptedData: $encryptedData, rawMessage: $rawMessage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_VfxShhMessage &&
            (identical(other.recipientAddress, recipientAddress) ||
                other.recipientAddress == recipientAddress) &&
            (identical(other.encryptedData, encryptedData) ||
                other.encryptedData == encryptedData) &&
            (identical(other.rawMessage, rawMessage) ||
                other.rawMessage == rawMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, recipientAddress, encryptedData, rawMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_VfxShhMessageCopyWith<_$_VfxShhMessage> get copyWith =>
      __$$_VfxShhMessageCopyWithImpl<_$_VfxShhMessage>(this, _$identity);
}

abstract class _VfxShhMessage extends VfxShhMessage {
  const factory _VfxShhMessage(
      {required final String recipientAddress,
      required final String encryptedData,
      required final String rawMessage}) = _$_VfxShhMessage;
  const _VfxShhMessage._() : super._();

  @override
  String get recipientAddress;
  @override
  String get encryptedData;
  @override
  String get rawMessage;
  @override
  @JsonKey(ignore: true)
  _$$_VfxShhMessageCopyWith<_$_VfxShhMessage> get copyWith =>
      throw _privateConstructorUsedError;
}
