// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_lock_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BridgeLockRecord _$BridgeLockRecordFromJson(Map<String, dynamic> json) {
  return _BridgeLockRecord.fromJson(json);
}

/// @nodoc
mixin _$BridgeLockRecord {
  @JsonKey(name: "lockId")
  String get lockId => throw _privateConstructorUsedError;
  @JsonKey(name: "scUID")
  String get scUid => throw _privateConstructorUsedError;
  @JsonKey(name: "ownerAddress")
  String get ownerAddress => throw _privateConstructorUsedError;
  @JsonKey(name: "amount")
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: "amountSats")
  int get amountSats => throw _privateConstructorUsedError;
  @JsonKey(name: "evmDestination")
  String get evmDestination => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String? get statusRaw => throw _privateConstructorUsedError;
  @JsonKey(name: "vfxLockTxHash")
  String? get vfxLockTxHash => throw _privateConstructorUsedError;
  @JsonKey(name: "vfxLockConfirmedOnChain")
  bool get vfxLockConfirmedOnChain => throw _privateConstructorUsedError;
  @JsonKey(name: "vfxLockBlockHeight")
  int get vfxLockBlockHeight => throw _privateConstructorUsedError;
  @JsonKey(name: "baseTxHash")
  String? get baseTxHash => throw _privateConstructorUsedError;
  @JsonKey(name: "exitBurnTxHash")
  String? get exitBurnTxHash => throw _privateConstructorUsedError;
  @JsonKey(name: "signaturesCollected")
  int get signaturesCollected => throw _privateConstructorUsedError;
  @JsonKey(name: "requiredSignatures")
  int get requiredSignatures => throw _privateConstructorUsedError;
  @JsonKey(name: "mintNonce")
  int get mintNonce => throw _privateConstructorUsedError;
  @JsonKey(name: "signatures")
  Map<String, String>? get signatures => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAtUtc")
  int get createdAtUtc => throw _privateConstructorUsedError;
  @JsonKey(name: "relayedAtUtc")
  int? get relayedAtUtc => throw _privateConstructorUsedError;
  @JsonKey(name: "finalizedAtUtc")
  int? get finalizedAtUtc => throw _privateConstructorUsedError;
  @JsonKey(name: "errorMessage")
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: "btcExitDestination")
  String? get btcExitDestination => throw _privateConstructorUsedError;
  @JsonKey(name: "btcExitTxHash")
  String? get btcExitTxHash => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BridgeLockRecordCopyWith<BridgeLockRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BridgeLockRecordCopyWith<$Res> {
  factory $BridgeLockRecordCopyWith(
          BridgeLockRecord value, $Res Function(BridgeLockRecord) then) =
      _$BridgeLockRecordCopyWithImpl<$Res, BridgeLockRecord>;
  @useResult
  $Res call(
      {@JsonKey(name: "lockId") String lockId,
      @JsonKey(name: "scUID") String scUid,
      @JsonKey(name: "ownerAddress") String ownerAddress,
      @JsonKey(name: "amount") double amount,
      @JsonKey(name: "amountSats") int amountSats,
      @JsonKey(name: "evmDestination") String evmDestination,
      @JsonKey(name: "status") String? statusRaw,
      @JsonKey(name: "vfxLockTxHash") String? vfxLockTxHash,
      @JsonKey(name: "vfxLockConfirmedOnChain") bool vfxLockConfirmedOnChain,
      @JsonKey(name: "vfxLockBlockHeight") int vfxLockBlockHeight,
      @JsonKey(name: "baseTxHash") String? baseTxHash,
      @JsonKey(name: "exitBurnTxHash") String? exitBurnTxHash,
      @JsonKey(name: "signaturesCollected") int signaturesCollected,
      @JsonKey(name: "requiredSignatures") int requiredSignatures,
      @JsonKey(name: "mintNonce") int mintNonce,
      @JsonKey(name: "signatures") Map<String, String>? signatures,
      @JsonKey(name: "createdAtUtc") int createdAtUtc,
      @JsonKey(name: "relayedAtUtc") int? relayedAtUtc,
      @JsonKey(name: "finalizedAtUtc") int? finalizedAtUtc,
      @JsonKey(name: "errorMessage") String? errorMessage,
      @JsonKey(name: "btcExitDestination") String? btcExitDestination,
      @JsonKey(name: "btcExitTxHash") String? btcExitTxHash});
}

