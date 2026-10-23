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
import '../models/withdrawal_result.dart';
import '../services/vbtc_v2_service.dart';
import '../../transactions/services/local_transaction_service.dart';
import '../../../core/utils/tx_refresh.dart';

const _tag = '[vBTC-V2] WithdrawalDialog';

class WithdrawalProcessingDialog extends StatefulWidget {
  final String scUid;
  final String requestHash;
  final String? ownerAddress;

  /// When true, the dialog will poll for the request tx to be confirmed
  /// in a block before calling completeWithdrawal.
  final bool waitForConfirmation;

  /// Replaces the CompleteWithdrawal call in widget tests.
  @visibleForTesting
  final Future<WithdrawalResult> Function()? completeWithdrawalOverride;

  /// Replaces the GetWithdrawalPin lookup in widget tests.
  @visibleForTesting
  final Future<WatchedWithdrawal?> Function()? watchedWithdrawalOverride;

  const WithdrawalProcessingDialog({
    super.key,
    required this.scUid,
    required this.requestHash,
    this.ownerAddress,
    this.waitForConfirmation = false,
    this.completeWithdrawalOverride,
    this.watchedWithdrawalOverride,
  });

  /// Show the dialog and begin the completeWithdrawal call immediately.
  static Future<WithdrawalResult?> show({
    required String scUid,
    required String requestHash,
    String? ownerAddress,
    bool waitForConfirmation = false,
    BuildContext? context,
  }) {
    return showDialog<WithdrawalResult>(
      context: context ?? rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => WithdrawalProcessingDialog(
        scUid: scUid,
        requestHash: requestHash,
        ownerAddress: ownerAddress,
        waitForConfirmation: waitForConfirmation,
      ),
    );
  }

  @override
  State<WithdrawalProcessingDialog> createState() => _WithdrawalProcessingDialogState();
}

enum _DialogState {
  waitingForBlock,

  /// Asking whether the vault is one the chain watches before choosing a path.
  checkingStatus,
  processing,
  verifying,

  /// A watched vault: the chain pays the withdrawal; the requester can only
  /// follow it, raise its fee, release it or (before it is pinned) cancel it.
  watched,
  success,
  failure,
}

class _WithdrawalProcessingDialogState extends State<WithdrawalProcessingDialog> {
  _DialogState _state = _DialogState.processing;
  WithdrawalResult? _result;
  Timer? _confirmationTimer;
  int _confirmationPollCount = 0;
  static const _maxConfirmationPolls = 60; // 60 * 5s = 5 minutes max
  static const _confirmationPollInterval = Duration(seconds: 5);
  static const _maxVerificationPolls = 24; // 24 * 5s = 2 minutes max

  /// Guards Retry against a double tap starting two signing ceremonies.
  bool _busy = false;

  WatchedWithdrawal? _watched;
  Timer? _watchedTimer;
  bool _watchedRefreshInFlight = false;
  static const _watchedRefreshInterval = Duration(seconds: 20);
  final _feeRateController = TextEditingController();
  String? _feeRateError;

  /// The withdrawal as it stood when a raise, release or cancel was sent.
  /// Actions stay off until the chain shows a change, or [kWatchedActionWait]
  /// passes: each send costs a VFX fee, and a second one for the same change
  /// does nothing.
  WatchedWithdrawal? _sentAgainst;
  DateTime? _sentAt;

  /// Kept after the lock above is released, so the "probably dropped" note
  /// holds until a refresh shows the change or the withdrawal closes.
  WatchedWithdrawal? _sentSnapshot;
  bool _sentNotSeen = false;

  @override
  void initState() {
    super.initState();
    if (widget.waitForConfirmation) {
      _waitForRequestConfirmation();
    } else {
      _startCompletion();
    }
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    _watchedTimer?.cancel();
    _feeRateController.dispose();
    super.dispose();
  }

