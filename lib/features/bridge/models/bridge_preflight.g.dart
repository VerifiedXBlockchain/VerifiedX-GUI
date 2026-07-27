// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_preflight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BridgePreflight _$$_BridgePreflightFromJson(Map<String, dynamic> json) =>
    _$_BridgePreflight(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      ownerAddress: json['ownerAddress'] as String? ?? "",
      scUid: json['scUID'] as String? ?? "",
      availableVbtc: (json['availableVbtc'] as num?)?.toDouble() ?? 0.0,
      vbtcError: json['vbtcError'] as String?,
      derivedBaseAddress: json['derivedBaseAddress'] as String? ?? "",
      hasDerivedAddress: json['hasDerivedAddress'] as bool? ?? false,
      ethBalance: (json['ethBalance'] as num?)?.toDouble(),
      ethError: json['ethError'] as String?,
      vbtcBBalance: (json['vbtcBBalance'] as num?)?.toDouble(),
      vbtcBError: json['vbtcBError'] as String?,
      bridgeConfigured: json['bridgeConfigured'] as bool? ?? false,
      canReadEth: json['canReadEth'] as bool? ?? false,
      canReadVbtc: json['canReadVbtc'] as bool? ?? false,
      networkName: json['networkName'] as String?,
      chainId: json['chainId'] as int?,
      contractAddress: json['contractAddress'] as String?,
    );

Map<String, dynamic> _$$_BridgePreflightToJson(_$_BridgePreflight instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'ownerAddress': instance.ownerAddress,
      'scUID': instance.scUid,
      'availableVbtc': instance.availableVbtc,
      'vbtcError': instance.vbtcError,
      'derivedBaseAddress': instance.derivedBaseAddress,
      'hasDerivedAddress': instance.hasDerivedAddress,
      'ethBalance': instance.ethBalance,
      'ethError': instance.ethError,
      'vbtcBBalance': instance.vbtcBBalance,
      'vbtcBError': instance.vbtcBError,
      'bridgeConfigured': instance.bridgeConfigured,
      'canReadEth': instance.canReadEth,
      'canReadVbtc': instance.canReadVbtc,
      'networkName': instance.networkName,
      'chainId': instance.chainId,
      'contractAddress': instance.contractAddress,
    };
