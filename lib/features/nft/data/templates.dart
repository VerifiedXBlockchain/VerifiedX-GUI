import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../generated/assets.gen.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../smart_contracts/features/evolve/evolve.dart';
import '../../smart_contracts/features/evolve/evolve_phase.dart';
import '../../smart_contracts/features/royalty/royalty.dart';
import '../../smart_contracts/models/smart_contract.dart';
import '../../smart_contracts/models/smart_contract_template.dart';
import '../../smart_contracts/providers/create_smart_contract_provider.dart';
import '../components/learn_more_content.dart';

List<SmartContractTemplate> getSmartContractTemplates(
    BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final _provider = ref.read(createSmartContractProvider.notifier);

  void _createBaseline() {
    final smartContract = SmartContract(
      owner: ref.read(sessionProvider).currentWallet!,
      name: "",
      description: "",
    );

    _provider.setSmartContract(smartContract);
  }

  void _createEvolving() {
    const evolve = Evolve(phases: [
      EvolvePhase(
        name: "",
        description: "",
      )
    ]);
    final smartContract = SmartContract(
        owner: ref.read(sessionProvider).currentWallet!,
        name: "",
        description: "",
        evolves: [evolve]);

    _provider.setSmartContract(smartContract);
  }

  void _createRoyalty() {
    final royalty = Royalty(
      amount: 0.05,
      type: RoyaltyType.percent,
      address: ref.read(sessionProvider).currentWallet!.address,
    );
    final smartContract = SmartContract(
      owner: ref.read(sessionProvider).currentWallet!,
      name: "",
      description: "",
      royalties: [royalty],
    );

    _provider.setSmartContract(smartContract);
  }

  final templates = [
    SmartContractTemplate(
      name: l10n.r3gTplBaselineName,
      color: Theme.of(context).colorScheme.primary,
      description: l10n.r3gTplBaselineDesc,
      images: [
        Assets.images.templateBasic1a.path,
        Assets.images.templateBasic2a.path,
        Assets.images.templateBasic3a.path,
      ],
      init: _createBaseline,
      learnMoreContent: LearnMoreContent(
        onCreate: _createBaseline,
        steps: [
          LearnMoreStep(
            title: l10n.r3gStepMetadataTitle,
            description: l10n.r3gStepMetadataDesc,
            imagePath: Assets.images.tutBasic1.path,
          ),
          LearnMoreStep(
            title: l10n.scwPrimaryAsset,
            description: l10n.r3gStepPrimaryAssetDesc,
            imagePath: Assets.images.tutBasic2.path,
          ),
          LearnMoreStep(
            title: l10n.r3gStepMintTitle,
            description: l10n.r3gStepMintDesc,
            imagePath: Assets.images.tutBasic3.path,
          ),
        ],
      ),
    ),
    SmartContractTemplate(
      name: l10n.r3gTplEvolvingName,
      description: l10n.r3gTplEvolvingDesc,
      images: [
        Assets.images.templateEvolving1a.path,
        Assets.images.templateEvolving2a.path,
        Assets.images.templateEvolving3a.path,
      ],
      learnMoreContent: LearnMoreContent(
        onCreate: _createEvolving,
        steps: [
          LearnMoreStep(
            title: l10n.r3gStepEvolutionModeTitle,
            description: l10n.r3gStepEvolutionModeDesc,
            imagePath: Assets.images.tutEvolve1.path,
          ),
          LearnMoreStep(
            title: l10n.r3gStepEvolutionTypeTitle,
            description: l10n.r3gStepEvolutionTypeDesc,
            imagePath: Assets.images.tutEvolve2.path,
          ),
          LearnMoreStep(
            title: l10n.r3gStepEvolutionStagesTitle,
            description: l10n.r3gStepEvolutionStagesDesc,
            imagePath: Assets.images.tutEvolve3.path,
          ),
        ],
      ),
      color: Theme.of(context).colorScheme.primary,
      init: _createEvolving,
    ),
    SmartContractTemplate(
      name: l10n.r3gTplRoyaltyName,
      description: l10n.r3gTplRoyaltyDesc,
      color: Theme.of(context).colorScheme.primary,
      images: [
        Assets.images.templateRoyalty1a.path,
        Assets.images.templateRoyalty2a.path,
        Assets.images.templateRoyalty3a.path,
      ],
      learnMoreContent: LearnMoreContent(
        onCreate: _createRoyalty,
        steps: [
          LearnMoreStep(
            title: l10n.scwRoyaltyType,
            description: l10n.r3gStepRoyaltyTypeDesc,
            imagePath: Assets.images.tutRoyalty1.path,
          ),
          LearnMoreStep(
            title: l10n.r3gStepAmountAddressTitle,
            description: l10n.r3gStepAmountAddressDesc,
            imagePath: Assets.images.tutRoyalty2.path,
          ),
          LearnMoreStep(
            title: l10n.r3gStepRoyaltyFeeTitle,
            description: l10n.r3gStepRoyaltyFeeDesc,
            imagePath: Assets.images.tutRoyalty3.path,
          ),
        ],
      ),
      init: _createRoyalty,
    ),
  ];

  return templates;
}
