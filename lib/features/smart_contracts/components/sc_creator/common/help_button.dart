import 'package:flutter/material.dart';

import '../../../../../core/app_constants.dart';
import '../../../../../core/dialogs.dart';
import '../../../../../l10n/l10n_helper.dart';

enum HelpType {
  unknown,
  baselineProperties,
  smartContractName,
  description,
  minterName,
  ownerAddress,
  primaryAsset,
  features,
  royaltyPercent,
  royaltyFlat,
  royaltyAddress,
  evolveMode,
  evolveType,
  evolveDatetime,
  evolveBlockHeight,
  evolveStageName,
  evolveAsset,
  evolveStageDescription,
  smartContract,
  saveAsDraft,
  compile,
  mint,
  delete,
  burn,
  transfer,
  minting,
  setEvolution,
  manageProperties,
  configuration,
  apiPort,
  apiCallUrl,
  walletUnlockTime,
  nftTimeout,
  passwordClearTime,
  autoDownloadNftAsset,
  ignoreIncomingNfts,
  rejectAssetExtensionTypes,
  allowedAssetExtensionTypes,
  motherAddress,
  motherPassword,
  mintQuantity,
  properties,
  propertyTyes,
}

class HelpButton extends StatelessWidget {
  final HelpType type;
  final bool subtle;
  final Color? color;
  final bool mini;
  const HelpButton(
    this.type, {
    Key? key,
    this.subtle = false,
    this.color,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: mini ? const BoxConstraints() : null,
      visualDensity: mini ? VisualDensity.compact : VisualDensity.standard,
      icon: Icon(
        Icons.help,
        color: color != null ? color! : Theme.of(context).colorScheme.secondary.withOpacity(subtle ? 0.7 : 1),
        size: subtle ? 16 : 22,
      ),
      onPressed: () {
        InfoDialog.show(title: _title, body: _body, closeText: globalL10n.actionClose, icon: Icons.help, headerColor: Theme.of(context).colorScheme.secondary);
      },
    );
  }

  String get _title {
    switch (type) {
      case HelpType.unknown:
        return globalL10n.r3aNotImplemented;
      case HelpType.smartContractName:
        return globalL10n.r3aSmartContractName;
      case HelpType.description:
        return globalL10n.btcDetailDescriptionLabel;
      case HelpType.ownerAddress:
        return globalL10n.scwOwnerAddress;
      case HelpType.baselineProperties:
        return globalL10n.scwProperties;
      case HelpType.minterName:
        return globalL10n.r3aMinterName;
      case HelpType.primaryAsset:
        return globalL10n.scwPrimaryAsset;
      case HelpType.features:
        return globalL10n.r3aFeatures;
      case HelpType.royaltyPercent:
        return globalL10n.r3aRoyaltyPercentageFeeAmount;
      case HelpType.royaltyFlat:
        return globalL10n.r3aRoyaltyFlatFeeAmount;
      case HelpType.royaltyAddress:
        return globalL10n.r3aPayeeAddress;

      case HelpType.evolveMode:
        return globalL10n.r3aEvolutionMode;
      case HelpType.evolveType:
        return globalL10n.r3aEvolutionType;
      case HelpType.evolveDatetime:
        return globalL10n.r3aDateTimeVariable;
      case HelpType.evolveBlockHeight:
        return globalL10n.r3aBlockHeightVariable;
      case HelpType.evolveStageName:
        return globalL10n.scwEvolveStageName;
      case HelpType.evolveStageDescription:
        return globalL10n.scwEvolveStageDescription;
      case HelpType.evolveAsset:
        return globalL10n.scwEvolveStageAsset;
      case HelpType.smartContract:
        return globalL10n.r3aSmartContract;
      case HelpType.saveAsDraft:
        return globalL10n.r3aSaveAsDraft;
      case HelpType.compile:
        return globalL10n.r3aCompile;
      case HelpType.mint:
        return globalL10n.r3aMint;
      case HelpType.delete:
        return globalL10n.actionDelete;
      case HelpType.burn:
        return globalL10n.r3aBurnNft;
      case HelpType.transfer:
        return globalL10n.r3aTransferNft;
      case HelpType.minting:
        return globalL10n.r3aMinting;
      case HelpType.setEvolution:
        return globalL10n.r3aSetEvolution;
      case HelpType.manageProperties:
        return globalL10n.scwProperties;

      case HelpType.configuration:
        return globalL10n.r3aConfiguration;
      case HelpType.apiPort:
        return globalL10n.hnavConfigApiPort;
      case HelpType.apiCallUrl:
        return globalL10n.hnavConfigApiCallUrl;
      case HelpType.walletUnlockTime:
        return globalL10n.r3aAccountUnlockTime;
      case HelpType.nftTimeout:
        return globalL10n.r3aNftTimeout;
      case HelpType.passwordClearTime:
        return globalL10n.r3aPasswordClearTime;
      case HelpType.autoDownloadNftAsset:
        return globalL10n.r3aAutoDownloadNftAsset;
      case HelpType.ignoreIncomingNfts:
        return globalL10n.r3aIgnoreIncomingNfts;
      case HelpType.rejectAssetExtensionTypes:
        return globalL10n.r3aRejectAssetExtensionTypes;
      case HelpType.allowedAssetExtensionTypes:
        return globalL10n.r3aAllowedAssetExtensionTypes;
      case HelpType.motherAddress:
        return globalL10n.r3aMotherAddress;
      case HelpType.motherPassword:
        return globalL10n.r3aMotherPassword;
      case HelpType.mintQuantity:
        return globalL10n.scwQuantityToMint;
      case HelpType.properties:
        return globalL10n.scwProperties;
      case HelpType.propertyTyes:
        return globalL10n.r3aPropertyTypes;
    }
  }

