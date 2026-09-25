import 'package:rbx_wallet/features/keygen/services/keygen_service.dart'
    if (dart.library.io) 'package:rbx_wallet/features/keygen/services/keygen_service_mock.dart';

import '../../../core/services/explorer_service.dart';
import '../../btc_web/models/btc_web_account.dart';
import '../../btc_web/services/btc_web_service.dart';
import '../../keygen/models/ra_keypair.dart';
import '../../keygen/utils/private_key_text.dart';

/// The Vault and Bitcoin accounts derived from one derivation text.
class DerivedAccounts {
  final String derivationText;
  final RaKeypair reserveKeypair;
  final BtcWebAccount? btcAccount;

  const DerivedAccounts({
    required this.derivationText,
    required this.reserveKeypair,
    required this.btcAccount,
  });
}

/// Every candidate pair for an imported key, canonical first, with what the
/// explorers show for each.
class ImportedKeyAccountOptions {
  final List<DerivedAccounts> options;
  final List<DerivedAccountsHistory> histories;

  const ImportedKeyAccountOptions(this.options, this.histories);

  /// The pair to restore without asking, or null when the user has to choose.
  DerivedAccounts? get autoSelected {
    final index = autoSelectDerivedAccounts(histories);
    return index == null ? null : options[index];
  }
}

/// The Vault keypair for [derivationText]: the first seed attempt whose
/// account has a Vault (xRBX) address.
Future<RaKeypair> deriveReserveKeypair(String derivationText) async {
  var attempt = 0;
  while (true) {
    final keypair = await KeygenService.seedToKeypair(reserveSeedFromDerivationText(derivationText, attempt));
    if (keypair != null) {
      final reserveKeypair = await KeygenService.importReserveAccountPrivateKey(keypair.private);
      if (reserveKeypair.address.startsWith("xRBX")) {
        return reserveKeypair;
      }
    }
    attempt += 1;
  }
}

Future<DerivedAccounts> deriveAccounts(String derivationText) async {
  final reserveKeypair = await deriveReserveKeypair(derivationText);
  final btcAccount = await BtcWebService().keypairFromEmailPassword(
    btcEmailFromDerivationText(derivationText),
    btcPasswordFromDerivationText(derivationText),
  );
  return DerivedAccounts(
    derivationText: derivationText,
    reserveKeypair: reserveKeypair,
    btcAccount: btcAccount,
  );
}

Future<bool?> _vaultHasHistory(String address) async {
  try {
    return await ExplorerService().addressHasHistory(address);
  } catch (e) {
    print("Could not check Vault history for $address: $e");
    return null;
  }
}

Future<bool?> _btcHasHistory(BtcWebAccount? account) async {
  if (account == null) {
    return false;
  }
  final info = await BtcWebService().addressInfo(account.address);
  if (info == null) {
    return null;
  }
  return info.txCount > 0;
}

Future<DerivedAccountsHistory> _history(DerivedAccounts accounts) async {
  final results = await Future.wait([
    _vaultHasHistory(accounts.reserveKeypair.address),
    _btcHasHistory(accounts.btcAccount),
  ]);
  return combineAccountHistory(vaultHasHistory: results[0], btcHasHistory: results[1]);
}

/// Derives the Vault and Bitcoin pair from the canonical text of an imported
/// key and from each historical text, and looks up activity on every pair
/// when there is more than one. [canonicalHex] comes from
/// canonicalPrivateKeyHex; [enteredText] is the key as the user supplied it.
Future<ImportedKeyAccountOptions> importedKeyAccountOptions(String canonicalHex, {String? enteredText}) async {
  final candidates = derivationTextCandidates(canonicalHex, enteredText: enteredText);
  final options = <DerivedAccounts>[];
  for (final candidate in candidates) {
    options.add(await deriveAccounts(candidate));
  }
  if (options.length == 1) {
    return ImportedKeyAccountOptions(options, const [DerivedAccountsHistory.none]);
  }
  final histories = await Future.wait(options.map(_history));
  return ImportedKeyAccountOptions(options, histories);
}
