import 'dart:async';

final _controller = StreamController<void>.broadcast();

/// Stream that fires when a transaction has been submitted.
/// [TransactionListProvider] listens to this to reload immediately.
Stream<void> get onTransactionSubmitted => _controller.stream;

/// Call this after any successful transaction submission to trigger
/// an immediate transaction list reload.
void notifyTransactionSubmitted() {
  print('[TxRefresh] notifyTransactionSubmitted() called');
  _controller.add(null);
}
