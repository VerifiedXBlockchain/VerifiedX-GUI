// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenized_bitcoin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TokenizedBitcoin _$$_TokenizedBitcoinFromJson(Map<String, dynamic> json) =>
    _$_TokenizedBitcoin(
      id: (json['Id'] as num).toDouble(),
      smartContractUid: json['SmartContractUID'] as String,
      rbxAddress: json['RBXAddress'] as String,
      btcAddress: json['BTCAddress'] as String?,
      tokenName: json['TokenName'] as String,
      tokenDescription: json['TokenDescription'] as String,
      smartContractMainId: (json['SmartContractMainId'] as num).toDouble(),
      isPublished: json['IsPublished'] as bool,
    );

Map<String, dynamic> _$$_TokenizedBitcoinToJson(_$_TokenizedBitcoin instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'SmartContractUID': instance.smartContractUid,
      'RBXAddress': instance.rbxAddress,
      'BTCAddress': instance.btcAddress,
      'TokenName': instance.tokenName,
      'TokenDescription': instance.tokenDescription,
      'SmartContractMainId': instance.smartContractMainId,
      'IsPublished': instance.isPublished,
    };