/// @nodoc
class _$BridgeLockRecordCopyWithImpl<$Res, $Val extends BridgeLockRecord>
    implements $BridgeLockRecordCopyWith<$Res> {
  _$BridgeLockRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lockId = null,
    Object? scUid = null,
    Object? ownerAddress = null,
    Object? amount = null,
    Object? amountSats = null,
    Object? evmDestination = null,
    Object? statusRaw = freezed,
    Object? vfxLockTxHash = freezed,
    Object? vfxLockConfirmedOnChain = null,
    Object? vfxLockBlockHeight = null,
    Object? baseTxHash = freezed,
    Object? exitBurnTxHash = freezed,
    Object? signaturesCollected = null,
    Object? requiredSignatures = null,
    Object? mintNonce = null,
    Object? signatures = freezed,
    Object? createdAtUtc = null,
    Object? relayedAtUtc = freezed,
    Object? finalizedAtUtc = freezed,
    Object? errorMessage = freezed,
    Object? btcExitDestination = freezed,
    Object? btcExitTxHash = freezed,
  }) {
    return _then(_value.copyWith(
      lockId: null == lockId
          ? _value.lockId
          : lockId // ignore: cast_nullable_to_non_nullable
              as String,
      scUid: null == scUid
          ? _value.scUid
          : scUid // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      amountSats: null == amountSats
          ? _value.amountSats
          : amountSats // ignore: cast_nullable_to_non_nullable
              as int,
      evmDestination: null == evmDestination
          ? _value.evmDestination
          : evmDestination // ignore: cast_nullable_to_non_nullable
              as String,
      statusRaw: freezed == statusRaw
          ? _value.statusRaw
          : statusRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      vfxLockTxHash: freezed == vfxLockTxHash
          ? _value.vfxLockTxHash
          : vfxLockTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
      vfxLockConfirmedOnChain: null == vfxLockConfirmedOnChain
          ? _value.vfxLockConfirmedOnChain
          : vfxLockConfirmedOnChain // ignore: cast_nullable_to_non_nullable
              as bool,
      vfxLockBlockHeight: null == vfxLockBlockHeight
          ? _value.vfxLockBlockHeight
          : vfxLockBlockHeight // ignore: cast_nullable_to_non_nullable
              as int,
      baseTxHash: freezed == baseTxHash
          ? _value.baseTxHash
          : baseTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
      exitBurnTxHash: freezed == exitBurnTxHash
          ? _value.exitBurnTxHash
          : exitBurnTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
      signaturesCollected: null == signaturesCollected
          ? _value.signaturesCollected
          : signaturesCollected // ignore: cast_nullable_to_non_nullable
              as int,
      requiredSignatures: null == requiredSignatures
          ? _value.requiredSignatures
          : requiredSignatures // ignore: cast_nullable_to_non_nullable
              as int,
      mintNonce: null == mintNonce
          ? _value.mintNonce
          : mintNonce // ignore: cast_nullable_to_non_nullable
              as int,
      signatures: freezed == signatures
          ? _value.signatures
          : signatures // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      createdAtUtc: null == createdAtUtc
          ? _value.createdAtUtc
          : createdAtUtc // ignore: cast_nullable_to_non_nullable
              as int,
      relayedAtUtc: freezed == relayedAtUtc
          ? _value.relayedAtUtc
          : relayedAtUtc // ignore: cast_nullable_to_non_nullable
              as int?,
      finalizedAtUtc: freezed == finalizedAtUtc
          ? _value.finalizedAtUtc
          : finalizedAtUtc // ignore: cast_nullable_to_non_nullable
              as int?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      btcExitDestination: freezed == btcExitDestination
          ? _value.btcExitDestination
          : btcExitDestination // ignore: cast_nullable_to_non_nullable
              as String?,
      btcExitTxHash: freezed == btcExitTxHash
          ? _value.btcExitTxHash
          : btcExitTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BridgeLockRecordCopyWith<$Res>
    implements $BridgeLockRecordCopyWith<$Res> {
  factory _$$_BridgeLockRecordCopyWith(
          _$_BridgeLockRecord value, $Res Function(_$_BridgeLockRecord) then) =
      __$$_BridgeLockRecordCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "lockId") String lockId,
      @JsonKey(name: "scUID") String scUid,
      @JsonKey(name: "ownerAddress") String ownerAddress,
      @JsonKey(name: "amount") double amount,
      @JsonKey(name: "amountSats") int amountSats,
      @JsonKey(name: "evmDestination") String evmDestination,
      @JsonKey(name: "status") String? statusRaw,
      @JsonKey(name: "vfxLockTxHash") String? vfxLockTxHash,
      @JsonKey(name: "vfxLockConfirmedOnChain") bool vfxLockConfirmedOnChain,
      @JsonKey(name: "vfxLockBlockHeight") int vfxLockBlockHeight,
      @JsonKey(name: "baseTxHash") String? baseTxHash,
      @JsonKey(name: "exitBurnTxHash") String? exitBurnTxHash,
      @JsonKey(name: "signaturesCollected") int signaturesCollected,
      @JsonKey(name: "requiredSignatures") int requiredSignatures,
      @JsonKey(name: "mintNonce") int mintNonce,
      @JsonKey(name: "signatures") Map<String, String>? signatures,
      @JsonKey(name: "createdAtUtc") int createdAtUtc,
      @JsonKey(name: "relayedAtUtc") int? relayedAtUtc,
      @JsonKey(name: "finalizedAtUtc") int? finalizedAtUtc,
      @JsonKey(name: "errorMessage") String? errorMessage,
      @JsonKey(name: "btcExitDestination") String? btcExitDestination,
      @JsonKey(name: "btcExitTxHash") String? btcExitTxHash});
}

