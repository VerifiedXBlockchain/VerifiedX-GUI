import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../btc_web/models/watched_withdrawal.dart';
import '../models/vbtc_withdrawal_part.dart';

/// Follows one withdrawal request drawn from several watched vaults: a row
/// per part with its state and Bitcoin transaction, and that part's own
/// Raise fee, Release, or (while it waits for its transaction) Cancel. Every
/// state is read from the chain on open and every 20 seconds; nothing is
/// kept locally.
class VbtcMultiWithdrawalDialog extends StatefulWidget {
  final String requestHash;
  final List<VbtcWithdrawalPart> parts;
  final VbtcWithdrawalPartActions actions;

  const VbtcMultiWithdrawalDialog({
    super.key,
    required this.requestHash,
    required this.parts,
    required this.actions,
  });

  static Future<void> show({
    required String requestHash,
    required List<VbtcWithdrawalPart> parts,
    required VbtcWithdrawalPartActions actions,
    BuildContext? context,
  }) {
    return showDialog<void>(
      context: context ?? rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => VbtcMultiWithdrawalDialog(
        requestHash: requestHash,
        parts: parts,
        actions: actions,
      ),
    );
  }

  @override
  State<VbtcMultiWithdrawalDialog> createState() => _VbtcMultiWithdrawalDialogState();
}

class _VbtcMultiWithdrawalDialogState extends State<VbtcMultiWithdrawalDialog> {
  static const _refreshInterval = Duration(seconds: 20);

  late final Map<String, WatchedWithdrawal?> _states = {for (final p in widget.parts) p.scIdentifier: null};

  /// A part's state when a raise, release or cancel was sent for it. Its
  /// actions stay off until the chain shows a change or [kWatchedActionWait]
  /// passes: each send costs a VFX fee.
  final Map<String, WatchedWithdrawal> _sentAgainst = {};
  final Map<String, DateTime> _sentAt = {};

