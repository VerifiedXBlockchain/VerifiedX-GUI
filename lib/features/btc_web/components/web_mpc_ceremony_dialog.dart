import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';
import '../../../core/app_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../transactions/models/web_transaction.dart';
import '../../transactions/providers/web_transaction_list_provider.dart';
import '../../web/utils/raw_transaction.dart';
import '../providers/btc_web_vbtc_token_list_provider.dart';

enum _CeremonyStep { initiating, polling, creatingContract, success, failure }

class WebMpcCeremonyDialog extends ConsumerStatefulWidget {
  final String ownerAddress;
  final String name;
  final String description;
  final String ticker;

  const WebMpcCeremonyDialog({
    super.key,
    required this.ownerAddress,
    required this.name,
    required this.description,
    required this.ticker,
  });

  static Future<bool?> show({
    required String ownerAddress,
    required String name,
    required String description,
    required String ticker,
  }) {
    return showDialog<bool>(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => WebMpcCeremonyDialog(
        ownerAddress: ownerAddress,
        name: name,
        description: description,
        ticker: ticker,
      ),
    );
  }

  @override
  ConsumerState<WebMpcCeremonyDialog> createState() => _WebMpcCeremonyDialogState();
}

class _WebMpcCeremonyDialogState extends ConsumerState<WebMpcCeremonyDialog> {
  _CeremonyStep _step = _CeremonyStep.initiating;
  String? _ceremonyId;
  int _progress = 0;
  String _statusMessage = "";
  String? _errorMessage;
  String? _transactionHash;
  String? _scIdentifier;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _initiateCeremony();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initiateCeremony() async {
    setState(() => _step = _CeremonyStep.initiating);

    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      setState(() {
        _step = _CeremonyStep.failure;
        _errorMessage = AppLocalizations.of(context).bw2NoKeypairFoundPeriod;
      });
      return;
    }

