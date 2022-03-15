// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Block _$BlockFromJson(Map<String, dynamic> json) {
  return _Block.fromJson(json);
}

/// @nodoc
class _$BlockTearOff {
  const _$BlockTearOff();

  _Block call(
      {@JsonKey(name: "Height") required int height,
      @JsonKey(name: "Timestamp") required int timestamp,
      @JsonKey(name: "Hash") required String hash,
      @JsonKey(name: "Validator") required String validator,
      @JsonKey(name: "NextValidators") required String nextValidators,
      @JsonKey(name: "TotalAmount") required double totalAmount,
      @JsonKey(name: "TotalReward") required double totalReward,
      @JsonKey(name: "NumOfTx") required int numberOfTransactions,
      @JsonKey(name: "Size") required int size,
      @JsonKey(name: "BCraftTime") required int craftTime,
      @JsonKey(name: "Transactions") required List<Transaction> transactions}) {
    return _Block(
      height: height,
      timestamp: timestamp,
      hash: hash,
      validator: validator,
      nextValidators: nextValidators,
      totalAmount: totalAmount,
      totalReward: totalReward,
      numberOfTransactions: numberOfTransactions,
      size: size,
      craftTime: craftTime,
      transactions: transactions,
    );
  }

  Block fromJson(Map<String, Object?> json) {
    return Block.fromJson(json);
  }
}

/// @nodoc
const $Block = _$BlockTearOff();

/// @nodoc
mixin _$Block {
  @JsonKey(name: "Height")
  int get height => throw _privateConstructorUsedError;
  @JsonKey(name: "Timestamp")
  int get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: "Hash")
  String get hash => throw _privateConstructorUsedError;
  @JsonKey(name: "Validator")
  String get validator => throw _privateConstructorUsedError;
  @JsonKey(name: "NextValidators")
  String get nextValidators => throw _privateConstructorUsedError;
  @JsonKey(name: "TotalAmount")
  double get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: "TotalReward")
  double get totalReward => throw _privateConstructorUsedError;
  @JsonKey(name: "NumOfTx")
  int get numberOfTransactions => throw _privateConstructorUsedError;
  @JsonKey(name: "Size")
  int get size => throw _privateConstructorUsedError;
  @JsonKey(name: "BCraftTime")
  int get craftTime => throw _privateConstructorUsedError;
  @JsonKey(name: "Transactions")
  List<Transaction> get transactions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BlockCopyWith<Block> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockCopyWith<$Res> {
  factory $BlockCopyWith(Block value, $Res Function(Block) then) =
      _$BlockCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(name: "Height") int height,
      @JsonKey(name: "Timestamp") int timestamp,
      @JsonKey(name: "Hash") String hash,
      @JsonKey(name: "Validator") String validator,
      @JsonKey(name: "NextValidators") String nextValidators,
      @JsonKey(name: "TotalAmount") double totalAmount,
      @JsonKey(name: "TotalReward") double totalReward,
      @JsonKey(name: "NumOfTx") int numberOfTransactions,
      @JsonKey(name: "Size") int size,
      @JsonKey(name: "BCraftTime") int craftTime,
      @JsonKey(name: "Transactions") List<Transaction> transactions});
}

/// @nodoc
class _$BlockCopyWithImpl<$Res> implements $BlockCopyWith<$Res> {
  _$BlockCopyWithImpl(this._value, this._then);

  final Block _value;
  // ignore: unused_field
  final $Res Function(Block) _then;

  @override
  $Res call({
    Object? height = freezed,
    Object? timestamp = freezed,
    Object? hash = freezed,
    Object? validator = freezed,
    Object? nextValidators = freezed,
    Object? totalAmount = freezed,
    Object? totalReward = freezed,
    Object? numberOfTransactions = freezed,
    Object? size = freezed,
    Object? craftTime = freezed,
    Object? transactions = freezed,
  }) {
    return _then(_value.copyWith(
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: timestamp == freezed
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      hash: hash == freezed
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      validator: validator == freezed
          ? _value.validator
          : validator // ignore: cast_nullable_to_non_nullable
              as String,
      nextValidators: nextValidators == freezed
          ? _value.nextValidators
          : nextValidators // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: totalAmount == freezed
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalReward: totalReward == freezed
          ? _value.totalReward
          : totalReward // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfTransactions: numberOfTransactions == freezed
          ? _value.numberOfTransactions
          : numberOfTransactions // ignore: cast_nullable_to_non_nullable
              as int,
      size: size == freezed
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      craftTime: craftTime == freezed
          ? _value.craftTime
          : craftTime // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: transactions == freezed
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
    ));
  }
}

