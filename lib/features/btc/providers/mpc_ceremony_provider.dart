import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/toast.dart';
import '../../../core/utils/tx_refresh.dart';
import '../models/mpc_ceremony.dart';
import '../services/vbtc_v2_service.dart';

const _tag = '[vBTC-V2] MpcCeremony';

enum MpcCeremonyPhase {
  idle,
  ceremonyInProgress,
  ceremonyCompleted,
  creatingContract,
  contractCreated,
  failed,
}

class MpcCeremonyState {
  final MpcCeremonyPhase phase;
  final MpcCeremony? ceremony;
  final String? errorMessage;
  final String? contractHash;

  const MpcCeremonyState({
    this.phase = MpcCeremonyPhase.idle,
    this.ceremony,
    this.errorMessage,
    this.contractHash,
  });

  MpcCeremonyState copyWith({
    MpcCeremonyPhase? phase,
    MpcCeremony? ceremony,
    String? errorMessage,
    String? contractHash,
  }) {
    return MpcCeremonyState(
      phase: phase ?? this.phase,
      ceremony: ceremony ?? this.ceremony,
      errorMessage: errorMessage ?? this.errorMessage,
      contractHash: contractHash ?? this.contractHash,
    );
  }

  bool get isIdle => phase == MpcCeremonyPhase.idle;
  bool get isInProgress => phase == MpcCeremonyPhase.ceremonyInProgress;
  bool get isFailed => phase == MpcCeremonyPhase.failed;
  bool get isContractCreated => phase == MpcCeremonyPhase.contractCreated;
}

/// Client-side timeout for ceremony polling. Extract as constant for easy
/// adjustment after testnet validation.
const _kCeremonyTimeoutDuration = Duration(minutes: 5);

const _kPollingInterval = Duration(seconds: 2);

const _kMaxConsecutivePollFailures = 3;

class MpcCeremonyNotifier extends StateNotifier<MpcCeremonyState> {
  final Ref ref;
  Timer? _pollingTimer;
  DateTime? _ceremonyStartTime;
  int _consecutivePollFailures = 0;
  String? _ownerAddress;

  MpcCeremonyNotifier(this.ref) : super(const MpcCeremonyState());

  Future<void> startCeremony(String ownerAddress) async {
    _ownerAddress = ownerAddress;
    debugPrint('$_tag startCeremony for owner: $ownerAddress');

    final ceremonyId = await VbtcV2Service().initiateCeremony(ownerAddress);

    if (ceremonyId == null) {
      debugPrint('$_tag startCeremony FAILED — no ceremonyId returned');
      state = const MpcCeremonyState(
        phase: MpcCeremonyPhase.failed,
        errorMessage: "Failed to initiate MPC ceremony.",
      );
      return;
    }

    debugPrint('$_tag Ceremony initiated — ceremonyId: $ceremonyId, starting polling');
    state = MpcCeremonyState(
      phase: MpcCeremonyPhase.ceremonyInProgress,
      ceremony: MpcCeremony(
        ceremonyId: ceremonyId,
        status: MpcCeremonyStatus.initiated,
      ),
    );

    _ceremonyStartTime = DateTime.now();
    _consecutivePollFailures = 0;
    _startPolling(ceremonyId);
  }