/// @nodoc
class __$$_BridgeLockRecordCopyWithImpl<$Res>
    extends _$BridgeLockRecordCopyWithImpl<$Res, _$_BridgeLockRecord>
    implements _$$_BridgeLockRecordCopyWith<$Res> {
  __$$_BridgeLockRecordCopyWithImpl(
      _$_BridgeLockRecord _value, $Res Function(_$_BridgeLockRecord) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lockId = null,
    Object? scUid = null,
    Object? ownerAddress = null,
    Object? amount = null,
    Object? amountSats = null,
    Object? evmDestination = null,
    Object? statusRaw = freezed,
    Object? vfxLockTxHash = freezed,
    Object? vfxLockConfirmedOnChain = null,
    Object? vfxLockBlockHeight = null,
    Object? baseTxHash = freezed,
    Object? exitBurnTxHash = freezed,
    Object? signaturesCollected = null,
    Object? requiredSignatures = null,
    Object? mintNonce = null,
    Object? signatures = freezed,
    Object? createdAtUtc = null,
    Object? relayedAtUtc = freezed,
    Object? finalizedAtUtc = freezed,
    Object? errorMessage = freezed,
    Object? btcExitDestination = freezed,
    Object? btcExitTxHash = freezed,
  }) {
    return _then(_$_BridgeLockRecord(
      lockId: null == lockId
          ? _value.lockId
          : lockId // ignore: cast_nullable_to_non_nullable
              as String,
      scUid: null == scUid
          ? _value.scUid
          : scUid // ignore: cast_nullable_to_non_nullable
              as String,
      ownerAddress: null == ownerAddress
          ? _value.ownerAddress
          : ownerAddress // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      amountSats: null == amountSats
          ? _value.amountSats
          : amountSats // ignore: cast_nullable_to_non_nullable
              as int,
      evmDestination: null == evmDestination
          ? _value.evmDestination
          : evmDestination // ignore: cast_nullable_to_non_nullable
              as String,
      statusRaw: freezed == statusRaw
          ? _value.statusRaw
          : statusRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      vfxLockTxHash: freezed == vfxLockTxHash
          ? _value.vfxLockTxHash
          : vfxLockTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
      vfxLockConfirmedOnChain: null == vfxLockConfirmedOnChain
          ? _value.vfxLockConfirmedOnChain
          : vfxLockConfirmedOnChain // ignore: cast_nullable_to_non_nullable
              as bool,
      vfxLockBlockHeight: null == vfxLockBlockHeight
          ? _value.vfxLockBlockHeight
          : vfxLockBlockHeight // ignore: cast_nullable_to_non_nullable
              as int,
      baseTxHash: freezed == baseTxHash
          ? _value.baseTxHash
          : baseTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
      exitBurnTxHash: freezed == exitBurnTxHash
          ? _value.exitBurnTxHash
          : exitBurnTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
      signaturesCollected: null == signaturesCollected
          ? _value.signaturesCollected
          : signaturesCollected // ignore: cast_nullable_to_non_nullable
              as int,
      requiredSignatures: null == requiredSignatures
          ? _value.requiredSignatures
          : requiredSignatures // ignore: cast_nullable_to_non_nullable
              as int,
      mintNonce: null == mintNonce
          ? _value.mintNonce
          : mintNonce // ignore: cast_nullable_to_non_nullable
              as int,
      signatures: freezed == signatures
          ? _value._signatures
          : signatures // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      createdAtUtc: null == createdAtUtc
          ? _value.createdAtUtc
          : createdAtUtc // ignore: cast_nullable_to_non_nullable
              as int,
      relayedAtUtc: freezed == relayedAtUtc
          ? _value.relayedAtUtc
          : relayedAtUtc // ignore: cast_nullable_to_non_nullable
              as int?,
      finalizedAtUtc: freezed == finalizedAtUtc
          ? _value.finalizedAtUtc
          : finalizedAtUtc // ignore: cast_nullable_to_non_nullable
              as int?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      btcExitDestination: freezed == btcExitDestination
          ? _value.btcExitDestination
          : btcExitDestination // ignore: cast_nullable_to_non_nullable
              as String?,
      btcExitTxHash: freezed == btcExitTxHash
          ? _value.btcExitTxHash
          : btcExitTxHash // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BridgeLockRecord extends _BridgeLockRecord {
  _$_BridgeLockRecord(
      {@JsonKey(name: "lockId")
          this.lockId = "",
      @JsonKey(name: "scUID")
          this.scUid = "",
      @JsonKey(name: "ownerAddress")
          this.ownerAddress = "",
      @JsonKey(name: "amount")
          this.amount = 0.0,
      @JsonKey(name: "amountSats")
          this.amountSats = 0,
      @JsonKey(name: "evmDestination")
          this.evmDestination = "",
      @JsonKey(name: "status")
          this.statusRaw,
      @JsonKey(name: "vfxLockTxHash")
          this.vfxLockTxHash,
      @JsonKey(name: "vfxLockConfirmedOnChain")
          this.vfxLockConfirmedOnChain = false,
      @JsonKey(name: "vfxLockBlockHeight")
          this.vfxLockBlockHeight = 0,
      @JsonKey(name: "baseTxHash")
          this.baseTxHash,
      @JsonKey(name: "exitBurnTxHash")
          this.exitBurnTxHash,
      @JsonKey(name: "signaturesCollected")
          this.signaturesCollected = 0,
      @JsonKey(name: "requiredSignatures")
          this.requiredSignatures = 0,
      @JsonKey(name: "mintNonce")
          this.mintNonce = 0,
      @JsonKey(name: "signatures")
          final Map<String, String>? signatures,
      @JsonKey(name: "createdAtUtc")
          this.createdAtUtc = 0,
      @JsonKey(name: "relayedAtUtc")
          this.relayedAtUtc,
      @JsonKey(name: "finalizedAtUtc")
          this.finalizedAtUtc,
      @JsonKey(name: "errorMessage")
          this.errorMessage,
      @JsonKey(name: "btcExitDestination")
          this.btcExitDestination,
      @JsonKey(name: "btcExitTxHash")
          this.btcExitTxHash})
      : _signatures = signatures,
        super._();

  factory _$_BridgeLockRecord.fromJson(Map<String, dynamic> json) =>
      _$$_BridgeLockRecordFromJson(json);

  @override
  @JsonKey(name: "lockId")
  final String lockId;
  @override
  @JsonKey(name: "scUID")
  final String scUid;
  @override
  @JsonKey(name: "ownerAddress")
  final String ownerAddress;
  @override
  @JsonKey(name: "amount")
  final double amount;
  @override
  @JsonKey(name: "amountSats")
  final int amountSats;
  @override
  @JsonKey(name: "evmDestination")
  final String evmDestination;
  @override
  @JsonKey(name: "status")
  final String? statusRaw;
  @override
  @JsonKey(name: "vfxLockTxHash")
  final String? vfxLockTxHash;
  @override
  @JsonKey(name: "vfxLockConfirmedOnChain")
  final bool vfxLockConfirmedOnChain;
  @override
  @JsonKey(name: "vfxLockBlockHeight")
  final int vfxLockBlockHeight;
  @override
  @JsonKey(name: "baseTxHash")
  final String? baseTxHash;
  @override
  @JsonKey(name: "exitBurnTxHash")
  final String? exitBurnTxHash;
  @override
  @JsonKey(name: "signaturesCollected")
  final int signaturesCollected;
  @override
  @JsonKey(name: "requiredSignatures")
  final int requiredSignatures;
  @override
  @JsonKey(name: "mintNonce")
  final int mintNonce;
  final Map<String, String>? _signatures;
  @override
  @JsonKey(name: "signatures")
  Map<String, String>? get signatures {
    final value = _signatures;
    if (value == null) return null;
    if (_signatures is EqualUnmodifiableMapView) return _signatures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: "createdAtUtc")
  final int createdAtUtc;
  @override
  @JsonKey(name: "relayedAtUtc")
  final int? relayedAtUtc;
  @override
  @JsonKey(name: "finalizedAtUtc")
  final int? finalizedAtUtc;
  @override
  @JsonKey(name: "errorMessage")
  final String? errorMessage;
  @override
  @JsonKey(name: "btcExitDestination")
  final String? btcExitDestination;
  @override
  @JsonKey(name: "btcExitTxHash")
  final String? btcExitTxHash;

  @override
  String toString() {
    return 'BridgeLockRecord(lockId: $lockId, scUid: $scUid, ownerAddress: $ownerAddress, amount: $amount, amountSats: $amountSats, evmDestination: $evmDestination, statusRaw: $statusRaw, vfxLockTxHash: $vfxLockTxHash, vfxLockConfirmedOnChain: $vfxLockConfirmedOnChain, vfxLockBlockHeight: $vfxLockBlockHeight, baseTxHash: $baseTxHash, exitBurnTxHash: $exitBurnTxHash, signaturesCollected: $signaturesCollected, requiredSignatures: $requiredSignatures, mintNonce: $mintNonce, signatures: $signatures, createdAtUtc: $createdAtUtc, relayedAtUtc: $relayedAtUtc, finalizedAtUtc: $finalizedAtUtc, errorMessage: $errorMessage, btcExitDestination: $btcExitDestination, btcExitTxHash: $btcExitTxHash)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BridgeLockRecord &&
            (identical(other.lockId, lockId) || other.lockId == lockId) &&
            (identical(other.scUid, scUid) || other.scUid == scUid) &&
            (identical(other.ownerAddress, ownerAddress) ||
                other.ownerAddress == ownerAddress) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.amountSats, amountSats) ||
                other.amountSats == amountSats) &&
            (identical(other.evmDestination, evmDestination) ||
                other.evmDestination == evmDestination) &&
            (identical(other.statusRaw, statusRaw) ||
                other.statusRaw == statusRaw) &&
            (identical(other.vfxLockTxHash, vfxLockTxHash) ||
                other.vfxLockTxHash == vfxLockTxHash) &&
            (identical(
                    other.vfxLockConfirmedOnChain, vfxLockConfirmedOnChain) ||
                other.vfxLockConfirmedOnChain == vfxLockConfirmedOnChain) &&
            (identical(other.vfxLockBlockHeight, vfxLockBlockHeight) ||
                other.vfxLockBlockHeight == vfxLockBlockHeight) &&
            (identical(other.baseTxHash, baseTxHash) ||
                other.baseTxHash == baseTxHash) &&
            (identical(other.exitBurnTxHash, exitBurnTxHash) ||
                other.exitBurnTxHash == exitBurnTxHash) &&
            (identical(other.signaturesCollected, signaturesCollected) ||
                other.signaturesCollected == signaturesCollected) &&
            (identical(other.requiredSignatures, requiredSignatures) ||
                other.requiredSignatures == requiredSignatures) &&
            (identical(other.mintNonce, mintNonce) ||
                other.mintNonce == mintNonce) &&
            const DeepCollectionEquality()
                .equals(other._signatures, _signatures) &&
            (identical(other.createdAtUtc, createdAtUtc) ||
                other.createdAtUtc == createdAtUtc) &&
            (identical(other.relayedAtUtc, relayedAtUtc) ||
                other.relayedAtUtc == relayedAtUtc) &&
            (identical(other.finalizedAtUtc, finalizedAtUtc) ||
                other.finalizedAtUtc == finalizedAtUtc) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.btcExitDestination, btcExitDestination) ||
                other.btcExitDestination == btcExitDestination) &&
            (identical(other.btcExitTxHash, btcExitTxHash) ||
                other.btcExitTxHash == btcExitTxHash));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        lockId,
        scUid,
        ownerAddress,
        amount,
        amountSats,
        evmDestination,
        statusRaw,
        vfxLockTxHash,
        vfxLockConfirmedOnChain,
        vfxLockBlockHeight,
        baseTxHash,
        exitBurnTxHash,
        signaturesCollected,
        requiredSignatures,
        mintNonce,
        const DeepCollectionEquality().hash(_signatures),
        createdAtUtc,
        relayedAtUtc,
        finalizedAtUtc,
        errorMessage,
        btcExitDestination,
        btcExitTxHash
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BridgeLockRecordCopyWith<_$_BridgeLockRecord> get copyWith =>
      __$$_BridgeLockRecordCopyWithImpl<_$_BridgeLockRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BridgeLockRecordToJson(
      this,
    );
  }
}

