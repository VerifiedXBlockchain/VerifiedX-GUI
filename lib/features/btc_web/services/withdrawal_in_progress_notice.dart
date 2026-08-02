import 'package:flutter/material.dart';

import '../../../core/dialogs.dart';

/// The node refuses a second withdrawal while one is outstanding on the same
/// contract, and reports it as a verification failure:
///
///   "Transaction verification failed: A withdrawal is already in progress for
///    contract <scUID>; try again once it completes."
///
/// Matched on the stable clause rather than the whole sentence, so a reworded
/// prefix or a different contract id still resolves.
bool isWithdrawalAlreadyInProgress(String? message) {
  if (message == null) return false;
  return message.toLowerCase().contains('withdrawal is already in progress');
}

/// Explains the shared-contract withdrawal gate.
///
/// Presented as a state rather than a fault, because that is what it is: the
/// holders of a vBTC contract share ONE Bitcoin deposit address, and a
/// withdrawal spends its UTXOs. Two at once would select the same inputs and
/// produce conflicting Bitcoin transactions, so the chain allows one at a time.
/// Nothing is broken and nothing is lost.
///
/// The raw node message is deliberately not shown — it leads with
/// "Transaction verification failed" and carries the full contract id, which
/// reads like a defect and tells the user nothing they can act on.
Future<void> showWithdrawalInProgressNotice() {
  return InfoDialog.show(
    title: "Withdrawal In Progress",
    icon: Icons.hourglass_top,
    closeText: "Got It",
    body: "This token already has a withdrawal underway, so another can't start yet.\n\n"
        "Everyone holding this token shares one Bitcoin deposit address. A withdrawal spends "
        "from it, so they have to go one at a time — otherwise two withdrawals would try to "
        "spend the same coins and neither would confirm.\n\n"
        "Your funds are safe. Try again once the current withdrawal finishes. If it has stalled, "
        "the token frees itself automatically about an hour after the request was made.",
  );
}