  Future<void> _waitForRequestConfirmation() async {
    debugPrint('$_tag Waiting for request tx to be confirmed in a block — hash: ${widget.requestHash}');
    setState(() => _state = _DialogState.waitingForBlock);
    _confirmationPollCount = 0;

    _confirmationTimer = Timer.periodic(_confirmationPollInterval, (timer) async {
      _confirmationPollCount++;
      debugPrint('$_tag Confirmation poll #$_confirmationPollCount for ${widget.requestHash}');

      if (_confirmationPollCount > _maxConfirmationPolls) {
        timer.cancel();
        if (!mounted) return;
        debugPrint('$_tag Confirmation poll timed out after $_maxConfirmationPolls attempts');
        setState(() {
          _result = WithdrawalResult(
            success: false,
            message: AppLocalizations.of(context).bw2WithdrawalTimedOut,
          );
          _state = _DialogState.failure;
        });
        return;
      }

      try {
        final transactions = await LocalTransactionService().transactionsAll();
        final match = transactions.where(
          (tx) => tx.hash == widget.requestHash && tx.height > 0,
        );

        if (match.isNotEmpty) {
          timer.cancel();
          debugPrint('$_tag Request tx confirmed in block ${match.first.height} — checking the vault');
          if (!mounted) return;
          _startCompletion();
        }
      } catch (e) {
        debugPrint('$_tag Confirmation poll error: $e');
      }
    });
  }

  /// A watched vault is paid by the chain, so it is only followed and
  /// CompleteWithdrawal (the FROST ceremony) is never called for it. When the
  /// lookup fails, CompleteWithdrawal still answers a watched vault with its
  /// state rather than signing, and that answer is handled the same way.
  Future<void> _startCompletion() async {
    setState(() => _state = _DialogState.checkingStatus);
    final watched = await _lookUpWatched();
    if (!mounted) return;
    if (watched != null) {
      _result = WithdrawalResult(success: true, requestHash: widget.requestHash, watched: watched);
      _showWatched(watched);
      return;
    }
    await _runCompleteWithdrawal();
  }

  Future<WatchedWithdrawal?> _lookUpWatched() {
    return widget.watchedWithdrawalOverride?.call() ??
        VbtcV2Service().watchedWithdrawal(
          scUid: widget.scUid,
          withdrawalRequestHash: widget.requestHash,
        );
  }

  Future<void> _runCompleteWithdrawal() async {
    if (_busy) return;
    _busy = true;
    debugPrint('$_tag Calling completeWithdrawal — scUid: ${widget.scUid}, requestHash: ${widget.requestHash}');
    setState(() => _state = _DialogState.processing);

    final result = await (widget.completeWithdrawalOverride?.call() ??
        VbtcV2Service().completeWithdrawal(
          scUid: widget.scUid,
          withdrawalRequestHash: widget.requestHash,
        ));

    _busy = false;
    if (!mounted) return;

    debugPrint('$_tag completeWithdrawal result — success: ${result.success}, vfxTx: ${result.vfxTransactionHash}, btcTx: ${result.btcTransactionHash}, message: ${result.message}');

    if (result.watched != null) {
      _result = result;
      _showWatched(result.watched!);
      return;
    }

    // A client-side timeout does not mean the ceremony failed — the CLI may
    // still be signing and broadcasting. Offering Retry here risks a second
    // Bitcoin transaction, so confirm the contract state first.
    if (!result.success && result.timedOut) {
      await _verifyWithdrawalSettled();
      return;
    }

    if (result.success) {
      notifyTransactionSubmitted();
    }

    setState(() {
      _result = result;
      _state = result.success ? _DialogState.success : _DialogState.failure;
    });
  }

  /// Polls the contract until this request shows up as settled, which means
  /// the CLI finished after our request timed out. Anything short of that —
  /// including a state the contract cannot account for — keeps polling.
  Future<void> _verifyWithdrawalSettled() async {
    debugPrint('$_tag Request timed out — verifying contract state for ${widget.requestHash}');
    setState(() => _state = _DialogState.verifying);

    for (int i = 0; i < _maxVerificationPolls; i++) {
      await Future.delayed(_confirmationPollInterval);
      if (!mounted) return;

      final stillActive = await VbtcV2Service().isWithdrawalStillActive(
        scUid: widget.scUid,
        withdrawalRequestHash: widget.requestHash,
      );
      if (!mounted) return;

      debugPrint('$_tag Verification poll #${i + 1} — stillActive: $stillActive');

      if (stillActive == false) {
        notifyTransactionSubmitted();
        setState(() {
          _result = WithdrawalResult(
            success: true,
            requestHash: widget.requestHash,
            message: "Withdrawal completed. The contract has recorded it as settled.",
          );
          _state = _DialogState.success;
        });
        return;
      }
    }

    if (!mounted) return;

    debugPrint('$_tag Verification exhausted — withdrawal still pending');
    setState(() {
      _result = WithdrawalResult(
        success: false,
        requestHash: widget.requestHash,
        message: "The signing ceremony timed out and the withdrawal has not been recorded as settled. "
            "It may yet complete on its own — re-check the token before retrying, as retrying can "
            "broadcast a second Bitcoin transaction.",
      );
      _state = _DialogState.failure;
    });
  }