abstract class _BridgeLockRecord extends BridgeLockRecord {
  factory _BridgeLockRecord(
      {@JsonKey(name: "lockId")
          final String lockId,
      @JsonKey(name: "scUID")
          final String scUid,
      @JsonKey(name: "ownerAddress")
          final String ownerAddress,
      @JsonKey(name: "amount")
          final double amount,
      @JsonKey(name: "amountSats")
          final int amountSats,
      @JsonKey(name: "evmDestination")
          final String evmDestination,
      @JsonKey(name: "status")
          final String? statusRaw,
      @JsonKey(name: "vfxLockTxHash")
          final String? vfxLockTxHash,
      @JsonKey(name: "vfxLockConfirmedOnChain")
          final bool vfxLockConfirmedOnChain,
      @JsonKey(name: "vfxLockBlockHeight")
          final int vfxLockBlockHeight,
      @JsonKey(name: "baseTxHash")
          final String? baseTxHash,
      @JsonKey(name: "exitBurnTxHash")
          final String? exitBurnTxHash,
      @JsonKey(name: "signaturesCollected")
          final int signaturesCollected,
      @JsonKey(name: "requiredSignatures")
          final int requiredSignatures,
      @JsonKey(name: "mintNonce")
          final int mintNonce,
      @JsonKey(name: "signatures")
          final Map<String, String>? signatures,
      @JsonKey(name: "createdAtUtc")
          final int createdAtUtc,
      @JsonKey(name: "relayedAtUtc")
          final int? relayedAtUtc,
      @JsonKey(name: "finalizedAtUtc")
          final int? finalizedAtUtc,
      @JsonKey(name: "errorMessage")
          final String? errorMessage,
      @JsonKey(name: "btcExitDestination")
          final String? btcExitDestination,
      @JsonKey(name: "btcExitTxHash")
          final String? btcExitTxHash}) = _$_BridgeLockRecord;
  _BridgeLockRecord._() : super._();

