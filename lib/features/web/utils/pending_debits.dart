import '../../transactions/models/web_transaction.dart';

/// VFX a reserve (Vault) account must keep across a block. The node refuses a
/// Vault send that would leave less.
const double kVaultMinimumBalance = 0.5;

/// Pending transactions from [address], one per hash. The same broadcast can
/// be recorded twice (once by the raw send path, once by its caller), and only
/// one of the copies may carry the data, so each hash keeps every copy for the
/// callers below to take the largest debit from.
Map<String, List<WebTransaction>> _pendingFrom(Iterable<WebTransaction> transactions, String address) {
  final byHash = <String, List<WebTransaction>>{};
  for (final tx in transactions) {
    if (tx.isPending && tx.fromAddress == address) {
      byHash.putIfAbsent(tx.hash, () => []).add(tx);
    }
  }
  return byHash;
}

double _maxOf(Iterable<double> values) => values.fold(0.0, (a, b) => b > a ? b : a);

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

/// VFX that [address] has already committed in transactions this session
/// broadcast but that have not confirmed yet: each one's amount plus fee.
/// The node counts a sender's pending transactions at admission (NEW-07), so a
/// new send must fit in the balance left after these.
double pendingVfxDebit(Iterable<WebTransaction> transactions, String address) {
  return _pendingFrom(transactions, address)
      .values
      .map((copies) => _maxOf(copies.map((tx) => (tx.amount ?? 0).abs() + (tx.fee ?? 0).abs())))
      .fold(0.0, (a, b) => a + b);
}

double _contractDebit(WebTransaction tx, String contractUid) {
  final data = tx.parseNftData();
  if (data == null) {
    return 0.0;
  }
  switch (data['Function']) {
    case 'TokenTransfer()':
    case 'TokenBurn()':
    case 'TransferVBTCV2()':
      return data['ContractUID'] == contractUid ? _asDouble(data['Amount']) : 0.0;
    case 'TransferVBTCMultiV2()':
      final inputs = data['Inputs'];
      if (inputs is! List) {
        return 0.0;
      }
      return inputs
          .whereType<Map>()
          .where((input) => input['SCUID'] == contractUid)
          .map((input) => _asDouble(input['Amount']))
          .fold(0.0, (a, b) => a + b);
    default:
      return 0.0;
  }
}

/// Fungible-token or vBTC V2 balance of [contractUid] that [address] has
/// already committed in pending transfers and burns this session broadcast.
double pendingContractDebit(Iterable<WebTransaction> transactions, String address, String contractUid) {
  return _pendingFrom(transactions, address)
      .values
      .map((copies) => _maxOf(copies.map((tx) => _contractDebit(tx, contractUid))))
      .fold(0.0, (a, b) => a + b);
}

/// VFX [address] can still send: its confirmed [balance] less pending debits
/// and, for a Vault, the minimum it has to keep. Never negative.
double spendableVfx({
  required double balance,
  required double pendingDebit,
  required bool isVault,
}) {
  final spendable = balance - pendingDebit - (isVault ? kVaultMinimumBalance : 0.0);
  return spendable > 0 ? spendable : 0.0;
}

/// Why a VFX send of a given amount cannot go ahead.
enum VfxSendShortfall {
  /// The confirmed balance itself is too small.
  balance,

  /// The balance covers it only if pending sends are ignored.
  pending,

  /// It would take a Vault below [kVaultMinimumBalance].
  vaultMinimum,
}

/// The reason a send of [amount] VFX from an address holding [balance] with
/// [pendingDebit] already committed cannot go ahead, or null when it can.
VfxSendShortfall? vfxSendShortfall({
  required double amount,
  required double balance,
  required double pendingDebit,
  required bool isVault,
}) {
  if (amount > balance) {
    return VfxSendShortfall.balance;
  }
  if (amount > spendableVfx(balance: balance, pendingDebit: pendingDebit, isVault: false)) {
    return VfxSendShortfall.pending;
  }
  if (amount > spendableVfx(balance: balance, pendingDebit: pendingDebit, isVault: isVault)) {
    return VfxSendShortfall.vaultMinimum;
  }
  return null;
}

final _trailingFractionZeros = RegExp(r'\.?0+$');

/// [value] with at most 8 decimals and no trailing zeros, for messages.
String formatDebitAmount(double value) {
  return value.toStringAsFixed(8).replaceFirst(_trailingFractionZeros, '');
}