  Timer? _timer;
  bool _refreshInFlight = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(_refreshInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// A tick waits for the previous tick's answers.
  Future<void> _refresh() async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      final answers = await Future.wait(widget.parts.map((p) => widget.actions.lookUp(p.scIdentifier)));
      if (!mounted) return;
      final now = DateTime.now();
      setState(() {
        for (var i = 0; i < widget.parts.length; i++) {
          final id = widget.parts[i].scIdentifier;
          final answer = answers[i];
          if (answer == null) continue;
          _states[id] = answer;
          final sent = _sentAgainst[id];
          if (sent != null && (answer.settlesChangeSentAgainst(sent) || watchedActionWaitIsOver(_sentAt[id], now))) {
            _sentAgainst.remove(id);
            _sentAt.remove(id);
          }
        }
      });
      if (_states.values.every((s) => s != null && s.isClosed)) {
        _timer?.cancel();
      }
    } finally {
      _refreshInFlight = false;
    }
  }

  void _markSent(String scIdentifier, WatchedWithdrawal against) {
    _sentAgainst[scIdentifier] = against;
    _sentAt[scIdentifier] = DateTime.now();
  }

  Future<void> _changeFee(int number, VbtcWithdrawalPart part, WatchedWithdrawal watched, {required bool release}) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final entered = await PromptModal.show(
      contextOverride: context,
      title: release ? l10n.btcMultiWdReleaseTitle(number) : l10n.btcMultiWdRaiseFeeTitle(number),
      body: release ? l10n.btcMultiWdReleaseBody : l10n.bw2WatchedNotConfirmingHint,
      labelText: l10n.bw2WatchedNewFeeRateLabel,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        final problem = watched.feeRateProblem(int.tryParse(value?.trim() ?? ''));
        return problem == null ? null : _feeRateProblemText(l10n, problem, watched);
      },
      confirmText: release ? l10n.bw2WatchedRelease : l10n.bw2WatchedRaiseFee,
      cancelText: l10n.actionCancel,
      fieldKey: const Key('vbtc:multi_wd_fee_rate'),
    );
    final feeRate = int.tryParse(entered?.trim() ?? '');
    if (feeRate == null || !mounted) return;

    setState(() => _busy = true);
    final sent = await widget.actions.changeFee(part.scIdentifier, feeRate, release: release);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (sent) _markSent(part.scIdentifier, watched);
    });
    if (sent) _refresh();
  }

  Future<void> _cancel(VbtcWithdrawalPart part, WatchedWithdrawal watched) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.bw2CancelWithdrawalQuestion,
      body: l10n.bw2WatchedCancelBody,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final sent = await widget.actions.cancel(part.scIdentifier);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (sent) _markSent(part.scIdentifier, watched);
    });
    if (sent) _refresh();
  }

  String _feeRateProblemText(AppLocalizations l10n, WatchedFeeRateProblem problem, WatchedWithdrawal watched) {
    switch (problem) {
      case WatchedFeeRateProblem.invalid:
        return l10n.bw2WatchedFeeRateInvalid;
      case WatchedFeeRateProblem.notAboveCurrent:
        return l10n.bw2WatchedFeeRateTooLow(watched.minimumNextFeeRate);
      case WatchedFeeRateProblem.aboveMaximum:
        return l10n.bw2WatchedFeeRateTooHigh(kWatchedWithdrawalMaxFeeRate);
    }
  }

  String _overallTitle(AppLocalizations l10n) {
    switch (vbtcMultiWithdrawalOverall(widget.parts.map((p) => _states[p.scIdentifier]).toList())) {
      case VbtcMultiWithdrawalOverall.notMinedYet:
        return l10n.btcMultiWdOverallNotMined;
      case VbtcMultiWithdrawalOverall.inProgress:
        return l10n.btcMultiWdOverallInProgress;
      case VbtcMultiWithdrawalOverall.sent:
        return l10n.btcMultiWdOverallSent;
      case VbtcMultiWithdrawalOverall.partlySent:
        return l10n.btcMultiWdOverallPartlySent;
      case VbtcMultiWithdrawalOverall.returned:
        return l10n.btcMultiWdOverallReturned;
    }
  }

  String _partStateText(AppLocalizations l10n, VbtcWithdrawalPartState state) {
    switch (state) {
      case VbtcWithdrawalPartState.checking:
        return l10n.btcMultiWdPartChecking;
      case VbtcWithdrawalPartState.notMinedYet:
        return l10n.btcMultiWdPartNotMined;
      case VbtcWithdrawalPartState.waiting:
        return l10n.btcMultiWdPartWaiting;
      case VbtcWithdrawalPartState.pinned:
        return l10n.btcMultiWdPartPinned;
      case VbtcWithdrawalPartState.releasing:
        return l10n.btcMultiWdPartReleasing;
      case VbtcWithdrawalPartState.paid:
        return l10n.btcMultiWdPartPaid;
      case VbtcWithdrawalPartState.returned:
        return l10n.btcMultiWdPartReturned;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(_overallTitle(l10n), style: const TextStyle(color: Colors.white)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 350),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.parts.length; i++) ...[
                if (i > 0) const Divider(height: 24),
                _buildPart(l10n, i + 1, widget.parts[i]),
              ],
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          key: const Key('vbtc:multi_wd_done'),
          label: l10n.actionDone,
          variant: AppColorVariant.Light,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildPart(AppLocalizations l10n, int number, VbtcWithdrawalPart part) {
    final watched = _states[part.scIdentifier];
    final state = vbtcWithdrawalPartState(watched);
    final awaitingChange = _sentAgainst.containsKey(part.scIdentifier);
    final enabled = !_busy && !awaitingChange;
    final btcTxHash = watched?.bitcoinTxHash;

    return Column(
      key: Key('vbtc:multi_wd_part_$number'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "${l10n.btcMultiWdPartLabel(number)} · ${part.name}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              "${part.amount} vBTC",
              style: TextStyle(color: Theme.of(context).colorScheme.btcOrange),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _partStateText(l10n, state),
          style: TextStyle(
            color: state == VbtcWithdrawalPartState.paid ? Colors.greenAccent : Colors.white70,
            fontSize: 13,
          ),
        ),
        if (btcTxHash != null) ...[
          const SizedBox(height: 6),
          _buildHashRow(l10n, btcTxHash),
        ],
        if (watched != null && watched.isPinned && watched.feeRate != null) ...[
          const SizedBox(height: 4),
          Text(l10n.bw2WatchedCurrentFeeRate(watched.feeRate!), style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
        if (awaitingChange) ...[
          const SizedBox(height: 6),
          Text(l10n.bw2WatchedChangeSent, style: const TextStyle(color: Color(0xFFE0A32E), fontSize: 12)),
        ],
        if (watched != null && (watched.canCancel || watched.canRelease || watched.canRaiseFee)) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (watched.canCancel)
                AppButton(
                  key: Key('vbtc:multi_wd_cancel_$number'),
                  label: l10n.bw2WatchedCancel,
                  variant: AppColorVariant.Danger,
                  onPressed: enabled ? () => _cancel(part, watched) : null,
                ),
              if (watched.canRelease)
                AppButton(
                  key: Key('vbtc:multi_wd_release_$number'),
                  label: l10n.bw2WatchedRelease,
                  variant: AppColorVariant.Warning,
                  onPressed: enabled ? () => _changeFee(number, part, watched, release: true) : null,
                ),
              if (watched.canRaiseFee)
                AppButton(
                  key: Key('vbtc:multi_wd_raise_$number'),
                  label: l10n.bw2WatchedRaiseFee,
                  variant: AppColorVariant.Primary,
                  onPressed: enabled ? () => _changeFee(number, part, watched, release: false) : null,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildHashRow(AppLocalizations l10n, String hash) {
    final explorerUrl = Env.btcExplorerTxUrl(hash);
    return Row(
      children: [
        Expanded(
          child: SelectableText(hash, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: l10n.actionCopyTransactionHash,
          button: true,
          child: InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: hash));
              Toast.message(l10n.messageCopiedToClipboard);
            },
            child: const Icon(Icons.copy, size: 16, color: Colors.white54),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: l10n.btcOpenInExplorer,
          button: true,
          child: InkWell(
            onTap: () => launchUrlString(explorerUrl),
            child: const Icon(Icons.open_in_new, size: 16, color: Colors.white54),
          ),
        ),
      ],
    );
  }
}
