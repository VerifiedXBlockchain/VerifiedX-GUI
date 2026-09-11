import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/dialogs.dart';
import '../../core/utils.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/toast.dart';
import '../../utils/validation.dart';
import '../asset/asset.dart';
import '../bridge/services/bridge_service.dart';
import '../encrypt/utils.dart';
import '../global_loader/global_loading_provider.dart';
import '../smart_contracts/features/evolve/evolve_phase.dart';
import '../smart_contracts/models/feature.dart';
import '../smart_contracts/services/smart_contract_service.dart';
import '../wallet/models/wallet.dart';
import '../wallet/providers/wallet_list_provider.dart';
import 'models/nft.dart';
import 'providers/nft_detail_provider.dart';
import 'providers/transferred_provider.dart';

Future<Nft> setAssetPath(Nft nft) async {
  final assetPath = await SmartContractService().getAssetPath(nft.id, nft.primaryAsset.fileName);

  if (assetPath != null) {
    final a = nft.primaryAsset.copyWith(localPath: assetPath);
    nft = nft.copyWith(primaryAsset: a);
  }

  final List<Asset> additionalAssets = [];

  for (final a in nft.additionalAssets) {
    final path = await SmartContractService().getAssetPath(nft.id, a.fileName);
    additionalAssets.add(a.copyWith(localPath: path));
  }

  nft = nft.copyWith(additionalLocalAssets: additionalAssets);

  for (final f in nft.featureList) {
    if (f.type == FeatureType.evolution) {
      final List<EvolvePhase> stages = [];
      for (final stage in nft.evolutionPhases) {
        if (stage.asset != null) {
          final p = await SmartContractService().getAssetPath(nft.id, stage.asset!.fileName);
          final a = stage.asset!.copyWith(localPath: p);
          stages.add(stage.copyWith(asset: a));
        } else {
          stages.add(stage);
        }
      }
      nft = nft.copyWith(updatedEvolutionPhases: stages);
    }
  }

  return nft;
}

Future<dynamic> initTransferNftProcess(
  BuildContext context,
  WidgetRef ref,
  Nft nft, {
  bool backupRequired = false,
  String? titleOverride,
  bool isToken = false,
  String? prefillAddress,
}) async {
  final id = nft.id;
  final l10n = AppLocalizations.of(context);
  final assetLabel = isToken ? 'Token' : 'NFT';

  final _provider = ref.read(nftDetailProvider(id).notifier);

  String? reservePassword;
  int? delayHours;
  String? fromAddress;

  if (nft.isListed(ref)) {
    Toast.error(l10n.r3gAssetListedInAuctionHouse(assetLabel));
    return;
  }

  if (!kIsWeb) {
    if (!await passwordRequiredGuard(context, ref)) {
      return;
    }

    Wallet? wallet = ref.read(walletListProvider).firstWhereOrNull((w) => w.address == nft.currentOwner);
    if (wallet == null) {
      Toast.error(l10n.messageNoAccountSelected);
      return;
    }

    fromAddress = wallet.address;

    if (wallet.balance < MIN_RBX_FOR_SC_ACTION) {
      Toast.error(l10n.nftNotEnoughBalanceToast);
      return;
    }

    final _nft = await setAssetPath(nft);

    final filesReady = await _nft.areFilesReady();

    if (!filesReady) {
      Toast.error(l10n.r3gMediaFilesNotFound);
      return;
    }
    if (wallet.isReserved) {
      reservePassword = await PromptModal.show(
        title: l10n.tkbVaultAccountPassword,
        validator: (_) => null,
        labelText: l10n.reservePasswordLabel,
        lines: 1,
        obscureText: true,
        revealObscure: true,
      );
      if (reservePassword == null) {
        return;
      }

      final hoursString = await PromptModal.show(
        title: l10n.svcTimelockDuration,
        validator: (_) => null,
        labelText: l10n.svcTimelockHoursLabel,
        initialValue: "24",
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );

      delayHours = (hoursString != null ? int.tryParse(hoursString) : 24) ?? 24;
      if (delayHours < 24) {
        delayHours = 24;
      }
    }
  }

  if (kIsWeb && nft.currentOwner.startsWith("xRBX")) {
    final hoursString = await PromptModal.show(
      title: l10n.svcTimelockDuration,
      validator: (_) => null,
      labelText: l10n.svcTimelockHoursLabel,
      initialValue: "24",
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );

    delayHours = (hoursString != null ? int.tryParse(hoursString) : 24) ?? 24;
    if (delayHours < 24) {
      delayHours = 24;
    }
  }
  final controller = TextEditingController(text: prefillAddress ?? '');
  PromptModal.show(
    controller: controller,
    contextOverride: context,
    // initialValue: prefillAddress ?? '',
    title: titleOverride ?? l10n.r3gTransferAssetTitle(assetLabel),
    validator: (value) => formValidatorRbxAddress(value, true),
    labelText: l10n.bw2LabelVfxAddress,
    confirmText: l10n.actionContinue,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9.]')),
    ],
    lines: 1,
    sufixIcon: AddressChoosingIconButton(controller: controller),
    onValidSubmission: (address) async {
      bool? success;

      address = address.trim().replaceAll("\n", "");

      if (kIsWeb) {
        ref.read(globalLoadingProvider.notifier).start();
        success = await _provider.transferWebOut(address, delayHours);
        if (success == true) {
          ref.read(transferredProvider.notifier).addId(id);

          Toast.message(l10n.r3gAssetTransferSentSuccess(assetLabel, address));
          Navigator.of(context).pop();
        } else {
          Toast.error();
        }
        ref.read(globalLoadingProvider.notifier).complete();
      } else {
        final isValid = await BridgeService().validateSendToAddress(address);
        if (!isValid) {
          Toast.error(l10n.nftInvalidAddressToast);
          return;
        }

        final optionalSuffix = backupRequired ? '' : l10n.r3gOptionalParenthetical;
        PromptModal.show(
          contextOverride: context,
          title: l10n.r3gBackupUrlTitle(optionalSuffix),
          body: l10n.r3gPasteZipfileUrl,
          validator: (value) {
            if (backupRequired) {
              if (value == null || value.trim().isEmpty) {
                return l10n.r3gBackupUrlRequired;
              }
              return null;
            }
            return null;
          },
          labelText: l10n.r3gUrlOptionalLabel(optionalSuffix),
          confirmText: l10n.nftTransfer,
          onValidSubmission: (url) async {
            final confirmed = await ConfirmDialog.show(
              title: l10n.bw2ConfirmTransfer,
              body: l10n.r3gConfirmSendAssetBody(
                assetLabel,
                address,
                reservePassword == null ? l10n.r3gNoRecoveryWarning(assetLabel) : '',
              ),
              confirmText: l10n.actionSend,
            );

            if (confirmed == true) {
              final success = reservePassword != null
                  ? await _provider.transferFromReserveAccount(
                      toAddress: address,
                      fromAddress: fromAddress!,
                      password: reservePassword,
                      backupUrl: url,
                      delayHours: delayHours!,
                      isToken: isToken)
                  : await _provider.transfer(address, url, isToken);

              if (!success) {
                return;
              }

              await InfoDialog.show(
                title: l10n.r3gTransferInProgress,
                body: l10n.r3gTransferInProgressBody(assetLabel),
                closeText: l10n.walletOkay,
              );

              Navigator.of(context).pop();
            }
          },
        );
      }
    },
  );
}
