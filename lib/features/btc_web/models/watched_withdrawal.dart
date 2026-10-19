/// A withdrawal from a vBTC V2 vault the chain watches (Bitcoin attestation).
///
/// On such a vault the requester sends the request and nothing else: the chain
/// fixes ("pins") the Bitcoin transaction that pays it, the vault's signers
/// sign and broadcast it on their own, and the withdrawal completes when
/// Bitcoin confirms it. There is no FROST ceremony for the wallet to lead and
/// the node refuses a Type 28 completion. The requester can only raise the fee
/// of a pinned transaction that is not confirming, or give the withdrawal up
/// (a release), both with one Type 44 transaction.
///
/// Read from the node's answer to `PrepareCompleteWithdrawalRaw`, which for a
/// watched vault signs nothing and says where the withdrawal stands
/// (`BtcVaultView.CompletionAnswer` in Core). Spyglass proxies that route as
/// `/btc/vbtc-v2/withdraw/complete/prepare/`.
class WatchedWithdrawal {
  /// `Completed`, `Awaiting_BTC_Confirmation`, `Awaiting_BTC_Transaction`,
  /// `Closed` or `Unknown`.
  final String status;
  final bool paid;

  /// The node has not mined the request yet; ask again shortly.
  final bool notMinedYet;
  final String? message;

  /// The chain's own state: `Waiting`, `Pinned`, `Settled`, `Released`, or a
  /// closed state. Null when the request is not mined yet.
  final String? state;
  final String? summary;

  /// The fee rate (sat/vB) the newest live Bitcoin transaction pays.
  final int? feeRate;
  final bool canRaiseFee;
  final bool canRelease;
  final bool releasing;
  final bool canCancel;
  final String? pinnedBtcTxHash;
  final String? paidBtcTxHash;
  final List<WatchedWithdrawalTransaction> transactions;

  const WatchedWithdrawal({
    required this.status,
    required this.paid,
    required this.notMinedYet,
    this.message,
    this.state,
    this.summary,
    this.feeRate,
    this.canRaiseFee = false,
    this.canRelease = false,
    this.releasing = false,
    this.canCancel = false,
    this.pinnedBtcTxHash,
    this.paidBtcTxHash,
    this.transactions = const [],
  });

  /// Parses the completion answer as Spyglass returns it, or null when the
  /// vault is not one the chain watches (the answer is then a FROST
  /// preparation, and the withdrawal is completed as before).
  ///
  /// Spyglass spreads a successful node answer into its own body and nests a
  /// failed one under `raw`, so both shapes are read.
  static WatchedWithdrawal? fromCompletionAnswer(Map<String, dynamic>? response) {
    if (response == null) return null;
    final raw = response['raw'];
    final answer = response['Attested'] == true
        ? response
        : raw is Map && raw['Attested'] == true
            ? Map<String, dynamic>.from(raw)
            : null;
    if (answer == null) return null;

    final withdrawal = answer['Withdrawal'] is Map ? Map<String, dynamic>.from(answer['Withdrawal']) : null;
    final transactions = withdrawal?['Transactions'] is List
        ? (withdrawal!['Transactions'] as List)
            .whereType<Map>()
            .map((t) => WatchedWithdrawalTransaction.fromJson(Map<String, dynamic>.from(t)))
            .toList()
        : <WatchedWithdrawalTransaction>[];

    return WatchedWithdrawal(
      status: answer['Status'] as String? ?? 'Unknown',
      paid: answer['Paid'] == true,
      notMinedYet: answer['NotMinedYet'] == true,
      message: _withoutMarker(answer['Message'] as String?),
      state: withdrawal?['State'] as String?,
      summary: withdrawal?['Summary'] as String?,
      feeRate: (withdrawal?['FeeRate'] as num?)?.toInt(),
      canRaiseFee: withdrawal?['CanRaiseFee'] == true,
      canRelease: withdrawal?['CanRelease'] == true,
      releasing: withdrawal?['Releasing'] == true,
      canCancel: withdrawal?['CanCancel'] == true,
      pinnedBtcTxHash: answer['PinnedBTCTransactionHash'] as String?,
      paidBtcTxHash: answer['BTCTransactionHash'] as String?,
      transactions: transactions,
    );
  }

