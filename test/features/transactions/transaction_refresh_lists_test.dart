import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/features/transactions/providers/transaction_list_provider.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';

final wallet = Wallet(id: 1, publicKey: 'pub', address: 'xRBXGu5Fk3zFDPMzLH1zoFFajnVG61ZcEY', balance: 10, isValidating: false);

/// A session with an account selected that never launches the CLI.
class StubSession extends SessionProvider {
  StubSession(Ref ref) : super(ref, SessionModel(cliStarted: true, currentWallet: wallet));

  @override
  Future<void> init(bool inLoop) async {}
}

/// Records each reload instead of asking the CLI.
class RecordingList extends TransactionListProvider {
  RecordingList(Ref ref, TransactionListType type, this.loads) : super(ref, type);

  final List<TransactionListType> loads;

  @override
  Future<void> load() async {
    loads.add(type);
  }
}

void main() {
  test("the Transactions screen's refresh reloads the Vaulted list too", () async {
    final loads = <TransactionListType>[];
    final container = ProviderContainer(overrides: [
      sessionProvider.overrideWith((ref) => StubSession(ref)),
      for (final type in TransactionListType.values) transactionListProvider(type).overrideWith((ref) => RecordingList(ref, type, loads)),
    ]);
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).loadTransactions();

    expect(loads.toSet(), TransactionListType.values.toSet());
  });
}
