import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'tokenize.dart';
import '../../token/models/token_sc_feature.dart';

import '../features/evolve/evolve.dart';
import '../features/royalty/royalty.dart';
import '../features/soul_bound/soul_bound.dart';
import '../features/ticket/ticket.dart';
import 'fractional.dart';
import 'multi_asset.dart';
import 'pair.dart';
import 'tokenization.dart';
import '../../../l10n/l10n_helper.dart';

part 'feature.freezed.dart';
part 'feature.g.dart';

enum FeatureType {
  royalty,
  evolution,
  multiAsset,
  ticket,
  tokenization,
  music,
  additionalOwners,
  selfDestructive,
  consumable,
  fractionalization,
  pair,
  soulBound,
  wrap,
  token,
  btcTokenization,
  notImplemented,
}

@freezed
abstract class Feature with _$Feature {
  const Feature._();

  factory Feature({
    @Default(FeatureType.royalty) FeatureType type,
    @Default({}) Map<String, dynamic> data,
  }) = _Feature;

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);

  factory Feature.fromCompiler(Map<String, dynamic> f) {
    switch (f['FeatureName']) {
      case Evolve.compilerEnum:
        final payload = {'phases': f['FeatureFeatures']};
        final data = Feature(
          type: FeatureType.evolution,
          data: Evolve.fromCompiler(payload).toJson(),
        );
        return data;
      case Royalty.compilerEnum:
        return Feature(
          type: FeatureType.royalty,
          data: Royalty.fromCompiler(f['FeatureFeatures']).toJson(),
        );
      case MultiAsset.compilerEnum:
        return Feature(
          type: FeatureType.multiAsset,
          data: MultiAsset.fromCompiler(f['FeatureFeatures']).toJson(),
        );

      case TokenScFeature.compilerEnum:
        return Feature(
          type: FeatureType.token,
          data: TokenScFeature.fromJson(f['FeatureFeatures']).toJson(),
        );
      case Tokenize.compilerEnum:
        return Feature(
          type: FeatureType.token,
          data: Tokenize.fromJson(f['FeatureFeatures']).toJson(),
        );

      default:
        return Feature(type: FeatureType.notImplemented, data: {});
    }
  }

  String get nameLabel {
    return typeToName(type);
  }

  String get genericDescription {
    if (isAvailable) {
      switch (type) {
        case FeatureType.royalty:
          return globalL10n.r3aFeatureDescRoyalty;
        case FeatureType.evolution:
          return globalL10n.r3aFeatureDescEvolution;
        case FeatureType.multiAsset:
          return globalL10n.r3aFeatureDescMultiAsset;
        case FeatureType.tokenization:
          return globalL10n.r3aFeatureDescTokenization;
        case FeatureType.fractionalization:
          return globalL10n.r3aFeatureDescFractional;
        case FeatureType.pair:
          return globalL10n.r3aFeatureDescPair;
        case FeatureType.soulBound:
          return globalL10n.r3aFeatureDescSoulBound;
        case FeatureType.btcTokenization:
          return globalL10n.r3aFeatureDescBtcTokenization;
        default:
          break;
      }
    }
    return globalL10n.r3aActivatingSoon;
  }

  IconData get icon {
    return typeToIcon(type);
  }

  bool get isAvailable {
    switch (type) {
      case FeatureType.royalty:
      case FeatureType.evolution:
      case FeatureType.multiAsset:
        // case FeatureType.btcTokenization:
        // case FeatureType.tokenization:
        // case FeatureType.pair:
        // case FeatureType.fractionalization:
        // case FeatureType.soulBound:
        // case FeatureType.ticket:
        return true;
      default:
        return false;
    }
  }

  static List<FeatureType> allTypes() {
    return [
      FeatureType.royalty,
      FeatureType.evolution,
      FeatureType.multiAsset,
      // FeatureType.tokenization,
      // FeatureType.fractionalization,
      // FeatureType.btcTokenization,
      // FeatureType.pair,
      // FeatureType.soulBound,
      // FeatureType.ticket,
      // FeatureType.music,
      // FeatureType.additionalOwners,
      // FeatureType.selfDestructive,
      // FeatureType.consumable,
      // FeatureType.wrap,
    ];
  }

  bool get canEdit {
    if (type == FeatureType.btcTokenization) {
      return false;
    }
    return true;
  }

  String get description {
    switch (type) {
      case FeatureType.royalty:
        final royalty = Royalty.fromJson(data);
        return "${royalty.typeLabel} ${royalty.amountWithSuffix} [${royalty.address}]";
      case FeatureType.evolution:
        final evolve = Evolve.fromJson(data);
        return "${evolve.phases.length + 1} phase${evolve.phases.length + 1 == 1 ? '' : 's'}";
      case FeatureType.ticket:
        final ticket = Ticket.fromJson(data);
        return "${ticket.typeLabel}: ${ticket.eventName} (${ticket.dateTimeLabel})";
      case FeatureType.multiAsset:
        final multiAsset = MultiAsset.fromJson(data);
        return "${multiAsset.assets.length} asset${multiAsset.assets.length == 1 ? '' : 's'}";
      case FeatureType.tokenization:
        final tokenization = Tokenization.fromJson(data);
        String label = tokenization.name;
        if (tokenization.properties.isNotEmpty) {
          if (tokenization.properties.length == 1) {
            label = "$label (1 property)";
          } else {
            label = "$label (${tokenization.properties.length} properties)";
          }
        }
        return label;
      case FeatureType.fractionalization:
        final fractional = Fractional.fromJson(data);
        return "${fractional.fractionalInterest}% | Creator Retains: ${fractional.creatorRetains}%";
      case FeatureType.pair:
        final pair = Pair.fromJson(data);
        return "${pair.network} [${pair.nftAddress}]";
      case FeatureType.soulBound:
        final sb = SoulBound.fromJson(data);
        return "${sb.ownerAddress} ${sb.beneficiaryAddress != null && sb.beneficiaryAddress!.isNotEmpty ? '(Beneficiary: ${sb.beneficiaryAddress})' : ''}";

      case FeatureType.token:
        if (data.containsKey("AssetTicker") && data.containsKey('AssetName')) {
          return "${data['AssetName']} [${data['AssetTicker']}]";
        }
        return globalL10n.r3aToken;
      case FeatureType.btcTokenization:
        return globalL10n.r3aBtcTokenization;
      default:
        return globalL10n.r3aNotImplemented;
    }
  }

  static String typeToName(FeatureType type) {
    switch (type) {
      case FeatureType.royalty:
        return globalL10n.scwRoyaltyTitle;
      case FeatureType.evolution:
        return globalL10n.r3aFeatureNameEvolving;
      case FeatureType.multiAsset:
        return globalL10n.r3aMultiAsset;
      case FeatureType.ticket:
        return globalL10n.r3aTicketing;
      case FeatureType.tokenization:
        return globalL10n.r3aTokenizationPhysicalDigital;
      case FeatureType.music:
        return globalL10n.r3aMusicRelease;
      case FeatureType.additionalOwners:
        return globalL10n.r3aAdditionalOwners;
      case FeatureType.selfDestructive:
        return globalL10n.r3aSelfDestructive;
      case FeatureType.consumable:
        return globalL10n.r3aConsumable;
      case FeatureType.fractionalization:
        return globalL10n.scwFractionalizationTitle;
      case FeatureType.pair:
        return globalL10n.r3aMintPhysicalRwa;
      case FeatureType.soulBound:
        return globalL10n.scwSoulBoundTitle;
      case FeatureType.wrap:
        return globalL10n.r3aWrap;
      case FeatureType.token:
        return globalL10n.r3aToken;
      case FeatureType.btcTokenization:
        return globalL10n.r3aBtcTokenization;
      case FeatureType.notImplemented:
        return globalL10n.r3aNotImplemented;
    }
  }

  static IconData typeToIcon(FeatureType type) {
    switch (type) {
      case FeatureType.royalty:
        return FontAwesomeIcons.moneyBill;
      case FeatureType.evolution:
        return FontAwesomeIcons.circleHalfStroke;
      case FeatureType.multiAsset:
        return FontAwesomeIcons.rectangleList;
      case FeatureType.ticket:
        return FontAwesomeIcons.ticketSimple;
      case FeatureType.tokenization:
        return FontAwesomeIcons.trophy;
      case FeatureType.music:
        return FontAwesomeIcons.music;
      case FeatureType.additionalOwners:
        return FontAwesomeIcons.users;
      case FeatureType.selfDestructive:
        return FontAwesomeIcons.fire;
      case FeatureType.consumable:
        return FontAwesomeIcons.boxOpen;
      case FeatureType.fractionalization:
        return FontAwesomeIcons.divide;
      case FeatureType.pair:
        return FontAwesomeIcons.leftRight;
      case FeatureType.soulBound:
        return FontAwesomeIcons.person;
      case FeatureType.btcTokenization:
        return FontAwesomeIcons.bitcoin;

      default:
        return Icons.star;
    }
  }
}
