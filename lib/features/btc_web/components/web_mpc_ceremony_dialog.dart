import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/toast.dart';
import '../providers/btc_web_vbtc_token_list_provider.dart';

enum _CeremonyStep { initiating, polling, promptingDetails, creatingContract, success, failure }

class WebMpcCeremonyDialog extends ConsumerStatefulWidget {
  final String ownerAddress;

  const WebMpcCeremonyDialog({
    super.key,
    required this.ownerAddress,
  });

  static Future<void> show({required String ownerAddress}) {
    return showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => WebMpcCeremonyDialog(ownerAddress: ownerAddress),
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

  final _nameController = TextEditingController(text: "vBTC Token");
  final _descriptionController = TextEditingController(text: "vBTC Token");
  final _tickerController = TextEditingController(text: "vBTC");

  @override
  void initState() {
    super.initState();
    _initiateCeremony();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    _tickerController.dispose();
    super.dispose();
  }

  Future<void> _initiateCeremony() async {
    setState(() => _step = _CeremonyStep.initiating);

    try {
      final result = await ExplorerService().initiateV2Ceremony(widget.ownerAddress);

      if (!mounted) return;

      if (result['success'] == true && result['ceremony_id'] != null) {
        _ceremonyId = result['ceremony_id'];
        _startPolling();
      } else {
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = result['message'] ?? "Failed to initiate MPC ceremony.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _CeremonyStep.failure;
        _errorMessage = "Failed to initiate MPC ceremony.";
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
          setState(() => _step = _CeremonyStep.promptingDetails);
        } else if (status == 'Failed' || status == 'failed' || status == 'TimedOut') {
          timer.cancel();
          setState(() {
            _step = _CeremonyStep.failure;
            _errorMessage = message.isNotEmpty ? message : "MPC ceremony failed.";
          });
        }
      } catch (e) {
        // Keep polling on transient errors
      }
    });
  }

  Future<void> _createContract() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final ticker = _tickerController.text.trim();

    if (name.isEmpty) {
      Toast.error("Token name is required");
      return;
    }

    setState(() => _step = _CeremonyStep.creatingContract);

    try {
      final result = await ExplorerService().createV2Contract(
        ownerAddress: widget.ownerAddress,
        name: name,
        description: description.isNotEmpty ? description : name,
        ticker: ticker.isNotEmpty ? ticker : "vBTC",
        ceremonyId: _ceremonyId!,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _step = _CeremonyStep.success;
          _transactionHash = result['transaction_hash'];
          _scIdentifier = result['sc_identifier'];
        });
      } else {
        setState(() {
          _step = _CeremonyStep.failure;
          _errorMessage = result['message'] ?? "Failed to create contract.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _CeremonyStep.failure;
        _errorMessage = "Failed to create contract.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titleForStep(),
            style: const TextStyle(color: Colors.white),
          ),
          if (_step == _CeremonyStep.success || _step == _CeremonyStep.failure || _step == _CeremonyStep.promptingDetails)
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
            if (_step == _CeremonyStep.initiating) _buildInitiatingSection(),
            if (_step == _CeremonyStep.polling) _buildPollingSection(),
            if (_step == _CeremonyStep.promptingDetails) _buildDetailsSection(),
            if (_step == _CeremonyStep.creatingContract) _buildCreatingSection(),
            if (_step == _CeremonyStep.success) _buildSuccessSection(),
            if (_step == _CeremonyStep.failure) _buildFailureSection(),
          ],
        ),
      ),
    );
  }

  String _titleForStep() {
    switch (_step) {
      case _CeremonyStep.initiating:
        return "Starting MPC Ceremony";
      case _CeremonyStep.polling:
        return "MPC Ceremony in Progress";
      case _CeremonyStep.promptingDetails:
        return "Ceremony Complete";
      case _CeremonyStep.creatingContract:
        return "Creating Contract";
      case _CeremonyStep.success:
        return "Token Created";
      case _CeremonyStep.failure:
        return "Error";
    }
  }

  Widget _buildInitiatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        SizedBox(height: 16),
        Text("Initiating MPC ceremony...", style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        Text("This starts the distributed key generation process.", style: TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildPollingSection() {
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
          "$_progress% complete",
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
        const Text(
          "Validators are generating threshold signing keys. This typically takes 30-90 seconds.",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF43ae52), size: 20),
            SizedBox(width: 8),
            Text("MPC ceremony completed!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Enter token details to create the contract:", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Token Name"),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: "Description"),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tickerController,
          decoration: const InputDecoration(labelText: "Ticker"),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: "Create Token",
            variant: AppColorVariant.Success,
            onPressed: _createContract,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3))),
        SizedBox(height: 16),
        Text("Creating vBTC contract on-chain...", style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        Text("This will be confirmed once indexed by the explorer.", style: TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF43ae52), size: 20),
            SizedBox(width: 8),
            Text("vBTC token created successfully!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        if (_transactionHash != null) ...[
          const SizedBox(height: 16),
          const Text("Transaction Hash:", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: SelectableText(_transactionHash!, style: const TextStyle(color: Colors.white, fontSize: 13))),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: _transactionHash!));
                  Toast.message("Copied to clipboard");
                },
                child: const Icon(Icons.copy, size: 16, color: Colors.white54),
              ),
            ],
          ),
        ],
        if (_scIdentifier != null) ...[
          const SizedBox(height: 12),
          const Text("Smart Contract ID:", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          SelectableText(_scIdentifier!, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        const Text("The token will appear in your list once indexed (typically a few seconds).", style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: "Done",
            variant: AppColorVariant.Success,
            onPressed: () {
              // Refresh the token list
              ref.read(btcWebVbtcTokenListProvider.notifier).reload(
                widget.ownerAddress,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFailureSection() {
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
                _errorMessage ?? "An error occurred.",
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
              label: "Dismiss",
              variant: AppColorVariant.Light,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: "Retry",
              variant: AppColorVariant.Warning,
              onPressed: _initiateCeremony,
            ),
          ],
        ),
      ],
    );
  }
}
