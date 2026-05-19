// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_lock_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BridgeLockRecord _$$_BridgeLockRecordFromJson(Map<String, dynamic> json) =>
    _$_BridgeLockRecord(
      lockId: json['lockId'] as String? ?? "",
      scUid: json['scUID'] as String? ?? "",
      ownerAddress: json['ownerAddress'] as String? ?? "",
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountSats: json['amountSats'] as int? ?? 0,
      evmDestination: json['evmDestination'] as String? ?? "",
      statusRaw: json['status'] as String?,
      vfxLockTxHash: json['vfxLockTxHash'] as String?,
      vfxLockConfirmedOnChain:
          json['vfxLockConfirmedOnChain'] as bool? ?? false,
      vfxLockBlockHeight: json['vfxLockBlockHeight'] as int? ?? 0,
      baseTxHash: json['baseTxHash'] as String?,
      exitBurnTxHash: json['exitBurnTxHash'] as String?,
      signaturesCollected: json['signaturesCollected'] as int? ?? 0,
      requiredSignatures: json['requiredSignatures'] as int? ?? 0,
      mintNonce: json['mintNonce'] as int? ?? 0,
      signatures: (json['signatures'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      createdAtUtc: json['createdAtUtc'] as int? ?? 0,
      relayedAtUtc: json['relayedAtUtc'] as int?,
      finalizedAtUtc: json['finalizedAtUtc'] as int?,
      errorMessage: json['errorMessage'] as String?,
      btcExitDestination: json['btcExitDestination'] as String?,
      btcExitTxHash: json['btcExitTxHash'] as String?,
    );

Map<String, dynamic> _$$_BridgeLockRecordToJson(_$_BridgeLockRecord instance) =>
    <String, dynamic>{
      'lockId': instance.lockId,
      'scUID': instance.scUid,
      'ownerAddress': instance.ownerAddress,
      'amount': instance.amount,
      'amountSats': instance.amountSats,
      'evmDestination': instance.evmDestination,
      'status': instance.statusRaw,
      'vfxLockTxHash': instance.vfxLockTxHash,
      'vfxLockConfirmedOnChain': instance.vfxLockConfirmedOnChain,
      'vfxLockBlockHeight': instance.vfxLockBlockHeight,
      'baseTxHash': instance.baseTxHash,
      'exitBurnTxHash': instance.exitBurnTxHash,
      'signaturesCollected': instance.signaturesCollected,
      'requiredSignatures': instance.requiredSignatures,
      'mintNonce': instance.mintNonce,
      'signatures': instance.signatures,
      'createdAtUtc': instance.createdAtUtc,
      'relayedAtUtc': instance.relayedAtUtc,
      'finalizedAtUtc': instance.finalizedAtUtc,
      'errorMessage': instance.errorMessage,
      'btcExitDestination': instance.btcExitDestination,
      'btcExitTxHash': instance.btcExitTxHash,
    };