/// @nodoc
abstract class _$BlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory _$BlockCopyWith(_Block value, $Res Function(_Block) then) =
      __$BlockCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(name: "Height") int height,
      @JsonKey(name: "Timestamp") int timestamp,
      @JsonKey(name: "Hash") String hash,
      @JsonKey(name: "Validator") String validator,
      @JsonKey(name: "NextValidators") String nextValidators,
      @JsonKey(name: "TotalAmount") double totalAmount,
      @JsonKey(name: "TotalReward") double totalReward,
      @JsonKey(name: "NumOfTx") int numberOfTransactions,
      @JsonKey(name: "Size") int size,
      @JsonKey(name: "BCraftTime") int craftTime,
      @JsonKey(name: "Transactions") List<Transaction> transactions});
}

/// @nodoc
class __$BlockCopyWithImpl<$Res> extends _$BlockCopyWithImpl<$Res>
    implements _$BlockCopyWith<$Res> {
  __$BlockCopyWithImpl(_Block _value, $Res Function(_Block) _then)
      : super(_value, (v) => _then(v as _Block));

  @override
  _Block get _value => super._value as _Block;

  @override
  $Res call({
    Object? height = freezed,
    Object? timestamp = freezed,
    Object? hash = freezed,
    Object? validator = freezed,
    Object? nextValidators = freezed,
    Object? totalAmount = freezed,
    Object? totalReward = freezed,
    Object? numberOfTransactions = freezed,
    Object? size = freezed,
    Object? craftTime = freezed,
    Object? transactions = freezed,
  }) {
    return _then(_Block(
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: timestamp == freezed
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      hash: hash == freezed
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      validator: validator == freezed
          ? _value.validator
          : validator // ignore: cast_nullable_to_non_nullable
              as String,
      nextValidators: nextValidators == freezed
          ? _value.nextValidators
          : nextValidators // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: totalAmount == freezed
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalReward: totalReward == freezed
          ? _value.totalReward
          : totalReward // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfTransactions: numberOfTransactions == freezed
          ? _value.numberOfTransactions
          : numberOfTransactions // ignore: cast_nullable_to_non_nullable
              as int,
      size: size == freezed
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      craftTime: craftTime == freezed
          ? _value.craftTime
          : craftTime // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: transactions == freezed
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Block extends _Block {
  _$_Block(
      {@JsonKey(name: "Height") required this.height,
      @JsonKey(name: "Timestamp") required this.timestamp,
      @JsonKey(name: "Hash") required this.hash,
      @JsonKey(name: "Validator") required this.validator,
      @JsonKey(name: "NextValidators") required this.nextValidators,
      @JsonKey(name: "TotalAmount") required this.totalAmount,
      @JsonKey(name: "TotalReward") required this.totalReward,
      @JsonKey(name: "NumOfTx") required this.numberOfTransactions,
      @JsonKey(name: "Size") required this.size,
      @JsonKey(name: "BCraftTime") required this.craftTime,
      @JsonKey(name: "Transactions") required this.transactions})
      : super._();

  factory _$_Block.fromJson(Map<String, dynamic> json) =>
      _$$_BlockFromJson(json);

  @override
  @JsonKey(name: "Height")
  final int height;
  @override
  @JsonKey(name: "Timestamp")
  final int timestamp;
  @override
  @JsonKey(name: "Hash")
  final String hash;
  @override
  @JsonKey(name: "Validator")
  final String validator;
  @override
  @JsonKey(name: "NextValidators")
  final String nextValidators;
  @override
  @JsonKey(name: "TotalAmount")
  final double totalAmount;
  @override
  @JsonKey(name: "TotalReward")
  final double totalReward;
  @override
  @JsonKey(name: "NumOfTx")
  final int numberOfTransactions;
  @override
  @JsonKey(name: "Size")
  final int size;
  @override
  @JsonKey(name: "BCraftTime")
  final int craftTime;
  @override
  @JsonKey(name: "Transactions")
  final List<Transaction> transactions;

  @override
  String toString() {
    return 'Block(height: $height, timestamp: $timestamp, hash: $hash, validator: $validator, nextValidators: $nextValidators, totalAmount: $totalAmount, totalReward: $totalReward, numberOfTransactions: $numberOfTransactions, size: $size, craftTime: $craftTime, transactions: $transactions)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Block &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp) &&
            const DeepCollectionEquality().equals(other.hash, hash) &&
            const DeepCollectionEquality().equals(other.validator, validator) &&
            const DeepCollectionEquality()
                .equals(other.nextValidators, nextValidators) &&
            const DeepCollectionEquality()
                .equals(other.totalAmount, totalAmount) &&
            const DeepCollectionEquality()
                .equals(other.totalReward, totalReward) &&
            const DeepCollectionEquality()
                .equals(other.numberOfTransactions, numberOfTransactions) &&
            const DeepCollectionEquality().equals(other.size, size) &&
            const DeepCollectionEquality().equals(other.craftTime, craftTime) &&
            const DeepCollectionEquality()
                .equals(other.transactions, transactions));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(timestamp),
      const DeepCollectionEquality().hash(hash),
      const DeepCollectionEquality().hash(validator),
      const DeepCollectionEquality().hash(nextValidators),
      const DeepCollectionEquality().hash(totalAmount),
      const DeepCollectionEquality().hash(totalReward),
      const DeepCollectionEquality().hash(numberOfTransactions),
      const DeepCollectionEquality().hash(size),
      const DeepCollectionEquality().hash(craftTime),
      const DeepCollectionEquality().hash(transactions));

  @JsonKey(ignore: true)
  @override
  _$BlockCopyWith<_Block> get copyWith =>
      __$BlockCopyWithImpl<_Block>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BlockToJson(this);
  }
}

abstract class _Block extends Block {
  factory _Block(
      {@JsonKey(name: "Height")
          required int height,
      @JsonKey(name: "Timestamp")
          required int timestamp,
      @JsonKey(name: "Hash")
          required String hash,
      @JsonKey(name: "Validator")
          required String validator,
      @JsonKey(name: "NextValidators")
          required String nextValidators,
      @JsonKey(name: "TotalAmount")
          required double totalAmount,
      @JsonKey(name: "TotalReward")
          required double totalReward,
      @JsonKey(name: "NumOfTx")
          required int numberOfTransactions,
      @JsonKey(name: "Size")
          required int size,
      @JsonKey(name: "BCraftTime")
          required int craftTime,
      @JsonKey(name: "Transactions")
          required List<Transaction> transactions}) = _$_Block;
  _Block._() : super._();

  factory _Block.fromJson(Map<String, dynamic> json) = _$_Block.fromJson;

  @override
  @JsonKey(name: "Height")
  int get height;
  @override
  @JsonKey(name: "Timestamp")
  int get timestamp;
  @override
  @JsonKey(name: "Hash")
  String get hash;
  @override
  @JsonKey(name: "Validator")
  String get validator;
  @override
  @JsonKey(name: "NextValidators")
  String get nextValidators;
  @override
  @JsonKey(name: "TotalAmount")
  double get totalAmount;
  @override
  @JsonKey(name: "TotalReward")
  double get totalReward;
  @override
  @JsonKey(name: "NumOfTx")
  int get numberOfTransactions;
  @override
  @JsonKey(name: "Size")
  int get size;
  @override
  @JsonKey(name: "BCraftTime")
  int get craftTime;
  @override
  @JsonKey(name: "Transactions")
  List<Transaction> get transactions;
  @override
  @JsonKey(ignore: true)
  _$BlockCopyWith<_Block> get copyWith => throw _privateConstructorUsedError;
}