  void _showWatched(WatchedWithdrawal watched) {
    setState(() {
      if (watched.settlesChangeSentAgainst(_sentSnapshot)) {
        _sentAgainst = null;
        _sentSnapshot = null;
        _sentNotSeen = false;
      } else if (_sentAgainst != null && watchedActionWaitIsOver(_sentAt, DateTime.now())) {
        _sentAgainst = null;
        _sentNotSeen = true;
      }
      _watched = watched;
      _state = _DialogState.watched;
    });
    _watchedTimer?.cancel();
    if (!watched.isClosed) {
      _watchedTimer = Timer.periodic(_watchedRefreshInterval, (_) => _refreshWatched());
    }
  }

  /// A tick waits for the previous tick's answer.
  Future<void> _refreshWatched() async {
    if (_watchedRefreshInFlight) return;
    _watchedRefreshInFlight = true;
    try {
      final watched = await _lookUpWatched();
      if (!mounted || watched == null) return;
      _showWatched(watched);
    } finally {
      _watchedRefreshInFlight = false;
    }
  }

  void _markSent(WatchedWithdrawal against) {
    _sentAgainst = against;
    _sentSnapshot = against;
    _sentAt = DateTime.now();
    _sentNotSeen = false;
  }

  String get _requester => _watched?.requester ?? widget.ownerAddress ?? '';

