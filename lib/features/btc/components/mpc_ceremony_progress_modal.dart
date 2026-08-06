import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/mpc_ceremony.dart';
import '../providers/mpc_ceremony_provider.dart';

class MpcCeremonyProgressModal extends ConsumerWidget {
  const MpcCeremonyProgressModal({super.key});

  static Future<bool?> show([BuildContext? context]) {
    return showDialog<bool>(
      context: context ?? rootNavigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (_) => const MpcCeremonyProgressModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mpcCeremonyProvider);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForPhase(state.phase, l10n),
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            color: Colors.white38,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, minWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.phase == MpcCeremonyPhase.ceremonyInProgress ||
                state.phase == MpcCeremonyPhase.ceremonyCompleted)
              _buildStepIndicators(state, context),
            if (state.phase == MpcCeremonyPhase.ceremonyInProgress) ...[
              const SizedBox(height: 16),
              _buildProgressSection(state, l10n),
            ],
            if (state.phase == MpcCeremonyPhase.ceremonyCompleted) ...[
              const SizedBox(height: 16),
              _buildCompletedSection(state, l10n),
            ],
            if (state.phase == MpcCeremonyPhase.creatingContract) ...[
              const SizedBox(height: 16),
              _buildCreatingContractSection(l10n),
            ],
            if (state.phase == MpcCeremonyPhase.contractCreated) ...[
              const SizedBox(height: 16),
              _buildContractCreatedSection(state, context),
            ],
            if (state.phase == MpcCeremonyPhase.failed) ...[
              const SizedBox(height: 16),
              _buildFailedSection(state, ref, context),
            ],
          ],
        ),
      ),
    );
  }

  String _titleForPhase(MpcCeremonyPhase phase, AppLocalizations l10n) {
    switch (phase) {
      case MpcCeremonyPhase.idle:
        return l10n.bw2MpcCeremony;
      case MpcCeremonyPhase.ceremonyInProgress:
        return l10n.bw2MpcCeremonyInProgress;
      case MpcCeremonyPhase.ceremonyCompleted:
        return l10n.bw2CeremonyCompleted;
      case MpcCeremonyPhase.creatingContract:
        return l10n.bw2CreatingContract;
      case MpcCeremonyPhase.contractCreated:
        return l10n.bw2ContractCreated;
      case MpcCeremonyPhase.failed:
        return l10n.bw2CeremonyFailed;
    }
  }

  Widget _buildStepIndicators(MpcCeremonyState state, BuildContext context) {
    final ceremony = state.ceremony;
    if (ceremony == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final currentStatus = ceremony.status;

    final steps = [
      _CeremonyStep(l10n.bw2StepInitiated, MpcCeremonyStatus.initiated),
      _CeremonyStep(l10n.bw2StepValidating, MpcCeremonyStatus.validatingValidators),
      _CeremonyStep(l10n.bw2StepRound1, MpcCeremonyStatus.round1InProgress),
      _CeremonyStep(l10n.bw2StepRound2, MpcCeremonyStatus.round2InProgress),
      _CeremonyStep(l10n.bw2StepRound3, MpcCeremonyStatus.round3InProgress),
      _CeremonyStep(l10n.bw2StepCompleted, MpcCeremonyStatus.completed),
    ];

    return Row(
      children: steps.map((step) {
        final isActive = currentStatus == step.status;
        final isPast = currentStatus.index > step.status.index;
        final isCompleted = isPast || (isActive && step.status == MpcCeremonyStatus.completed);

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.success
                      : isActive
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white24,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : isActive
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive || isCompleted ? Colors.white : Colors.white38,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressSection(MpcCeremonyState state, AppLocalizations l10n) {
    final ceremony = state.ceremony;
    if (ceremony == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: ceremony.progressPercentage / 100.0,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(_secondaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bw2PercentComplete(ceremony.progressPercentage.toString()),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        if (ceremony.validatorCount != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.bw2ValidatorsThreshold(ceremony.validatorCount.toString(), (ceremony.requiredThreshold ?? '-').toString()),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          l10n.bw2CeremonyDismissHint,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCompletedSection(MpcCeremonyState state, AppLocalizations l10n) {
    final ceremony = state.ceremony;
    if (ceremony == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: _successColor, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.bw2MpcCeremonyCompletedSuccess,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (ceremony.depositAddress != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.bw2DepositAddressLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SelectableText(
            ceremony.depositAddress!,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildCreatingContractSection(AppLocalizations l10n) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.bw2CreatingVbtcContract,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildContractCreatedSection(MpcCeremonyState state, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: _successColor, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.bw2VbtcContractCreatedSuccess,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (state.contractHash != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.bw2TransactionHashColon,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SelectableText(
            state.contractHash!,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: l10n.actionDone,
            variant: AppColorVariant.Success,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedSection(MpcCeremonyState state, WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: _dangerColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.errorMessage ?? AppLocalizations.of(context).bw2AnErrorOccurred,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppButton(
          label: AppLocalizations.of(context).btcRetry,
          variant: AppColorVariant.Danger,
          onPressed: () {
            ref.read(mpcCeremonyProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class _CeremonyStep {
  final String label;
  final MpcCeremonyStatus status;

  const _CeremonyStep(this.label, this.status);
}

const _secondaryColor = Color(0xFF73c4fa);
const _successColor = Color(0xFF43ae52);
const _dangerColor = Color(0xFFBA2121);