  factory _BridgeLockRecord.fromJson(Map<String, dynamic> json) =
      _$_BridgeLockRecord.fromJson;

  @override
  @JsonKey(name: "lockId")
  String get lockId;
  @override
  @JsonKey(name: "scUID")
  String get scUid;
  @override
  @JsonKey(name: "ownerAddress")
  String get ownerAddress;
  @override
  @JsonKey(name: "amount")
  double get amount;
  @override
  @JsonKey(name: "amountSats")
  int get amountSats;
  @override
  @JsonKey(name: "evmDestination")
  String get evmDestination;
  @override
  @JsonKey(name: "status")
  String? get statusRaw;
  @override
  @JsonKey(name: "vfxLockTxHash")
  String? get vfxLockTxHash;
  @override
  @JsonKey(name: "vfxLockConfirmedOnChain")
  bool get vfxLockConfirmedOnChain;
  @override
  @JsonKey(name: "vfxLockBlockHeight")
  int get vfxLockBlockHeight;
  @override
  @JsonKey(name: "baseTxHash")
  String? get baseTxHash;
  @override
  @JsonKey(name: "exitBurnTxHash")
  String? get exitBurnTxHash;
  @override
  @JsonKey(name: "signaturesCollected")
  int get signaturesCollected;
  @override
  @JsonKey(name: "requiredSignatures")
  int get requiredSignatures;
  @override
  @JsonKey(name: "mintNonce")
  int get mintNonce;
  @override
  @JsonKey(name: "signatures")
  Map<String, String>? get signatures;
  @override
  @JsonKey(name: "createdAtUtc")
  int get createdAtUtc;
  @override
  @JsonKey(name: "relayedAtUtc")
  int? get relayedAtUtc;
  @override
  @JsonKey(name: "finalizedAtUtc")
  int? get finalizedAtUtc;
  @override
  @JsonKey(name: "errorMessage")
  String? get errorMessage;
  @override
  @JsonKey(name: "btcExitDestination")
  String? get btcExitDestination;
  @override
  @JsonKey(name: "btcExitTxHash")
  String? get btcExitTxHash;
  @override
  @JsonKey(ignore: true)
  _$$_BridgeLockRecordCopyWith<_$_BridgeLockRecord> get copyWith =>
      throw _privateConstructorUsedError;
}
