import 'app_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'VFX Wallet';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navNfts => 'NFTs';

  @override
  String get navDomains => 'Domains';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSend => 'Send';

  @override
  String get actionReceive => 'Receive';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionPaste => 'Paste';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSearch => 'Search';

  @override
  String get statusLoading => 'Loading...';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusFailed => 'Failed';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelAddress => 'Address';

  @override
  String get labelBalance => 'Balance';

  @override
  String get labelAvailable => 'Available';

  @override
  String get labelTotal => 'Total';

  @override
  String get labelFee => 'Fee';

  @override
  String get labelFrom => 'From';

  @override
  String get labelTo => 'To';

  @override
  String get walletCreate => 'Create Wallet';

  @override
  String get walletImport => 'Import Wallet';

  @override
  String get walletPrivateKey => 'Private Key';

  @override
  String get walletRecoveryPhrase => 'Recovery Phrase';

  @override
  String get messageNoResults => 'No results found';

  @override
  String get messageCopiedToClipboard => 'Copied to clipboard';

  @override
  String sentAmount(String amount) {
    return 'Sent $amount VFX';
  }
}
