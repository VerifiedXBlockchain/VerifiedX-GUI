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

/// Largest supply the node accepts in TokenDeploy() (VX-02).
const int kTokenMaxSupply = 2147483647;

final _wholeNumber = RegExp(r'^\d+(\.0*)?$');

/// Whether [text] is a token supply the node accepts: a whole number from 0 to
/// [kTokenMaxSupply]. A trailing ".0" is allowed because the form shows a
/// stored supply in its double form, for example "1000.0".
bool isValidTokenSupply(String text) {
  final trimmed = text.trim();
  if (!_wholeNumber.hasMatch(trimmed)) {
    return false;
  }
  final whole = BigInt.parse(trimmed.split('.').first);
  return whole <= BigInt.from(kTokenMaxSupply);
}
