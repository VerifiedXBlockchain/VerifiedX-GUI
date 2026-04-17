import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get actionContinue => 'Continue';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionDone => 'Done';

  @override
  String get actionImport => 'Import';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get statusLoading => 'Loading...';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusSuccessful => 'Successful';

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
  String get labelLocked => 'Locked';

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
  String get messageAddressCopied => 'Address copied to clipboard';

  @override
  String get messagePrivateKeyCopied => 'Private Key copied to clipboard';

  @override
  String get messageNoAccountSelected => 'No account selected';

  @override
  String get messageClipboardInvalid => 'Clipboard text is invalid';

  @override
  String sentAmount(String amount) {
    return 'Sent $amount VFX';
  }

  @override
  String sendAppBarTitle(String currency) {
    return 'Send $currency';
  }

  @override
  String get sendFormLabelTo => 'To:';

  @override
  String get sendFormLabelFrom => 'From:';

  @override
  String get sendFormLabelAmount => 'Amount:';

  @override
  String get sendFormLabelFeeRate => 'Fee Rate:';

  @override
  String get sendRecipientHint => 'Recipient\'s Account Address';

  @override
  String sendAmountHint(String currency) {
    return 'Amount of $currency to send';
  }

  @override
  String get sendBadgeNotActivated => 'Not Activated';

  @override
  String get sendChooseAddressTitle => 'Choose an address';

  @override
  String get sendPaymentLinkCta => 'Create Payment Link';

  @override
  String get sendPasteHelperCtrl => 'Use ctrl+v to paste or click ';

  @override
  String get sendPasteHelperCmd => 'Use cmd+v to paste or click ';

  @override
  String get sendPasteHelperHereLink => 'here';

  @override
  String receiveAppBarTitle(String currency) {
    return 'Receive $currency';
  }

  @override
  String receiveSelectedVfxAddress(String vaultSuffix) {
    return 'Your Selected VFX$vaultSuffix Address';
  }

  @override
  String get receiveSelectedBtcAddress => 'Your Selected BTC Address';

  @override
  String get receiveVaultNotActivatedToast => 'This Vault Account has not been activated yet.';

  @override
  String get receiveActionCopyAddress => 'Copy\nAddress';

  @override
  String get receiveActionNewAccount => 'New\nAccount';

  @override
  String get receiveActionImportKey => 'Import\nKey';

  @override
  String get receiveRescanDialogTitle => 'Rescan Blocks?';

  @override
  String get receiveRescanDialogBody => 'Would you like to rescan the chain to include any transactions relevant to this key?';

  @override
  String get receiveBtcAccountCreatedTitle => 'BTC Account Created';

  @override
  String get receiveBtcAccountCreatedBody => 'Here are your BTC account details. Please ensure to back up your private key in a safe place.';

  @override
  String get receiveBtcImportKeyDialogTitle => 'Import BTC Private Key';

  @override
  String get receiveBtcImportKeyDialogBody => 'Paste in your BTC private key to import your account.';

  @override
  String get txAppBarAll => 'All Transactions';

  @override
  String get txAppBarVfx => 'VFX Transactions';

  @override
  String get txAppBarBtc => 'BTC Transactions';

  @override
  String get txTabAll => 'All';

  @override
  String get txTabPending => 'Pending';

  @override
  String get txTabSuccessful => 'Successful';

  @override
  String get txTabFailed => 'Failed';

  @override
  String get txTabVaulted => 'Vaulted';

  @override
  String get txTabTransactions => 'Transactions';

  @override
  String get txTabInputs => 'Inputs';

  @override
  String get homeKeysHeading => 'Keys';

  @override
  String get homeActionSendCoin => 'Send\nCoin';

  @override
  String get homeActionReceiveCoin => 'Receive\nCoin';

  @override
  String get homeActionTxs => 'TXs';

  @override
  String get homeGetVfxBtcCta => 'Get \$VFX/\$BTC Now';

  @override
  String get homeGetVfxCta => 'Get \$VFX';

  @override
  String get configAppBarTitle => 'CLI Configuration';

  @override
  String get configCloseDialogTitle => 'Are you sure you want to close the configuration screen?';

  @override
  String get configCloseDialogBody => 'All unsaved changes will be lost.';

  @override
  String get configButtonOpenConfig => 'Open Config';

  @override
  String get configButtonViewDocs => 'View Docs';

  @override
  String get configWarningAdvanced => 'Warning: These are advanced options. Proceed with caution.';

  @override
  String get configRestartRequiredToast => 'CLI restart is required for changes to propagate.';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystemDefault => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Español';
}