    try {
      // Step 1: Prepare — get ceremony ID and messages to sign
      final prepared = await ExplorerService().prepareV2Ceremony(widget.ownerAddress);

      if (!mounted) return;

      if (prepared['success'] != true || prepared['ceremony_id'] == null) {
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = prepared['message'] ?? AppLocalizations.of(context).bw2FailedPrepareMpc;
        });
        return;
      }

      _ceremonyId = prepared['ceremony_id'] as String;
      final sessionId = prepared['session_id'] as String;
      final messages = prepared['messages_to_sign'] as Map<String, dynamic>;
      final startMessage = messages['start_message'] as String;
      final startTimestamp = messages['start_timestamp'] as int;
      final shareMessage = messages['share_distribution_message'] as String;
      final shareTimestamp = messages['share_distribution_timestamp'] as int;

      // Step 2: Sign both messages
      final startSig = await RawTransaction.getSignature(
        message: startMessage,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      final shareSig = await RawTransaction.getSignature(
        message: shareMessage,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      if (startSig == null || shareSig == null) {
        if (!mounted) return;
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = AppLocalizations.of(context).bw2FailedSignCeremony;
        });
        return;
      }

      // Step 3: Execute — send signatures to start the ceremony
      final executeResult = await ExplorerService().executeV2Ceremony(
        ceremonyId: _ceremonyId!,
        sessionId: sessionId,
        ownerAddress: widget.ownerAddress,
        startSignature: startSig,
        startTimestamp: startTimestamp,
        shareDistributionSignature: shareSig,
        shareDistributionTimestamp: shareTimestamp,
      );

      if (!mounted) return;

      if (executeResult['success'] == true) {
        _startPolling();
      } else {
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = executeResult['message'] ?? AppLocalizations.of(context).bw2FailedExecuteMpc;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _CeremonyStep.failure;
        _errorMessage = AppLocalizations.of(context).bw2FailedInitiateMpc;
      });
    }
  }

  void _startPolling() {
    setState(() => _step = _CeremonyStep.polling);

    _pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        final result = await ExplorerService().getV2CeremonyStatus(_ceremonyId!);

        if (!mounted) return;

        final status = result['status'] as String? ?? '';
        final progress = result['progress'] as int? ?? 0;
        final message = result['message'] as String? ?? '';

        setState(() {
          _progress = progress;
          _statusMessage = message;
        });

        if (status == 'Completed' || status == 'completed') {
          timer.cancel();
          _createContract();
        } else if (status == 'Failed' || status == 'failed' || status == 'TimedOut') {
          timer.cancel();
          setState(() {
            _step = _CeremonyStep.failure;
            _errorMessage = message.isNotEmpty ? message : AppLocalizations.of(context).bw2MpcCeremonyFailedToast;
          });
        }
      } catch (e) {
        // Keep polling on transient errors
      }
    });
  }

  Future<void> _createContract() async {
    final name = widget.name.isNotEmpty ? widget.name : 'vBTC Token';
    final description = widget.description.isNotEmpty ? widget.description : name;
    final ticker = widget.ticker.isNotEmpty ? widget.ticker : 'vBTC';

    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      setState(() {
        _step = _CeremonyStep.failure;
        _errorMessage = AppLocalizations.of(context).bw2NoKeypairFoundPeriod;
      });
      return;
    }

    setState(() => _step = _CeremonyStep.creatingContract);

    try {
      // Step 1: Sign ownership proof
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final uniqueId = generateRandomString(16, 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz');
      final signatureData = '${widget.ownerAddress}$name$description$ticker${_ceremonyId}$timestamp$uniqueId';

      final ownerSignature = await RawTransaction.getSignature(
        message: signatureData,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      if (ownerSignature == null) {
        if (!mounted) return;
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = AppLocalizations.of(context).bw2FailedSignOwnershipProof;
        });
        return;
      }

      // Step 2: Prepare — get hash to sign
      final prepared = await ExplorerService().prepareV2Create(
        ownerAddress: widget.ownerAddress,
        name: name,
        description: description,
        ticker: ticker,
        ceremonyId: _ceremonyId!,
        timestamp: timestamp,
        uniqueId: uniqueId,
        ownerSignature: ownerSignature,
      );

      if (!mounted) return;

      if (prepared['success'] != true || prepared['Hash'] == null) {
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = prepared['message'] ?? AppLocalizations.of(context).bw2FailedPrepareContractCreation;
        });
        return;
      }

      // Step 3: Sign the TX hash
      final signature = await RawTransaction.getSignature(
        message: prepared['Hash'] as String,
        privateKey: keypair.private,
        publicKey: keypair.public,
      );

      if (signature == null) {
        if (!mounted) return;
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = AppLocalizations.of(context).bw2FailedSignContractTx;
        });
        return;
      }

      // Step 4: Send — broadcast the signed TX
      final result = await ExplorerService().sendV2Create(
        hash: prepared['Hash'] as String,
        signature: signature,
        publicKey: keypair.public,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final txHash = result['TransactionHash'] as String? ?? result['Hash'] as String? ?? '';
        ref.read(webTransactionListProvider(widget.ownerAddress).notifier).insertPendingTx(
          WebTransaction(
            hash: txHash,
            toAddress: widget.ownerAddress,
            fromAddress: widget.ownerAddress,
            type: TxType.vbtcV2ContractCreate,
            amount: 0,
            fee: 0,
            date: DateTime.now(),
            height: 0,
          ),
        );
        setState(() {
          _step = _CeremonyStep.success;
          _transactionHash = txHash;
          _scIdentifier = result['SmartContractUID'] as String?;
        });
      } else {
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = result['message'] ?? AppLocalizations.of(context).bw2FailedCreateContractShort;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _CeremonyStep.failure;
        _errorMessage = AppLocalizations.of(context).bw2FailedCreateContractShort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForStep(l10n),
            style: const TextStyle(color: Colors.white),
          ),
          if (_step == _CeremonyStep.success || _step == _CeremonyStep.failure)
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
            if (_step == _CeremonyStep.initiating) _buildInitiatingSection(l10n),
            if (_step == _CeremonyStep.polling) _buildPollingSection(l10n),
            if (_step == _CeremonyStep.creatingContract) _buildCreatingSection(l10n),
            if (_step == _CeremonyStep.success) _buildSuccessSection(l10n),
            if (_step == _CeremonyStep.failure) _buildFailureSection(l10n),
          ],
        ),
      ),
    );
  }

  String _titleForStep(AppLocalizations l10n) {
    switch (_step) {
      case _CeremonyStep.initiating:
        return l10n.bw2StartingMpcCeremony;
      case _CeremonyStep.polling:
        return l10n.bw2MpcCeremonyInProgress;
      case _CeremonyStep.creatingContract:
        return l10n.bw2CreatingContract;
      case _CeremonyStep.success:
        return l10n.bw2TokenCreated;
      case _CeremonyStep.failure:
        return l10n.tkbError;
    }
  }

  Widget _buildInitiatingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(l10n.bw2InitiatingMpc, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(l10n.bw2DkgStartHint, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildPollingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _progress / 100.0,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF73c4fa)),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.bw2PercentComplete(_progress.toString()),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        if (_statusMessage.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _statusMessage,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.bw2ValidatorsGeneratingKeys,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCreatingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 16),
        Text(l10n.bw2CreatingVbtcContract, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(l10n.bw2ConfirmedWhenIndexed, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildSuccessSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF43ae52), size: 20),
            const SizedBox(width: 8),
            Text(l10n.bw2VbtcTokenCreatedSuccess, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        if (_transactionHash != null) ...[
          const SizedBox(height: 16),
          Text(l10n.bw2TransactionHashColon, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: SelectableText(_transactionHash!, style: const TextStyle(color: Colors.white, fontSize: 13))),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: _transactionHash!));
                  Toast.message(l10n.messageCopiedToClipboard);
                },
                child: const Icon(Icons.copy, size: 16, color: Colors.white54),
              ),
            ],
          ),
        ],
        if (_scIdentifier != null) ...[
          const SizedBox(height: 12),
          Text(l10n.bw2SmartContractIdColon, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          SelectableText(_scIdentifier!, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Text(l10n.bw2TokenAppearWhenIndexed, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: l10n.actionDone,
            variant: AppColorVariant.Success,
            onPressed: () {
              ref.read(btcWebVbtcTokenListProvider.notifier).reload(
                widget.ownerAddress,
              );
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFailureSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFBA2121), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage ?? l10n.bw2AnErrorOccurred,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              label: l10n.tkbDismiss,
              variant: AppColorVariant.Light,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: l10n.btcRetry,
              variant: AppColorVariant.Warning,
              onPressed: _initiateCeremony,
            ),
          ],
        ),
      ],
    );
  }
}
