// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'btc_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BtcTransaction _$BtcTransactionFromJson(Map<String, dynamic> json) {
  return _BtcTransaction.fromJson(json);
}

/// @nodoc
mixin _$BtcTransaction {
  @JsonKey(name: "Hash")
  String get hash => throw _privateConstructorUsedError;
  @JsonKey(name: "ToAddress")
  String get toAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "FromAddress")
  String get fromAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "Amount")
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: "Fee")
  double get fee => throw _privateConstructorUsedError;
  @JsonKey(name: "Timestamp")
  int get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: "Signature")
  String get signature => throw _privateConstructorUsedError;
  @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
  BTCTransactionType get type => throw _privateConstructorUsedError;
  @JsonKey(name: "FeeRate")
  int get feeRate => throw _privateConstructorUsedError;
  @JsonKey(name: "ConfirmedHeight")
  int get confirmedHeight => throw _privateConstructorUsedError;
  @JsonKey(name: "IsConfirmed")
  bool get isConfirmed => throw _privateConstructorUsedError;
  @JsonKey(name: "BitcoinUTXOs")
  List<BtcUtxo> get utxos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BtcTransactionCopyWith<BtcTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BtcTransactionCopyWith<$Res> {
  factory $BtcTransactionCopyWith(
          BtcTransaction value, $Res Function(BtcTransaction) then) =
      _$BtcTransactionCopyWithImpl<$Res, BtcTransaction>;
  @useResult
  $Res call(
      {@JsonKey(name: "Hash")
          String hash,
      @JsonKey(name: "ToAddress")
          String toAddress,
      @JsonKey(name: "FromAddress")
          String fromAddress,
      @JsonKey(name: "Amount")
          double amount,
      @JsonKey(name: "Fee")
          double fee,
      @JsonKey(name: "Timestamp")
          int timestamp,
      @JsonKey(name: "Signature")
          String signature,
      @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
          BTCTransactionType type,
      @JsonKey(name: "FeeRate")
          int feeRate,
      @JsonKey(name: "ConfirmedHeight")
          int confirmedHeight,
      @JsonKey(name: "IsConfirmed")
          bool isConfirmed,
      @JsonKey(name: "BitcoinUTXOs")
          List<BtcUtxo> utxos});
}

/// @nodoc
class _$BtcTransactionCopyWithImpl<$Res, $Val extends BtcTransaction>
    implements $BtcTransactionCopyWith<$Res> {
  _$BtcTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hash = null,
    Object? toAddress = null,
    Object? fromAddress = null,
    Object? amount = null,
    Object? fee = null,
    Object? timestamp = null,
    Object? signature = null,
    Object? type = null,
    Object? feeRate = null,
    Object? confirmedHeight = null,
    Object? isConfirmed = null,
    Object? utxos = null,
  }) {
    return _then(_value.copyWith(
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      fee: null == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BTCTransactionType,
      feeRate: null == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int,
      confirmedHeight: null == confirmedHeight
          ? _value.confirmedHeight
          : confirmedHeight // ignore: cast_nullable_to_non_nullable
              as int,
      isConfirmed: null == isConfirmed
          ? _value.isConfirmed
          : isConfirmed // ignore: cast_nullable_to_non_nullable
              as bool,
      utxos: null == utxos
          ? _value.utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as List<BtcUtxo>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BtcTransactionCopyWith<$Res>
    implements $BtcTransactionCopyWith<$Res> {
  factory _$$_BtcTransactionCopyWith(
          _$_BtcTransaction value, $Res Function(_$_BtcTransaction) then) =
      __$$_BtcTransactionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "Hash")
          String hash,
      @JsonKey(name: "ToAddress")
          String toAddress,
      @JsonKey(name: "FromAddress")
          String fromAddress,
      @JsonKey(name: "Amount")
          double amount,
      @JsonKey(name: "Fee")
          double fee,
      @JsonKey(name: "Timestamp")
          int timestamp,
      @JsonKey(name: "Signature")
          String signature,
      @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
          BTCTransactionType type,
      @JsonKey(name: "FeeRate")
          int feeRate,
      @JsonKey(name: "ConfirmedHeight")
          int confirmedHeight,
      @JsonKey(name: "IsConfirmed")
          bool isConfirmed,
      @JsonKey(name: "BitcoinUTXOs")
          List<BtcUtxo> utxos});
}