  String get _body {
    switch (type) {
      case HelpType.unknown:
        return globalL10n.scwNotImplemented;
      case HelpType.smartContractName:
        return globalL10n.r3aHelpBodyScName;
      case HelpType.ownerAddress:
        return globalL10n.r3aHelpBodyOwnerAddress;
      case HelpType.description:
        return globalL10n.r3aHelpBodyDescription;
      case HelpType.baselineProperties:
        return globalL10n.r3aHelpBodyBaseline;
      case HelpType.minterName:
        return globalL10n.r3aHelpBodyMinterName;
      case HelpType.primaryAsset:
        return globalL10n.r3aHelpBodyPrimaryAsset;
      case HelpType.features:
        return globalL10n.r3aHelpBodyFeatures;
      case HelpType.royaltyPercent:
        return globalL10n.r3aHelpBodyRoyaltyPercent;
      case HelpType.royaltyFlat:
        return globalL10n.r3aHelpBodyRoyaltyFlat;
      case HelpType.royaltyAddress:
        return globalL10n.r3aHelpBodyRoyaltyAddress;
      case HelpType.evolveMode:
        return globalL10n.r3aHelpBodyEvolveMode;
      case HelpType.evolveType:
        return globalL10n.r3aHelpBodyEvolveType;
      case HelpType.evolveBlockHeight:
        return globalL10n.r3aHelpBodyEvolveBlockHeight;
      case HelpType.evolveStageName:
        return globalL10n.r3aHelpBodyEvolveStageName;
      case HelpType.evolveStageDescription:
        return globalL10n.r3aHelpBodyEvolveStageDescription;
      case HelpType.evolveAsset:
        return globalL10n.r3aHelpBodyEvolveAsset;
      case HelpType.evolveDatetime:
        return globalL10n.r3aHelpBodyEvolveDatetime;
      case HelpType.smartContract:
        return globalL10n.r3aHelpBodySmartContract;
      case HelpType.saveAsDraft:
        return globalL10n.r3aHelpBodySaveAsDraft;
      case HelpType.compile:
        return globalL10n.r3aHelpBodyCompile;
      case HelpType.mint:
        return globalL10n.r3aHelpBodyMint;
      case HelpType.delete:
        return globalL10n.r3aHelpBodyDelete;
      case HelpType.burn:
        return globalL10n.r3aHelpBodyBurn;
      case HelpType.transfer:
        return globalL10n.r3aHelpBodyTransfer;
      case HelpType.minting:
        return globalL10n.r3aHelpBodyMinting;
      case HelpType.setEvolution:
        return globalL10n.r3aHelpBodySetEvolution;
      case HelpType.manageProperties:
        return globalL10n.r3aHelpBodyManageProperties;

      case HelpType.configuration:
        return globalL10n.r3aHelpBodyConfiguration;
      case HelpType.apiPort:
        return globalL10n.r3aHelpBodyApiPort;
      case HelpType.apiCallUrl:
        return globalL10n.r3aHelpBodyApiCallUrl;
      case HelpType.walletUnlockTime:
        return globalL10n.r3aHelpBodyWalletUnlockTime;
      case HelpType.nftTimeout:
        return globalL10n.r3aHelpBodyNftTimeout;
      case HelpType.passwordClearTime:
        return globalL10n.r3aHelpBodyPasswordClearTime;
      case HelpType.autoDownloadNftAsset:
        return globalL10n.r3aHelpBodyAutoDownload;
      case HelpType.ignoreIncomingNfts:
        return globalL10n.r3aHelpBodyIgnoreIncoming;
      case HelpType.rejectAssetExtensionTypes:
        return globalL10n.r3aHelpBodyRejectExt(DEFAULT_REJECTED_EXTENIONS.join(','));
      case HelpType.allowedAssetExtensionTypes:
        return globalL10n.r3aHelpBodyAllowedExt;
      case HelpType.motherAddress:
        return globalL10n.r3aHelpBodyMotherAddress;
      case HelpType.motherPassword:
        return globalL10n.r3aHelpBodyMotherPassword;
      case HelpType.mintQuantity:
        return globalL10n.r3aHelpBodyMintQuantity;
      case HelpType.properties:
        return globalL10n.r3aHelpBodyProperties;
      case HelpType.propertyTyes:
        return globalL10n.r3aHelpBodyPropertyTypes;
    }
  }
}