  Future<void> _sendWatchedChange({required bool release}) async {
    final watched = _watched;
    if (watched == null || _busy) return;
    final feeRate = int.tryParse(_feeRateController.text.trim());
    final problem = watched.feeRateProblem(feeRate);
    if (problem != null) {
      setState(() => _feeRateError = _feeRateProblemText(problem, watched));
      return;
    }

    setState(() {
      _busy = true;
      _feeRateError = null;
    });
    final sentHash = await VbtcV2Service().changeWatchedWithdrawal(
      scUid: widget.scUid,
      requestorAddress: _requester,
      withdrawalRequestHash: widget.requestHash,
      feeRate: feeRate!,
      release: release,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (sentHash != null) _markSent(watched);
    });
    if (sentHash != null) {
      _feeRateController.clear();
      _refreshWatched();
    }
  }

  /// Cancels a watched withdrawal still waiting for its Bitcoin transaction:
  /// when the cancel is mined the withdrawal closes and the vBTC is returned.
  Future<void> _cancelWatched() async {
    final watched = _watched;
    if (watched == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      title: l10n.bw2CancelWithdrawalQuestion,
      body: l10n.bw2WatchedCancelBody,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final sent = await VbtcV2Service().cancelWithdrawal(
      scUid: widget.scUid,
      ownerAddress: _requester,
      withdrawalRequestHash: widget.requestHash,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (sent) _markSent(watched);
    });
    if (sent) _refreshWatched();
  }

  String _feeRateProblemText(WatchedFeeRateProblem problem, WatchedWithdrawal watched) {
    final l10n = AppLocalizations.of(context);
    switch (problem) {
      case WatchedFeeRateProblem.invalid:
        return l10n.bw2WatchedFeeRateInvalid;
      case WatchedFeeRateProblem.notAboveCurrent:
        return l10n.bw2WatchedFeeRateTooLow(watched.minimumNextFeeRate);
      case WatchedFeeRateProblem.aboveMaximum:
        return l10n.bw2WatchedFeeRateTooHigh(kWatchedWithdrawalMaxFeeRate);
    }
  }

  /// What the caller gets back: the latest watched state, so a withdrawal
  /// still unconfirmed on Bitcoin is not reported as paid.
  void _close() => Navigator.of(context).pop(_result?.withWatched(_watched));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForState(l10n),
            style: const TextStyle(color: Colors.white),
          ),
          if (_isTerminal)
            IconButton(
              onPressed: _close,
              icon: const Icon(Icons.close, size: 20),
              tooltip: l10n.actionClose,
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
            if (_state == _DialogState.waitingForBlock) _buildWaitingForBlockSection(l10n),
            if (_state == _DialogState.checkingStatus) _buildCheckingSection(),
            if (_state == _DialogState.watched) _buildWatchedSection(l10n),
            if (_state == _DialogState.processing) _buildProcessingSection(l10n),
            if (_state == _DialogState.verifying) _buildVerifyingSection(l10n),
            if (_state == _DialogState.success) _buildSuccessSection(l10n),
            if (_state == _DialogState.failure) _buildFailureSection(l10n),
          ],
        ),
      ),
    );
  }

  bool get _isTerminal =>
      _state == _DialogState.success ||
      _state == _DialogState.failure ||
      // Nothing is asked of the requester while the chain pays it.
      _state == _DialogState.watched;

  String _titleForState(AppLocalizations l10n) {
    switch (_state) {
      case _DialogState.waitingForBlock:
        return l10n.bw2WaitingForConfirmation;
      case _DialogState.checkingStatus:
        return l10n.bw2CheckingWithdrawalStatus;
      case _DialogState.watched:
        return _watched?.paid == true ? l10n.bw2WithdrawalComplete : l10n.bw2WatchedWithdrawalTitle;
      case _DialogState.processing:
        return l10n.bw2ProcessingWithdrawal;
      case _DialogState.verifying:
        return l10n.bw2CheckingWithdrawalStatus;
      case _DialogState.success:
        return l10n.bw2WithdrawalComplete;
      case _DialogState.failure:
        return l10n.bw2WithdrawalFailed;
    }
  }

  Widget _buildWaitingForBlockSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.bw2WaitingForBlockBody,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bw2RequestConfirmHint,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCheckingSection() {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  Widget _buildWatchedSection(AppLocalizations l10n) {
    final watched = _watched!;
    final btcTxHash = watched.bitcoinTxHash;
    final awaitingChange = _sentAgainst != null;
    final canAct = (watched.canRaiseFee || watched.canRelease) && !awaitingChange;
    final actionsEnabled = !_busy && !awaitingChange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              watched.paid ? Icons.check_circle : Icons.schedule,
              color: watched.paid ? _successColor : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _watchedHeadline(watched, l10n),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (watched.summary != null || watched.message != null) ...[
          const SizedBox(height: 12),
          // The node's own account of the withdrawal (English, as the node gives it).
          Text(watched.summary ?? watched.message!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
        if (btcTxHash != null) ...[
          const SizedBox(height: 16),
          _buildHashRow(
            l10n.bw2BtcTransactionLabel,
            btcTxHash,
            explorerUrl: Env.btcExplorerTxUrl(btcTxHash),
          ),
        ],
        if (watched.isPinned && watched.feeRate != null) ...[
          const SizedBox(height: 12),
          Text(l10n.bw2WatchedCurrentFeeRate(watched.feeRate!), style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
        if (awaitingChange || _sentNotSeen) ...[
          const SizedBox(height: 16),
          Text(
            awaitingChange ? l10n.bw2WatchedChangeSent : l10n.bw2WatchedChangeNotSeen,
            style: const TextStyle(color: Color(0xFFE0A32E), fontSize: 12),
          ),
        ],
        if (canAct) ...[
          const SizedBox(height: 16),
          Text(l10n.bw2WatchedNotConfirmingHint, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            key: const Key('withdrawal:watched-fee-rate'),
            controller: _feeRateController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.bw2WatchedNewFeeRateLabel,
              hintText: l10n.bw2WatchedFeeRateTooLow(watched.minimumNextFeeRate),
              errorText: _feeRateError,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (watched.canCancel)
                AppButton(
                  label: l10n.bw2WatchedCancel,
                  variant: AppColorVariant.Danger,
                  onPressed: actionsEnabled ? _cancelWatched : null,
                ),
              if (watched.canRelease)
                AppButton(
                  label: l10n.bw2WatchedRelease,
                  variant: AppColorVariant.Warning,
                  onPressed: actionsEnabled ? () => _sendWatchedChange(release: true) : null,
                ),
              if (watched.canRaiseFee)
                AppButton(
                  label: l10n.bw2WatchedRaiseFee,
                  variant: AppColorVariant.Primary,
                  onPressed: actionsEnabled ? () => _sendWatchedChange(release: false) : null,
                ),
              AppButton(
                label: l10n.actionDone,
                variant: watched.paid ? AppColorVariant.Success : AppColorVariant.Light,
                onPressed: _close,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _watchedHeadline(WatchedWithdrawal watched, AppLocalizations l10n) {
    if (watched.paid) return l10n.bw2WithdrawalCompletedSuccess;
    if (watched.notMinedYet) return l10n.bw2WatchedNotMinedYet;
    if (watched.releasing) return l10n.bw2WatchedReleasing;
    if (watched.isPinned) return l10n.bw2WatchedPinned;
    if (watched.isWaiting) return l10n.bw2WatchedWaiting;
    return l10n.bw2WatchedClosed;
  }

  Widget _buildProcessingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.bw2ValidatorsSigningBtc,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bw2DoNotCloseApp,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildVerifyingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.bw2VerifyingWithdrawalBody,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bw2VerifyingWithdrawalHint,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSuccessSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: _successColor, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.bw2WithdrawalCompletedSuccess,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (_result?.vfxTransactionHash != null) ...[
          const SizedBox(height: 16),
          _buildHashRow(
            l10n.bw2VfxTransactionLabel,
            _result!.vfxTransactionHash!,
            explorerUrl: Env.explorerTransactionUrl(_result!.vfxTransactionHash!),
          ),
        ],
        if (_result?.btcTransactionHash != null) ...[
          const SizedBox(height: 12),
          _buildHashRow(
            l10n.bw2BtcTransactionLabel,
            _result!.btcTransactionHash!,
            explorerUrl: Env.btcExplorerTxUrl(_result!.btcTransactionHash!),
          ),
        ],
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: l10n.actionDone,
            variant: AppColorVariant.Success,
            onPressed: _close,
          ),
        ),
      ],
    );
  }

  Widget _buildFailureSection(AppLocalizations l10n) {
    final canCancel = widget.ownerAddress != null && _result?.btcTransactionHash != null;
    final unpayable = _result?.unpayable ?? false;

    // Why there is no Cancel (QA MTI#10.1). Cancelling a request that sent no
    // Bitcoin transaction needs the contract's validators to vote, which the
    // wallet cannot start yet, so no button is offered that could not finish.
    final String? noCancelNote = canCancel
        ? null
        : unpayable
            ? l10n.bw2NoCancelUnpayable
            : (_result?.btcTransactionHash == null ? l10n.bw2NoCancelNoBtcTx : null);

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
                _result?.message ?? l10n.bw2WithdrawalError,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        if (noCancelNote != null) ...[
          const SizedBox(height: 12),
          Text(
            noCancelNote,
            key: const Key('withdrawal:no-cancel-note'),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
        const SizedBox(height: 20),
        // Wrap, not Row: three buttons can exceed the dialog's 450 px.
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton(
                label: l10n.tkbDismiss,
                variant: AppColorVariant.Light,
                onPressed: _close,
              ),
              if (canCancel)
                AppButton(
                  label: l10n.bw2CancelWithdrawal,
                  variant: AppColorVariant.Danger,
                  onPressed: _cancelWithdrawal,
                ),
              // Retrying an unpayable request fails every time.
              if (!unpayable)
                AppButton(
                  label: l10n.btcRetry,
                  variant: AppColorVariant.Warning,
                  onPressed: _busy ? null : _runCompleteWithdrawal,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHashRow(String label, String hash, {String? explorerUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                hash,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: AppLocalizations.of(context).actionCopyTransactionHash,
              button: true,
              child: InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: hash));
                  Toast.message(AppLocalizations.of(context).messageCopiedToClipboard);
                },
                child: const Icon(Icons.copy, size: 16, color: Colors.white54),
              ),
            ),
            if (explorerUrl != null) ...[
              const SizedBox(width: 8),
              Semantics(
                label: AppLocalizations.of(context).btcOpenInExplorer,
                button: true,
                child: InkWell(
                  onTap: () => launchUrlString(explorerUrl),
                  child: const Icon(Icons.open_in_new, size: 16, color: Colors.white54),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _cancelWithdrawal() async {
    if (widget.ownerAddress == null || _result?.btcTransactionHash == null) return;

    debugPrint('$_tag Cancelling withdrawal — scUid: ${widget.scUid}, requestHash: ${widget.requestHash}, btcTx: ${_result!.btcTransactionHash}');
    setState(() => _state = _DialogState.processing);

    final success = await VbtcV2Service().cancelWithdrawal(
      scUid: widget.scUid,
      ownerAddress: widget.ownerAddress!,
      withdrawalRequestHash: widget.requestHash,
      btcTxHash: _result!.btcTransactionHash!,
      failureProof: "Withdrawal failed — cancelled by user via GUI.",
    );

    if (!mounted) return;

    debugPrint('$_tag Cancel result — success: $success');
    if (success) {
      Toast.message(AppLocalizations.of(context).bw2CancellationSubmitted);
      Navigator.of(context).pop(null);
    } else {
      setState(() => _state = _DialogState.failure);
    }
  }
}

const _successColor = Color(0xFF43ae52);
const _dangerColor = Color(0xFFBA2121);
