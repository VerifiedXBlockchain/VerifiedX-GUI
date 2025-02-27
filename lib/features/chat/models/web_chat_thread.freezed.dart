// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'web_chat_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WebChatThread _$WebChatThreadFromJson(Map<String, dynamic> json) {
  return _WebChatThread.fromJson(json);
}

/// @nodoc
mixin _$WebChatThread {
  String get uuid => throw _privateConstructorUsedError;
  WebShop get shop => throw _privateConstructorUsedError;
  @JsonKey(name: "is_third_party")
  bool get isThirdParty => throw _privateConstructorUsedError;
  @JsonKey(name: "buyer_address")
  String get buyerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<WebChatMessage> get messages => throw _privateConstructorUsedError;
  @JsonKey(name: "latest_message")
  WebChatMessage? get latestMessage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WebChatThreadCopyWith<WebChatThread> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebChatThreadCopyWith<$Res> {
  factory $WebChatThreadCopyWith(
          WebChatThread value, $Res Function(WebChatThread) then) =
      _$WebChatThreadCopyWithImpl<$Res, WebChatThread>;
  @useResult
  $Res call(
      {String uuid,
      WebShop shop,
      @JsonKey(name: "is_third_party") bool isThirdParty,
      @JsonKey(name: "buyer_address") String buyerAddress,
      @JsonKey(name: "created_at") DateTime createdAt,
      List<WebChatMessage> messages,
      @JsonKey(name: "latest_message") WebChatMessage? latestMessage});

  $WebShopCopyWith<$Res> get shop;
  $WebChatMessageCopyWith<$Res>? get latestMessage;
}

/// @nodoc
class _$WebChatThreadCopyWithImpl<$Res, $Val extends WebChatThread>
    implements $WebChatThreadCopyWith<$Res> {
  _$WebChatThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? shop = null,
    Object? isThirdParty = null,
    Object? buyerAddress = null,
    Object? createdAt = null,
    Object? messages = null,
    Object? latestMessage = freezed,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      shop: null == shop
          ? _value.shop
          : shop // ignore: cast_nullable_to_non_nullable
              as WebShop,
      isThirdParty: null == isThirdParty
          ? _value.isThirdParty
          : isThirdParty // ignore: cast_nullable_to_non_nullable
              as bool,
      buyerAddress: null == buyerAddress
          ? _value.buyerAddress
          : buyerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<WebChatMessage>,
      latestMessage: freezed == latestMessage
          ? _value.latestMessage
          : latestMessage // ignore: cast_nullable_to_non_nullable
              as WebChatMessage?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WebShopCopyWith<$Res> get shop {
    return $WebShopCopyWith<$Res>(_value.shop, (value) {
      return _then(_value.copyWith(shop: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WebChatMessageCopyWith<$Res>? get latestMessage {
    if (_value.latestMessage == null) {
      return null;
    }

    return $WebChatMessageCopyWith<$Res>(_value.latestMessage!, (value) {
      return _then(_value.copyWith(latestMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_WebChatThreadCopyWith<$Res>
    implements $WebChatThreadCopyWith<$Res> {
  factory _$$_WebChatThreadCopyWith(
          _$_WebChatThread value, $Res Function(_$_WebChatThread) then) =
      __$$_WebChatThreadCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uuid,
      WebShop shop,
      @JsonKey(name: "is_third_party") bool isThirdParty,
      @JsonKey(name: "buyer_address") String buyerAddress,
      @JsonKey(name: "created_at") DateTime createdAt,
      List<WebChatMessage> messages,
      @JsonKey(name: "latest_message") WebChatMessage? latestMessage});

  @override
  $WebShopCopyWith<$Res> get shop;
  @override
  $WebChatMessageCopyWith<$Res>? get latestMessage;
}

/// @nodoc
class __$$_WebChatThreadCopyWithImpl<$Res>
    extends _$WebChatThreadCopyWithImpl<$Res, _$_WebChatThread>
    implements _$$_WebChatThreadCopyWith<$Res> {
  __$$_WebChatThreadCopyWithImpl(
      _$_WebChatThread _value, $Res Function(_$_WebChatThread) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? shop = null,
    Object? isThirdParty = null,
    Object? buyerAddress = null,
    Object? createdAt = null,
    Object? messages = null,
    Object? latestMessage = freezed,
  }) {
    return _then(_$_WebChatThread(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      shop: null == shop
          ? _value.shop
          : shop // ignore: cast_nullable_to_non_nullable
              as WebShop,
      isThirdParty: null == isThirdParty
          ? _value.isThirdParty
          : isThirdParty // ignore: cast_nullable_to_non_nullable
              as bool,
      buyerAddress: null == buyerAddress
          ? _value.buyerAddress
          : buyerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<WebChatMessage>,
      latestMessage: freezed == latestMessage
          ? _value.latestMessage
          : latestMessage // ignore: cast_nullable_to_non_nullable
              as WebChatMessage?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_WebChatThread extends _WebChatThread {
  _$_WebChatThread(
      {required this.uuid,
      required this.shop,
      @JsonKey(name: "is_third_party") required this.isThirdParty,
      @JsonKey(name: "buyer_address") required this.buyerAddress,
      @JsonKey(name: "created_at") required this.createdAt,
      final List<WebChatMessage> messages = const [],
      @JsonKey(name: "latest_message") this.latestMessage})
      : _messages = messages,
        super._();

  factory _$_WebChatThread.fromJson(Map<String, dynamic> json) =>
      _$$_WebChatThreadFromJson(json);

  @override
  final String uuid;
  @override
  final WebShop shop;
  @override
  @JsonKey(name: "is_third_party")
  final bool isThirdParty;
  @override
  @JsonKey(name: "buyer_address")
  final String buyerAddress;
  @override
  @JsonKey(name: "created_at")
  final DateTime createdAt;
  final List<WebChatMessage> _messages;
  @override
  @JsonKey()
  List<WebChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey(name: "latest_message")
  final WebChatMessage? latestMessage;

  @override
  String toString() {
    return 'WebChatThread(uuid: $uuid, shop: $shop, isThirdParty: $isThirdParty, buyerAddress: $buyerAddress, createdAt: $createdAt, messages: $messages, latestMessage: $latestMessage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WebChatThread &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.shop, shop) || other.shop == shop) &&
            (identical(other.isThirdParty, isThirdParty) ||
                other.isThirdParty == isThirdParty) &&
            (identical(other.buyerAddress, buyerAddress) ||
                other.buyerAddress == buyerAddress) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.latestMessage, latestMessage) ||
                other.latestMessage == latestMessage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uuid,
      shop,
      isThirdParty,
      buyerAddress,
      createdAt,
      const DeepCollectionEquality().hash(_messages),
      latestMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WebChatThreadCopyWith<_$_WebChatThread> get copyWith =>
      __$$_WebChatThreadCopyWithImpl<_$_WebChatThread>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WebChatThreadToJson(
      this,
    );
  }
}

abstract class _WebChatThread extends WebChatThread {
  factory _WebChatThread(
      {required final String uuid,
      required final WebShop shop,
      @JsonKey(name: "is_third_party")
          required final bool isThirdParty,
      @JsonKey(name: "buyer_address")
          required final String buyerAddress,
      @JsonKey(name: "created_at")
          required final DateTime createdAt,
      final List<WebChatMessage> messages,
      @JsonKey(name: "latest_message")
          final WebChatMessage? latestMessage}) = _$_WebChatThread;
  _WebChatThread._() : super._();

  factory _WebChatThread.fromJson(Map<String, dynamic> json) =
      _$_WebChatThread.fromJson;

  @override
  String get uuid;
  @override
  WebShop get shop;
  @override
  @JsonKey(name: "is_third_party")
  bool get isThirdParty;
  @override
  @JsonKey(name: "buyer_address")
  String get buyerAddress;
  @override
  @JsonKey(name: "created_at")
  DateTime get createdAt;
  @override
  List<WebChatMessage> get messages;
  @override
  @JsonKey(name: "latest_message")
  WebChatMessage? get latestMessage;
  @override
  @JsonKey(ignore: true)
  _$$_WebChatThreadCopyWith<_$_WebChatThread> get copyWith =>
      throw _privateConstructorUsedError;
}