  bool get isPinned => state == 'Pinned';
  bool get isWaiting => state == 'Waiting';

  /// Nothing more will happen to it: paid, released or closed.
  bool get isClosed => paid || (state != null && !isPinned && !isWaiting);

  /// The lowest rate a fee raise or a release may name: Core refuses any rate
  /// not above what the newest transaction pays (`FeeBumpRefusal`).
  int get minimumNextFeeRate => (feeRate ?? 0) + 1;

  /// The newest Bitcoin transaction the chain has fixed for it, paid or not.
  String? get bitcoinTxHash => paidBtcTxHash ?? pinnedBtcTxHash;

  /// Why [feeRate] cannot be sent as a raise or release, or null when it can.
  /// Core also refuses a release whose total fee does not beat the newest
  /// transaction by its relay cost; that is left to the node's answer.
  WatchedFeeRateProblem? feeRateProblem(int? requested) {
    if (requested == null || requested <= 0) return WatchedFeeRateProblem.invalid;
    if (requested < minimumNextFeeRate) return WatchedFeeRateProblem.notAboveCurrent;
    if (requested > kWatchedWithdrawalMaxFeeRate) return WatchedFeeRateProblem.aboveMaximum;
    return null;
  }

  static String? _withoutMarker(String? message) {
    if (message == null) return null;
    return message.replaceFirst(RegExp(r'^\[[A-Z-]+\]\s*'), '');
  }
}

/// Core's `BtcCanonicalWithdrawal.MaxFeeRate`: a request or raise naming more is refused.
const kWatchedWithdrawalMaxFeeRate = 5000;

enum WatchedFeeRateProblem { invalid, notAboveCurrent, aboveMaximum }

/// One Bitcoin transaction the chain has fixed for a watched withdrawal.
class WatchedWithdrawalTransaction {
  final String txid;

  /// `Payment` or `Release`.
  final String kind;
  final int? feeRate;
  final int? feeSats;
  final bool superseded;
  final bool dead;
  final bool confirmed;

  const WatchedWithdrawalTransaction({
    required this.txid,
    required this.kind,
    this.feeRate,
    this.feeSats,
    this.superseded = false,
    this.dead = false,
    this.confirmed = false,
  });

  factory WatchedWithdrawalTransaction.fromJson(Map<String, dynamic> json) {
    return WatchedWithdrawalTransaction(
      txid: json['Txid'] as String? ?? '',
      kind: json['Kind'] as String? ?? 'Payment',
      feeRate: (json['FeeRate'] as num?)?.toInt(),
      feeSats: (json['FeeSats'] as num?)?.toInt(),
      superseded: json['Superseded'] == true,
      dead: json['Dead'] == true,
      confirmed: json['Confirmed'] == true,
    );
  }

  bool get isRelease => kind == 'Release';
}

/// The `Data` of the Type 44 (VBTC_V2_COIN_PIN) transaction that raises a
/// pinned withdrawal's Bitcoin fee, or with [release] gives it up. Mirrors
/// Core's `VBTCService.BuildWithdrawalFeeBumpTx`; the transaction is sent by
/// the requester to itself with no amount.
Map<String, dynamic> watchedWithdrawalFeeBumpData({
  required String scIdentifier,
  required String withdrawalRequestHash,
  required int feeRate,
  required bool release,
}) {
  return {
    "Function": release ? "VBTCWithdrawalRelease()" : "VBTCWithdrawalFeeBump()",
    "ContractUID": scIdentifier,
    "WithdrawalRequestHash": withdrawalRequestHash,
    "FeeRate": feeRate,
  };
}