  void _startPolling(String ceremonyId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_kPollingInterval, (_) {
      _poll(ceremonyId);
    });
  }

  Future<void> _poll(String ceremonyId) async {
    if (!mounted) return;

    // Client-side timeout check
    if (_ceremonyStartTime != null &&
        DateTime.now().difference(_ceremonyStartTime!) > _kCeremonyTimeoutDuration) {
      _pollingTimer?.cancel();
      final elapsed = DateTime.now().difference(_ceremonyStartTime!);
      debugPrint('$_tag Poll TIMEOUT after ${elapsed.inSeconds}s — aborting');
      state = const MpcCeremonyState(
        phase: MpcCeremonyPhase.failed,
        errorMessage: "Ceremony timed out. Please try again.",
      );
      Toast.error("MPC ceremony timed out.");
      return;
    }

    final result = await VbtcV2Service().getCeremonyStatus(ceremonyId);

    if (!mounted) return;

    if (result == null) {
      _consecutivePollFailures++;
      debugPrint('$_tag Poll returned null — consecutive failures: $_consecutivePollFailures/$_kMaxConsecutivePollFailures');
      if (_consecutivePollFailures >= _kMaxConsecutivePollFailures) {
        _pollingTimer?.cancel();
        debugPrint('$_tag Max poll failures reached — aborting');
        state = const MpcCeremonyState(
          phase: MpcCeremonyPhase.failed,
          errorMessage: "Lost connection while monitoring ceremony. Please try again.",
        );
        Toast.error("Lost connection to ceremony.");
      }
      return;
    }

    _consecutivePollFailures = 0;

    final ceremony = MpcCeremony.fromJson(result);
    debugPrint('$_tag Poll → status: ${ceremony.status.name} | progress: ${ceremony.progressPercentage}%');

    if (ceremony.status == MpcCeremonyStatus.completed) {
      _pollingTimer?.cancel();
      debugPrint('$_tag Ceremony COMPLETED — depositAddress: ${ceremony.depositAddress} | frostKey: ${ceremony.frostGroupPublicKey}');
      debugPrint('$_tag Full ceremony result:\n${const JsonEncoder.withIndent('  ').convert(result)}');
      state = MpcCeremonyState(
        phase: MpcCeremonyPhase.ceremonyCompleted,
        ceremony: ceremony,
      );
      Toast.message("MPC ceremony completed successfully.");
      return;
    }

    if (ceremony.status == MpcCeremonyStatus.failed ||
        ceremony.status == MpcCeremonyStatus.timedOut) {
      _pollingTimer?.cancel();
      debugPrint('$_tag Ceremony ${ceremony.status.name.toUpperCase()} — full result:\n${const JsonEncoder.withIndent('  ').convert(result)}');
      state = MpcCeremonyState(
        phase: MpcCeremonyPhase.failed,
        ceremony: ceremony,
        errorMessage: ceremony.status == MpcCeremonyStatus.timedOut
            ? "Ceremony timed out on the network. Please try again."
            : "Ceremony failed. Please try again.",
      );
      Toast.error("MPC ceremony failed.");
      return;
    }

    // Still in progress — update state with latest data
    state = MpcCeremonyState(
      phase: MpcCeremonyPhase.ceremonyInProgress,
      ceremony: ceremony,
    );
  }

  Future<void> createContract({
    required String name,
    required String description,
    required String ticker,
  }) async {
    if (state.phase != MpcCeremonyPhase.ceremonyCompleted) return;
    if (state.ceremony == null || _ownerAddress == null) return;

    debugPrint('$_tag createContract — owner: $_ownerAddress, name: $name, ticker: $ticker, ceremonyId: ${state.ceremony!.ceremonyId}');
    state = state.copyWith(phase: MpcCeremonyPhase.creatingContract);

    final hash = await VbtcV2Service().createContract(
      ownerAddress: _ownerAddress!,
      name: name,
      description: description,
      ticker: ticker,
      ceremonyId: state.ceremony!.ceremonyId,
    );

    if (!mounted) return;

    if (hash != null) {
      debugPrint('$_tag Contract created — hash: $hash');
      state = MpcCeremonyState(
        phase: MpcCeremonyPhase.contractCreated,
        ceremony: state.ceremony,
        contractHash: hash,
      );
      Toast.message("vBTC contract created. Hash: $hash");
      notifyTransactionSubmitted();
    } else {
      debugPrint('$_tag Contract creation FAILED');
      state = MpcCeremonyState(
        phase: MpcCeremonyPhase.failed,
        ceremony: state.ceremony,
        errorMessage: "Failed to create contract. Please try again.",
      );
    }
  }

  void reset() {
    _pollingTimer?.cancel();
    _ceremonyStartTime = null;
    _consecutivePollFailures = 0;
    _ownerAddress = null;
    state = const MpcCeremonyState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final mpcCeremonyProvider = StateNotifierProvider<MpcCeremonyNotifier, MpcCeremonyState>((ref) {
  return MpcCeremonyNotifier(ref);
});
