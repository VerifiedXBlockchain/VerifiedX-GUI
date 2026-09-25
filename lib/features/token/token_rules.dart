/// Consensus rules for fungible tokens that the wallet checks before building
/// a transaction, so a refusal is explained in the form instead of arriving as
/// a node error.

/// Whether a token transfer names its own sender as the recipient. The node
/// refuses a TokenTransfer() to the sender's own address (NEW-04, NEW-09), and
/// the address field accepts mixed case, so the comparison ignores case and
/// surrounding whitespace.
bool isTokenTransferToSelf(String fromAddress, String toAddress) {
  return fromAddress.trim().toLowerCase() == toAddress.trim().toLowerCase();
}