/// @nodoc
class __$$_BtcTransactionCopyWithImpl<$Res>
    extends _$BtcTransactionCopyWithImpl<$Res, _$_BtcTransaction>
    implements _$$_BtcTransactionCopyWith<$Res> {
  __$$_BtcTransactionCopyWithImpl(
      _$_BtcTransaction _value, $Res Function(_$_BtcTransaction) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hash = null,
    Object? toAddress = null,
    Object? fromAddress = null,
    Object? amount = null,
    Object? fee = null,
    Object? timestamp = null,
    Object? signature = null,
    Object? type = null,
    Object? feeRate = null,
    Object? confirmedHeight = null,
    Object? isConfirmed = null,
    Object? utxos = null,
  }) {
    return _then(_$_BtcTransaction(
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      fee: null == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BTCTransactionType,
      feeRate: null == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int,
      confirmedHeight: null == confirmedHeight
          ? _value.confirmedHeight
          : confirmedHeight // ignore: cast_nullable_to_non_nullable
              as int,
      isConfirmed: null == isConfirmed
          ? _value.isConfirmed
          : isConfirmed // ignore: cast_nullable_to_non_nullable
              as bool,
      utxos: null == utxos
          ? _value._utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as List<BtcUtxo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BtcTransaction extends _BtcTransaction {
  _$_BtcTransaction(
      {@JsonKey(name: "Hash")
          required this.hash,
      @JsonKey(name: "ToAddress")
          this.toAddress = "",
      @JsonKey(name: "FromAddress")
          this.fromAddress = "",
      @JsonKey(name: "Amount")
          required this.amount,
      @JsonKey(name: "Fee")
          required this.fee,
      @JsonKey(name: "Timestamp")
          required this.timestamp,
      @JsonKey(name: "Signature")
          required this.signature,
      @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
          required this.type,
      @JsonKey(name: "FeeRate")
          required this.feeRate,
      @JsonKey(name: "ConfirmedHeight")
          required this.confirmedHeight,
      @JsonKey(name: "IsConfirmed")
          required this.isConfirmed,
      @JsonKey(name: "BitcoinUTXOs")
          final List<BtcUtxo> utxos = const []})
      : _utxos = utxos,
        super._();

  factory _$_BtcTransaction.fromJson(Map<String, dynamic> json) =>
      _$$_BtcTransactionFromJson(json);

  @override
  @JsonKey(name: "Hash")
  final String hash;
  @override
  @JsonKey(name: "ToAddress")
  final String toAddress;
  @override
  @JsonKey(name: "FromAddress")
  final String fromAddress;
  @override
  @JsonKey(name: "Amount")
  final double amount;
  @override
  @JsonKey(name: "Fee")
  final double fee;
  @override
  @JsonKey(name: "Timestamp")
  final int timestamp;
  @override
  @JsonKey(name: "Signature")
  final String signature;
  @override
  @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
  final BTCTransactionType type;
  @override
  @JsonKey(name: "FeeRate")
  final int feeRate;
  @override
  @JsonKey(name: "ConfirmedHeight")
  final int confirmedHeight;
  @override
  @JsonKey(name: "IsConfirmed")
  final bool isConfirmed;
  final List<BtcUtxo> _utxos;
  @override
  @JsonKey(name: "BitcoinUTXOs")
  List<BtcUtxo> get utxos {
    if (_utxos is EqualUnmodifiableListView) return _utxos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_utxos);
  }

  @override
  String toString() {
    return 'BtcTransaction(hash: $hash, toAddress: $toAddress, fromAddress: $fromAddress, amount: $amount, fee: $fee, timestamp: $timestamp, signature: $signature, type: $type, feeRate: $feeRate, confirmedHeight: $confirmedHeight, isConfirmed: $isConfirmed, utxos: $utxos)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BtcTransaction &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.fromAddress, fromAddress) ||
                other.fromAddress == fromAddress) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.signature, signature) ||
                other.signature == signature) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate) &&
            (identical(other.confirmedHeight, confirmedHeight) ||
                other.confirmedHeight == confirmedHeight) &&
            (identical(other.isConfirmed, isConfirmed) ||
                other.isConfirmed == isConfirmed) &&
            const DeepCollectionEquality().equals(other._utxos, _utxos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hash,
      toAddress,
      fromAddress,
      amount,
      fee,
      timestamp,
      signature,
      type,
      feeRate,
      confirmedHeight,
      isConfirmed,
      const DeepCollectionEquality().hash(_utxos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BtcTransactionCopyWith<_$_BtcTransaction> get copyWith =>
      __$$_BtcTransactionCopyWithImpl<_$_BtcTransaction>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BtcTransactionToJson(
      this,
    );
  }
}

abstract class _BtcTransaction extends BtcTransaction {
  factory _BtcTransaction(
      {@JsonKey(name: "Hash")
          required final String hash,
      @JsonKey(name: "ToAddress")
          final String toAddress,
      @JsonKey(name: "FromAddress")
          final String fromAddress,
      @JsonKey(name: "Amount")
          required final double amount,
      @JsonKey(name: "Fee")
          required final double fee,
      @JsonKey(name: "Timestamp")
          required final int timestamp,
      @JsonKey(name: "Signature")
          required final String signature,
      @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
          required final BTCTransactionType type,
      @JsonKey(name: "FeeRate")
          required final int feeRate,
      @JsonKey(name: "ConfirmedHeight")
          required final int confirmedHeight,
      @JsonKey(name: "IsConfirmed")
          required final bool isConfirmed,
      @JsonKey(name: "BitcoinUTXOs")
          final List<BtcUtxo> utxos}) = _$_BtcTransaction;
  _BtcTransaction._() : super._();

  factory _BtcTransaction.fromJson(Map<String, dynamic> json) =
      _$_BtcTransaction.fromJson;

  @override
  @JsonKey(name: "Hash")
  String get hash;
  @override
  @JsonKey(name: "ToAddress")
  String get toAddress;
  @override
  @JsonKey(name: "FromAddress")
  String get fromAddress;
  @override
  @JsonKey(name: "Amount")
  double get amount;
  @override
  @JsonKey(name: "Fee")
  double get fee;
  @override
  @JsonKey(name: "Timestamp")
  int get timestamp;
  @override
  @JsonKey(name: "Signature")
  String get signature;
  @override
  @JsonKey(name: "TransactionType", fromJson: txTypeFromJson)
  BTCTransactionType get type;
  @override
  @JsonKey(name: "FeeRate")
  int get feeRate;
  @override
  @JsonKey(name: "ConfirmedHeight")
  int get confirmedHeight;
  @override
  @JsonKey(name: "IsConfirmed")
  bool get isConfirmed;
  @override
  @JsonKey(name: "BitcoinUTXOs")
  List<BtcUtxo> get utxos;
  @override
  @JsonKey(ignore: true)
  _$$_BtcTransactionCopyWith<_$_BtcTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}
