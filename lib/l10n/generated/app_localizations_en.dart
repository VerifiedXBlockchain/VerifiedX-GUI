import 'package:intl/intl.dart' as intl;

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

  @override
  String get walletAccountsTitle => 'My Accounts';

  @override
  String get walletChangeAccount => 'Change Account:';

  @override
  String get walletPrivateKeyLabel => 'Private Key';

  @override
  String get walletImportLabel => 'Import';

  @override
  String get walletBulkImportTitle => 'Bulk Account Importer';

  @override
  String get walletBulkImportHint => 'Paste in your private keys. Each key should be a separate line.';

  @override
  String get walletConfirmImportTitle => 'Confirm Import';

  @override
  String walletConfirmImportBody(String label) {
    return 'Would you like to proceed with importing $label?';
  }

  @override
  String walletKeypairsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count keypairs',
      one: '1 keypair',
    );
    return '$_temp0';
  }

  @override
  String get walletRescanBlocksTitle => 'Rescan Blocks?';

  @override
  String get walletRescanBlocksBodyKeys => 'Would you like to rescan the chain to include any transactions relevant to these keys?';

  @override
  String get walletRescanBlocksBodyKey => 'Would you like to rescan the chain to include any transactions relevant to this key?';

  @override
  String walletImportedToast(String label) {
    return '$label imported!';
  }

  @override
  String walletAddressCopiedToast(String address) {
    return '$address copied to clipboard';
  }

  @override
  String get walletPrivateKeyCopiedToast => 'Private Key copied to clipboard';

  @override
  String get walletCopyVfxAddressTooltip => 'Copy VFX Address';

  @override
  String get walletCopyBtcAddressTooltip => 'Copy BTC Address';

  @override
  String get walletAddressesPlaceholder => 'VFX/BTC Account Addresses';

  @override
  String get walletImportTitle => 'Import Wallet';

  @override
  String get walletBulkImportLabel => 'Bulk Import';

  @override
  String get walletNewAccount => 'New Account';

  @override
  String get walletImportBtcWallet => 'Import BTC Wallet';

  @override
  String get walletImportBtcDialogTitle => 'Import BTC Private Key';

  @override
  String get walletImportBtcDialogBody => 'Paste in your BTC private key to import your account.';

  @override
  String get walletNewBtcAccount => 'New BTC Account';

  @override
  String get walletBtcAccountCreatedTitle => 'BTC Account Created';

  @override
  String get walletBtcAccountCreatedBody => 'Here are your BTC account details. Please ensure to back up your private key in a safe place.';

  @override
  String get walletAddressLabel => 'Address';

  @override
  String get walletManageAccounts => 'Manage Accounts';

  @override
  String get walletPrivateKeyImportedToast => 'Private Key Imported!';

  @override
  String walletPrivateKeyImportedSyncToast(String nextSync) {
    return 'Private Key Imported! Please wait until $nextSync for the balance to sync.';
  }

  @override
  String get walletRevealPrivateKey => 'Reveal Private Key';

  @override
  String get walletHideAccountTitle => 'Hide Account';

  @override
  String get walletHideAccountBody => 'Are you sure you want to hide this account?';

  @override
  String get walletHideLabel => 'Hide';

  @override
  String get walletStatusActivated => 'Activated';

  @override
  String get walletRestoreHidden => 'Restore Hidden Accounts';

  @override
  String get walletNoHiddenAccounts => 'You have no hidden accounts.';

  @override
  String get walletNoHiddenAccountsTitle => 'No Accounts to Restore';

  @override
  String get walletOkay => 'Okay';

  @override
  String get walletSelectToRestore => 'Select Account(s) to Restore';

  @override
  String get walletRestoreAll => 'Restore All';

  @override
  String get walletRestoreSelected => 'Restore Selected';

  @override
  String get walletNameLabel => 'Name';

  @override
  String walletRenameTitle(String label) {
    return 'Rename $label';
  }

  @override
  String get walletRename => 'Rename';

  @override
  String get walletDelete => 'Delete';

  @override
  String get walletPrivateKeyValidatorLabel => 'Private Key';

  @override
  String get walletDoneLabel => 'Done';

  @override
  String get walletVaultAccountCreatedTitle => 'Vault Account Created';

  @override
  String get walletRestoreCodeWarning => '🚨 Make sure to backup your RESTORE CODE somewhere safe. 🚨';

  @override
  String get walletRestoreCodeLabel => 'Restore Code';

  @override
  String get walletCopyAll => 'Copy All';

  @override
  String get walletSaveAsFile => 'Save as File';

  @override
  String get walletVaultDataCopiedToast => 'Vault Account Data copied to clipboard';

  @override
  String walletSavedToToast(String path) {
    return 'Saved to $path';
  }

  @override
  String get walletRestoreCodeCopiedToast => 'Restore Code copied to clipboard';

  @override
  String get walletRecoveryAddressLabel => 'Recovery Address';

  @override
  String get walletRecoveryAddressCopiedToast => 'Recovery Address copied to clipboard';

  @override
  String get walletRecoveryPrivateKeyLabel => 'Recovery Private Key';

  @override
  String get walletRecoveryPrivateKeyCopiedToast => 'Recovery Private Key copied to clipboard';

  @override
  String get walletBackupConfirmTitle => 'Backed up?';

  @override
  String get walletBackupConfirmBody => 'Please confirm you have backed up your RESTORE CODE as well as your PASSWORD.';

  @override
  String get walletBackupConfirmYes => 'I\'m Backed Up';

  @override
  String get walletRestoreCodeNote => 'You will need the Restore Code and Password to Recover any transaction. It is highly advised to copy all and store safely as you would for any private key.';

  @override
  String get authWelcomeTitle => 'Welcome to the VerifiedX Web Wallet!';

  @override
  String get authWelcomeBodyOne => 'The network does NOT store your email/password or mnemonic. They are used as seeds to generate your accounts\' keypairs.';

  @override
  String get authWelcomeBodyTwo => 'This includes your VFX account, Vault account, and Bitcoin account.';

  @override
  String get authWelcomeBodyThree => 'We recommend backing up all private keys however, when generating with an email/password or mnemonic, your VFX private key will restore all three accounts.';

  @override
  String get authBackupKeys => 'Backup Keys';

  @override
  String get authUnlockWalletFor => 'Unlock wallet for:';

  @override
  String get authUnknownAddress => 'Unknown Address';

  @override
  String get authEnterPassword => 'Enter Password';

  @override
  String get authEnterPasswordBody => 'Enter your password to decrypt your stored keys.';

  @override
  String get authDecryptFailed => 'Failed to decrypt keys';

  @override
  String get authLogout => 'Logout';

  @override
  String get authLoginCreateAccount => 'Login / Create Account';

  @override
  String get authResumeSession => 'Resume Session';

  @override
  String authWebWalletSubtitle(String version) {
    return 'Web Wallet $version';
  }

  @override
  String get authTypeEmailPassword => 'Email & Password';

  @override
  String get authTypeMnemonic => 'Mnemonic (HD account)';

  @override
  String get authTypeVfxPrivateKey => 'VFX Private Key';

  @override
  String get authTypeBtcPrivateKey => 'Bitcoin Private Key / WIF Key';

  @override
  String get authTypeVfxExtension => 'VFX Extension';

  @override
  String get btcVbtcOnboardTitle => 'vBTC Onboard';

  @override
  String get btcExitOnboardingTitle => 'Exit vBTC Onboarding?';

  @override
  String get btcExitOnboardingBody => 'Are you sure you want to cancel setting up your account with Tokenized Bitcoin?';

  @override
  String get btcVbtcReady => 'Your vBTC token is ready and funded.';

  @override
  String get btcViewToken => 'View Token';

  @override
  String get btcTokenNotFoundToast => 'Token not found';

  @override
  String get btcNoBtcAccountOrToken => 'No BTC account / Token Found.';

  @override
  String get btcStartOver => 'Start Over';

  @override
  String btcFromAddress(String address) {
    return 'From: $address';
  }

  @override
  String btcToAddress(String address) {
    return 'To: $address';
  }

  @override
  String get btcAmountToSendLabel => 'Amount to Send (BTC)';

  @override
  String get btcFeeRateLabel => 'Fee Rate:';

  @override
  String get btcInitiateTransfer => 'Initiate Transfer';

  @override
  String get btcInvalidAmountToast => 'Invalid Amount';

  @override
  String get btcAddressLabel => 'BTC Address';

  @override
  String get btcAddressCopiedToast => 'Address copied to clipboard!';

  @override
  String get btcSentManually => 'I\'ve sent this manually!';

  @override
  String get btcNoBtcAccount => 'No BTC Account Found.';

  @override
  String get btcWifCopiedToast => 'WIF private key copied to clipboard';

  @override
  String get btcDoneExclamation => 'Done!';

  @override
  String get btcImportExisting => 'Import Existing';

  @override
  String get btcCreateNew => 'Create New';

  @override
  String get btcBalanceFoundTitle => 'Balance Found!';

  @override
  String get btcVfxAccountImportedToast => 'VFX Account Imported Successfully';

  @override
  String get btcVfxAccountCreatedToast => 'VFX account Created Successfully';

  @override
  String get btcUseExistingVfxAccount => 'Or use one of your existing VFX Accounts:';

  @override
  String get btcUseExistingBtcAccount => 'Or use one of your existing BTC Accounts:';

  @override
  String get btcNoVfxAccount => 'No VFX Account Found.';

  @override
  String get btcUseFaucet => 'Use Faucet';

  @override
  String get btcPhoneNumberTitle => 'Phone Number';

  @override
  String get btcPhoneNumberLabel => 'Your Phone Number';

  @override
  String get btcInvalidPhoneToast => 'Invalid Phone Number';

  @override
  String btcVerificationCodeTitle(String phone) {
    return 'Enter verification code sent to $phone';
  }

  @override
  String get btcVerificationCodeLabel => 'Verification Code';

  @override
  String get btcManualSendBody => 'Alternatively, you can send the BTC manually to your token\'s deposit address.';

  @override
  String btcNotEnoughBalance(String amount) {
    return 'Not enough balance in BTC account to send $amount BTC';
  }

  @override
  String btcFundsSuccessToast(String hash) {
    return 'Success! Funds are on their way. TX Hash: $hash';
  }

  @override
  String get btcTransferManually => 'Transfer Manually';

  @override
  String get btcBulkTransferTitle => 'Bulk vBTC Transfer';

  @override
  String get btcBulkMaxTransferAmount => 'Maximum Transfer Amount:';

  @override
  String get btcBulkContinue => 'Continue';

  @override
  String get btcBulkNoTokensSelected => 'No tokens selected.';

  @override
  String get btcBulkAmountHint => 'Amount';

  @override
  String btcBulkMaxLabel(String amount) {
    return '(MAX: $amount vBTC)';
  }

  @override
  String btcBulkTotalLabel(String amount) {
    return 'Total: $amount vBTC';
  }

  @override
  String get btcBulkTransferToLabel => 'Transfer To VFX Address';

  @override
  String get btcBulkTransferToHint => 'Recipient\'s VFX Account Address';

  @override
  String get btcBulkConfirmTxTitle => 'Confirm Bulk Tx';

  @override
  String get btcBulkBroadcastedToast => 'vBTC Bulk Transfer TX broadcasted';

  @override
  String get btcBulkNoVfxSelectedToast => 'No VFX account selected';

  @override
  String get btcTokenizeTitle => 'Tokenize BTC (vBTC)';

  @override
  String get btcVbtcTokenHint => 'vBTC Token';

  @override
  String get btcVbtcHint => 'vBTC';

  @override
  String get btcViewProgress => 'View Progress';

  @override
  String get btcCompileMint => 'Compile & Mint';

  @override
  String get btcTransactionBroadcastedTitle => 'Transaction Broadcasted';

  @override
  String get btcMintAndDeploy => 'Mint & Deploy';

  @override
  String get btcVfxAddressRequired => 'A VFX address is required';

  @override
  String get btcCreateVbtcTitle => 'Create vBTC Token?';

  @override
  String get btcMpcStartBody => 'This will start an MPC ceremony to create your vBTC token.';

  @override
  String get btcNetworkFeeBody => 'A network fee of ~0.000028 VFX is required.';

  @override
  String btcVfxAccountLabel(String address) {
    return 'VFX Account: $address';
  }

  @override
  String get btcChangeAccountLabel => 'Change Account:';

  @override
  String get btcVfxAddressLabel => 'VFX Address:';

  @override
  String get btcContinueQuestion => 'Continue?';

  @override
  String get btcVbtcListTitle => 'Tokenized Bitcoin (vBTC)';

  @override
  String get btcBulkTransferLabel => 'Bulk vBTC Transfer';

  @override
  String get btcNoVbtcWithBalance => 'No vBTC tokens with a balance';

  @override
  String get btcCreateVerifiedToken => 'Create Verified BTC Token';

  @override
  String get btcVfxBalanceRequiredTitle => 'VFX Address with Balance Required';

  @override
  String get btcUseWizard => 'Use Wizard';

  @override
  String get btcVbtcLabel => 'vBTC';

  @override
  String get btcNoTokenizedBtc => 'No Tokenized Bitcoin found in account.';

  @override
  String get btcDetailsLabel => 'Details';

  @override
  String get btcNoTransactions => 'No Transactions';

  @override
  String get btcTokenNotFoundLabel => 'Token Not Found';

  @override
  String get btcDetailNameLabel => 'Name';

  @override
  String get btcDetailDescriptionLabel => 'Description';

  @override
  String get btcDetailOwnerLabel => 'Owner';

  @override
  String get btcDetailScOwnerLabel => 'Smart Contract Owner';

  @override
  String get btcDetailScOwnerAddressLabel => 'SmartContract Owner Address';

  @override
  String get btcDetailDepositAddressLabel => 'BTC Deposit Address';

  @override
  String get btcDetailScIdLabel => 'Smart Contract ID';

  @override
  String get btcDetailMyBalanceLabel => 'My Balance';

  @override
  String get btcDetailTotalBalanceLabel => 'Token Total Balance';

  @override
  String get btcDetailOwnerOnlyMedia => 'Only the token owner can view the additional media.';

  @override
  String get btcDetailTransferNow => 'Transfer Now';

  @override
  String get btcTransferNowToast => 'Transfer request has been broadcasted. Your assets should be available soon.';

  @override
  String btcLabelCopiedToast(String label) {
    return '$label copied to clipboard';
  }

  @override
  String get btcRetry => 'Retry';

  @override
  String get btcConfirmedLabel => 'Confirmed';

  @override
  String get btcPendingLabel => 'Pending';

  @override
  String get btcReplaceByFee => 'Replace By Fee';

  @override
  String get btcRbfFeeRateTitle => 'Fee Rate';

  @override
  String get btcRbfFeeRateLabel => 'Fee Rate (SATS /byte)';

  @override
  String get btcCopyDepositAddress => 'Copy Deposit Address';

  @override
  String get btcAddressCopiedShort => 'BTC Address copied to clipboard';

  @override
  String get btcFundLabel => 'Fund';

  @override
  String btcAmountWithBalanceTitle(String balance) {
    return 'Amount (Balance: $balance BTC)';
  }

  @override
  String get btcPleaseConfirmTitle => 'Please Confirm';

  @override
  String get btcOpenInExplorer => 'Open in BTC Explorer';

  @override
  String get btcManualSendTitle => 'Manual Send';

  @override
  String get btcWithdrawLabel => 'Withdraw';

  @override
  String get btcWithdrawAmountLabel => 'Withdrawl Amount';

  @override
  String get btcReceivingAddressLabel => 'Receiving Address';

  @override
  String get btcResponseTitle => 'Response';

  @override
  String get btcTransferOwnership => 'Transfer Ownership';

  @override
  String get btcVbtcNoBalanceTransfer => 'vBTC tokens with no balance can not be transferred';

  @override
  String get btcTransferToTitle => 'Transfer to';

  @override
  String get btcTransferLabel => 'Transfer';

  @override
  String get btcProveOwnership => 'Prove Ownership';

  @override
  String get btcBorrowLend => 'Borrow/Lend';

  @override
  String get btcActionNotAvailable => 'Action Not Available Yet.';

  @override
  String get btcCancelLabel => 'Cancel';

  @override
  String get btcInvalidAmount => 'Invalid Amount';

  @override
  String get btcNotEnoughBalanceShort => 'Not enough balance';

  @override
  String get btcAddBtcAccount => 'Add BTC Account (Segwit)';

  @override
  String get btcGenerateKeypair => 'Generate Keypair';

  @override
  String get btcGenerateKeypairSubtitle => 'Generate a random BTC keypair.';

  @override
  String get btcImportWifTitle => 'Import WIF Private Key';

  @override
  String get btcImportWifSubtitle => 'Import your BTC WIF private key';

  @override
  String get btcDomainPending => 'BTC Domain Pending';

  @override
  String get btcDomainTransferPending => 'BTC Domain Transfer Pending';

  @override
  String get btcDomainDeletePending => 'BTC Domain Delete Pending';

  @override
  String get btcCreateDomain => 'Create Domain';

  @override
  String get btcTransferBtcDomain => 'Transfer BTC Domain';

  @override
  String get btcVfxOwnerTitle => 'VFX Owner';

  @override
  String get btcVfxAddressLabelComma => 'VFX Address,';

  @override
  String get btcInvalidTxData => 'Invalid transaction data.';

  @override
  String get btcValidTxTitle => 'Valid Transaction';

  @override
  String get btcTxCancelledToast => 'Transaction Cancelled';

  @override
  String get btcDeleteDomainTitle => 'Delete BTC Domain?';

  @override
  String get btcStatusLabel => 'Status';

  @override
  String get btcFeeLabel => 'Fee';

  @override
  String get btcBlockTimeLabel => 'Block Time';

  @override
  String get btcBlockHeightLabel => 'Block Height';

  @override
  String get btcWebNoBtcAddress => 'No BTC Address';

  @override
  String btcWebNoTransactionsForAddress(String address) {
    return 'No Transactions found for $address.';
  }

  @override
  String get btcWebError => 'Error';

  @override
  String get reserveManageTitle => 'Manage Vault Accounts';

  @override
  String get reserveSetupNewAccount => 'Setup New Account';

  @override
  String get reserveRestoreVaultAccount => 'Restore Vault Account';

  @override
  String get reserveNoVaultAccounts => 'No Vault Accounts';

  @override
  String get reserveAddressColon => 'Address:';

  @override
  String get reserveAvailableBalanceColon => 'Available Balance:';

  @override
  String get reserveStatusColon => 'Status:';

  @override
  String get reserveSendFunds => 'Send Funds';

  @override
  String get reserveManageAssets => 'Manage Assets';

  @override
  String get reserveAssetsNfts => 'NFTs';

  @override
  String get reserveAssetsTokens => 'Fungible Tokens';

  @override
  String get reserveAssetsBtc => 'Bitcoin (vBTC)';

  @override
  String get reserveNoAssetsToast => 'This account has no assets/NFTS.';

  @override
  String get reserveTransferLabel => 'Transfer';

  @override
  String get reserveViewDetailsLabel => 'View Details';

  @override
  String get reserveNoVbtcTokens => 'This account has no vBTC Tokens';

  @override
  String get reserveReceiveAssets => 'Receive Assets';

  @override
  String get reserveActivateAccountAction => 'Activate\nAccount';

  @override
  String get reserveOverviewTitle => 'Vault Accounts';

  @override
  String get reserveWhatIsVault => 'What are Vault Accounts?';

  @override
  String reserveAvailableLabel(String amount) {
    return 'Available: $amount VFX';
  }

  @override
  String get reserveActivated => 'Activated';

  @override
  String get reserveActivationPending => 'Activation Pending';

  @override
  String get reserveAwaitingFunds => 'Awaiting Funds';

  @override
  String get reserveActivateNow => 'Activate Now';

  @override
  String get reserveRecoverLabel => 'Recover';

  @override
  String get reserveRecoverTitle => 'Recover Funds & NFTs';

  @override
  String reserveRecoverBody(String address) {
    return 'This is a destructive function that will callback all pending transactions and assets and move everything to this recovery account:\n\n$address';
  }

  @override
  String get reserveRecoverProceed => 'Proceed';

  @override
  String get reserveBackupMediaTitle => 'Backup Media';

  @override
  String get reserveBackupMediaBody => 'NFT Media will not be transferred in this process. Would you like to export a backup now now so you can import into your new environment?';

  @override
  String get reserveBackupAction => 'Backup';

  @override
  String get reserveManageVaultAccounts => 'Manage Vault Accounts';

  @override
  String get reserveExistingAccounts => 'Existing Accounts';

  @override
  String get reserveWebTitle => 'Your Vault Account';

  @override
  String get reserveWebNoAccount => 'No Vault Account Found';

  @override
  String get reserveWebRevealKeys => 'Reveal Keys';

  @override
  String get reserveWebVaultBalanceTitle => 'Vault Account Balance';

  @override
  String get reserveWebNoNftsToast => 'Your Vault Account has no NFTS.';

  @override
  String get reserveCallbackLabel => 'Callback';

  @override
  String get reserveCallbackTitle => 'Callback Transaction';

  @override
  String get reserveCallbackBody => 'Callbacks can be used to return the funds/assets to the same account for escrow purposes. Input your password to callback this transaction.';

  @override
  String get reservePasswordLabel => 'Password';

  @override
  String reserveCallbackSentToast(String hash) {
    return 'Callback TX sent with hash of $hash';
  }

  @override
  String get nodePoolTitle => 'Validator Pool';

  @override
  String get nodeSearchHint => 'Search by validator name...';

  @override
  String get nodeSearchExactNote => '* Must be the name exactly';

  @override
  String get nodeValidatorHeading => 'Validator';

  @override
  String get nodeStatusActive => 'Active';

  @override
  String get nodeStatusInactive => 'Inactive';

  @override
  String get nodePeerInfoHeading => 'Peer Info';

  @override
  String get nodeIpLabel => 'IP:';

  @override
  String get nodeHeightLabel => 'Height:';

  @override
  String get nodeLatencyLabel => 'Latency:';

  @override
  String get nodeLastCheckedLabel => 'Last Checked:';

  @override
  String nodeConnectedLabel(String date) {
    return 'Connected: $date';
  }

  @override
  String nodeWalletVersionLabel(String version) {
    return 'Wallet Version: $version';
  }

  @override
  String nodeConnectionDateLabel(String date) {
    return 'Connection Date: $date';
  }

  @override
  String nodeBlocksLabel(String count) {
    return 'Blocks: $count';
  }

  @override
  String get validatorTitle => 'Validator';

  @override
  String get validatorNoAccountSelected => 'No account selected';

  @override
  String validatorCannotValidate(String label) {
    return '$label can not validate.';
  }

  @override
  String get validatorOnlyOneAccount => 'You can only validate with one account.';

  @override
  String validatorRequirementHint(String amount) {
    return 'Validating requires $amount VFX.';
  }

  @override
  String get validatorChooseAccount => 'Please choose another account:';

  @override
  String validatorTransferHint(String amount, String address) {
    return 'Or transfer $amount VFX to $address.';
  }

  @override
  String validatorPortInstructions(String port, String port2, String port3, String amount) {
    return 'You must have port $port, $port2, and $port3 open to external networks with a balance of $amount VFX in order to validate.';
  }

  @override
  String get validatorStartValidating => 'Start Validating';

  @override
  String validatorBalanceInsufficient(String amount) {
    return 'Balance not currently sufficient to validate. $amount VFX required.';
  }

  @override
  String get validatorNamePromptTitle => 'Name your validator';

  @override
  String get validatorNameLabel => 'Validator Name';

  @override
  String validatorNowValidating(String name, String label) {
    return '$name [$label] is now validating.';
  }

  @override
  String validatorNotValidating(String label) {
    return '$label is NOT Validating...';
  }

  @override
  String get validatorCheckAgain => 'Check Again';

  @override
  String get validatorActive => 'Validating...';

  @override
  String validatorAddressLabel(String label) {
    return 'Address: $label';
  }

  @override
  String get validatorRenameTooltip => 'Rename Validator';

  @override
  String get validatorNamePromptTitleAlt => 'Validator Name';

  @override
  String get validatorNameField => 'Name';

  @override
  String get validatorNewNameLabel => 'New Validator Name';

  @override
  String validatorRenamedToast(String name) {
    return 'Validator name changed to $name.';
  }

  @override
  String get validatorRestartCliTitle => 'Restart CLI';

  @override
  String get validatorRestartCliBody => 'In order for the name to be reflected,\na restart of the CLI is required.\n\nRestart now?';

  @override
  String get validatorRestartCliConfirm => 'Restart';

  @override
  String get validatorRestartingToast => 'Restarting CLI...';

  @override
  String get validatorStopValidating => 'Stop Validating';

  @override
  String get validatorStopValidatingBody => 'Are you sure you want to stop validating?';

  @override
  String get validatorStopLabel => 'Stop';

  @override
  String validatorStoppedToast(String label) {
    return '$label has stopped validating.';
  }

  @override
  String validatorBlocksValidatedHeading(String count) {
    return 'Blocks Validated ($count)';
  }

  @override
  String get validatorNoValidatedBlocks => 'No Validated Blocks';

  @override
  String validatorBlockTitle(String height) {
    return 'Block $height';
  }

  @override
  String get adnrTitleAny => 'Domains';

  @override
  String get adnrTitleVfx => 'VFX Domains';

  @override
  String get adnrTitleBtc => 'BTC Domains';

  @override
  String get adnrCreateAnyHeading => 'Create a domain as an alias to your address for receiving funds.';

  @override
  String get adnrCreateVfxHeading => 'Create a VFX domain as an alias to your address for receiving funds.';

  @override
  String get adnrCreateBtcHeading => 'Create a BTC domain as an alias to your BTC address for receiving funds.';

  @override
  String adnrCostNoteAny(String cost) {
    return 'Domains cost $cost VFX plus the transaction fee.';
  }

  @override
  String adnrCostNoteVfx(String cost) {
    return 'VFX domains cost $cost VFX plus the transaction fee.';
  }

  @override
  String adnrCostNoteBtc(String cost) {
    return 'BTC domains cost $cost VFX plus the transaction fee.';
  }

  @override
  String get adnrNoDomain => 'No Domain';

  @override
  String get adnrCreateDomain => 'Create Domain';

  @override
  String get adnrTransfer => 'Transfer';

  @override
  String get adnrDelete => 'Delete';

  @override
  String get adnrCreatePending => 'Creation Pending';

  @override
  String get adnrTransferPending => 'Transfer Pending';

  @override
  String get adnrDeletePending => 'Delete Pending';

  @override
  String get adnrVfxDomainBadge => 'VFX Domain';

  @override
  String get adnrBtcDomainBadge => 'BTC Domain';

  @override
  String get adnrVfxDomainPending => 'VFX Domain Pending';

  @override
  String get adnrVfxDomainTransferPending => 'VFX Domain Transfer Pending';

  @override
  String get adnrVfxDomainDeletePending => 'VFX Domain Delete Pending';

  @override
  String get adnrCreateVfxOnAccount => 'Create a VFX Domain as an alias to your account\'s address for receiving funds.';

  @override
  String get adnrTransferDomainTitle => 'Transfer VFX Domain';

  @override
  String adnrTransferDomainBody(String cost) {
    return 'There is a cost of $cost VFX to transfer a VFX Domain.';
  }

  @override
  String get adnrAddressFieldLabel => 'Address';

  @override
  String get adnrInsufficientFundsTransfer => 'Not enough VFX in this account to create a transaction.';

  @override
  String adnrInsufficientFundsCreateBtc(String cost) {
    return 'Not enough VFX in your account to create a BTC domain. $cost VFX required (plus TX fee).';
  }

  @override
  String adnrInsufficientFundsCreateVfx(String cost) {
    return 'Not enough VFX in this account to create a VFX domain. $cost VFX required (plus TX fee).';
  }

  @override
  String adnrInsufficientFundsCreateInWallet(String cost) {
    return 'Not enough VFX in this wallet to transfer a VFX domain. $cost VFX required (plus TX fee).';
  }

  @override
  String get adnrInsufficientFundsDeleteInWallet => 'Not enough VFX in this wallet to delete a VFX domain.';

  @override
  String get adnrTxBroadcastedToast => 'VFX Domain Transaction has been broadcasted. See log for hash.';

  @override
  String get adnrBtcTxBroadcastedToast => 'BTC Domain Transaction has been broadcasted. See log for hash.';

  @override
  String get adnrTransferTxBroadcastedToast => 'VFX domain transfer transaction has been broadcasted. Check logs for tx hash';

  @override
  String get adnrDeleteTxBroadcastedToast => 'VFX domain delete transaction has been broadcasted. Check logs for tx hash';

  @override
  String get adnrDeleteTitle => 'Delete VFX Domain?';

  @override
  String get adnrFundAccountTitle => 'Fund Account';

  @override
  String get adnrFundCopyAddress => 'Copy Address';

  @override
  String get adnrAddressCopiedToast => 'Address copied to clipboard.';

  @override
  String get adnrFundsSentTitle => 'Funds Sent';

  @override
  String adnrFundsSentBody(String amount, String address) {
    return '$amount VFX has been sent to $address.\n\nPlease wait for transaction to reflect and then you can get your domain.';
  }

  @override
  String get adnrCreateDialogTitleVfx => 'New VFX Domain';

  @override
  String get adnrCreateDialogTitleBtc => 'New BTC Domain';

  @override
  String adnrCreateDialogCostVfx(String cost) {
    return 'VFX Domains cost $cost VFX.';
  }

  @override
  String adnrCreateDialogCostBtc(String cost) {
    return 'BTC Domains cost $cost VFX.';
  }

  @override
  String get adnrCreateDialogSuffixHelpVfx => 'Your domain must only contain letters and numbers and will automatically be appended with \".vfx\" upon verification';

  @override
  String get adnrCreateDialogSuffixHelpBtc => 'Your domain must only contain letters and numbers and will automatically be appended with \".btc\" upon verification';

  @override
  String get adnrDomainNameLabel => 'Domain Name';

  @override
  String get adnrCreateButton => 'Create';

  @override
  String adnrFaucetRequiredTitle(String cost) {
    return '$cost VFX Required';
  }

  @override
  String adnrFaucetRequiredBody(String cost) {
    return 'There is a $cost VFX cost (plus TX fee) to create a BTC domain.\n\nThe community has allocated some VFX to lower the barrier to entry for trying out this feature. In order to prevent abuse, a phone number is required for an SMS authorization. Only a hash of your phone number will be stored.\n\nWoud you like to proceed?';
  }

  @override
  String get adnrFaucetContinue => 'Continue';

  @override
  String get adnrFaucetNoThanks => 'No Thanks';

  @override
  String get adnrFaucetTitle => 'VFX Faucet';

  @override
  String get adnrFaucetWaitToast => 'Please wait for your balance to arrive before continuing.';

  @override
  String get adnrMaxLengthToast => 'Maximum characters for domain is 65';

  @override
  String adnrAlreadyExistsToast(String currency) {
    return 'This $currency Domain already exists';
  }

  @override
  String get adnrNoBtcAddress => 'No BTC Address Found';

  @override
  String get adnrNoBtcWif => 'No BTC WIF Private Key Found';

  @override
  String get adnrNoAccountToast => 'No account';

  @override
  String adnrLogTransferEntry(String hash) {
    return 'VFX domain transfer transaction broadcasted. Tx Hash: $hash';
  }

  @override
  String adnrLogDeleteEntry(String hash) {
    return 'VFX domain delete transaction broadcasted. Tx Hash: $hash';
  }

  @override
  String adnrLogCreateEntry(String hash) {
    return 'ADNR create transaction broadcasted. Tx Hash: $hash';
  }

  @override
  String get nftListTitle => 'NFTs';

  @override
  String get nftImportLabel => 'Import NFT';

  @override
  String get nftImportPromptTitle => 'Smart Contract Identifier';

  @override
  String get nftImportPromptBody => 'Paste in the smart contract\'s unique identifier.';

  @override
  String get nftImportFieldLabel => 'Identifier';

  @override
  String get nftImportedToast => 'Smart Contract imported from network';

  @override
  String get nftTabMyNfts => 'My NFTs';

  @override
  String get nftTabManageMinted => 'Manage Minted NFTs';

  @override
  String get nftBadgeTransferred => 'Transferred';

  @override
  String get nftBadgeListed => 'Listed';

  @override
  String get nftSaleInProgress => 'Sale in Progress...';

  @override
  String get nftBurnedOverlay => 'Burned';

  @override
  String get nftLockedBadge => 'NFT Locked';

  @override
  String get nftTransferringDefault => 'Transferring...';

  @override
  String get nftMediaUploadProgress => 'Media Upload Progress';

  @override
  String get nftCopyUrl => 'Copy URL';

  @override
  String get nftUrlCopiedToast => 'URL copied to clipboard';

  @override
  String get nftQrSave => 'Save';

  @override
  String get nftQrOpen => 'Open';

  @override
  String get nftLearnMoreCancel => 'Cancel';

  @override
  String get nftLearnMoreCreate => 'Create';

  @override
  String get nftDetailFallback => 'NFT';

  @override
  String get nftMinterAddressLabel => 'Minter Address';

  @override
  String get nftPropertiesHeading => 'Properties:';

  @override
  String get nftFeaturesHeading => 'Features:';

  @override
  String get nftRevealEvolveStages => 'Reveal Evolve Stages';

  @override
  String get nftProveOwnership => 'Prove Ownership';

  @override
  String get nftTransfer => 'Transfer';

  @override
  String get nftSell => 'Sell';

  @override
  String get nftActivatingSoonToast => 'Activating soon!';

  @override
  String get nftNoAccountSelectedToast => 'No account selected';

  @override
  String get nftVaultCannotSellToast => 'Vault Accounts can not sell NFTs.';

  @override
  String get nftNotEnoughBalanceToast => 'Not enough balance for transaction';

  @override
  String get nftMediaNotFoundToast => 'Media files not found on this machine.';

  @override
  String get nftSellTitle => 'Sell NFT';

  @override
  String get nftSellAddressLabel => 'VFX Address';

  @override
  String get nftInvalidAddressToast => 'Invalid Address';

  @override
  String get nftSellAmountTitle => 'Sale Amount';

  @override
  String get nftSellAmountLabel => 'VFX Amount)';

  @override
  String get nftSellInvalidAmountToast => 'Invalid Amount';

  @override
  String get nftBackupUrlTitle => 'Backup URL (Optional)';

  @override
  String get nftBackupUrlLabel => 'URL (Optional)';

  @override
  String get nftConfirmSaleStartTitle => 'Confirm Sale Start';

  @override
  String get nftManage => 'Manage';

  @override
  String get nftViewCode => 'View Code';

  @override
  String get nftSyncMedia => 'Sync Media';

  @override
  String get nftBurn => 'Burn';

  @override
  String get nftBurnTitle => 'Burn NFT?';

  @override
  String get nftTransferNow => 'Transfer Now';

  @override
  String get nftDecrypt => 'Decrypt';

  @override
  String get nftDecrypted => 'Decrypted';

  @override
  String get nftMediaBackupUrl => 'Media Backup URL';

  @override
  String get nftEvolveTitle => 'Evolve?';

  @override
  String get nftDevolveTitle => 'Devolve?';

  @override
  String get nftEvolveSentToast => 'Evolve transaction sent successfully!';

  @override
  String get nftDevolveSentToast => 'Devolve transaction sent successfully!';

  @override
  String get nftEvolveSentTitle => 'Evolve transaction sent successfully';

  @override
  String get nftClose => 'Close';

  @override
  String get nftViewLabel => 'View NFT';

  @override
  String get nftOwnedByMe => 'Owned by Me';

  @override
  String get nftAssociate => 'Associate';

  @override
  String get nftOpenFile => 'Open File';

  @override
  String nftPhaseNameLabel(String name) {
    return 'Name: $name';
  }

  @override
  String get nftEvolve => 'Evolve';

  @override
  String get scTitle => 'Smart Contracts';

  @override
  String get scMyTitle => 'My Smart Contracts';

  @override
  String get scTemplatesTitle => 'Smart Contracts Templates';

  @override
  String get scTabCompiled => 'Compiled';

  @override
  String get scTabDrafts => 'Drafts';

  @override
  String get scNoDrafts => 'No Smart Contracts Drafts Found';

  @override
  String get scNoCompiled => 'No Smart Contracts Found';

  @override
  String get scCreateAndMintTitle => 'Create a Smart Contract & Mint';

  @override
  String get scCreateAndMintBody => 'Start with a baseline smart contract and add customized features';

  @override
  String get scMintCollectionTitle => 'Mint NFT Collection';

  @override
  String get scMintCollectionBody => 'Mint multiple Smart Contracts into a collection';

  @override
  String get scLaunchIdeTitle => 'Launch IDE';

  @override
  String get scLaunchIdeBody => 'Open the online IDE to write your own Trillium code for your smart contract';

  @override
  String get scChooseVfxToast => 'Please choose a VFX account to begin creating a smart contract.';

  @override
  String get scVaultCannotMintToast => 'Vault Accounts cannot mint smart contracts';

  @override
  String get scTemplatesHeading => 'Choose a Smart Contract & Add Features';

  @override
  String get scCreateButton => 'Create';

  @override
  String get scLearnMore => 'Learn More';

  @override
  String get tokenListTitle => 'Fungible Tokens';

  @override
  String get tokenCreateNew => 'Create New Token';

  @override
  String get tokenCreateTitle => 'Create Fungible Token';

  @override
  String get tokenTopicCreateTitle => 'Create Token Topic';

  @override
  String get tokenNotSupportedByVault => 'Not Supported by Vault Account';

  @override
  String get tokenProveOwnership => 'Prove Ownership';

  @override
  String get tokenVoting => 'Voting';

  @override
  String get tokenViewTopics => 'View Topics';

  @override
  String get tokenNoTopicsTitle => 'No Topics';

  @override
  String get tokenNoTopicsBody => 'This token doesn\'\'t have any voting topics yet.';

  @override
  String get tokenListBans => 'List Bans';

  @override
  String get tokenBannedAddressesTitle => 'Banned Addresses';

  @override
  String get tokenScUidLabel => 'Smart Contract UID';

  @override
  String get tokenNameLabel => 'Token Name';

  @override
  String get tokenLifetimeCapLabel => 'Lifetime Cap';

  @override
  String get tokenMintableLabel => 'Mintable';

  @override
  String get tokenOwnerLabel => 'Owner';

  @override
  String get tokenTickerLabel => 'Token Ticker';

  @override
  String get tokenCirculatingSupplyLabel => 'Circulating Supply';

  @override
  String get tokenBurnedLabel => 'Burned';

  @override
  String get tokenBurnableLabel => 'Burnable';

  @override
  String get tokenTopicCreatedLabel => 'Topic Created';

  @override
  String get tokenVotingEndsLabel => 'Voting Ends';

  @override
  String get tokenVoteYes => 'Vote Yes';

  @override
  String get tokenVoteNo => 'Vote No';

  @override
  String get tokenConfirmVoteYes => 'Confirm Vote [YES]';

  @override
  String get tokenConfirmVoteNo => 'Confirm Vote [NO]';

  @override
  String get tokenNoOwnerToast => 'Could not get owner of token';

  @override
  String get tokenVoteCastedToast => 'Vote casted';

  @override
  String get tokenVoteHistory => 'Vote History';

  @override
  String get tokenNoVotesToast => 'No Votes';

  @override
  String tokenVoteBlockSubtitle(String height) {
    return 'Block $height';
  }

  @override
  String get tokenBanAddress => 'Ban Address';

  @override
  String get tokenBanAddressTitle => 'Address To Ban';

  @override
  String get tokenAddressFieldLabel => 'Address';

  @override
  String get tokenBanBroadcastedToast => 'Token address ban transaction broadcasted';

  @override
  String get tokenBurn => 'Burn';

  @override
  String get tokenNotBurnableToast => 'This token is not burnable';

  @override
  String get tokenAmountToBurnTitle => 'Amount to Burn';

  @override
  String get tokenAmountLabel => 'Amount';

  @override
  String get tokenInvalidAmountToast => 'Invalid Amount';

  @override
  String get tokenInsufficientBalanceToast => 'Not enough balance to perform this transaction';

  @override
  String get tokenBurnBroadcastedToast => 'Token burn transaction broadcasted';

  @override
  String get tokenChangeOwnership => 'Change Ownership';

  @override
  String get tokenTransferToAddressTitle => 'Transfer To Address';

  @override
  String get tokenToAddressLabel => 'To Address';

  @override
  String get tokenOwnershipBroadcastedToast => 'Token ownership change transaction broadcasted';

  @override
  String get tokenCreateButton => 'Create Token';

  @override
  String get tokenSearchHint => 'Search...';

  @override
  String get tokenPrevPage => 'Prev Page';

  @override
  String get tokenNextPage => 'Next Page';

  @override
  String get tokenMintTokens => 'Mint Tokens';

  @override
  String get tokenAmountToMintTitle => 'Amount to Mint';

  @override
  String get tokenMintBroadcastedToast => 'Token mint transaction broadcasted';

  @override
  String get tokenStateChangePendingToast => 'Token state change is pending. Please wait';

  @override
  String tokenAddressCopiedToast(String address) {
    return 'Address copied to clipboard ($address)';
  }

  @override
  String get tokenFormNameHint => 'MyToken';

  @override
  String get tokenFormTickerHint => 'ABC';

  @override
  String get tokenFormCreate => 'Create';

  @override
  String get tokenFormCancel => 'Cancel';

  @override
  String get tokenFormNoAccountSelectedToast => 'No account selected';

  @override
  String get tokenFormIconRequiredToast => 'Icon Image Required';

  @override
  String get tokenFormCompileMintTitle => 'Compile & Mint Token Smart Contract?';

  @override
  String get tokenFormConfirmAddressTitle => 'Confirm Address';

  @override
  String get tokenFormStandByTitle => 'Stand by';

  @override
  String get tokenTransfer => 'Transfer';

  @override
  String get tokenAmountToTransferTitle => 'Amount to Transfer';

  @override
  String get tokenTransferBroadcastedToast => 'Token transfer transaction broadcasted';

  @override
  String get tokenTransferTo => 'Transfer to';

  @override
  String tokenWebInsufficient(String address, String ticker) {
    return 'This address\'\'s ($address) $ticker balance is insufficient.';
  }

  @override
  String get tokenCreateNewVotingTopic => 'Create New Voting Topic';

  @override
  String get tokenCreateNewVotingTopicBody => 'As the token owner, you can create topics for other holders to vote on.';

  @override
  String tokenListBansWithCount(String count) {
    return 'List Bans ($count)';
  }

  @override
  String get dstAuctionsTitle => 'P2P Auctions';

  @override
  String get dstConnectToAuctionHouse => 'Connect to Auction House';

  @override
  String get dstConnectToAuctionHouseBody => 'Connect to a remote auction house to trade NFTs.';

  @override
  String get dstManageMyAuctionHouse => 'Manage my Auction House';

  @override
  String get dstManageMyAuctionHouseBody => 'Manage your account\'\'s auction house and trade NFTs.';

  @override
  String get dstManageMyAuctionHouseBodyWeb => 'Manage your wallet\'\'s auction house and trade NFTs.';

  @override
  String get dstMyAuctionHouseTitle => 'My Auction House';

  @override
  String get dstEditDetails => 'Edit Details';

  @override
  String get dstDeleteShop => 'Delete Shop';

  @override
  String get dstDeleteCollection => 'Delete Collection';

  @override
  String get dstImportShop => 'Import Shop';

  @override
  String get dstImportShopAddressLabel => 'Your VFX Address';

  @override
  String get dstDiscardChanges => 'Discard Changes';

  @override
  String get dstPublishUpdatesTitle => 'Publish Updates?';

  @override
  String get dstCliRestartTitle => 'CLI Restart Required';

  @override
  String get dstAuctionActivity => 'Auction Activity';

  @override
  String get dstCompleted => 'Completed';

  @override
  String dstCloseShopEditConfirm(String mode) {
    return 'Are you sure you want to close the shop $mode screen?';
  }

  @override
  String dstCloseStoreEditConfirm(String mode) {
    return 'Are you sure you want to close the store $mode screen?';
  }

  @override
  String dstCloseCollectionEditConfirm(String mode) {
    return 'Are you sure you want to close the collection $mode screen?';
  }

  @override
  String dstCloseListingEditConfirm(String mode) {
    return 'Are you sure you want to close the listing $mode screen?';
  }

  @override
  String get dstDiscardListingTitle => 'Are you sure you want to discard the listing?';

  @override
  String get dstModeEditing => 'editing';

  @override
  String get dstModeCreation => 'creation';

  @override
  String get shopAuctionHousesTitle => 'Auction Houses';

  @override
  String get shopMyAuctionHousesTitle => 'My Auction Houses';

  @override
  String get shopUrlPromptTitle => 'Shop URL';

  @override
  String get shopUrlRequired => 'Shop URL required';

  @override
  String get shopUrlLabel => 'Input Shop Name Only';

  @override
  String get shopWalletNotSyncedTitle => 'Wallet Not Synced';

  @override
  String get shopWalletNotSyncedBody => 'Since your wallet is not synced there may be some issues viewing the data in this shop. Continue anyway?';

  @override
  String get shopConnectToShop => 'Connect to a Shop';

  @override
  String get shopShareShop => 'Share Shop';

  @override
  String get shopShareCollection => 'Share Collection';

  @override
  String get shopCreateListing => 'Create Listing';

  @override
  String get shopCreateCollection => 'Create Collection';

  @override
  String get shopPublished => 'Published';

  @override
  String get shopPublishShop => 'Publish Shop';

  @override
  String get shopPublishShopTitle => 'Publish Shop?';

  @override
  String get shopDeleteShopTitle => 'Delete shop?';

  @override
  String get shopDeleteCollectionConfirm => 'Are you sure you want to delete this collection?';

  @override
  String get shopErrorTitle => 'Error';

  @override
  String get shopLoading => 'Loading...';

  @override
  String get shopNoActiveListings => 'No Active Listings';

  @override
  String get shopNoActiveCollections => 'No Active Collections';

  @override
  String get shopSendSaleStartTx => 'Send Sale Start TX';

  @override
  String get shopSignIn => 'Sign In';

  @override
  String get shopStartTransaction => 'Start Transaction';

  @override
  String get shopSearchAuctionHouseHint => 'Search for auction house...';

  @override
  String get shopBidSent => 'Sent';

  @override
  String get shopBidReceived => 'Received';

  @override
  String get shopBidPurchased => 'Purchased';

  @override
  String get shopBidAccepted => 'Accepted';

  @override
  String get shopBidRejected => 'Rejected';

  @override
  String get shopResendBid => 'Resend Bid';

  @override
  String get shopPriceLabel => 'Price';

  @override
  String get shopBuyNow => 'Buy Now';

  @override
  String get shopFloorPriceLabel => 'Floor Price';

  @override
  String get shopHighestBidLabel => 'Highest Bid';

  @override
  String get shopBidNow => 'Bid Now';

  @override
  String get shopDetailsLabel => 'Details';

  @override
  String get shopAuctionDetailsTitle => 'Auction Details';

  @override
  String get shopBidHistory => 'Bid History';

  @override
  String get paymentLinkTitle => 'Payment Link';

  @override
  String get paymentLinkHistory => 'Payment Link History';

  @override
  String get paymentLinkNoneYet => 'No payment links yet';

  @override
  String get paymentLinkIntro => 'Use Butterfly to create a payment link, claimable by anyone you send the link to.';

  @override
  String get paymentAmountLabel => 'Amount (VFX)';

  @override
  String get paymentAmountHint => 'Enter amount';

  @override
  String get paymentMessageLabel => 'Message (Optional)';

  @override
  String get paymentMessageHint => 'What\'\'s this payment for?';

  @override
  String get paymentCreateLinkLabel => 'Create Payment Link';

  @override
  String get paymentAmountRequired => 'Amount is required';

  @override
  String get paymentValidAmount => 'Please enter a valid amount';

  @override
  String get paymentInsufficientBalance => 'Insufficient balance';

  @override
  String get paymentMinimumAmount => 'Minimum amount is 0.0001 VFX';

  @override
  String paymentAvailableLabel(String amount) {
    return 'Available: $amount VFX';
  }

  @override
  String get paymentPayWithCryptoCom => 'Pay with Crypto.com';

  @override
  String get paymentPayWithCard => 'Pay with Credit Card';

  @override
  String get paymentCancel => 'Cancel';

  @override
  String get navMenuDashboard => 'Dashboard';

  @override
  String get navMenuVaultAccounts => 'Vault Accounts';

  @override
  String get navMenuSend => 'Send';

  @override
  String get navMenuReceive => 'Receive';

  @override
  String get navMenuTransactions => 'Transactions';

  @override
  String get navMenuValidator => 'Validator';

  @override
  String get navMenuDomains => 'VFX/BTC Domains';

  @override
  String get navMenuTokenizeBitcoin => 'Tokenize Bitcoin';

  @override
  String get navMenuSmartContracts => 'Smart Contracts';

  @override
  String get navMenuFungibleTokens => 'Fungible Tokens';

  @override
  String get navMenuNfts => 'NFTs';

  @override
  String get navMenuP2PAuctions => 'P2P Auctions';

  @override
  String get navMenuAccountRequiredToast => 'An account is required to access this section.';

  @override
  String get navMenuLogout => 'Logout';

  @override
  String get navAddAccount => 'Add Account';

  @override
  String get statusUpdateAvailable => 'Update Available';

  @override
  String get statusBlockchainVersion => 'Blockchain Version';

  @override
  String get statusCliVersion => 'CLI Version';

  @override
  String get statusBlockHeight => 'Block Height';

  @override
  String get statusPeers => 'Peers (In / Out)';

  @override
  String get statusWalletStarted => 'Wallet Started';

  @override
  String get statusNetworkMetrics => 'Network Metrics';

  @override
  String get statusCliInactive => 'CLI Inactive';

  @override
  String get statusLoadingLabel => 'Loading';

  @override
  String get statusVfxOnline => 'VFX Online';

  @override
  String get statusVfxOffline => 'VFX Offline';

  @override
  String get statusBtcLoading => 'BTC Loading';

  @override
  String get statusBtcOnline => 'BTC Online';

  @override
  String get statusBtcOffline => 'BTC Offline';

  @override
  String get webNoWalletDetected => 'No Wallet detected.';

  @override
  String get webSetupWallet => 'Setup Wallet';

  @override
  String get webPendingActivation => 'Pending Activation';

  @override
  String get webActivateNow => 'Activate Now';

  @override
  String get webRestoreVaultAccount => 'Restore Vault Account';

  @override
  String get webRestoreCodeLabel => 'Restore Code';

  @override
  String get webVaultRestoredToast => 'Vault Account restored';

  @override
  String get webRecover => 'Recover';

  @override
  String get webRecoverFundsTitle => 'Recover Funds & NFTs';

  @override
  String get webRecoveryBroadcasted => 'Recovery transaction broadcasted.';

  @override
  String get webCallback => 'Callback';

  @override
  String get webCallbackTitle => 'Callback Transaction';

  @override
  String get webCallbackBroadcasted => 'Callback TX broadcasted';

  @override
  String get webRevealPrivateKeyTitle => 'Reveal Private Key?';

  @override
  String webAddressCopiedToast(String address) {
    return 'Address $address copied to clipboard';
  }

  @override
  String get webCurrencyAll => 'All';

  @override
  String get webCurrencyVfx => 'VFX';

  @override
  String get webCurrencyVault => 'Vault';

  @override
  String get webCurrencyBtc => 'BTC';

  @override
  String get webFundAccount => 'Fund Account';

  @override
  String get webFundVaultTitle => 'Fund Your Vault Account';

  @override
  String get webAutoActivateTitle => 'Automatically Activate?';

  @override
  String get keygenImportWalletTitle => 'Import Wallet';

  @override
  String get keygenPrivateKeyLabel => 'Private Key';

  @override
  String get keygenEmailAddressTitle => 'Email Address';

  @override
  String get keygenEmailLabel => 'Email';

  @override
  String get keygenRecoveryMnemonicTitle => 'Input Recovery Mnemonic';

  @override
  String get keygenRecoveryMnemonicLabel => 'Recovery Mnemonic';

  @override
  String get keygenKeyGeneratedTitle => 'Key Generated';

  @override
  String get keygenKeyGeneratedBody => 'Here is your account details. Please ensure to back up your private key in a safe place.';

  @override
  String get keygenAddressLabel => 'Address';

  @override
  String get keygenMnemonicCopiedToast => 'Mnemonic copied to clipboard';

  @override
  String get keygenPublicKeyCopiedToast => 'Public key copied to clipboard';

  @override
  String get keygenPrivateKeyCopiedToast => 'Private key copied to clipboard';

  @override
  String get keygenDone => 'Done';

  @override
  String get keygenImportPrivateKey => 'Import Private Key';

  @override
  String get keygenGenerateKeypair => 'Generate Keypair';

  @override
  String get keygenRecoverAccount => 'Recover Account';

  @override
  String get votingTitle => 'Validator Voting Topics';

  @override
  String get votingCreateTopic => 'Create Topic';

  @override
  String get votingTabActive => 'Active';

  @override
  String get votingTabInactive => 'Inactive';

  @override
  String get votingTabVoted => 'Voted';

  @override
  String get votingTabNotVoted => 'Not Voted';

  @override
  String get votingTabAll => 'All';

  @override
  String get votingTabMyTopics => 'My Topics';

  @override
  String get votingCreateTopicTitle => 'Create Topic';

  @override
  String get votingError => 'Error';

  @override
  String get chatTitle => 'Chats';

  @override
  String get chatTitleSingle => 'Chat';

  @override
  String chatChattingWith(String name) {
    return 'Chatting with $name';
  }

  @override
  String chatWithAddress(String address) {
    return 'Chat with $address';
  }

  @override
  String get chatNoChats => 'No Chats';

  @override
  String get chatSendHint => 'Send message...';

  @override
  String get chatDeleteThread => 'Delete Chat Thread';

  @override
  String get chatErrorTitle => 'Error';

  @override
  String get beaconTitle => 'Beacons';

  @override
  String get beaconAddRemote => 'Add Remote Beacon';

  @override
  String get beaconCreateHost => 'Create / Host Beacon';

  @override
  String get beaconAddTitle => 'Add Beacon';

  @override
  String get beaconCreateTitle => 'Create Beacon';

  @override
  String get beaconCreatedTitle => 'Beacon Created';

  @override
  String get beaconNameLabel => 'Beacon Name';

  @override
  String get beaconIpLabel => 'IP Address';

  @override
  String get beaconPortLabel => 'Port (leave blank for default)';

  @override
  String get beaconRetainDaysLabel => 'Days to retain files (0 for unlimited)';

  @override
  String get beaconMakePrivate => 'Make Private';

  @override
  String get beaconAutoDelete => 'Auto Delete After Download';

  @override
  String get beaconCancel => 'Cancel';

  @override
  String get beaconAdd => 'Add';

  @override
  String get beaconCreate => 'Create';

  @override
  String get beaconRemove => 'Remove';

  @override
  String get beaconRemoveTitle => 'Remove Beacon';

  @override
  String get beaconNoBeacons => 'No Beacons';

  @override
  String get beaconRemoteBadge => 'Remote';

  @override
  String get faucetTitle => 'VFX Faucet';

  @override
  String get faucetChooseAccount => 'Please choose a VFX account to continue';

  @override
  String get faucetVerificationCodeLabel => 'Verification Code';

  @override
  String get faucetVerify => 'Verify';

  @override
  String get faucetAmountLabel => 'Amount';

  @override
  String faucetAmountSuffix(String amount) {
    return 'Amount: $amount VFX';
  }

  @override
  String get faucetPhoneLabel => 'Phone Number';

  @override
  String get faucetCancel => 'Cancel';

  @override
  String get faucetRequestVfx => 'Request VFX';

  @override
  String get encryptUnlockedToast => 'Account unlocked!';

  @override
  String get encryptIncorrectPasswordToast => 'Incorrect account decryption password';

  @override
  String get encryptPasswordHint => 'Account Password';

  @override
  String get motherDashboardTitle => 'MOTHER Dashboard';

  @override
  String get motherAddHostTitle => 'Add Host';

  @override
  String get motherAddHostBody => 'Set the IP address and password set of your MOTHER HOST.';

  @override
  String get motherIpHostLabel => 'IP Address of HOST';

  @override
  String get motherPasswordHostLabel => 'Password set on HOST';

  @override
  String get motherHostNameLabel => 'Host Name';

  @override
  String get motherCreatePasswordLabel => 'Create Password';

  @override
  String get motherCliRestartTitle => 'CLI Restart Required';

  @override
  String get motherChildBalance => 'Balance';

  @override
  String get motherChildIpAddress => 'IP Address';

  @override
  String get motherChildBlockHeight => 'Block Height';

  @override
  String get motherChildIsValidating => 'Is Validating?';

  @override
  String get motherChildIsConnected => 'Is Connected to Mother?';

  @override
  String get motherOpenInExplorer => 'Open in Explorer';

  @override
  String get motherClose => 'Close';

  @override
  String get motherLaunchHost => 'Launch MOTHER';

  @override
  String get motherStopHost => 'Stop Host';

  @override
  String get motherStopHostConfirmTitle => 'Stop MOTHER Host?';

  @override
  String get motherSetWalletRemote => 'Set Wallet as Remote';

  @override
  String get motherStopRemote => 'Stop Remote';

  @override
  String get adjudicatorTitle => 'Adjudicator';

  @override
  String get adjudicatorNoAccountSelected => 'No account selected';

  @override
  String get adjudicatorStart => 'Start Adjudicating';

  @override
  String get adjudicatorStop => 'Stop Adjudicating';

  @override
  String adjudicatorIsAdjudicating(String label) {
    return '$label  is Adjudicating...';
  }

  @override
  String adjudicatorPortOpen(String port) {
    return 'Port $port is open!';
  }

  @override
  String adjudicatorPortClosed(String port) {
    return 'Port $port is NOT open. Please configure your firewall.';
  }

  @override
  String get datanodeTitle => 'Datanode';

  @override
  String get datanodeActivatingSoon => 'Activating soon.';

  @override
  String get operationsTitle => 'Operations';

  @override
  String get operationsActivityLog => 'Activity Log';

  @override
  String get operationsStatus => 'Status';

  @override
  String get operationsDocs => 'Docs';

  @override
  String get operationsBlockchainVersion => 'Blockchain Version';

  @override
  String get operationsCliVersion => 'CLI Version';

  @override
  String get operationsBlockHeight => 'Block Height';

  @override
  String get operationsPeers => 'Peers (In / Out)';

  @override
  String get operationsWalletStarted => 'Wallet Started';

  @override
  String get operationsNetworkMetrics => 'Network Metrics';

  @override
  String get operationsViewMetrics => 'View Metrics';

  @override
  String operationsActiveValidators(String value) {
    return 'Active Validators: $value';
  }

  @override
  String get votingMustBeValidatorToCreate => 'Your active account must be a validator to create a topic.';

  @override
  String get votingOnlyOneActive => 'Only one active topic per address is allowed.';

  @override
  String get votingBalanceRequired => 'A balance is required';

  @override
  String get votingInsufficientForValidate => 'Balance will not be sufficient to validate due to the cost of creating a topic (1 VFX + fee)';

  @override
  String get votingCategoryLabel => 'Category';

  @override
  String get votingEndsLabel => 'Voting Ends';

  @override
  String get votingTopicNameLabel => 'Topic Name';

  @override
  String get votingTopicDescriptionLabel => 'Topic Description';

  @override
  String get votingCharLimit128 => '128 character limit';

  @override
  String get votingCharLimit1600 => '1,600 character limit including provided links';

  @override
  String get votingDiscardTitle => 'Discard';

  @override
  String get votingDiscardBody => 'Are you sure you want to discard this new topic?';

  @override
  String votingCreateTopicConfirmBody(String cost) {
    return 'There is a cost of $cost VFX to create a topic.';
  }

  @override
  String get votingCreateAction => 'Create';

  @override
  String get votingTopicCreatedToast => 'Topic created';

  @override
  String get votingSearchHint => 'Search...';

  @override
  String votingEndedOn(String date) {
    return 'Voting Ended on $date.';
  }

  @override
  String get votingMustHaveAccountToVote => 'Must have an account selected to vote.';

  @override
  String get votingMustBeValidatorToVote => 'You must be a validator to vote.';

  @override
  String votingAlreadyVotedPending(String label) {
    return 'You voted $label. Transaction is pending.';
  }

  @override
  String votingAlreadyVoted(String label, String block) {
    return 'You voted $label on block $block';
  }

  @override
  String get votingPendingTx => 'Vote transaction pending.';

  @override
  String get votingCastYourVote => 'Cast Your Vote';

  @override
  String get votingVoteYes => 'Vote Yes';

  @override
  String get votingVoteNo => 'Vote No';

  @override
  String get votingConfirmYesTitle => 'Confirm Vote [YES]';

  @override
  String get votingConfirmYesBody => 'Are you sure you want to vote YES on this topic?';

  @override
  String get votingConfirmYesAction => 'Vote YES';

  @override
  String get votingConfirmNoTitle => 'Confirm Vote [NO]';

  @override
  String get votingConfirmNoBody => 'Are you sure you want to vote NO on this topic?';

  @override
  String get votingConfirmNoAction => 'Vote NO';

  @override
  String votingEndsAt(String date) {
    return 'Voting ends $date.';
  }

  @override
  String get votingNoVotesYet => 'No votes yet.';

  @override
  String get votingVoteCounts => 'Vote Counts';

  @override
  String get votingVotesYes => 'Votes Yes';

  @override
  String get votingVotesNo => 'Votes No';

  @override
  String get votingTotalVotes => 'Total Votes';

  @override
  String get votingPercentages => 'Percentages';

  @override
  String get votingResult => 'Result';

  @override
  String get votingInProgress => 'In Progress';

  @override
  String get votingPass => 'Pass';

  @override
  String get votingFail => 'Fail';

  @override
  String get votingShowHistory => 'Show History';

  @override
  String get votingTopicCreatedLabel => 'Topic Created';

  @override
  String votingBlockHeightDetail(String value) {
    return 'Block Height: $value';
  }

  @override
  String votingTopicOwner(String address) {
    return 'Topic Owner: $address';
  }

  @override
  String votingUid(String uid) {
    return 'UID: $uid';
  }

  @override
  String get votingCatGeneral => 'General';

  @override
  String get votingCatCodeChange => 'Code Change';

  @override
  String get votingCatAddDeveloper => 'Add Developer';

  @override
  String get votingCatRemoveDeveloper => 'Remove Developer';

  @override
  String get votingCatNetworkChange => 'Network Change';

  @override
  String get votingCatAdjVoteIn => 'Adj Vote In';

  @override
  String get votingCatAdjVoteOut => 'Adj Vote Out';

  @override
  String get votingCatValidatorChange => 'Validator Change';

  @override
  String get votingCatBlockModify => 'Block Modify';

  @override
  String get votingCatTransactionModify => 'Transaction Modify';

  @override
  String get votingCatBalanceCorrection => 'Balance Correction';

  @override
  String get votingCatHackOrExploit => 'Hack or Exploit Correction';

  @override
  String get votingCatOther => 'Other';

  @override
  String get votingDays30 => '30 Days';

  @override
  String get votingDays60 => '60 Days';

  @override
  String get votingDays90 => '90 Days';

  @override
  String get votingDays180 => '180 Days';

  @override
  String get votingProviderOnlineCloud => 'Online Cloud VPS';

  @override
  String get votingProviderOnlineDedicated => 'Online Dedicated';

  @override
  String get votingProviderLocalDedicated => 'Local Dedicated';

  @override
  String get votingProviderHomeMachine => 'Home Machine';

  @override
  String get votingProviderOfficeMachine => 'Office Machine';

  @override
  String get votingOsLinux => 'Linux';

  @override
  String get votingOsWindows => 'Windows';

  @override
  String get votingOsMac => 'Mac';

  @override
  String get beaconRemoveBody => 'Are you sure you want to remove this beacon?';

  @override
  String get beaconRemoveSelfBody => 'Are you sure you want to remove this beacon?\n\nA CLI restart is required.';

  @override
  String get beaconRemoveAndRestart => 'Remove & Restart CLI';

  @override
  String get beaconCreateBodyExplanation => 'Create a beacon if you want to be the owner of the relay of assets. Setup your wallet as a beacon to participate in media transferring on the VFX network. The name is a friendly name only visible to you. You can configure a specific port or just use the default setting. You can also configure whether your beacon is private and how long assets should remain cached.';

  @override
  String get beaconAddBodyExplanation => 'Add an existing beacon to foreign nodes to use that relay instead of default ones on the VFX network. Configure your wallet to use a remote beacon for media transferring rather than using the default VFX network beacons. You will need to know the IP address of the remote beacon. If that beacon is using the non-default port, provide that as well. The beacon name is a friendly name visible only to you.';

  @override
  String get beaconCreatedBody => 'A CLI restart is required for this to take effect.\n\nRestart Now?';

  @override
  String get beaconActiveBadge => 'Active';

  @override
  String get beaconInactiveBadge => 'Inactive';

  @override
  String get beaconErrorOnePerWallet => 'Only one beacon per wallet allowed.';

  @override
  String get beaconRestartNow => 'Restart';

  @override
  String get beaconLater => 'Later';

  @override
  String get beaconAutoDeleteAssets => 'Auto Delete Assets';

  @override
  String get beaconAssetCache => 'Asset Cache';

  @override
  String get beaconCacheInfinite => 'Infinite';

  @override
  String get beaconPrivateLabel => '[Private]';

  @override
  String get navMenuPayWithButterfly => 'Pay /w Butterfly';

  @override
  String get navMenuCryptoCom => 'Crypto.com';

  @override
  String get navMenuOperations => 'Operations';

  @override
  String get navMenuSignOut => 'Sign Out';

  @override
  String get navMenuVaultAccountSingular => 'Vault Account';

  @override
  String get navSignOutTitle => 'Sign Out';

  @override
  String get navSignOutBody => 'Are you sure you want to logout of the VFX Web Wallet?';

  @override
  String get navLatestTx => 'Latest TX:';

  @override
  String get navViewAllTxs => 'View All Txs';

  @override
  String get navNoTransactions => 'No Transactions';

  @override
  String get navConfirmedStatus => 'Confirmed';

  @override
  String get navPendingStatus => 'Pending';

  @override
  String get navViewAddress => 'View\nAddress';

  @override
  String get navViewAddresses => 'View\nAddresses';

  @override
  String get navNewAddress => 'New\nAddress';

  @override
  String get navGetVfx => 'Get\nVFX';

  @override
  String get navGetBtc => 'Get\nBTC';

  @override
  String navAddressSingular(String count) {
    return '$count Address';
  }

  @override
  String navAddressPlural(String count) {
    return '$count Addresses';
  }

  @override
  String navVaultAddressSingular(String count) {
    return '$count Vault Address';
  }

  @override
  String navVaultAddressPlural(String count) {
    return '$count Vault Addresses';
  }

  @override
  String navAccountSingular(String count) {
    return '$count Account';
  }

  @override
  String navAccountPlural(String count) {
    return '$count Accounts';
  }

  @override
  String get navNoVfxAccounts => 'No VFX Accounts';

  @override
  String get navNoBtcAccounts => 'No BTC Accounts';

  @override
  String get navNoAccounts => 'No Accounts';

  @override
  String get navNew => 'NEW';

  @override
  String get webRevealPrivateKeyBody => 'Are you sure you want to reveal your private key?';

  @override
  String get webRevealPrivateKeyAccountBody => 'Are you sure you want to reveal your private key for this account?';

  @override
  String get webReveal => 'Reveal';

  @override
  String webFundVaultBody(String address) {
    return 'Would you like to send 5 VFX from $address?';
  }

  @override
  String get webAutoActivateBody => 'Would you like to activate the account automatically once the funding is complete?';

  @override
  String webSent5Vfx(String address) {
    return '5 VFX sent to $address';
  }

  @override
  String webRecoverFundsBody(String address) {
    return 'This is a destructive function that will callback all pending transactions and assets and move everything to this recovery address:\n\n$address';
  }

  @override
  String get webProceed => 'Proceed';

  @override
  String get webRestoreVaultBody => 'Importing an existing Vault Account will replace the current one tied to your login. To revert you can logout and login again.\n\nContinue?';

  @override
  String get webRestoreCodeBody => 'Paste in your RESTORE CODE to import your existing Vault Account.';

  @override
  String get webCalledBack => 'Called Back';

  @override
  String get webCallbackBody => 'Are you sure you want to callback this transaction?';

  @override
  String get webErrorTimestamp => 'Failed to retrieve timestamp';

  @override
  String get webErrorNonce => 'Failed to retrieve nonce';

  @override
  String get webErrorFee => 'Failed to parse fee';

  @override
  String get webErrorHash => 'Failed to parse hash';

  @override
  String get webErrorSignatureGen => 'Signature generation failed.';

  @override
  String get webErrorSignatureInvalid => 'Signature not valid';

  @override
  String get webErrorTxInvalid => 'Transaction not valid';

  @override
  String get webErrorRecoverySig => 'Problem generating RecoverySigScript';

  @override
  String get webSelectAccount => 'Select Account';

  @override
  String get webAddBtcAccount => 'Add BTC Account';

  @override
  String get webImportBtcWifTitle => 'Import BTC WIF Private Key';

  @override
  String get webWifPrivateKey => 'WIF Private Key';

  @override
  String get webImport => 'Import';

  @override
  String get webBtcAccountImported => 'BTC Account Imported';

  @override
  String get webManageAccounts => 'Manage Accounts';

  @override
  String get webDefaultAccount => 'Default Account';

  @override
  String webAccountN(String id) {
    return 'Account $id';
  }

  @override
  String get webRenameAccountTitle => 'Rename Account';

  @override
  String get webAccountName => 'Account Name';

  @override
  String get webRenameAccountBody => 'What would you like to name this account?';

  @override
  String get webLockWallet => 'Lock Wallet';

  @override
  String webForgetTitle(String id) {
    return 'Forget Account $id';
  }

  @override
  String get webForgetBody => 'Are you sure you want to remove this account from your wallet?';

  @override
  String get webForgetBodyLastAccount => 'Are you sure you want to remove this account from your wallet? Since you have no other accounts, you will be logged out.';

  @override
  String get webForget => 'Forget';

  @override
  String get webForgetAndLogout => 'Forget & Logout';

  @override
  String get webBackupKeys => 'Backup Keys';

  @override
  String get webSetActive => 'Set Active';

  @override
  String get webScanCameraError => 'Camera Error';

  @override
  String get webScanRetry => 'Retry';

  @override
  String get webScanScanning => 'Scanning...';

  @override
  String get webScanCameraRequired => 'Camera access required to scan QR codes';

  @override
  String get webScanInstruction => 'Position QR code within the frame to scan';

  @override
  String webBalanceTooltip(String available, String locked, String total) {
    return 'Available: $available VFX\nLocked: $locked VFX \nTotal: $total RBX';
  }

  @override
  String get motherTitle => 'Monitor Of The Roster';

  @override
  String get motherDescription => 'MOTHER is a tool for monitoring the state of your remote validators.';

  @override
  String get motherStatusHeading => 'Status';

  @override
  String motherIsHostRow(String value) {
    return 'Is Host: $value';
  }

  @override
  String motherIsRemoteRow(String value) {
    return 'Is Remote: $value';
  }

  @override
  String motherChildrenRow(String count) {
    return 'Children: $count';
  }

  @override
  String get motherYes => 'YES';

  @override
  String get motherNo => 'NO';

  @override
  String get motherChildYes => 'Yes';

  @override
  String get motherChildNo => 'No';

  @override
  String get motherUpdateHostInfo => 'Update Host Info';

  @override
  String get motherSetWalletHost => 'Set Wallet as Host';

  @override
  String get motherStop => 'Stop';

  @override
  String get motherStopHostBody => 'Are you sure you want to stop running this wallet as a MOTHER host?';

  @override
  String get motherCliRestartBody => 'Would you like to restart now?';

  @override
  String get motherStopRemoteBody => 'Are you sure you want to remove this node as a REMOTE?\n\nA CLI restart will be required.';

  @override
  String get motherStopRemoteAction => 'Stop Remote & Restart CLI';

  @override
  String get motherRemoteRemoved => 'REMOTE node has been removed from MOTHER';

  @override
  String get motherWhatIs => 'What is MOTHER?';

  @override
  String motherInfoBody(String port) {
    return 'MOTHER is a tool for monitoring the state of your remote validators.\n\nFirst you must setup one of your wallets as the HOST and then add your additional node as a REMOTE.\n\nWhen adding a REMOTE node, you will need to know the IP address and the password for the HOST.\n\nOnce complete, you\'ll be able to view a dashboard tracking all of your node\'s activity from one wallet.\n\nNote: you must have port \'$port\' open on the HOST machine.';
  }

  @override
  String get motherIpRequired => 'IP Address Required';

  @override
  String get motherPasswordRequired => 'Password Required';

  @override
  String get motherNameRequired => 'Name Required';

  @override
  String motherPortNote(String port) {
    return 'You must have port \'$port\' open on the HOST machine.';
  }

  @override
  String get motherHostCreated => 'Host Created';

  @override
  String get motherOpenInBrowser => 'Open in Browser';

  @override
  String get homeActionTokens => 'Tokens';

  @override
  String get homeActionTutorials => 'Tutorials';

  @override
  String get homeActionGetHelp => 'Get\nHelp';

  @override
  String get homeActionOpenExplorer => 'Open\nExplorer';

  @override
  String get homeActionVerifyOwner => 'Verify\nOwner';

  @override
  String get homeActionSignOut => 'Sign\nOut';

  @override
  String get homeGetHelpTitle => 'Get Help';

  @override
  String get homeJoinDiscord => 'Join Discord';

  @override
  String get homeVisitWebsite => 'Visit Website';

  @override
  String get homeReadDocs => 'Read Docs';

  @override
  String get homeValidateOwnership => 'Validate Ownership';

  @override
  String get homeValidateOwnershipBody => 'Paste in the signature provided by the owner to validate its ownership.';

  @override
  String get homeSignatureLabel => 'Signature';

  @override
  String get homeInvalidSignature => 'Invalid ownership verification signature';

  @override
  String get homeVerified => 'Verified';

  @override
  String get homeNotVerified => 'Not Verified';

  @override
  String get homeOwnershipVerified => 'Ownership Verified';

  @override
  String get homeOwnershipNotVerified => 'Ownership NOT Verified';

  @override
  String get homeOwns => 'OWNS';

  @override
  String get homeDoesNotOwn => 'does NOT own';

  @override
  String get webAddressesLabel => 'Addresses';

  @override
  String get webVaultLabel => 'Vault';

  @override
  String get webRecoveredDeactivated => 'Recovered & Deactivated';

  @override
  String get webCopyAddressPopup => 'Copy Address';

  @override
  String get webRevealPrivateKeyPopup => 'Reveal Private Key';

  @override
  String webBlockHeight(String height) {
    return 'Block $height';
  }

  @override
  String webTokensCount(String count) {
    return '$count Tokens';
  }

  @override
  String get dashCopyAddress => 'Copy\nAddress';

  @override
  String get dashVaultAddress => 'Vault\nAddress';

  @override
  String get dashGetVfx => 'Get\nVFX';

  @override
  String get dashGetBtc => 'Get\nBTC';

  @override
  String get dashOffRampBtc => 'Off Ramp\nBTC';

  @override
  String get dashVbtcTokens => 'vBTC\nTokens';

  @override
  String get dashWhatsVbtc => 'What\'s\nvBTC';

  @override
  String get statusSuccess => 'Success';

  @override
  String txFromColonAddress(String address) {
    return 'From: $address';
  }

  @override
  String txToColonAddress(String address) {
    return 'To: $address';
  }

  @override
  String get webAddressesAddressCopiedDot => 'Address copied to clipboard.';

  @override
  String get butterflyCreatePassword => 'Create Butterfly Password';

  @override
  String get butterflyPasswordMessage => 'Create a password to securely transfer your credentials to Butterfly. You will need to enter this same password on the Butterfly website.';

  @override
  String get butterflyLoginTitle => 'Login to Butterfly';

  @override
  String butterflyLoginBody(String address) {
    return 'You are about to open Butterfly and log in with:\n\n$address\n\nContinue?';
  }

  @override
  String get butterflyOpenButton => 'Open Butterfly';

  @override
  String get butterflyNoWalletError => 'No wallet selected. Please create or import a wallet first.';

  @override
  String butterflyLoginUrlError(String error) {
    return 'Failed to generate login URL: $error';
  }

  @override
  String get navPrivateKeyNotAvailable => 'Private key not available.';

  @override
  String get webAddAccount => 'Add Account';

  @override
  String get webLanguageLabel => 'Language';

  @override
  String get webYourAddress => 'Your Address';

  @override
  String get webYourDomain => 'Your Domain';

  @override
  String get webCopyLink => 'Copy\nLink';

  @override
  String get webQrCode => 'QR\nCode';

  @override
  String get webRequestFunds => 'Request Funds';

  @override
  String get webRequestFundsBody => 'Generate a URL to send to another user.';

  @override
  String get webAmountToRequest => 'Amount to request';

  @override
  String get webGenerateLink => 'Generate Link';

  @override
  String get webRequestLinkCopied => 'Request funds link copied to clipboard';

  @override
  String webCopiedToClipboard(String value) {
    return '\'$value\' Copied to clipboard';
  }

  @override
  String get webInvalidAmount => 'Invalid amount';

  @override
  String get segmentAll => 'All';

  @override
  String get segmentVault => 'Vault';

  @override
  String get dialogClose => 'Close';

  @override
  String get dialogYes => 'Yes';

  @override
  String get dialogNo => 'No';

  @override
  String get dialogSubmit => 'Submit';

  @override
  String get govAdjAdditionalLinksLabel => 'Additional Links: ';

  @override
  String get govAdjBandwidthLabel => 'Bandwidth (TB): ';

  @override
  String get govAdjBandwidthUnlimited => 'Unlimited';

  @override
  String get govAdjCpuCoresLabel => 'CPU Cores: ';

  @override
  String get govAdjCpuLabel => 'CPU: ';

  @override
  String get govAdjCpuThreadsLabel => 'CPU Threads: ';

  @override
  String get govAdjGithubLinkLabel => 'Github Link: ';

  @override
  String get govAdjHdSizeLabel => 'HD Size: ';

  @override
  String get govAdjInternetDownLabel => 'Internet Speed down(Gbps): ';

  @override
  String get govAdjInternetUpLabel => 'Internet Speed up(Gbps): ';

  @override
  String get govAdjIpAddressLabel => 'Adjudicator to be Ip Address: ';

  @override
  String get govAdjMachineProviderLabel => 'Machine Provider: ';

  @override
  String get govAdjMachineTypeLabel => 'Machine type: ';

  @override
  String get govAdjOperatingSystemLabel => 'Operating System: ';

  @override
  String get govAdjRamLabel => 'RAM (GB): ';

  @override
  String get govAdjReasonLabel => 'Reasons to be added as adjudicator: ';

  @override
  String get govAdjTechnicalBackgroundLabel => 'Technical background: ';

  @override
  String get govAdjVfxAddressLabel => 'Adjudicator to be VFX Address: ';

  @override
  String govVoteBlock(int height) {
    return 'Block $height';
  }

  @override
  String get hnavActivatingSoon => 'Activating soon.';

  @override
  String get hnavAgreeAndClose => 'Agree and Close';

  @override
  String get hnavAllMyTokens => 'All My Tokens';

  @override
  String hnavBackupKeysSubtitle(String vaultSuffix) {
    return 'Export and save all your VFX$vaultSuffix and BTC private keys & addresses to a text file.';
  }

  @override
  String get hnavBackupLabel => 'Backup';

  @override
  String get hnavBackupMediaSubtitle => 'Zip and export your NFT media assets.';

  @override
  String hnavBlockNumber(String height) {
    return 'Block $height';
  }

  @override
  String get hnavBtcInactive => 'BTC Inactive';

  @override
  String get hnavBtcLoading => 'BTC Loading';

  @override
  String get hnavBtcLoginWarningBody => 'Although if you login with a BTC Private key, if this key was generated originally with a different login mechanism, your VFX/Vault account keypairs will not match with your previous login since private keys are not reversable.';

  @override
  String get hnavBtcOffline => 'BTC Offline';

  @override
  String get hnavBtcOnline => 'BTC Online';

  @override
  String get hnavCliInactive => 'CLI Inactive';

  @override
  String get hnavCloseRecoveryPhraseBody => 'Are you sure you have copied your recovery phrase to a secure location?';

  @override
  String get hnavCloseRecoveryPhraseTitle => 'Close Recovery Phrase?';

  @override
  String get hnavConfigAccountUnlockTime => 'Account Unlock Time';

  @override
  String get hnavConfigAllowedExtensionTypes => 'Allowed Extension Types';

  @override
  String get hnavConfigApiCallUrl => 'Api Call Url';

  @override
  String get hnavConfigApiPort => 'Api Port';

  @override
  String get hnavConfigAutoDownloadNft => 'Auto Download NFT Assets';

  @override
  String get hnavConfigHeader => 'Configuration';

  @override
  String get hnavConfigIgnoreIncomingNfts => 'Ignore Incoming NFTs';

  @override
  String get hnavConfigMotherAddress => 'Mother Address';

  @override
  String get hnavConfigMotherPassword => 'Mother Password';

  @override
  String get hnavConfigNftTimeout => 'NFT Timeout';

  @override
  String get hnavConfigPasswordClearTime => 'Password Clear Time';

  @override
  String get hnavConfigRejectedExtensionTypes => 'Rejected Asset Extension Types';

  @override
  String get hnavConfirmCreateMnemonicBody => 'Are you sure you want to create a Mnemonic account?';

  @override
  String get hnavCopyRecoveryPhraseInstruction => 'Copy your recovery phrase to a secure location.';

  @override
  String get hnavCopyToClipboard => 'Copy to Clipboard';

  @override
  String get hnavCouldNotGenerateKeypair => 'Could not generate keypair';

  @override
  String get hnavCreateNewMnemonic => 'Create New Mnemonic';

  @override
  String get hnavCurrencyAll => 'All';

  @override
  String get hnavDecryptAccountKeysBody => 'Enter the password for this account to decrypt and view its private keys.';

  @override
  String get hnavDecryptionFailedCheckPassword => 'Decryption failed. Check your password.';

  @override
  String get hnavEncryptGeneratedMnemonicMessage => 'This password will encrypt your generated mnemonic keys.';

  @override
  String get hnavEncryptImportedBtcPrivateKeyMessage => 'This password will encrypt your imported BTC private key.';

  @override
  String get hnavEncryptImportedPrivateKeyMessage => 'This password will encrypt your imported private key.';

  @override
  String get hnavEncryptRecoveredMnemonicMessage => 'This password will encrypt your recovered mnemonic keys.';

  @override
  String get hnavEnterAccountPasswordTitle => 'Enter Account Password';

  @override
  String get hnavEnterBtcAddressHint => 'Enter your BTC address';

  @override
  String get hnavEnterBtcPrivateKeyOrWif => 'Enter your BTC Private Key or WIF Key:';

  @override
  String get hnavEnterPrivateKeyHint => 'Enter your private key';

  @override
  String get hnavEnterWalletPasswordTitle => 'Enter Wallet Password';

  @override
  String get hnavExtensionDecryptPasswordBody => 'Enter the password you used in the VFX Extension to decrypt your private key.';

  @override
  String get hnavExtensionNotDetected => 'VFX Extension not detected';

  @override
  String get hnavExtensionUnlockFirst => 'Please unlock your extension wallet first';

  @override
  String get hnavExtensionWebOnly => 'VFX Extension is only available on web';

  @override
  String get hnavFailedDecryptAccountKeys => 'Failed to decrypt account keys. Check your password.';

  @override
  String get hnavFungibleToken => 'Fungible Token';

  @override
  String hnavFungibleTokenWithBalance(String balance, String ticker) {
    return 'Fungible Token ($balance $ticker)';
  }

  @override
  String get hnavHd12Words => '12 Words';

  @override
  String get hnavHd24Words => '24 Words';

  @override
  String get hnavHdAccountTitle => 'HD Account';

  @override
  String get hnavHdCreateAccount => 'Create HD Account';

  @override
  String get hnavHdEncryptedError => 'You can not create an HD account with an encrypted wallet.';

  @override
  String get hnavHdExplanation1 => 'By creating an HD account you are creating a function to recover your private keys by use of recovery phrase.';

  @override
  String get hnavHdExplanation2 => 'Once generated, any keys you create will use this phrase to seed the private key generation. Therefore, you will only need to remember this to deterministically recover your keys.';

  @override
  String get hnavHdExplanation3 => 'This is an advanced feature and is not recommended unless you are familiar with Hierarchical Deterministic concepts.\n\nAny keys created prior to this will not be recoverable through this phrase so please ensure they are backed up as well.';

  @override
  String get hnavHdGenerateStrength => 'Generate with strength:';

  @override
  String get hnavIDontKnow => 'I don\'t know';

  @override
  String get hnavImportBtcPrivateKeyOrWifTitle => 'Import BTC Private Key or WIF Key';

  @override
  String get hnavInvalidBtcAddress => 'Invalid BTC Address';

  @override
  String get hnavInvalidPrivateKeyOrWif => 'Not a valid Private Key or WIF Key. Should be 64 or 52 characters';

  @override
  String hnavIsAdjudicating(String label) {
    return '$label is Adjudicating...';
  }

  @override
  String get hnavKeysBackedUpSuccess => 'Keys backed up successfully.';

  @override
  String get hnavMediaBackedUpSuccess => 'Media backed up successfully.';

  @override
  String get hnavMempool => 'Mempool';

  @override
  String get hnavMempoolEmpty => 'Mempool is empty.';

  @override
  String get hnavMnemonicTitle => 'Mnemonic';

  @override
  String get hnavNoTokensEmptyState => 'You have no vBTC Tokens, Fungible Tokens, or Non-Fungible Tokens';

  @override
  String get hnavNoWalletDetected => 'No Wallet detected.';

  @override
  String get hnavNonFungibleToken => 'Non-Fungible Token';

  @override
  String get hnavNoticeTitle => 'Notice';

  @override
  String get hnavPasteBtcAddress => 'Paste your BTC address:';

  @override
  String hnavPortNotOpen(String port) {
    return 'Port $port is NOT open. Please configure your firewall.';
  }

  @override
  String hnavPortOpen(String port) {
    return 'Port $port is open!';
  }

  @override
  String get hnavProposalsVoting => 'Proposals & Voting';

  @override
  String get hnavRecoverFromMnemonic => 'Recover From Mnemonic';

  @override
  String get hnavRecoveryPhraseGeneratedTitle => 'Recovery Phrase Generated';

  @override
  String get hnavRequestCancelled => 'Request cancelled';

  @override
  String get hnavRequestTimedOut => 'Request timed out';

  @override
  String get hnavReserveAccountsNotExported => 'Please note that Reserve/Protected Accounts will not be exported.';

  @override
  String get hnavRestoreHiddenBracket => '[Restore Hidden]';

  @override
  String get hnavResyncing => 'Resyncing...';

  @override
  String get hnavRevealPrivateKeysPasswordMessage => 'Enter your password to reveal private keys.';

  @override
  String get hnavRevealVaultKeysPasswordMessage => 'Enter your password to reveal Vault account private keys.';

  @override
  String get hnavSectionAccountSecurity => 'Account Security';

  @override
  String get hnavSectionDiagnose => 'Diagnose';

  @override
  String get hnavSectionTokensNfts => 'Tokens / NFTs';

  @override
  String get hnavSectionValidator => 'Validator';

  @override
  String get hnavSelectAddressType => 'Select your address type:';

  @override
  String get hnavSelectedBtcAccountTooltip => 'Selected BTC Account';

  @override
  String get hnavSelectedVfxAddressTooltip => 'Selected VFX Address';

  @override
  String get hnavSetEncryptionPasswordTitle => 'Set Encryption Password';

  @override
  String hnavShowKeysAccountDetailsBody(String currencySuffix) {
    return 'Here are your$currencySuffix account details. Please ensure to back up your private key in a safe place.';
  }

  @override
  String get hnavSnapshotAllDone => 'All done!';

  @override
  String get hnavSnapshotDownloading => 'Downloading...';

  @override
  String hnavSnapshotDownloadingFile(String file) {
    return 'Downloading: $file';
  }

  @override
  String get hnavSnapshotError => 'An error occurred. Please restart and try again.';

  @override
  String get hnavSnapshotImported => 'Database Snapshot Imported.';

  @override
  String get hnavSnapshotInitializing => 'Initializing...';

  @override
  String get hnavSnapshotShuttingDown => 'Shutting down CLI...';

  @override
  String get hnavSnapshotStartingUp => 'Starting up CLI now...';

  @override
  String get hnavStartAdjudicating => 'Start Adjudicating';

  @override
  String get hnavStopAdjudicating => 'Stop Adjudicating';

  @override
  String get hnavSynced => 'Synced';

  @override
  String get hnavSyncing => 'Syncing...';

  @override
  String get hnavValidating => 'Validating...';

  @override
  String get hnavVaultAccountDetailsBody => 'Here are your Vault Account details. Please ensure to back up your private key in a safe place.';

  @override
  String get hnavVaultAccountDetailsTitle => 'Vault Account Details';

  @override
  String get hnavVaultSuffix => ' Vault';

  @override
  String hnavVbtcTokenWithBalance(String balance) {
    return 'vBTC Token ($balance vBTC)';
  }

  @override
  String get hnavVfxCliLoading => 'VFX CLI Loading';

  @override
  String get hnavVfxCliOffline => 'VFX CLI Offline';

  @override
  String get hnavVfxOnline => 'VFX Online';

  @override
  String get hnavWalletPasswordLabel => 'Wallet Password';

  @override
  String get hnavWarningTitle => 'Warning';

  @override
  String get mktAddReservePrice => 'Add Reserve Price';

  @override
  String get mktAuction => 'Auction';

  @override
  String mktAuctionActivityForTitle(String name) {
    return 'Auction Activity for $name';
  }

  @override
  String get mktAuctionAlreadyStartedToast => 'The auction has already started.';

  @override
  String get mktAuctionFloorPriceLabel => 'Auction Floor Price';

  @override
  String get mktAuctionNotLiveToast => 'Auction is not live';

  @override
  String get mktAuctionOverToast => 'Auction is over';

  @override
  String get mktAuctionReservePriceLabel => 'Auction Reserve Price';

  @override
  String get mktAuctionStartedDatesLocked => 'Auction has started so the dates & times can\'t be updated.';

  @override
  String get mktAuctionStartedPricingLocked => 'Auction has started so the pricing can\'t be updated.';

  @override
  String get mktBidAmountLabel => 'Bid Amount (VFX)';

  @override
  String mktBidIncrementToast(String increment, String minimum) {
    return 'The minimum increment amount is $increment VFX. A bid greater than $minimum VFX is required.';
  }

  @override
  String get mktBidInsufficientBody => 'You don\'t have enough balance to cover this bid.\n\nWould you like to pay with a Credit Card or another crypto token?';

  @override
  String mktBidMustBeGreaterFooter(String minimum) {
    return 'Must be greater than $minimum VFX';
  }

  @override
  String mktBidMustBeGreaterToast(String price) {
    return 'Your bid must be greater than the current highest bid ($price VFX)';
  }

  @override
  String get mktBidSubmittedToast => 'Bid Submitted';

  @override
  String mktBuyNowConfirmBody(String price) {
    return 'Are you sure you want to buy now for $price VFX?';
  }

  @override
  String mktBuyNowInsufficientBody(String price) {
    return 'This NFT has a buy now price of $price VFX and you don\'t have enough balance to cover it.\n\nWould you like to pay with a Credit Card or another crypto token?';
  }

  @override
  String get mktBuyNowPriceLabel => 'Buy Now Price';

  @override
  String get mktBuyNowTxBroadcastedTitle => 'Buy Now TX broadcasted.';

  @override
  String get mktBuyNowTxBroadcastedToast => 'Buy Now TX broadcasted. Please wait for it to be accepted by the shop owner';

  @override
  String get mktChooseAddressTitle => 'Choose an Address';

  @override
  String get mktCloseCreateListingTitle => 'Are you sure you want to close the listing creation screen?';

  @override
  String get mktCloseEditListingTitle => 'Are you sure you want to close the listing editing screen?';

  @override
  String get mktCollectionDeletedToast => 'Collection deleted.';

  @override
  String get mktCollectionDescriptionLabel => 'Collection Description';

  @override
  String get mktCollectionNameLabel => 'Collection Name';

  @override
  String get mktCouldNotGenerateHashToast => 'Could not generate hash';

  @override
  String get mktCouldNotGetFeeToast => 'Could not get fee';

  @override
  String get mktCouldNotGetNonceToast => 'Could not get nonce';

  @override
  String get mktCouldNotGetTimestampToast => 'Could not get timestamp';

  @override
  String get mktCouldNotProduceSignatureToast => 'Could not produce signature';

  @override
  String get mktCouldNotVerifyTransactionToast => 'Could not verify transaction';

  @override
  String get mktCreateAuctionHouseBody => 'Create your auction house / gallery and publish it to the network.\nThen you\'ll be able to create collections and add listings to them.';

  @override
  String get mktDatesHeading => 'Dates';

  @override
  String get mktDeleteChatThreadBody => 'Are you sure you want to delete this chat thread?';

  @override
  String get mktDeleteChatThreadLocalBody => 'Are you sure you want to delete this chat thread locally?';

  @override
  String get mktDeleteListing => 'Delete Listing';

  @override
  String get mktDeleteStoreConfirmBody => 'Are you sure you want to delete this store?';

  @override
  String get mktEditCollection => 'Edit Collection';

  @override
  String get mktEditListing => 'Edit Listing';

  @override
  String get mktEnableAuction => 'Enable Auction?';

  @override
  String get mktEnableBuyNow => 'Enable Buy Now?';

  @override
  String get mktEndDateLabel => 'End Date';

  @override
  String get mktEndTimeLabel => 'End Time';

  @override
  String get mktErrorOccurred => 'An error occurred.';

  @override
  String get mktGalleryOnly => 'Gallery Only?';

  @override
  String get mktInsufficientBalanceTitle => 'Insufficient Balance';

  @override
  String mktListingForTitle(String name) {
    return 'Listing for $name';
  }

  @override
  String get mktNftAlreadyListedToast => 'This NFT is already listed. Please choose another';

  @override
  String get mktNftColonLabel => 'NFT:';

  @override
  String mktNftNameLabel(String name) {
    return 'NFT: $name';
  }

  @override
  String get mktNoAccountToast => 'No Account';

  @override
  String get mktNoAuctionToast => 'No auction';

  @override
  String get mktNoBalanceToast => 'No Balance';

  @override
  String get mktNoBidsYet => 'No Bids Yet.';

  @override
  String get mktNoMessagesYet => 'No messages yet';

  @override
  String get mktNoShopToast => 'No shop';

  @override
  String get mktNoThreadToast => 'No Thread';

  @override
  String get mktNotEnoughBalanceToast => 'Not enough balance.';

  @override
  String get mktNotEnoughBalanceValidatingToast => 'Not enough balance since you are validating.';

  @override
  String get mktNotNotifiedToast => 'You will not be notified. You can update this setting on the dashboard if you change your mind.';

  @override
  String get mktOptionsHeading => 'Options';

  @override
  String get mktOwnersAddressLabel => 'Owner\'s Address';

  @override
  String get mktPayWithCardCryptoTitle => 'Pay with Credit Card / Crypto';

  @override
  String get mktPlaceBid => 'Place Bid';

  @override
  String mktPlaceBidConfirmBody(String amount) {
    return 'Are you sure you want to place a bid of $amount VFX?';
  }

  @override
  String get mktPresignProblemToast => 'A problem occurred presigning the sale transaction. Please try again';

  @override
  String get mktProblemOccurredToast => 'A problem occurred';

  @override
  String get mktPublishLive => 'Publish Live';

  @override
  String get mktReplaceNft => 'Replace NFT';

  @override
  String get mktReservePriceLabel => 'Reserve Price';

  @override
  String get mktSelectNft => 'Select NFT';

  @override
  String get mktSelectOwnerAddressHint => 'Select an address from the list to be the shop owner.';

  @override
  String get mktShopDescriptionLabel => 'Shop Description';

  @override
  String get mktShopIdentifierLabel => 'Shop Identifier';

  @override
  String get mktShopNameLabel => 'Shop Name';

  @override
  String get mktSignatureNotValidPrimaryToast => 'Signature not valid (primary)';

  @override
  String get mktStartDateLabel => 'Start Date';

  @override
  String get mktStartTimeLabel => 'Start Time';

  @override
  String get mktSubscribeUpdatesBody => 'In order for the web wallet to provide notifications to auction winners to sign transactions, an email address is required.';

  @override
  String get mktSubscribeUpdatesTitle => 'Subscribe for updates?';

  @override
  String get mktSubscribedToast => 'Subscribed';

  @override
  String get mktThirdPartySaleStartNote => 'Because this auction house is hosted on the VFX Web Wallet, the seller will need to authorize the Sale Start transaction. You will see that in your transaction list once it\'s been sent.';

  @override
  String get mktTxBroadcastedToast => 'TX Broadcasted';

  @override
  String get mktWaitForFinalizeBody => 'Please wait for the transaction to be finalized.';

  @override
  String get scwAddAFeature => 'Add a Feature';

  @override
  String get scwAddCreatorName => 'Add Creator Name';

  @override
  String get scwAddDescription => 'Add Description';

  @override
  String get scwAddEvolvingPhase => 'Add evolving phase';

  @override
  String get scwAddName => 'Add Name';

  @override
  String get scwAddProperty => 'Add property';

  @override
  String get scwAddPropertyButton => 'Add Property';

  @override
  String get scwAddRoyalty => 'Add Royalty';

  @override
  String get scwAddStat => 'Add Stat';

  @override
  String get scwAdditionalAssets => 'Additional Assets';

  @override
  String get scwAllowVoting => 'Allow Voting';

  @override
  String get scwBeneficiaryAddressOptional => 'Beneficiary Address (Optional)';

  @override
  String get scwBlockHeightValue => 'Block Height Value';

  @override
  String get scwCantAddEvolveBody => 'You already have an evolve feature in this smart contract. Edit the existing evolving feature to add more stages.';

  @override
  String get scwCantAddEvolveTitle => 'Can\'t add Evolve';

  @override
  String get scwCantAddMultiAssetBody => 'You already have a multi asset feature in this smart contract. Edit the existing multi asset feature to add more assets.';

  @override
  String get scwCantAddMultiAssetTitle => 'Can\'t add Multi Asset';

  @override
  String get scwCantAddRoyaltyBody => 'You already have a royalty feature in this smart contract.';

  @override
  String get scwCantAddRoyaltyTitle => 'Can\'t add Royalty';

  @override
  String get scwCantAddSoulBoundBody => 'You already have a soul bound feature in this smart contract.';

  @override
  String get scwCantAddSoulBoundTitle => 'Can\'t add Soul Bound';

  @override
  String get scwChoose => 'Choose';

  @override
  String get scwChooseAnAddress => 'Choose an address';

  @override
  String get scwCollectionDescription => 'Collection Description';

  @override
  String get scwCollectionName => 'Collection Name';

  @override
  String get scwCollectionThumbnail => 'Collection Thumbnail';

  @override
  String get scwCollectionWizard => 'Collection Wizard';

  @override
  String get scwColorProperty => 'Color Property';

  @override
  String get scwCreateAndMintBody => 'Start with a baseline smart contract and add customized features';

  @override
  String get scwCreateAndMintTitle => 'Create a Smart Contract & Mint';

  @override
  String get scwCreateSmartContractTitle => 'Create Smart Contract';

  @override
  String get scwCreatorName => 'Creator Name';

  @override
  String get scwCreatorRetainedOwnership => 'Creator’s Retained Ownership';

  @override
  String scwCreatorValue(String name) {
    return 'Creator: $name';
  }

  @override
  String get scwDeletePrimaryAssetBody => 'Are you sure you want to delete the primary asset?';

  @override
  String get scwDeletePrimaryAssetTitle => 'Delete Primary Asset?';

  @override
  String get scwDescription => 'Description';

  @override
  String get scwDescriptionOfPhysicalDigitalGood => 'Description of Physical/Digital Good';

  @override
  String get scwDownloadExampleCsv => 'Download Example CSV';

  @override
  String get scwDownloadExampleJson => 'Download Example JSON';

  @override
  String get scwEdit => 'Edit';

  @override
  String get scwEditCreatorName => 'Edit Creator Name';

  @override
  String get scwEditDescription => 'Edit Description';

  @override
  String get scwEditName => 'Edit Name';

  @override
  String get scwEventAddress => 'Event Address';

  @override
  String get scwEventCode => 'Event Code';

  @override
  String get scwEventDate => 'Event Date';

  @override
  String get scwEventDescription => 'Event Description';

  @override
  String get scwEventName => 'Event Name';

  @override
  String get scwEventTime => 'Event Time';

  @override
  String get scwEventUrl => 'Event URL';

  @override
  String get scwEvolutionDate => 'Evolution Date';

  @override
  String scwEvolutionTime(String timezone) {
    return 'Evolution Time ($timezone)';
  }

  @override
  String get scwEvolve => 'Evolve';

  @override
  String get scwEvolveOnRedeem => 'Evolve on Redeem?';

  @override
  String get scwEvolveStageAsset => 'Evolve Stage Asset';

  @override
  String get scwEvolveStageDescription => 'Evolve Stage Description';

  @override
  String get scwEvolveStageName => 'Evolve Stage Name';

  @override
  String get scwEvolveType => 'Evolve Type';

  @override
  String get scwEvolveTypeBlockHeight => 'Block Height';

  @override
  String get scwEvolveTypeDateTime => 'Date/Time';

  @override
  String get scwEvolveTypeManualOnly => 'Manual Only';

  @override
  String scwEvolveWithType(String type) {
    return 'Evolve ($type)';
  }

  @override
  String get scwEvolvingPhase => 'Evolving phase';

  @override
  String get scwExpireDate => 'Expire Date';

  @override
  String get scwExpireTime => 'Expire Time';

  @override
  String get scwFractionalInterest => 'Fractional Interest';

  @override
  String get scwFractionalizationTitle => 'Fractionalization';

  @override
  String get scwFullDescription => 'Full Description';

  @override
  String get scwImages => 'Image(s)';

  @override
  String get scwImporting => 'Importing';

  @override
  String get scwLaunchIdeBody => 'Open the online IDE to write your own Trillium code for your smart contract';

  @override
  String get scwLaunchIdeMobileBody => 'The IDE is optimized for larger screens. Would you like to proceed?';

  @override
  String get scwLaunchIdeMobileTitle => 'Launch IDE on mobile?';

  @override
  String get scwLaunchIdeTitle => 'Launch IDE';

  @override
  String get scwLaunchWizard => 'Launch Wizard';

  @override
  String get scwMaxQuantity => 'Max quantity is 100.';

  @override
  String get scwMetadataUrl => 'Metadata URL';

  @override
  String get scwMinQuantity => 'Min quantity is 1.';

  @override
  String get scwMintNftCollectionBody => 'Mint multiple Smart Contracts into a collection';

  @override
  String get scwMintNftCollectionTitle => 'Mint NFT Collection';

  @override
  String get scwName => 'Name';

  @override
  String get scwNetwork => 'Network';

  @override
  String scwNetworkContractAddress(String network) {
    return '$network Contract Address';
  }

  @override
  String get scwNoProperties => 'No Properties';

  @override
  String get scwNotImplemented => 'Not implemented.';

  @override
  String get scwNumericalProperty => 'Numerical Property';

  @override
  String get scwOtherOptions => 'Other Options';

  @override
  String get scwOwnerAddress => 'Owner Address';

  @override
  String get scwPairWrapTitle => 'Pair/Wrap with Existing NFT';

  @override
  String get scwPercentage => 'Percentage';

  @override
  String get scwPercentageRequiredForVotingApproval => 'Percentage Required for Voting Approval';

  @override
  String scwPhaseLabel(int number, String name) {
    return 'Phase #$number: $name';
  }

  @override
  String get scwPhysicalDigitalGoodName => 'Physical/Digital Good Name';

  @override
  String get scwPrimaryAsset => 'Primary Asset';

  @override
  String get scwProperties => 'Properties';

  @override
  String get scwPropertiesOptional => 'Properties (Optional)';

  @override
  String get scwPropertyName => 'Property Name';

  @override
  String get scwPropertyType => 'Property Type';

  @override
  String get scwPropertyTypeColor => 'Color';

  @override
  String get scwPropertyTypeNumber => 'Number';

  @override
  String get scwPropertyTypeText => 'Text';

  @override
  String get scwPropertyValue => 'Property Value';

  @override
  String get scwProvenanceFilesOptional => 'Provenance Files (Optional)';

  @override
  String get scwQuantity => 'Quantity';

  @override
  String get scwQuantityToMint => 'Quantity to Mint';

  @override
  String scwQuantityValue(int quantity) {
    return 'Quantity: $quantity';
  }

  @override
  String get scwReasonForPairingWrapping => 'Reason for Pairing/Wrapping';

  @override
  String get scwRemove => 'Remove';

  @override
  String get scwRemoveAssetBody => 'Are you sure you want to remove this additional asset?';

  @override
  String get scwRemoveAssetTitle => 'Remove Asset?';

  @override
  String get scwRemovePhaseBody => 'Are you sure you want to remove this evolution phase?';

  @override
  String get scwRemovePhaseTitle => 'Remove Phase?';

  @override
  String get scwRemovePropertyBody => 'Are you sure you want to remove this property?';

  @override
  String get scwRemovePropertyTitle => 'Remove Property?';

  @override
  String get scwRemoveRoyaltyBody => 'Are you sure you want to remove the royalty?';

  @override
  String get scwRemoveRoyaltyTitle => 'Remove Royalty?';

  @override
  String get scwRoyaltyTitle => 'Royalty';

  @override
  String scwRoyaltyToAddress(String amount, String address) {
    return '$amount to $address';
  }

  @override
  String get scwRoyaltyType => 'Royalty Type';

  @override
  String get scwRoyaltyTypeFixed => 'Fixed';

  @override
  String get scwRoyaltyTypePercent => 'Percent';

  @override
  String get scwSeatingInfo => 'Seating Info';

  @override
  String get scwSoulBoundTitle => 'Soul Bound';

  @override
  String get scwStatTypeString => 'Type: String';

  @override
  String get scwStats => 'Stats';

  @override
  String get scwTextProperty => 'Text Property';

  @override
  String get scwTicketTitle => 'Ticket';

  @override
  String get scwTicketType => 'Ticket Type';

  @override
  String get scwTokenIdOptional => 'Token ID (Optional)';

  @override
  String get scwTokenStandardOptional => 'Token Standard (Optional)';

  @override
  String get scwTokenizationTitle => 'Tokenization';

  @override
  String get scwUploadCsv => 'Upload CSV';

  @override
  String get scwUploadJson => 'Upload JSON';

  @override
  String get scwUploadJsonCsv => 'Upload JSON / CSV';

  @override
  String get scwUploadJsonCsvBody => 'Create a collection with a JSON or CSV file. See the example files below and use them as a template. Upon uploading the file you will be able to configure and tweak the settings through the wizard\'s UI.\n\nThis is an advanced feature for users who want to compile and mint collections outside of the graphical user interface.';

  @override
  String get scwUseMyAddress => 'Use My Address';

  @override
  String get scwVotingDescription => 'Voting Description';

  @override
  String get tkbAmountGreaterThanZero => 'Amount must be greater than 0.0 BTC';

  @override
  String tkbAmountOfVbtcTo(String action) {
    return 'Amount of vBTC to $action';
  }

  @override
  String get tkbAssociateLocalFile => 'Associate Local File';

  @override
  String get tkbAssociateMedia => 'Associate Media';

  @override
  String get tkbAuthorizeNow => 'Authorize Now';

  @override
  String tkbBalanceFoundBody(String balance) {
    return 'A balance of $balance VFX was found in this account. Skipping to step 3.';
  }

  @override
  String tkbBalanceValue(String balance) {
    return 'Balance: $balance';
  }

  @override
  String tkbBlockHeightValue(String height) {
    return 'Block Height: $height';
  }

  @override
  String tkbBtcAddressGenerated(String address) {
    return 'BTC Address generated ($address)';
  }

  @override
  String get tkbBtcAddressPending => 'BTC Address Pending';

  @override
  String get tkbBtcAmount => 'BTC Amount';

  @override
  String tkbBtcSentTo(String amount, String address) {
    return '$amount BTC has been sent to $address.';
  }

  @override
  String get tkbBtcTransferBroadcasted => 'BTC Transfer TX Broadcasted successfully.';

  @override
  String tkbBtcWithdrawalBroadcasted(String hash) {
    return 'BTC Withdrawl TX Broadcasted successfully. Hash: $hash';
  }

  @override
  String get tkbCallMedia => 'Call Media';

  @override
  String get tkbCallMediaFromBeacon => 'Call Media from Beacon';

  @override
  String get tkbCallToBeaconStartedBody => 'Please be patient while ALL assets associated with the NFT are called and downloaded.\n\nDo not close your wallet or attempt to call again.';

  @override
  String get tkbCallToBeaconStartedTitle => 'Call to beacon process has started.';

  @override
  String get tkbCallToBeaconStartedToast => 'Call to beacon process has started. Please be patient while ALL assets associated with the NFT are called and downloaded.';

  @override
  String get tkbCheckOtherAccount => 'Please check any other account with the same address for the media.';

  @override
  String get tkbChooseBtcAccount => 'Choose BTC Account to Send From';

  @override
  String get tkbChooseVaultAccount => 'Choose Vault Account';

  @override
  String get tkbComplete => 'Complete';

  @override
  String tkbConfirmSendBtcBody(String amount, String from, String to, String fee) {
    return 'Sending $amount BTC from $from to $to.\n\nFee:\n$fee BTC';
  }

  @override
  String get tkbConfirmTransaction => 'Confirm Transaction';

  @override
  String get tkbConfirmVoteNoBody => 'Are you sure you want to vote NO on this token topic?';

  @override
  String get tkbConfirmVoteYesBody => 'Are you sure you want to vote YES on this token topic?';

  @override
  String tkbControlledBy(String address) {
    return 'Controlled by: $address';
  }

  @override
  String tkbCouldNotResolveNft(String id) {
    return 'Could not resolve nft from $id';
  }

  @override
  String get tkbCreateBtcDomain => 'Create BTC Domain';

  @override
  String tkbCreateDomainFor(String address) {
    return 'Create Domain for $address';
  }

  @override
  String get tkbCreateTokenTopicBody => 'Are you sure you want to create this token topic?';

  @override
  String get tkbCreationPending => 'Creation Pending';

  @override
  String tkbDeleteBtcDomainBody(String costLine) {
    return 'Are you sure you want to delete this BTC Domain?\n$costLine\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.';
  }

  @override
  String get tkbDeleteDomainNoCost => 'There is no cost to delete and VFX Domain (aside from the TX fee).';

  @override
  String tkbDeleteDomainWithCost(String cost) {
    return 'There is a cost of $cost VFX to delete an RBX Domain.';
  }

  @override
  String get tkbDeletePending => 'Delete Pending';

  @override
  String get tkbDescriptionColon => 'Description:';

  @override
  String get tkbDismiss => 'Dismiss';

  @override
  String get tkbDomainName => 'Domain Name';

  @override
  String get tkbDomainNameRule => 'Your domain must only contain letters and numbers and will automatically be appended with \".btc\" upon verification';

  @override
  String get tkbDownloadAsset => 'Download Asset';

  @override
  String get tkbError => 'Error';

  @override
  String get tkbErrorLoadingData => 'Error Loading Data';

  @override
  String get tkbFailedRequestWithdrawal => 'Failed to request withdrawal.';

  @override
  String tkbFeeEstimate(String feeEstimate, String feeEstimateBtc, String fee, String feeBtc) {
    return 'Fee Estimate: ~$feeEstimate SATS | ~$feeEstimateBtc BTC    ($fee SATS /byte | $feeBtc BTC /byte)';
  }

  @override
  String get tkbFeeRateHint => 'Fee rate in satoshis';

  @override
  String tkbFeeRatePerByte(String sats, String btc) {
    return 'Fee Rate: $sats SATS per byte ($btc BTC per byte)';
  }

  @override
  String get tkbFeeRateRequired => 'Fee Rate Required';

  @override
  String tkbFileNameLabel(String name) {
    return 'File Name: $name';
  }

  @override
  String get tkbFileSize => 'File Size';

  @override
  String get tkbFileType => 'File Type';

  @override
  String tkbFilenameCreator(String filename, String creator) {
    return 'Filename: $filename | Creator: $creator';
  }

  @override
  String get tkbFixedSupply => 'Fixed Supply';

  @override
  String get tkbFungibleToken => 'Fungible Token';

  @override
  String get tkbGenerate => 'Generate';

  @override
  String get tkbGenerateBtcAddress => 'Generate BTC Address';

  @override
  String get tkbGenerateBtcAddressBody => 'Are you sure you want to generate this token\'\'s BTC address?';

  @override
  String get tkbImagePreviewNotFound => 'File not found for preview.\nLikely this means this NFT no longer exists on this machine.\n';

  @override
  String get tkbInProgress => 'In Progress';

  @override
  String get tkbInfinite => 'Infinite';

  @override
  String tkbInsufficientBalanceAccount(String balance) {
    return 'Insufficient Balance to cover tx and fee. This account only has $balance BTC.';
  }

  @override
  String get tkbInvalidFeeRate => 'Invalid Fee Rate. Must be atleast 1 satoshi.';

  @override
  String get tkbManualSendSubtitle => 'Send coin manually to this token\'\'s BTC deposit address';

  @override
  String tkbMediaNotFound(String fileName) {
    return 'Media asset file not found on your machine ($fileName).';
  }

  @override
  String get tkbMinimumTokenRequirement => 'Minimum Token Requirement';

  @override
  String get tkbMinimumTokenRequirementHelper => 'The minimum token balance required to vote.';

  @override
  String tkbMinimumTokensToVote(String count) {
    return 'Minimum Tokens to Vote: $count';
  }

  @override
  String get tkbMultiSigFeeCalculated => 'This is a Multi-signature. The fee rate has been calculated for you.';

  @override
  String tkbNeedTokensToVote(String count) {
    return 'You need at least $count tokens to vote.';
  }

  @override
  String tkbNoAddressesHolding(String ticker) {
    return 'None of your addresses are holding $ticker';
  }

  @override
  String get tkbNoFungibleTokens => 'No Fungible Tokens';

  @override
  String get tkbNoFungibleTokensBody => 'You have no fungible tokens with supply in any of your accounts.';

  @override
  String get tkbNoRequestHash => 'No request hash returned.';

  @override
  String get tkbNoUpper => 'NO';

  @override
  String get tkbNoUtxos => 'No UTXOs';

  @override
  String get tkbNoVaultAccounts => 'You don\'\'t have any Vault Accounts in this wallet';

  @override
  String get tkbNoVotesYet => 'No votes yet.';

  @override
  String get tkbNone => 'None';

  @override
  String get tkbNotFound => 'Not Found.';

  @override
  String get tkbOpenAsset => 'Open Asset';

  @override
  String get tkbOpenFolder => 'Open Folder';

  @override
  String get tkbOwnershipTransferInitiated => 'Ownership transfer initiated.';

  @override
  String get tkbPassword => 'Password';

  @override
  String tkbPendingWithdrawalBody(String amount, String destination) {
    return 'You have a pending withdrawal of $amount vBTC to $destination.\n\nWould you like to complete it?';
  }

  @override
  String get tkbPendingWithdrawalContractBody => 'You have a pending withdrawal for this contract. Would you like to complete it?';

  @override
  String get tkbPendingWithdrawalFound => 'Pending Withdrawal Found';

  @override
  String get tkbPercentages => 'Percentages';

  @override
  String get tkbResult => 'Result';

  @override
  String get tkbResultFail => 'Fail';

  @override
  String get tkbResultPass => 'Pass';

  @override
  String get tkbSelectVfxAddress => 'Select VFX Address';

  @override
  String get tkbSelectedAddress => 'Selected Address:';

  @override
  String get tkbSendAutomatically => 'Send Automatically';

  @override
  String tkbSendFundsTo(String address) {
    return 'Send funds to $address (address copied to clipboard)';
  }

  @override
  String get tkbSendManually => 'Send Manually';

  @override
  String tkbSmartContractUidWithValue(String uid) {
    return 'Smart Contract UID: $uid';
  }

  @override
  String get tkbToBtcAddress => 'To BTC Address';

  @override
  String get tkbToVfxAddress => 'To VFX Address';

  @override
  String get tkbTokenBalances => 'Token Balances';

  @override
  String get tkbTokenDetails => 'Token Details';

  @override
  String get tkbTokenTopicCreated => 'Token Topic Created';

  @override
  String tkbTopicUidLabel(String uid) {
    return 'UID: $uid';
  }

  @override
  String get tkbTotalVotes => 'Total Votes';

  @override
  String get tkbTransactionBroadcastedBang => 'Transaction Broadcasted!';

  @override
  String get tkbTransactionHash => 'Transaction Hash';

  @override
  String get tkbTransactionHashCopied => 'Transaction Hash copied to clipboard';

  @override
  String get tkbTransferBtc => 'Transfer BTC';

  @override
  String tkbTransferDomainFrom(String address) {
    return 'Transfer Domain from $address';
  }

  @override
  String tkbTransferOwnershipBody(String address) {
    return 'Are you sure you want to transfer ownership of this vBTC token to $address?';
  }

  @override
  String get tkbTransferOwnershipToReserve => 'Transfer Ownership To Reserve/Protected Account';

  @override
  String get tkbTransferOwnershipToReserveSubtitle => 'Transfer the ownership of this token to your reserve/protected account.';

  @override
  String get tkbTransferPending => 'Transfer Pending';

  @override
  String get tkbTransferToken => 'Transfer Token';

  @override
  String get tkbTransferTokenOwnership => 'Transfer Token Ownership';

  @override
  String get tkbTransferTokenOwnershipSubtitle => 'Transfer the ownership of this token to another VFX account.';

  @override
  String get tkbTransferVbtc => 'Transfer vBTC';

  @override
  String tkbTransferVbtcBody(String amount, String address) {
    return 'Are you sure you want to transfer $amount vBTC to $address?';
  }

  @override
  String get tkbTransferVbtcSubtitle => 'Transfer a specific portion of the vBTC within the token to another VFX address.';

  @override
  String get tkbTxBroadcasted => 'TX broadcasted!';

  @override
  String tkbUtxoAddress(String address) {
    return 'Address: $address';
  }

  @override
  String tkbUtxoDetails(String txId, String amount) {
    return 'TX ID: $txId\nAmount:$amount';
  }

  @override
  String get tkbUtxoUnused => 'Unused';

  @override
  String get tkbUtxoUsed => 'Used';

  @override
  String get tkbVaultAccountPassword => 'Vault Account Password';

  @override
  String get tkbVaultAuthorizeDownload => 'Since this is a Vault Account you\'\'ll need to authorize the download.';

  @override
  String get tkbVaultCannotWithdraw => 'Vault Accounts can not withdrawl. Please transfer vBTC to a standard VFX address';

  @override
  String get tkbVaultOwnedCannotAction => 'Vault Account owned tokens can not perform this action.';

  @override
  String tkbVbtcTransferBroadcasted(String hash) {
    return 'vBTC V2 Transfer TX Broadcasted. Hash: $hash';
  }

  @override
  String get tkbVbtcZeroBalance => 'vBTC tokens with zero balance can not be transferred.';

  @override
  String get tkbVfxWalletRequired => 'An VFX wallet is required for this functionality.';

  @override
  String get tkbVoteCounts => 'Vote Counts';

  @override
  String tkbVotedOnBlock(String label, String block) {
    return 'You voted $label on block $block.';
  }

  @override
  String get tkbVotesNo => 'Votes No';

  @override
  String get tkbVotesYes => 'Votes Yes';

  @override
  String get tkbWalletControlsDomain => 'This wallet will control transfer/delete ownership over this new domain.';

  @override
  String get tkbWithdrawBtc => 'Withdraw BTC';

  @override
  String tkbWithdrawBtcBody(String amount, String address) {
    return 'Are you sure you want to withdraw $amount BTC to $address?';
  }

  @override
  String get tkbYesUpper => 'YES';

  @override
  String get tkbYouHaveVoted => 'You have voted.';

  @override
  String tkbYourBalanceValue(String balance) {
    return 'Your Balance: $balance';
  }

  @override
  String tkbYourBalanceVbtc(String balance, String usd) {
    return 'Your Balance: $balance vBTC$usd';
  }

  @override
  String get txpAccountBalance => 'Account Balance';

  @override
  String get txpAccountCreated => 'Account Created';

  @override
  String get txpActivateOnNetwork => 'Activate on Network?';

  @override
  String get txpActivateOnNetworkBody => 'There is a cost of 4 VFX (which is burned) plus TX fee to activate this Vault Account on the network.  Continue?';

  @override
  String get txpAddBtcAccount => 'Add BTC Account';

  @override
  String get txpAddNewAccount => 'Add New Account';

  @override
  String get txpAddVfxAccount => 'Add VFX Account';

  @override
  String get txpAddressCopied => 'Address copied';

  @override
  String get txpAddressCopiedClipboard => 'Address copied to clipboard.';

  @override
  String get txpAllAddresses => 'All Addresses';

  @override
  String get txpAmountCopied => 'Amount copied';

  @override
  String get txpAutoActivate => 'Auto Activate?';

  @override
  String get txpAutoActivateBody => 'Would you like to automatically activate this account once the funds are received?';

  @override
  String get txpAutoActivateQueued => 'Auto activate queued.';

  @override
  String txpBlockDiffAvg(String value) {
    return 'Block Diff Avg: $value';
  }

  @override
  String txpBlockLastDelay(String value) {
    return 'Block Last Delay: $value';
  }

  @override
  String txpBlockLastReceived(String value) {
    return 'Block Last Received: $value';
  }

  @override
  String get txpBlockNumber => 'Block Number';

  @override
  String txpBlocksAveraged(String value) {
    return 'Blocks Averaged: $value';
  }

  @override
  String get txpBtcNoBalance => 'BTC account has no balance';

  @override
  String get txpChooseCoinType => 'Choose Coin Type';

  @override
  String get txpChoosePaymentGateway => 'Choose Payment Gateway';

  @override
  String get txpClearFilters => 'Clear Filters';

  @override
  String get txpCompleteMoonpayDeposit => 'Complete MoonPay Deposit';

  @override
  String get txpCompleteSale => 'Complete Sale';

  @override
  String txpCompleteSaleConfirmBody(String scId, String amount) {
    return 'Are you sure you want to complete the sale of $scId for $amount VFX?';
  }

  @override
  String get txpConfirmPassword => 'Confirm Password';

  @override
  String get txpConfirmPasswordBody => 'Please confirm your password.';

  @override
  String get txpConfirmSend => 'Confirm Send';

  @override
  String txpConfirmSendBody(String amount, String currency, String toAddress, String fromAddress, String feeRate) {
    return 'Amount: $amount $currency\nTo: $toAddress\nFrom: $fromAddress\nFee Rate: $feeRate sats/vB';
  }

  @override
  String get txpCopyAddress => 'Copy Address';

  @override
  String get txpCreate => 'Create';

  @override
  String get txpCreateBtcAccountSub => 'Create a new BTC account';

  @override
  String get txpCreateVfxAccountSub => 'Create a new VFX account';

  @override
  String get txpCryptoDotComOnRamp => 'Crypto.com On-Ramp';

  @override
  String get txpData => 'Data';

  @override
  String get txpDate => 'Date';

  @override
  String get txpDepositAddressMoonpay => 'Deposit Address (MoonPay)';

  @override
  String get txpDisclaimerAnd => ' and ';

  @override
  String txpDisclaimerIntro(String gateway) {
    return 'I understand that I will now be purchasing VFX or BTC native coin directly through $gateway (';
  }

  @override
  String txpDisclaimerMiddle(String gateway) {
    return '), which is a third-party services platform. By proceeding and procuring services from $gateway, you acknowledge that you have read and agreed to $gateway’s ';
  }

  @override
  String txpDisclaimerOutro(String gateway) {
    return '. You additionally understand that the VerifiedX VFX Network is an autonomous and decentralized ecosystem and does not share in any fees whatsoever by you utilizing $gateway’s services and does not take any responsibility for any issues that may affect your transaction with any third-party service provider at anytime. For any questions related to $gateway’s services, please contact $gateway at ';
  }

  @override
  String get txpErrorOccurred => 'An error occurred';

  @override
  String get txpFundAccount => 'Fund Account';

  @override
  String get txpFundVaultBody => 'You must now fund your Vault Account with a minimum of 5 VFX. 4 VFX will be burned upon activation.';

  @override
  String get txpFundVaultBodyShort => 'You must now fund your Vault Account with a minimum of 5 VFX.';

  @override
  String get txpFundsSent => 'Funds Sent';

  @override
  String txpFundsSentBody(String amount, String address) {
    return '$amount VFX has been sent to $address.\n\nPlease wait for transaction to reflect and then activate your Vault Account.';
  }

  @override
  String get txpGetBtcNow => 'Get \$BTC Now';

  @override
  String get txpGetQuote => 'Get Quote';

  @override
  String get txpGetVfxNow => 'Get \$VFX Now';

  @override
  String get txpImportBtcKeySub => 'Import an existing BTC private key';

  @override
  String get txpImportVfxKeySub => 'Import an existing VFX private key';

  @override
  String get txpManualDeposit => 'Manual Deposit';

  @override
  String txpManualDepositBody(String amount, String currency) {
    return 'You can send this from another wallet by sending the exact amount ($amount $currency) to the deposit address above.';
  }

  @override
  String get txpMeMarker => '[ME]';

  @override
  String get txpMinBalanceActivate => 'A minimum balance of 5 VFX is required to activate.';

  @override
  String get txpMoonpayManualMarked => 'MoonPay transaction marked as manual deposit';

  @override
  String get txpMustConfirmPassword => 'You must confirm your password.';

  @override
  String get txpNativeMoonpaySoon => 'Native Moonpay Integration Activating Soon.';

  @override
  String get txpNoAccountFound => 'No account found';

  @override
  String get txpNoAddressSelected => 'No address selected';

  @override
  String get txpNonce => 'Nonce';

  @override
  String get txpNotAvailableOnPlatform => 'Not available on this platform';

  @override
  String get txpNotEnoughBtcFee => 'Not enough BTC to cover transaction + fee';

  @override
  String get txpNotVaultAccount => 'Not a Vault Account';

  @override
  String get txpOffRampInstructions => 'To complete this off-ramp, send the exact BTC amount to the deposit address below:';

  @override
  String get txpOriginalTx => 'Original TX';

  @override
  String get txpPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String txpPleaseSendFundsTo(String address) {
    return 'Please send funds to $address';
  }

  @override
  String get txpPrivacyPolicy => 'Privacy Policy';

  @override
  String get txpRestoreCodeRecoveryBody => 'Paste in your RESTORE CODE to import the recovery account for this Vault Account.';

  @override
  String get txpScanAndPay => 'Scan & Pay';

  @override
  String get txpSendManually => 'I have/will send manually';

  @override
  String get txpSendNow => 'Send Now';

  @override
  String txpSendingConfirmBody(String amount, String toAddress, String fromAddress) {
    return 'Sending:\n$amount VFX\n\nTo:\n$toAddress\n\nFrom:\n$fromAddress';
  }

  @override
  String txpSentToAddress(String amount, String currency, String address) {
    return '$amount $currency sent to $address';
  }

  @override
  String get txpSetupBtcAccount => 'Setup a Bitcoin account';

  @override
  String get txpSetupVaultAccount => 'Setup Vault Account';

  @override
  String get txpSetupVaultAccountBody => 'Create a password to continue. You must remember this password as it will be required for any transaction with this Vault Account.';

  @override
  String get txpSetupVfxAccount => 'Setup a VerifiedX account';

  @override
  String txpStatusWithValue(String value) {
    return 'Status: $value';
  }

  @override
  String get txpStripeCreditCard => 'Stripe (Credit Card)';

  @override
  String txpSufficientBalanceBody(String address, String balance) {
    return 'You have an account with a sufficient balance.\n\nWould you like to send 5 VFX from:\n$address\n[Balance: $balance VFX]?';
  }

  @override
  String get txpTermsOfUse => 'Terms of Use';

  @override
  String get txpTestnetFaucet => 'Testnet Faucet';

  @override
  String get txpTestnetFaucetNoTerms => 'Testnet Faucet does not have any terms. Have fun!';

  @override
  String get txpTileAmountLabel => 'Amount: ';

  @override
  String txpTileDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String txpTileHashLabel(String hash) {
    return 'Hash: $hash';
  }

  @override
  String txpTileSettlementDateLabel(String date) {
    return 'Settlement Date: $date';
  }

  @override
  String get txpTileStatusLabel => 'Status: ';

  @override
  String get txpTileTypeLabel => 'Type: ';

  @override
  String get txpTileViewData => 'View Data';

  @override
  String txpTimeSinceLastBlock(String value) {
    return 'Time Since Last Block: ${value}s';
  }

  @override
  String get txpTransactionFailed => 'Transaction failed';

  @override
  String get txpTransactionHashLabel => 'Transaction Hash';

  @override
  String get txpTransactionSent => 'Transaction Sent';

  @override
  String get txpTxDetailTitle => 'Transaction Detail';

  @override
  String get txpTxFilters => 'Transaction Filters';

  @override
  String get txpTxHash => 'Tx Hash';

  @override
  String get txpTxHashCopied => 'Tx hash copied';

  @override
  String get txpTxType => 'Tx Type';

  @override
  String txpTxTypeLabel(String suffix) {
    return 'Tx Type$suffix:';
  }

  @override
  String txpValueCopied(String value) {
    return '\'$value\' Copied to clipboard';
  }

  @override
  String get txpVaultActivationSent => 'Vault Account activation transaction sent.\n\nPlease wait for it to reflect as \"Activated\".';

  @override
  String get txpVfxAmount => 'VFX Amount';

  @override
  String get txpVfxOffRampSoon => 'VFX Off Ramp feature coming soon';

  @override
  String get txpVfxQuote => 'VFX Quote';

  @override
  String txpVfxQuoteBody(String amountVfx, String amountUsd) {
    return '$amountVfx VFX for \$$amountUsd USD\nWould you like to continue?';
  }

  @override
  String get txpWalletDetailsBackup => 'Here are your wallet details. Please ensure to back up your private key in a safe place.';

  @override
  String txpWalletVersionInfo(String envTag, String version, String nickname) {
    return 'VFX Wallet$envTag\nVersion $version ($nickname)';
  }

  @override
  String tkbHashLabel(String hash) {
    return 'Hash: $hash';
  }
}
