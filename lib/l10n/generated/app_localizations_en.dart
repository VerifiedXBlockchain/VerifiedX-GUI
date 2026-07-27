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

  @override
  String get tkbBulkTransferUnavailableWeb => 'Bulk transfer is not yet available on the web wallet.';

  @override
  String get tkbCreateVbtcToken => 'Create vBTC Token';

  @override
  String hnavSnapshotDownloadingProgress(String file, int done, int total) {
    return 'Downloading: $file ($done/$total)';
  }

  @override
  String get tkbFundToken => 'Fund Token';

  @override
  String get tkbManualSendExchangeSubtitle => 'Send BTC from any exchange or wallet to this token\'s deposit address';

  @override
  String get bw2AmountOfBtcToSend => 'Amount of BTC to Send';

  @override
  String get bw2AnErrorOccurred => 'An error occurred.';

  @override
  String get bw2BeaconUploadFailed => 'Beacon upload failed';

  @override
  String get bw2BlockConfirmTimedOut => 'Timed out waiting for block confirmation. You can retry later from the token detail screen.';

  @override
  String bw2BlockWithValue(String height) {
    return 'Block $height';
  }

  @override
  String get bw2BridgeToBase => 'Bridge to Base';

  @override
  String get bw2BridgeVbtcToBase => 'Bridge vBTC to Base (vBTC.b)';

  @override
  String get bw2BroadcastingRequest => 'Broadcasting Request';

  @override
  String get bw2BroadcastingWithdrawal => 'Broadcasting withdrawal request...';

  @override
  String get bw2BtcAccountNoBalance => 'This BTC account doesn\'t have a balance';

  @override
  String get bw2BtcAddressTitle => 'BTC Address';

  @override
  String bw2BtcAmount(String amount) {
    return '$amount BTC';
  }

  @override
  String get bw2BtcFundsReceived => 'BTC Funds Received!';

  @override
  String get bw2BtcTransactionLabel => 'BTC Transaction:';

  @override
  String get bw2BuyBtcOnRamp => 'Buy BTC (On-Ramp)';

  @override
  String get bw2BuyBtcOnRampSubtitle => 'Purchase BTC with fiat and send directly to this token';

  @override
  String get bw2CancelWithdrawal => 'Cancel Withdrawal';

  @override
  String get bw2CancelWithdrawalBody => 'Are you sure you want to cancel this withdrawal request?';

  @override
  String get bw2CancelWithdrawalQuestion => 'Cancel Withdrawal?';

  @override
  String get bw2CancelWithdrawalTooltip => 'Cancel withdrawal';

  @override
  String bw2CancellationFailedError(String error) {
    return 'Cancellation failed: $error';
  }

  @override
  String get bw2CancellationSubmitted => 'Cancellation request submitted. Awaiting validator votes.';

  @override
  String get bw2Cancelled => 'Cancelled';

  @override
  String get bw2CeremonyCompleted => 'Ceremony Completed';

  @override
  String get bw2CeremonyDismissHint => 'You can dismiss this dialog. The ceremony will continue in the background.';

  @override
  String get bw2CeremonyFailed => 'Ceremony Failed';

  @override
  String get bw2CeremonyFailedRetry => 'Ceremony failed. Please try again.';

  @override
  String get bw2CeremonyTimedOut => 'Ceremony timed out. Please try again.';

  @override
  String get bw2CeremonyTimedOutNetwork => 'Ceremony timed out on the network. Please try again.';

  @override
  String bw2ConfirmSendBtcBody(String amount, String toAddress, String fromAddress, String feeRate) {
    return 'Sending:\n$amount BTC\n\nTo:\n$toAddress (Token Deposit Address)\n\nFrom:\n$fromAddress\n\nFeeRate:\n$feeRate SATS';
  }

  @override
  String get bw2ConfirmTransfer => 'Confirm Transfer';

  @override
  String bw2ConfirmTransferBody(String amount, String address) {
    return 'Transfer $amount vBTC to $address?';
  }

  @override
  String get bw2ConfirmWithdrawalRequest => 'Confirm Withdrawal Request';

  @override
  String get bw2ConfirmedWhenIndexed => 'This will be confirmed once indexed by the explorer.';

  @override
  String get bw2ContractCreated => 'Contract Created';

  @override
  String get bw2CouldNotConnectArbiter => 'Could not connect to arbiter. Try again later';

  @override
  String get bw2CreatingContract => 'Creating Contract';

  @override
  String get bw2CreatingVbtcContract => 'Creating vBTC contract on-chain...';

  @override
  String get bw2DateLabel => 'Date:';

  @override
  String get bw2DepositAddress => 'Deposit Address';

  @override
  String get bw2DepositAddressCopied => 'Deposit address copied to clipboard';

  @override
  String get bw2DepositAddressLabel => 'Deposit Address:';

  @override
  String get bw2DepositAmount => 'Deposit amount';

  @override
  String get bw2DkgStartHint => 'This starts the distributed key generation process.';

  @override
  String get bw2DoNotCloseApp => 'This may take a minute. Please do not close the application.';

  @override
  String get bw2DomainNameRequired => 'Domain Name Required';

  @override
  String bw2DomainTooLong(String max) {
    return 'Domain must be less than $max charcters.';
  }

  @override
  String get bw2FailedBroadcastBtc => 'Failed to broadcast BTC transaction';

  @override
  String get bw2FailedBroadcastWithdrawal => 'Failed to broadcast withdrawal request.';

  @override
  String get bw2FailedCreateContract => 'Failed to create contract. Please try again.';

  @override
  String get bw2FailedCreateContractShort => 'Failed to create contract.';

  @override
  String get bw2FailedExecuteMpc => 'Failed to execute MPC ceremony.';

  @override
  String get bw2FailedInitiateMpc => 'Failed to initiate MPC ceremony.';

  @override
  String get bw2FailedPrepareCancellation => 'Failed to prepare cancellation';

  @override
  String get bw2FailedPrepareContractCreation => 'Failed to prepare contract creation.';

  @override
  String get bw2FailedPrepareFrost => 'Failed to prepare FROST signing';

  @override
  String get bw2FailedPrepareMpc => 'Failed to prepare MPC ceremony.';

  @override
  String get bw2FailedPrepareOwnershipTransfer => 'Failed to prepare ownership transfer';

  @override
  String get bw2FailedPrepareTransfer => 'Failed to prepare transfer';

  @override
  String get bw2FailedPrepareWithdrawalRequest => 'Failed to prepare withdrawal request';

  @override
  String get bw2FailedSignBeacon => 'Failed to sign beacon upload';

  @override
  String get bw2FailedSignCeremony => 'Failed to sign ceremony messages.';

  @override
  String get bw2FailedSignContractTx => 'Failed to sign contract creation transaction.';

  @override
  String get bw2FailedSignFrost => 'Failed to sign FROST messages';

  @override
  String get bw2FailedSignOwnershipProof => 'Failed to sign ownership proof.';

  @override
  String get bw2FailedSignTransaction => 'Failed to sign transaction';

  @override
  String get bw2FailedStartFrost => 'Failed to start FROST signing';

  @override
  String get bw2FrostConfirmHint => 'This typically takes 10-20 seconds. The FROST signing will begin automatically once confirmed.';

  @override
  String get bw2FrostConfirmHintWeb => 'This typically takes 10-20 seconds. FROST signing will begin automatically once confirmed.';

  @override
  String get bw2FrostFailedOrTimedOut => 'FROST signing failed or timed out. The withdrawal may still complete — check back shortly.';

  @override
  String get bw2FrostGroupKey => 'FROST Group Key';

  @override
  String get bw2FrostJobNotFound => 'FROST signing job not found';

  @override
  String get bw2FrostSigning => 'FROST Signing';

  @override
  String get bw2FrostSigningFailed => 'FROST signing failed';

  @override
  String bw2FrostSigningFailedError(String error) {
    return 'FROST signing failed: $error';
  }

  @override
  String get bw2FrostSigningInProgress => 'FROST signing in progress...';

  @override
  String get bw2FrostTimedOut => 'FROST signing timed out. The withdrawal may still complete — check back shortly.';

  @override
  String get bw2FrostValidatorsSigning => 'Validators are signing the Bitcoin transaction. This may take a minute or two. Please do not close this window.';

  @override
  String get bw2FundVbtcToken => 'Fund vBTC Token';

  @override
  String get bw2FundViaManualSend => 'Fund via Manual Send';

  @override
  String bw2HashWithValue(String hash) {
    return 'Hash: $hash';
  }

  @override
  String get bw2HowMuchBtcWithdraw => 'How much BTC do you want to withdraw?';

  @override
  String get bw2InitiatingMpc => 'Initiating MPC ceremony...';

  @override
  String bw2InsufficientBalanceAvailable(String available) {
    return 'Insufficient balance. Available: $available vBTC';
  }

  @override
  String get bw2InvalidDomainLetters => 'Invalid domain. Must only contain letters and/or numbers.';

  @override
  String get bw2InvalidFeeRateWhole => 'Invalid fee rate. Must be a whole number';

  @override
  String get bw2InvalidSupplyAmount => 'Invalid Supply Amount';

  @override
  String get bw2LabelHash => 'Hash';

  @override
  String get bw2LabelTransactionSignature => 'Transaction Signature';

  @override
  String get bw2LabelVfxAddress => 'VFX Address';

  @override
  String get bw2Loading => 'Loading';

  @override
  String get bw2LostConnectionCeremony => 'Lost connection while monitoring ceremony. Please try again.';

  @override
  String get bw2LostConnectionToast => 'Lost connection to ceremony.';

  @override
  String get bw2ManualSendInstructions => 'Send BTC from any exchange or external wallet to the deposit address below.';

  @override
  String get bw2MediaColon => 'Media:';

  @override
  String get bw2MediaOptional => 'Media (Optional)';

  @override
  String get bw2MpcCeremony => 'MPC Ceremony';

  @override
  String get bw2MpcCeremonyCompletedSuccess => 'MPC ceremony completed successfully.';

  @override
  String get bw2MpcCeremonyFailedToast => 'MPC ceremony failed.';

  @override
  String get bw2MpcCeremonyInProgress => 'MPC Ceremony in Progress';

  @override
  String get bw2MpcCeremonyTimedOutToast => 'MPC ceremony timed out.';

  @override
  String get bw2MultiSigHigherFee => 'This is a Multi-signature transaction so a higher fee rate is recommended.';

  @override
  String bw2MyBalanceVbtc(String balance) {
    return 'My Balance: $balance vBTC';
  }

  @override
  String get bw2MyTotalBalance => 'My Total Balance:';

  @override
  String get bw2NoBtcAccountSelected => 'No BTC Account selected';

  @override
  String get bw2NoBtcAddressInToken => 'No BTC address in token';

  @override
  String get bw2NoBtcTokenSelected => 'No BTC Token selected';

  @override
  String get bw2NoInitialIssuance => 'No Initial Issuance';

  @override
  String get bw2NoKeypairFound => 'No keypair found';

  @override
  String get bw2NoKeypairFoundPeriod => 'No keypair found.';

  @override
  String get bw2NoKeypairToSign => 'No keypair found to sign transaction';

  @override
  String get bw2NoVbtcToBridge => 'No vBTC available to bridge';

  @override
  String get bw2NoVfxAccountFound => 'No VFX account found';

  @override
  String get bw2NotEnoughBtcCoverFee => 'Not enough BTC to cover this transaction + fee';

  @override
  String bw2NotEnoughVfxDeleteDomain(String address) {
    return 'Not enough VFX in your controlling account to delete a VFX domain. [$address]';
  }

  @override
  String get bw2OnboardCreateVfxDetails => 'First you\'ll need a VFX Wallet. You can either import an existing one or create one now.';

  @override
  String get bw2OnboardFaucetDetails => 'The community has provided a faucet to withdraw a minimal amount of VFX from in order to try out this feature. A phone number is required for verification purposes and to reduce the chance of abuse. Please note that only a hash of the phone number is stored with the faucet. Alternatively, you are welcome to purchase VFX via an exchange or on-ramp if you like.';

  @override
  String get bw2OnboardImportBtcDetails => 'Now you need a BTC account added to your wallet. You can either import a private key or generate a new one.';

  @override
  String get bw2OnboardTokenizeDetails => 'Time to tokenize a vBTC token. The following fields are all optional!';

  @override
  String get bw2OnboardTransferBtcDetails => 'Looks like this account doesn\'t have any BTC. Please transfer BTC to this account to continue.';

  @override
  String get bw2OnboardTransferToVbtcDetails => 'Now you are ready to transfer BTC to your vBTC token. Select the amount and Fee Rate below';

  @override
  String get bw2OneVbtcEqualsBtc => '1 vBTC = 1 BTC';

  @override
  String get bw2OnlyOwnerCanAction => 'Only the owner of this token can perform this action';

  @override
  String bw2OwnershipTransferFailed(String error) {
    return 'Ownership transfer failed: $error';
  }

  @override
  String get bw2PendingTapResume => 'Pending — tap to resume';

  @override
  String get bw2PendingWithdrawal => 'Pending Withdrawal';

  @override
  String bw2PercentComplete(String percent) {
    return '$percent% complete';
  }

  @override
  String get bw2PreMintTitle => 'Pre Mint Initial Issuance?';

  @override
  String get bw2PreMintTitleOptional => 'Pre Mint Initial Issuance? (Optional)';

  @override
  String get bw2ProcessingWithdrawal => 'Processing Withdrawal';

  @override
  String get bw2RbfFeeRateBody => 'Input your desired fee rate (SATS /byte) for this transaction.';

  @override
  String get bw2RebroadcastTx => 'Rebroadcast TX';

  @override
  String get bw2RebroadcastTxBody => 'Are you sure you want to rebroadcast this transaction?';

  @override
  String bw2RebroadcastedTx(String hash) {
    return 'Rebroadcasted TX. ($hash)';
  }

  @override
  String get bw2ReceivingBtcAddress => 'Receiving BTC Address';

  @override
  String get bw2RecipientVfxAddress => 'Recipient VFX Address';

  @override
  String bw2ReplacedByFeeMessage(String feeRate, String hash) {
    return 'Replaced by fee ($feeRate SATS /byte) TX sent. Hash: $hash';
  }

  @override
  String get bw2RetrySigning => 'Retry Signing';

  @override
  String bw2SatsAmount(String amount) {
    return '$amount SATS';
  }

  @override
  String get bw2SelectBtcAddressRequired => 'Selecting a BTC address is required.';

  @override
  String get bw2SelectVfxAddressRequired => 'Selecting a VFX Address is required.';

  @override
  String get bw2SigningThreshold => 'Signing Threshold';

  @override
  String get bw2SmartContractIdColon => 'Smart Contract ID:';

  @override
  String get bw2StartingMpcCeremony => 'Starting MPC Ceremony';

  @override
  String bw2StatusWithValue(String status) {
    return 'Status: $status';
  }

  @override
  String get bw2StepCompleted => 'Completed';

  @override
  String get bw2StepCreateVfxAccount => 'Create VFX Account';

  @override
  String get bw2StepGetVfx => 'Get VFX';

  @override
  String get bw2StepImportBtcAccount => 'Import BTC Account';

  @override
  String get bw2StepInitiated => 'Initiated';

  @override
  String get bw2StepRound1 => 'Round 1';

  @override
  String get bw2StepRound2 => 'Round 2';

  @override
  String get bw2StepRound3 => 'Round 3';

  @override
  String get bw2StepTokenizedVbtc => 'Tokenized vBTC';

  @override
  String get bw2StepTransferBtc => 'Transfer BTC';

  @override
  String get bw2StepTransferBtcToVbtc => 'Transfer BTC to vBTC Token';

  @override
  String get bw2StepValidating => 'Validating';

  @override
  String get bw2SubmittingTxVfx => 'Submitting a transaction to the VFX network.';

  @override
  String get bw2SupplyAmount => 'Supply Amount';

  @override
  String get bw2SupplyLabel => 'Supply';

  @override
  String get bw2ToBtcAddressRequired => 'To BTC address required.';

  @override
  String get bw2ToVfxAddressRequired => 'To VFX address required.';

  @override
  String get bw2TokenAppearWhenIndexed => 'The token will appear in your list once indexed (typically a few seconds).';

  @override
  String get bw2TokenCreated => 'Token Created';

  @override
  String get bw2TokenDeployed => 'Token Deployed!';

  @override
  String get bw2TokenDescriptionOptional => 'Token Description (Optional)';

  @override
  String get bw2TokenImageOptional => 'Token Image (Optional)';

  @override
  String get bw2TokenNameOptional => 'Token Name (Optional)';

  @override
  String get bw2TokenPaused => 'Transactions on this token are currently paused.';

  @override
  String get bw2TokenTickerOptional => 'Token Ticker (Optional)';

  @override
  String get bw2TransactionBroadcasted => 'Transaction broadcasted!';

  @override
  String bw2TransactionFailed(String error) {
    return 'Transaction failed: $error';
  }

  @override
  String get bw2TransactionHashColon => 'Transaction Hash:';

  @override
  String get bw2TransactionsColon => 'Transactions:';

  @override
  String get bw2TransferComplete => 'Transfer Complete!';

  @override
  String get bw2TransferFailed => 'Transfer failed';

  @override
  String bw2TransferFailedError(String error) {
    return 'Transfer failed: $error';
  }

  @override
  String bw2TransferOwnershipConfirmBody(String address) {
    return 'Transfer ownership of this vBTC token to $address?\n\nThis cannot be undone.';
  }

  @override
  String bw2TxVerifiedFeeBody(String fee) {
    return 'Transaction verified. There will be a fee of $fee VFX. Would you like to proceed?';
  }

  @override
  String get bw2TypeLabel => 'Type:';

  @override
  String get bw2UtxosLabel => 'UTXOs:';

  @override
  String get bw2ValidatorsGeneratingKeys => 'Validators are generating threshold signing keys. This typically takes 30-90 seconds.';

  @override
  String get bw2ValidatorsSigningBtc => 'Validators are signing the Bitcoin transaction...';

  @override
  String bw2ValidatorsThreshold(String count, String threshold) {
    return 'Validators: $count (threshold: $threshold)';
  }

  @override
  String get bw2VaultBalanceRequired => 'A balance on your Vault account is required to broadcast this transaction';

  @override
  String get bw2VaultCannotActionTransferFirst => 'Vault accounts cannot perform this action. Please transfer ownership to your standard VFX account first';

  @override
  String bw2VbtcAmount(String amount) {
    return '$amount vBTC';
  }

  @override
  String get bw2VbtcBalanceUpdateHint => 'Once the BTC transaction is confirmed on-chain, your vBTC balance will update automatically.';

  @override
  String bw2VbtcContractCreatedHash(String hash) {
    return 'vBTC contract created. Hash: $hash';
  }

  @override
  String get bw2VbtcContractCreatedSuccess => 'vBTC contract created successfully!';

  @override
  String get bw2VbtcInfoBody => 'This wallet provides a specific smart contract that enables tokenizing actual Bitcoin! This will allow you to lock any denomination of Bitcoin you choose into a smart contract with or without media / documents.\n\nOnce minted, you will then hold a Verified Bitcoin Token that you may send to any other person at any time in whole or in part without moving it across the BTC network and without paying any BTC fees. Only you or the holder of a vBTC token may unlock the underlying BTC from the smart contract. You may also add additional BTC to your token at anytime without creating an additional one should you choose.\n\nAny and all vBTC tokens may also be stored in your registered Reserve (Protected) Account feature enabling full on-chain recovery and call-back options providing incredibly secure self-custodial vaulting.';

  @override
  String get bw2VbtcInfoWelcome => 'Welcome to true on-chain utility for your BTC!';

  @override
  String get bw2VbtcTokenCreatedSuccess => 'vBTC token created successfully!';

  @override
  String get bw2VbtcTransferBroadcastedSuccess => 'vBTC transfer broadcasted successfully';

  @override
  String get bw2VfxAccountBalanceRequired => 'A VFX account with a balance is required to proceed.';

  @override
  String get bw2VfxAccountBalanceRequiredShort => 'A VFX account with a balance is required.';

  @override
  String get bw2VfxAccountRequired => 'A VFX account is required to proceed.';

  @override
  String get bw2VfxBalanceRequiredBody => 'A VFX address with a balance is required to proceed.';

  @override
  String get bw2VfxBalanceRequiredBroadcast => 'A balance on your VFX account is required to broadcast this transaction';

  @override
  String get bw2VfxBalanceRequiredSetupBody => 'A VFX address with a balance is required to proceed. Would you like to set this up now?';

  @override
  String bw2VfxControllerNotFound(String address) {
    return 'The VFX account that controls this BTC domain was not found. [$address]';
  }

  @override
  String get bw2VfxFundsReceived => 'VFX Funds Received!';

  @override
  String get bw2VfxTransactionLabel => 'VFX Transaction:';

  @override
  String get bw2WaitingBlockConfirmation => 'Waiting for block confirmation...';

  @override
  String get bw2WaitingBtcToVbtc => 'Waiting for BTC to vBTC transaction to reflect on-chain.';

  @override
  String get bw2WaitingBtcTransfer => 'Waiting for BTC transfer to reflect on-chain.';

  @override
  String get bw2WaitingForBlockBody => 'Waiting for the withdrawal request to be confirmed in a block...';

  @override
  String get bw2WaitingForConfirmation => 'Waiting for Confirmation';

  @override
  String get bw2WaitingTokenization => 'MPC ceremony and contract creation in progress.';

  @override
  String get bw2WaitingVfxTransfer => 'Waiting for VFX Transfer to reflect on-chain.';

  @override
  String get bw2WhatIsVbtc => 'What is vBTC?';

  @override
  String get bw2WithdrawalAmount => 'Withdrawal Amount';

  @override
  String get bw2WithdrawalComplete => 'Withdrawal Complete';

  @override
  String get bw2WithdrawalCompletedSuccess => 'Withdrawal completed successfully!';

  @override
  String get bw2WithdrawalError => 'An error occurred during withdrawal.';

  @override
  String get bw2WithdrawalFailed => 'Withdrawal Failed';

  @override
  String get bw2WithdrawalHistory => 'Withdrawal History:';

  @override
  String bw2WithdrawalRequestBody(String amount, String address, String feeRate) {
    return 'Withdraw $amount BTC to $address\nFee rate: $feeRate sats/byte\n\nProceed?';
  }

  @override
  String get bw2WithdrawalRequestFailed => 'Withdrawal request failed';

  @override
  String bw2WithdrawalRequestFailedError(String error) {
    return 'Withdrawal request failed: $error';
  }

  @override
  String get bw2WithdrawalTimedOut => 'Timed out waiting for withdrawal request to be confirmed. You can retry later.';

  @override
  String bw2WithdrawalToLine(String amount, String address) {
    return '$amount vBTC → $address';
  }

  @override
  String get prvActivateWallet => 'Activate Privacy Wallet';

  @override
  String get prvActivating => 'Activating...';

  @override
  String get prvActivationDescription => 'Activate your privacy wallet to shield VFX using zero-knowledge proofs. Shielded funds are hidden from the public ledger and can be transferred privately.';

  @override
  String get prvAddressCopied => 'Address copied to clipboard';

  @override
  String get prvAmountVbtcLabel => 'Amount (vBTC)';

  @override
  String get prvAmountVfxLabel => 'Amount (VFX)';

  @override
  String get prvBack => 'Back';

  @override
  String prvBlockLabel(String block) {
    return 'Block $block';
  }

  @override
  String get prvBridgeAboutTo => 'You\'re about to bridge';

  @override
  String get prvBridgeAmountRequired => 'Amount is required';

  @override
  String get prvBridgeAmountToBridge => 'Amount to bridge';

  @override
  String prvBridgeAmountToDest(String amount, String dest) {
    return '$amount vBTC → $dest';
  }

  @override
  String prvBridgeAtDest(String dest) {
    return 'at $dest';
  }

  @override
  String prvBridgeAvailableAmount(String amount) {
    return 'Available: $amount vBTC';
  }

  @override
  String get prvBridgeBaseAddressRequired => 'Base address is required';

  @override
  String get prvBridgeBaseEvmAddress => 'Base (EVM) Address';

  @override
  String prvBridgeBlockHeight(String height) {
    return 'Block height: $height';
  }

  @override
  String get prvBridgeBulletExit => 'Exit back to vBTC on VFX or directly to BTC (whoever holds the vBTC.b initiates the exit; the network will detect it and credit you back automatically)';

  @override
  String get prvBridgeBulletTransfer => 'Transfer to another Base address';

  @override
  String get prvBridgeBulletYield => 'Earn yield via Base DeFi';

  @override
  String get prvBridgeCantLoadInfo => 'Couldn\'t load bridge info.';

  @override
  String get prvBridgeCantReach => 'Couldn\'t reach the bridge service. Check your connection and try again.';

  @override
  String prvBridgeCantReadBalance(String error) {
    return 'Couldn\'t read your vBTC balance: $error';
  }

  @override
  String get prvBridgeCheckingAccounts => 'Checking your accounts…';

  @override
  String get prvBridgeCompleteTitle => 'Bridge complete';

  @override
  String get prvBridgeConfirmAndBridge => 'Confirm & Bridge';

  @override
  String get prvBridgeContractLabel => 'Contract';

  @override
  String get prvBridgeCouldNotComplete => 'The bridge could not complete.';

  @override
  String get prvBridgeCurrentBalance => 'Current balance';

  @override
  String prvBridgeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get prvBridgeDetailsTitle => 'Bridge details';

  @override
  String get prvBridgeEnterPositive => 'Enter a positive amount';

  @override
  String get prvBridgeEstimatedTime => 'Estimated time: 2–5 minutes once submitted.';

  @override
  String prvBridgeEthAmount(String amount) {
    return '$amount ETH';
  }

  @override
  String get prvBridgeEthForGas => 'ETH for gas';

  @override
  String prvBridgeExceedsAvailable(String amount) {
    return 'Exceeds available ($amount vBTC)';
  }

  @override
  String get prvBridgeFailedBodyFallback => 'Open Bridge History for details.';

  @override
  String get prvBridgeFailedFallback => 'Bridge failed.';

  @override
  String get prvBridgeFailedHelp => 'Your vBTC may still be locked on VFX. Check Bridge History for details, or contact support if this persists.';

  @override
  String get prvBridgeFailedTitle => 'Bridge failed';

  @override
  String get prvBridgeFailedToStart => 'Failed to start bridge. Please try again.';

  @override
  String get prvBridgeFromVfx => 'from VFX';

  @override
  String get prvBridgeGasLowBalance => 'Low balance — gas costs vary. Top up the address above if the mint fails.';

  @override
  String get prvBridgeGasTitle => 'Gas (paid on Base)';

  @override
  String get prvBridgeGasZeroEth => 'This address pays the gas fee for the mint transaction on Base. Send a small amount of Base ETH (≈ 0.001 ETH) to the address above before bridging. You can fund it from any exchange or Base wallet that supports withdrawing to Base mainnet. Balance updates automatically every 10s — tap Refresh for an immediate check.';

  @override
  String get prvBridgeHideDetails => 'Hide details';

  @override
  String get prvBridgeHistoryLoadError => 'Couldn\'t load bridge history. Check your connection and try again.';

  @override
  String get prvBridgeHistoryLoading => 'Loading bridge history…';

  @override
  String get prvBridgeHistoryTitle => 'Bridge History';

  @override
  String prvBridgeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get prvBridgeInvalidBaseAddress => 'Must be a valid 0x Base address (40 hex chars)';

  @override
  String get prvBridgeJustNow => 'just now';

  @override
  String get prvBridgeLoadingStatus => 'Loading bridge status…';

  @override
  String prvBridgeLockId(String id) {
    return 'Lock ID: $id';
  }

  @override
  String prvBridgeMintedBody(String amount) {
    return '$amount vBTC.b minted on Base.';
  }

  @override
  String prvBridgeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String prvBridgeMonthsAgo(int months) {
    return '${months}mo ago';
  }

  @override
  String get prvBridgeNetworkInfo => 'Network info';

  @override
  String get prvBridgeNetworkLabel => 'Network';

  @override
  String get prvBridgeNoOperations => 'No bridge operations yet.';

  @override
  String get prvBridgeNothingAvailable => 'Nothing available to bridge yet.\n\nYour wallet may show a balance, but the chain doesn\'t see any confirmed vBTC for this contract yet. The most common cause is a BTC deposit that hasn\'t received enough Bitcoin confirmations. Bridge reservations from an earlier attempt could also be holding the balance.\n\nWait a few minutes and try again, or check Bridge History below for any in-flight operations.';

  @override
  String get prvBridgeOneWayDisclaimer => 'Bridging is one-way from this app. Once vBTC.b is on Base, use your DeFi provider or another Base (EVM) wallet to manage, transfer, or exit.';

  @override
  String get prvBridgeOneWayReminder => 'Reminder: this is one-way from this app. You\'ll use your DeFi provider or another Base (EVM) wallet for any further actions on vBTC.b.';

  @override
  String get prvBridgePasteDestination => 'Paste the destination address from your DeFi provider or Base wallet.';

  @override
  String get prvBridgeReconnecting => 'Reconnecting… the bridge service didn\'t respond to recent status checks. We\'ll keep retrying.';

  @override
  String get prvBridgeRetryFailedToast => 'Retry failed. See history detail for status.';

  @override
  String get prvBridgeRetrySubmitted => 'Retry submitted. Watching for status updates.';

  @override
  String get prvBridgeReviewBridge => 'Review Bridge';

  @override
  String get prvBridgeSafeToClose => 'Safe to close this dialog — your bridge will continue in the background. Track progress in Bridge History.';

  @override
  String get prvBridgeShowDetails => 'Show details';

  @override
  String prvBridgeSigsProgress(int collected, int required) {
    return '$collected / $required signatures collected';
  }

  @override
  String get prvBridgeStageCollectingSigs => 'Collecting validator signatures…';

  @override
  String get prvBridgeStageConfirmed => 'Confirmed on VFX';

  @override
  String get prvBridgeStageLockSubmitted => 'VFX lock submitted';

  @override
  String get prvBridgeStageMinted => 'Minted on Base';

  @override
  String get prvBridgeStageSigsCollected => 'Validator signatures collected';

  @override
  String get prvBridgeStageSubmittingMint => 'Submitting mint on Base';

  @override
  String get prvBridgeStalled => 'Taking longer than expected. Validator signing can occasionally lag — we\'ll keep watching. You can safely close this dialog; Bridge History will surface the final result.';

  @override
  String get prvBridgeStateLost => 'Bridge state lost. Close and try again.';

  @override
  String prvBridgeStepLock(String amount) {
    return 'Lock your $amount vBTC on VFX';
  }

  @override
  String get prvBridgeStepMint => 'Submit a mintWithProof transaction on Base (paid from your derived Base address)';

  @override
  String get prvBridgeStepWaitSignatures => 'Wait for validator signatures';

  @override
  String prvBridgeSuccessAmount(String amount) {
    return 'You now have $amount vBTC.b on Base';
  }

  @override
  String get prvBridgeSuccessTitle => 'Bridged to Base';

  @override
  String get prvBridgeThisWill => 'This will:';

  @override
  String get prvBridgeToBaseTitle => 'Bridge to Base';

  @override
  String prvBridgeToDestOnBase(String dest) {
    return 'to $dest on Base';
  }

  @override
  String get prvBridgeTxLabel => 'Tx';

  @override
  String get prvBridgeUnavailableCli => 'Bridging is currently unavailable. The CLI is not configured to talk to Base.';

  @override
  String get prvBridgeUnavailableNoAddress => 'Bridge unavailable — your Base address couldn\'t be derived. This usually means the wallet is locked. Unlock your wallet and try again.';

  @override
  String get prvBridgeUseDefiTo => 'Use your DeFi provider or another Base (EVM) wallet to:';

  @override
  String prvBridgeVbtcbAmount(String amount) {
    return '$amount vBTC.b';
  }

  @override
  String get prvBridgeVbtcbBalanceLabel => 'vBTC.b balance';

  @override
  String get prvBridgeViewDetails => 'View Details';

  @override
  String get prvBridgeViewOnBasescan => 'View on Basescan';

  @override
  String get prvBridgeWhatsNext => 'What\'s next?';

  @override
  String get prvBridgeYesterday => 'yesterday';

  @override
  String get prvBridgeYourBaseAddress => 'Your Base address';

  @override
  String get prvBridgeYourGasAddress => 'Your gas address';

  @override
  String get prvBridging => 'Bridging…';

  @override
  String get prvCheckingStatus => 'Checking privacy layer status...';

  @override
  String get prvChooseVbtcContract => 'Choose which vBTC contract to resync.';

  @override
  String get prvConfirmPasswordLabel => 'Confirm Password';

  @override
  String get prvConfirmPasswordTitle => 'Confirm Password';

  @override
  String get prvConsolidateAction => 'Consolidate';

  @override
  String get prvConsolidateMinNotes => 'At least 2 unspent notes are required to consolidate.';

  @override
  String get prvConsolidateNotesBody => 'Merge your 2 smallest notes into a single note. This reduces dust and improves privacy.';

  @override
  String get prvConsolidateNotesTitle => 'Consolidate Notes';

  @override
  String get prvConsolidateVbtcNotesBody => 'Merge your 2 smallest vBTC notes into a single note. This reduces dust and improves privacy.';

  @override
  String get prvConsolidateVbtcNotesTitle => 'Consolidate vBTC Notes';

  @override
  String get prvConsolidationBroadcastSuccess => 'Consolidation broadcast successfully';

  @override
  String prvConsolidationFailed(String error) {
    return 'Consolidation failed: $error';
  }

  @override
  String prvContractName(String name) {
    return 'Contract: $name';
  }

  @override
  String get prvCopyAddress => 'Copy address';

  @override
  String get prvCreatePasswordBody => 'Create a password to secure your shielded wallet\'s spending key. You\'ll need this password to unshield, transfer, or consolidate funds.';

  @override
  String get prvCreatePasswordTitle => 'Create Privacy Password';

  @override
  String prvCurrentNotes(int count) {
    return 'Current notes: $count';
  }

  @override
  String get prvEnterValidAmount => 'Please enter a valid amount';

  @override
  String get prvEnterValidVfxAddress => 'Please enter a valid VFX address';

  @override
  String get prvEnterValidZfxAddress => 'Please enter a valid zfx_ address';

  @override
  String get prvEnterVfxAddressHint => 'Enter VFX address';

  @override
  String get prvEnterViewingKey => 'Please enter the viewing key';

  @override
  String prvErrorActivatingWallet(String error) {
    return 'Error activating privacy wallet: $error';
  }

  @override
  String get prvExportViewingKey => 'Export Viewing Key';

  @override
  String get prvExportViewingKeyBody => 'Copy this key to import a view-only wallet on another device. This key can see balances but cannot spend.';

  @override
  String get prvFailedExportViewingKey => 'Failed to export viewing key';

  @override
  String get prvFailedGenerateShieldedAddress => 'Failed to generate shielded address';

  @override
  String get prvFailedImportViewingKey => 'Failed to import viewing key';

  @override
  String prvFeeDeductedFromShielded(String fee) {
    return 'Fee: $fee (deducted from shielded balance)';
  }

  @override
  String prvFeeDeductedFromShieldedVfx(String fee) {
    return 'Fee: $fee (deducted from shielded VFX balance)';
  }

  @override
  String prvFeeDeductedShieldedShort(String fee) {
    return '$fee fee deducted from shielded balance.';
  }

  @override
  String prvFeeDeductedShieldedVfxLong(String fee) {
    return 'A fee of $fee will be deducted from your shielded VFX balance.';
  }

  @override
  String prvFromAddress(String address) {
    return 'From: $address';
  }

  @override
  String get prvImportAction => 'Import';

  @override
  String get prvImportViewingKey => 'Import Viewing Key';

  @override
  String get prvImportViewingKeyBody => 'Import a viewing key to create a view-only wallet. You can see balances but cannot spend.';

  @override
  String get prvInsufficientVfxFee => 'Insufficient shielded VFX to cover the privacy transaction fee.';

  @override
  String get prvLayerStartingUp => 'Privacy Layer Starting Up';

  @override
  String get prvMax => 'Max';

  @override
  String prvMinHint(String amount) {
    return 'Min: $amount';
  }

  @override
  String prvMinShieldAmountVbtc(String amount) {
    return 'Minimum shield amount is $amount vBTC';
  }

  @override
  String prvMinShieldAmountVfx(String amount) {
    return 'Minimum shield amount is $amount VFX';
  }

  @override
  String get prvNoAccountsFound => 'No accounts found';

  @override
  String get prvNoShieldedAddress => 'No shielded address found';

  @override
  String get prvNoVbtcTokens => 'No vBTC tokens found';

  @override
  String get prvNoWalletSelected => 'No wallet selected';

  @override
  String prvNoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String get prvPasswordConfirmationFailed => 'Password confirmation failed';

  @override
  String get prvPasswordLabel => 'Password';

  @override
  String get prvPasswordRequired => 'Privacy wallet password required. Please unlock first.';

  @override
  String get prvPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get prvPasteBase64Hint => 'Paste Base64 key here';

  @override
  String get prvPlonkInitializing => 'The PLONK proof system is initializing. This may take a moment\nwhile cryptographic parameters are loaded.';

  @override
  String get prvPrismLayerTitle => 'PRISM Privacy Layer';

  @override
  String get prvPrivateTransferTitle => 'Private Transfer';

  @override
  String get prvPrivateTransferVbtcBody => 'Transfer shielded vBTC to another zfx_ address. Fully private.';

  @override
  String get prvPrivateTransferVbtcTitle => 'Private Transfer vBTC';

  @override
  String get prvPrivateTransferVfxBody => 'Transfer shielded VFX to another zfx_ address. Fully private.';

  @override
  String get prvRecipientInvalidZfx => 'Recipient must be a valid zfx_ address';

  @override
  String get prvRecipientZfxLabel => 'Recipient (zfx_ address)';

  @override
  String get prvRefresh => 'Refresh';

  @override
  String get prvResetAction => 'Reset';

  @override
  String get prvResetPrivacyWallet => 'Reset Privacy Wallet';

  @override
  String get prvResetWalletBody => 'This will clear your local privacy wallet state and return to the activation screen. Your shielded funds on the network are not affected — you can re-activate with the same account to recover them.\n\nContinue?';

  @override
  String get prvResyncAction => 'Resync';

  @override
  String get prvResyncComplete => 'Resync complete';

  @override
  String get prvResyncFailed => 'Resync failed';

  @override
  String get prvResyncShieldedWalletBody => 'This will wipe all cached notes and balances, then rescan from the beginning. This may take a while.\n\nContinue?';

  @override
  String get prvResyncShieldedWalletTitle => 'Resync Shielded Wallet';

  @override
  String get prvResyncStarted => 'Resync started...';

  @override
  String prvResyncVbtcBody(String name) {
    return 'This will wipe cached notes and balances for \"$name\" and rescan from the beginning. This may take a while.\n\nContinue?';
  }

  @override
  String get prvResyncVbtcWallet => 'Resync vBTC Wallet';

  @override
  String get prvResyncWallet => 'Resync Wallet';

  @override
  String get prvRetry => 'Retry';

  @override
  String get prvScreenTitle => 'PRISM Privacy';

  @override
  String get prvSelectFromAccounts => 'Select from my accounts';

  @override
  String get prvSelectVbtcContract => 'Select vBTC Contract';

  @override
  String get prvSettingsTooltip => 'Privacy settings';

  @override
  String get prvShieldAction => 'Shield';

  @override
  String get prvShieldBroadcastSuccess => 'Shield transaction broadcast successfully';

  @override
  String prvShieldFailed(String error) {
    return 'Shield failed: $error';
  }

  @override
  String get prvShieldVbtcBody => 'Move vBTC from your transparent wallet into the shielded pool.';

  @override
  String get prvShieldVbtcTitle => 'Shield vBTC';

  @override
  String get prvShieldVfxBody => 'Move VFX from your transparent wallet into the shielded pool.';

  @override
  String get prvShieldVfxTitle => 'Shield VFX';

  @override
  String get prvShieldedAddressLabel => 'Shielded Address';

  @override
  String get prvShieldedBalanceLabel => 'Shielded Balance';

  @override
  String get prvShieldedVbtcHeading => 'Shielded vBTC';

  @override
  String prvShieldedVfxRequiredBody(String balance, String fee) {
    return 'vBTC privacy operations require a small fee paid from your shielded VFX balance.\n\nYou currently have $balance shielded VFX.\nPlease shield at least $fee first.';
  }

  @override
  String get prvShieldedVfxRequiredTitle => 'Shielded VFX Required';

  @override
  String get prvToAddressLabel => 'To Address (transparent)';

  @override
  String get prvTransferAction => 'Transfer';

  @override
  String get prvTransferBroadcastSuccess => 'Private transfer broadcast successfully';

  @override
  String prvTransferFailed(String error) {
    return 'Private transfer failed: $error';
  }

  @override
  String get prvTransparentFeeAutoCalc => 'Transparent network fee will be auto-calculated.';

  @override
  String get prvTryAgain => 'Try again';

  @override
  String get prvUnlockAction => 'Unlock';

  @override
  String get prvUnlockBannerText => 'Enter your privacy password to unlock spending operations.';

  @override
  String get prvUnlockWalletBody => 'Enter your privacy wallet password to enable spending.';

  @override
  String get prvUnlockWalletTitle => 'Unlock Privacy Wallet';

  @override
  String get prvUnshieldAction => 'Unshield';

  @override
  String get prvUnshieldBroadcastSuccess => 'Unshield transaction broadcast successfully';

  @override
  String prvUnshieldFailed(String error) {
    return 'Unshield failed: $error';
  }

  @override
  String get prvUnshieldVbtcBody => 'Move vBTC from the shielded pool back to a transparent address.';

  @override
  String get prvUnshieldVbtcTitle => 'Unshield vBTC';

  @override
  String get prvUnshieldVfxBody => 'Move VFX from the shielded pool back to a transparent address.';

  @override
  String get prvUnshieldVfxTitle => 'Unshield VFX';

  @override
  String prvVbtcAmountSuffix(String amount) {
    return '$amount vBTC';
  }

  @override
  String get prvVbtcConsolidationBroadcastSuccess => 'vBTC consolidation broadcast successfully';

  @override
  String prvVbtcConsolidationFailed(String error) {
    return 'vBTC consolidation failed: $error';
  }

  @override
  String get prvVbtcResyncComplete => 'vBTC resync complete';

  @override
  String get prvVbtcResyncFailed => 'vBTC resync failed';

  @override
  String get prvVbtcResyncStarted => 'vBTC resync started...';

  @override
  String get prvVbtcShieldBroadcastSuccess => 'vBTC shield transaction broadcast successfully';

  @override
  String prvVbtcShieldFailed(String error) {
    return 'vBTC shield failed: $error';
  }

  @override
  String get prvVbtcTransferBroadcastSuccess => 'vBTC private transfer broadcast successfully';

  @override
  String prvVbtcTransferFailed(String error) {
    return 'vBTC private transfer failed: $error';
  }

  @override
  String get prvVbtcUnshieldBroadcastSuccess => 'vBTC unshield transaction broadcast successfully';

  @override
  String prvVbtcUnshieldFailed(String error) {
    return 'vBTC unshield failed: $error';
  }

  @override
  String prvVfxAmountSuffix(String amount) {
    return '$amount VFX';
  }

  @override
  String get prvViewOnly => 'VIEW ONLY';

  @override
  String get prvViewingKeyBase64Label => 'Viewing Key (Base64)';

  @override
  String get prvViewingKeyCopied => 'Viewing key copied to clipboard';

  @override
  String get prvViewingKeyImported => 'Viewing key imported successfully';

  @override
  String get prvViewingKeyTitle => 'Viewing Key';

  @override
  String prvWalletActivated(String address) {
    return 'Privacy wallet activated: $address';
  }

  @override
  String get prvWalletReset => 'Privacy wallet reset';

  @override
  String get prvWalletUnlocked => 'Privacy wallet unlocked';

  @override
  String get prvZfxAddressLabel => 'zfx_ Address';

  @override
  String get svcActionUpdate => 'Update';

  @override
  String get svcActivateVaultBeforeProceeding => 'You must activate your Vault Account before proceeding.';

  @override
  String get svcAddressOrDomainRequired => 'Address or VFX domain required';

  @override
  String svcAdnrDeleteConfirmBody(String costLine) {
    return 'Are you sure you want to delete this VFX Domain?\n$costLine\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.';
  }

  @override
  String get svcAdnrDeleteNoCost => 'There is no cost to delete a VFX Domain (aside from the TX fee).';

  @override
  String svcAdnrDeleteWithCost(String cost) {
    return 'There is a cost of $cost RBX to delete an RBX Domain.';
  }

  @override
  String get svcAdnrFundNeededBody => 'You don\'t have the required funds to buy the domain in this account.';

  @override
  String svcAdnrSufficientBalanceBody(String fromAddress, String balance) {
    return 'You have an account with a sufficient balance.\n\nWould you like to send 6 VFX from:\n$fromAddress\n[Balance: $balance VFX]?';
  }

  @override
  String get svcAmountPositive => 'The amount has to be a positive value';

  @override
  String get svcAmountRequired => 'Amount required';

  @override
  String get svcAssetsRequestFailed => 'Assets Request failed.';

  @override
  String svcBalanceRowFromTo(String from, String to) {
    return 'From: $from\nTo: $to';
  }

  @override
  String get svcBeaconSignatureError => 'Couldn\'t produce beacon upload signature';

  @override
  String get svcBeaconUploadRequestError => 'Could not create beacon upload request.';

  @override
  String get svcBtcAddressRequired => 'BTC Address required';

  @override
  String svcBtcSentToAddress(String amount, String address) {
    return '$amount BTC has been sent to $address.';
  }

  @override
  String get svcCliRestartRequiredBody => 'A restart of the CLI is required. Restart Now?';

  @override
  String get svcCliUpdateAvailableBody => 'A CLI update is available. Download and install now?';

  @override
  String get svcCliUpdateAvailableTitle => 'CLI Update Available';

  @override
  String get svcCliUpdatedTitle => 'CLI Updated';

  @override
  String get svcComplete => 'Complete';

  @override
  String get svcCouldNotParseEncryptedMessage => 'Could not parse encrypted message';

  @override
  String get svcCsvHeadersInvalid => 'The CSV headers are not in the correct format, please check the example file';

  @override
  String get svcDecryptFailed => 'Failed to decrypt message. Invalid key or corrupted data.';

  @override
  String get svcFailedParseFee => 'Failed to parse fee';

  @override
  String get svcFailedParseHash => 'Failed to parse hash';

  @override
  String get svcFailedRetrieveFee => 'Failed to retrieve fee';

  @override
  String get svcFailedRetrieveNonce => 'Failed to retrieve nonce';

  @override
  String get svcFailedRetrieveTimestamp => 'Failed to retrieve timestamp';

  @override
  String get svcGuiUpdateAvailableBody => 'A GUI update is available. Download now?';

  @override
  String get svcGuiUpdateAvailableTitle => 'GUI Update Available';

  @override
  String get svcGuiUpdateLaunchBody => 'The VFX GUI download will be launched in your browser. Once launched, the CLI will be shutdown and your wallet will be closed to ensure a safe update.';

  @override
  String get svcGuiUpdateTitle => 'GUI Update';

  @override
  String get svcImBackedUp => 'I\'m Backed Up';

  @override
  String svcImportSnapshotBody(String blockHeight, String snapshotHeight) {
    return 'You are only at $blockHeight block height locally. The network has a snapshot at $snapshotHeight block height that will help you sync more quickly. \n\nWould you like to import it now?';
  }

  @override
  String get svcImportSnapshotTitle => 'Import Snapshot?';

  @override
  String get svcInsufficientBalanceToSend => 'Insufficient balance to send';

  @override
  String get svcInvalidJson => 'Invalid JSON';

  @override
  String get svcLocatorsRequestFailed => 'Locators request failed.';

  @override
  String svcMainMenuSyncTooltip(String lastSync, String nextSync) {
    return 'Last Sync: $lastSync\nNext Sync: $nextSync';
  }

  @override
  String get svcMessageDecryptedSuccess => 'Message decrypted successfully!';

  @override
  String svcMinTxAmountBtc(String amount) {
    return 'The minimum transaction amount is $amount BTC';
  }

  @override
  String svcMintingProgress(String current, String total) {
    return 'Minting $current/$total...';
  }

  @override
  String get svcNavPrivacyLabel => 'Privacy';

  @override
  String get svcNftNotEnoughVfxAction => 'Not enough VFX to do this action';

  @override
  String get svcNftNotLoaded => 'NFT not loaded';

  @override
  String get svcNftNotOwner => 'You are not the owner of this NFT.';

  @override
  String get svcNftNotOwnerOrMinter => 'You are not the owner or minter of this NFT.';

  @override
  String get svcNoAccountSelectedPeriod => 'No account selected.';

  @override
  String get svcNoBtcAccount => 'No BTC Account';

  @override
  String get svcNoEncryptedMessage => 'No encrypted message found';

  @override
  String get svcNotEnoughBalanceAccount => 'Not enough balance in account.';

  @override
  String get svcNotEnoughBalanceBtcAccount => 'Not enough balance in BTC account';

  @override
  String get svcNotValidAmount => 'Not a valid amount';

  @override
  String svcNotifBtcDomainCreatedBody(String name) {
    return 'BTC Domain created for $name.btc';
  }

  @override
  String get svcNotifBtcDomainCreatedTitle => 'BTC Domain Name Created';

  @override
  String svcNotifBtcDomainDeletedBody(String name) {
    return 'BTC Domain deleted for $name';
  }

  @override
  String get svcNotifBtcDomainDeletedTitle => 'BTC Domain Name Deleted';

  @override
  String get svcNotifBtcDomainTransferredTitle => 'BTC Domain Name Transferred';

  @override
  String get svcNotifDecShopTxBody => 'DecShop TX Complete';

  @override
  String get svcNotifDecShopTxTitle => 'DecShop TX';

  @override
  String get svcNotifDomainCreatedTitle => 'Domain Name Created';

  @override
  String get svcNotifDomainDeletedTitle => 'Domain Name Deleted';

  @override
  String get svcNotifDomainTransferredTitle => 'Domain Name Transferred';

  @override
  String svcNotifFundsReceivedBody(String amount, String fromAddress) {
    return '$amount VFX from $fromAddress';
  }

  @override
  String get svcNotifFundsReceivedTitle => 'Funds Received';

  @override
  String svcNotifFundsSentBody(String amount, String toAddress) {
    return '$amount VFX to $toAddress';
  }

  @override
  String get svcNotifNftBurnedTitle => 'NFT Burned';

  @override
  String svcNotifNftEvolvedBody(String state) {
    return 'NFT evolved to state $state.';
  }

  @override
  String get svcNotifNftEvolvedTitle => 'NFT Evolved';

  @override
  String get svcNotifNftMintedTitle => 'NFT Minted';

  @override
  String svcNotifNftReceivedBody(String fromAddress) {
    return 'NFT from $fromAddress';
  }

  @override
  String get svcNotifNftReceivedTitle => 'NFT Received';

  @override
  String svcNotifNftSentBody(String toAddress) {
    return 'NFT to $toAddress';
  }

  @override
  String get svcNotifNftSentTitle => 'NFT Sent';

  @override
  String get svcNotifPaused => 'Paused';

  @override
  String get svcNotifResumed => 'Resumed';

  @override
  String get svcNotifSaleCompletedManualTitle => 'Sale Completed (Manual)';

  @override
  String get svcNotifSaleCompletedTitle => 'Sale Completed';

  @override
  String get svcNotifSaleStartedManualTitle => 'Sale Started (Manual)';

  @override
  String get svcNotifSaleStartedTitle => 'Sale Started';

  @override
  String get svcNotifTokenBanAddressTitle => 'Token Ban Address';

  @override
  String get svcNotifTokenBurnTitle => 'Token Burn';

  @override
  String get svcNotifTokenChangeOwnershipTitle => 'Token Change Ownership';

  @override
  String get svcNotifTokenDeployedTitle => 'Token Deployed';

  @override
  String get svcNotifTokenPauseTitle => 'Token Pause';

  @override
  String get svcNotifTokenTopicCreatedTitle => 'Token Topic Created';

  @override
  String get svcNotifTokenTransferTitle => 'Token Transfer';

  @override
  String get svcNotifTokenVoteCastTitle => 'Token Vote Cast';

  @override
  String get svcNotifTokensMintedTitle => 'Tokens Minted';

  @override
  String svcNotifTopicCreatedBody(String name) {
    return 'Topic $name Created.';
  }

  @override
  String get svcNotifTopicCreatedTitle => 'Topic Created';

  @override
  String get svcNotifVbtcTokenizationMintTitle => 'vBTC Tokenization Mint';

  @override
  String svcNotifVfxDomainCreatedBody(String name) {
    return 'VFX Domain created for $name.vfx';
  }

  @override
  String svcNotifVfxDomainDeletedBody(String name) {
    return 'VFX Domain deleted for $name';
  }

  @override
  String svcNotifVfxDomainTransferBody(String name) {
    return 'VFX Domain transfer for $name';
  }

  @override
  String svcNotifVoteCastedBody(String topic) {
    return 'Vote casted on $topic';
  }

  @override
  String get svcNotifVoteCastedTitle => 'Vote Casted';

  @override
  String get svcPrivateKeyNotAvailableUnlock => 'Private key not available. Please ensure wallet is unlocked.';

  @override
  String get svcPrivateKeyNotFoundRecipient => 'Private key not found for recipient address';

  @override
  String svcProblemDownloadingSkipping(String url) {
    return 'Problem downloading $url. Skipping.';
  }

  @override
  String svcSendingConfirmBtcFee(String amount, String toAddress, String fromAddress, String fee) {
    return 'Sending:\n$amount BTC\n\nTo:\n$toAddress\n\nFrom:\n$fromAddress\n\nFee:\n$fee BTC';
  }

  @override
  String svcSendingConfirmBtcFeeRate(String amount, String toAddress, String fromAddress, String feeRate) {
    return 'Sending:\n$amount BTC\n\nTo:\n$toAddress\n\nFrom:\n$fromAddress\n\nFeeRate:\n$feeRate SATS';
  }

  @override
  String get svcSignatureGenerationFailed => 'Signature generation failed.';

  @override
  String get svcSignatureNotValid => 'Signature not valid';

  @override
  String get svcSnapshotBackupWarningBody => 'Be sure your private keys are backed up as this process will wipe your database folder.\n\nIf they are NOT backed up, click cancel now, back them up, and then restart your wallet to be prompted with this again.';

  @override
  String get svcSnapshotDetermineStateError => 'Could not determine latest snapshot state';

  @override
  String get svcSnapshotImportFailedBody => 'Snapshot import failed.';

  @override
  String get svcSnapshotImportFailedTitle => 'Import Failed';

  @override
  String get svcSnapshotRestartTryAgain => 'Please restart and try again.';

  @override
  String get svcTimelockDuration => 'Timelock Duration';

  @override
  String get svcTimelockHoursLabel => 'Hours (24 Minimum)';

  @override
  String svcTokenAutoMintInitiated(String scId, String amount) {
    return 'Token Auto Mint initiated. ($scId: $amount)';
  }

  @override
  String get svcTransactionNotValid => 'Transaction not valid';

  @override
  String get svcUnimplemented => 'Unimplemented';

  @override
  String svcValidTxConfirmBody(String toAddress, String amount) {
    return 'This transaction is valid and is ready to send.\nAre you sure you want to proceed?\n\nTo: $toAddress\n\nAmount: $amount VFX';
  }

  @override
  String svcValidTxFeeSuffix(String fee, String total) {
    return '\nTX Fee: $fee VFX\nTotal: $total VFX';
  }

  @override
  String get svcVaultAutoActivationInitiated => 'Vault Account Auto Activation process initiated';

  @override
  String svcVfxSentToAddress(String amount, String address) {
    return '$amount VFX sent to $address';
  }

  @override
  String svcVfxSentToAddressDashboard(String amount, String address) {
    return '$amount VFX has been sent to $address. See dashboard for TX ID.';
  }

  @override
  String get r3aActivatingSoon => 'Activating soon...';

  @override
  String get r3aAdditionalOwners => 'Additional Owners';

  @override
  String get r3aAssetIsRequired => 'Asset is required';

  @override
  String get r3aAssets => 'Assets';

  @override
  String get r3aAutomatedAppControlled => 'Automated/Application Controlled';

  @override
  String r3aBlockHeightMustBeGreaterThan(String currentBh) {
    return 'Block height must be greater than $currentBh.';
  }

  @override
  String get r3aBtcTokenization => 'BTC Tokenization';

  @override
  String get r3aChooseAFile => 'Choose a File';

  @override
  String get r3aClearNftWizardTitle => 'Clear NFT Collection Wizard?';

  @override
  String get r3aCloseNftWizardConfirm => 'Are you sure you want to close the NFT collection Wizard?';

  @override
  String get r3aCloseScCreatorConfirm => 'Are you sure you want to close the smart contract creator?';

  @override
  String get r3aCompileMintScConfirm => 'Compile & Mint Smart Contract?';

  @override
  String r3aConfirmMintBody(String amount) {
    return 'Are you sure you want to proceed minting $amount Smart Contract(s)?\n\nOnce compiled you will not be able to make any changes\nand the smart contract will be deployed to the chain.';
  }

  @override
  String get r3aConsumable => 'Consumable';

  @override
  String get r3aCreateInstance => 'Create Instance';

  @override
  String get r3aCreateNewInstance => 'Create New Instance';

  @override
  String get r3aCreateNewPhase => 'Create New Phase';

  @override
  String get r3aCreateRarity => 'Create Rarity';

  @override
  String get r3aCreatorRetainedOwnership => 'Creator Retained Ownership';

  @override
  String get r3aDateMustBeInFuture => 'Date must be in the future.';

  @override
  String get r3aDateTime => 'Date/Time';

  @override
  String get r3aDeleteInstanceConfirm => 'Are you sure you want to delete this instance?';

  @override
  String get r3aDeleteInstanceTitle => 'Delete Instance?';

  @override
  String get r3aDeleteStage => 'Delete Stage';

  @override
  String get r3aDeleteThisStageConfirm => 'Are you sure you want to delete this stage?';

  @override
  String get r3aDescriptionIsRequired => 'Description is required';

  @override
  String get r3aEditRarity => 'Edit Rarity';

  @override
  String r3aEvolutionTime(String tz) {
    return 'Evolution Time ($tz)';
  }

  @override
  String get r3aEvolutionType => 'Evolution Type';

  @override
  String r3aEvolveStageNumber(String number) {
    return 'Evolve Stage $number';
  }

  @override
  String get r3aEvolvingMode => 'Evolving Mode';

  @override
  String get r3aFeatureDescBtcTokenization => 'Tokenize BTC within a smart contract';

  @override
  String get r3aFeatureDescEvolution => 'Allow the smart contract to evolve based on time or network variables';

  @override
  String get r3aFeatureDescFractional => 'Share ownership between multiple wallets and support voting';

  @override
  String get r3aFeatureDescMultiAsset => 'Allow multiple assets to be compiled into the smart contract';

  @override
  String get r3aFeatureDescPair => 'Pair/Wrap this smart contract with an existing NFT on or off this network';

  @override
  String get r3aFeatureDescRoyalty => 'Include a royalty that is enforced on-chain upon any trade';

  @override
  String get r3aFeatureDescSoulBound => 'Create a non-transferrable smart contract bound to a perminent address';

  @override
  String get r3aFeatureDescTokenization => 'Pair this smart contract with a physical/digital good';

  @override
  String get r3aFeatureNameEvolving => 'Evolving';

  @override
  String get r3aInvalidHexColor => 'Invalid hex color';

  @override
  String get r3aInvalidSmartContract => 'Invalid Smart Contract';

  @override
  String get r3aInvalidValue => 'Invalid value';

  @override
  String get r3aIssuerMinterControlled => 'Issuer/Minter Controlled';

  @override
  String get r3aLabel => 'Label';

  @override
  String get r3aMint => 'Mint';

  @override
  String get r3aMintPhysicalRwa => 'Mint a physical or Real World Asset';

  @override
  String get r3aMinterAddressColon => 'Minter Address:';

  @override
  String get r3aMinterNameIsRequired => 'Minter name is required';

  @override
  String get r3aMultiAsset => 'Multi Asset';

  @override
  String get r3aMusicRelease => 'Music Release';

  @override
  String get r3aNameIsRequired => 'Name is required';

  @override
  String get r3aNewInstance => 'New Instance';

  @override
  String get r3aNftAddress => 'NFT Address';

  @override
  String get r3aNftCollectionWizard => 'NFT Collection Wizard';

  @override
  String get r3aNotEnoughVfxToMint => 'Not enough VFX balance to mint a smart contract.';

  @override
  String get r3aNotImplemented => 'Not implemented';

  @override
  String get r3aOnlineEvent => 'Online Event';

  @override
  String get r3aPhysicalEvent => 'Physical Event';

  @override
  String get r3aPrimaryAssetIsRequired => 'Primary Asset is required';

  @override
  String get r3aPrimaryAssetOverride => 'Primary Asset Override';

  @override
  String get r3aRareness => 'Rareness';

  @override
  String get r3aReason => 'Reason';

  @override
  String get r3aRemoveEverythingConfirm => 'Are you sure you want to remove everything?';

  @override
  String get r3aRequiredForBlockHeightEvolution => 'Required for Block Height evolution.';

  @override
  String get r3aRequiredForDateTimeEvolution => 'Required for Date/Time evolution.';

  @override
  String get r3aSaveAndClose => 'Save and Close';

  @override
  String get r3aSaveClose => 'Save & Close';

  @override
  String get r3aSelfDestructive => 'Self Destructive';

  @override
  String get r3aStatsOverride => 'Stats Override';

  @override
  String get r3aThumbnailOverride => 'Thumbnail Override';

  @override
  String get r3aTicketing => 'Ticketing';

  @override
  String get r3aTimeMustBeInFuture => 'Time must be in the future.';

  @override
  String get r3aToken => 'Token';

  @override
  String get r3aTokenizationPhysicalDigital => 'Tokenization of Physical/Digital Good';

  @override
  String get r3aValueIsRequired => 'Value is required';

  @override
  String get r3aViewCompiledSmartContract => 'View Compiled Smart Contract';

  @override
  String r3aWillBeMintedBy(String name) {
    return 'This will be minted by $name';
  }

  @override
  String get r3aWrap => 'Wrap';

  @override
  String get r3bActionCreation => 'creation';

  @override
  String get r3bActionEditing => 'editing';

  @override
  String get r3bActionPublish => 'Publish';

  @override
  String get r3bActive => 'Active:';

  @override
  String get r3bAddBeaconDescription => 'Add an existing beacon to foreign nodes to use that relay instead of default ones on the VFX network. Configure your wallet to use a remote beacon for media transferring rather than using the default VFX network beacons. You will need to know the IP address of the remote beacon. If that beacon is using the non-default port, provide that as well. The beacon name is a friendly name visible only to you.';

  @override
  String get r3bAddressRequired => 'Address Required.';

  @override
  String get r3bAlreadyOwnerNft => 'You are already the owner of this NFT.';

  @override
  String r3bAmountValue(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get r3bApproveSaleStart => 'Please approve the Sale Start TX for your shop purchase.';

  @override
  String get r3bAssetCache => 'Asset Cache';

  @override
  String get r3bAuctionEnds => 'Auction Ends';

  @override
  String get r3bAutoDeleteAssets => 'Auto Delete Assets';

  @override
  String get r3bBaselineAsset => 'Baseline Asset';

  @override
  String get r3bBeaconUploadSigFailed => 'Couldn\'t produce beacon upload signature';

  @override
  String get r3bBidAmount => 'Bid Amount';

  @override
  String get r3bBidNotFound => 'Error: Bid not found.';

  @override
  String get r3bBuyNowTag => '[Buy Now]';

  @override
  String r3bBuyerLabel(String address) {
    return 'Buyer: $address';
  }

  @override
  String get r3bChain => 'Chain';

  @override
  String r3bCloseCollectionConfirm(String action) {
    return 'Are you sure you want to close the collection $action screen?';
  }

  @override
  String r3bCloseShopConfirm(String action) {
    return 'Are you sure you want to close the shop $action screen?';
  }

  @override
  String r3bCloseStoreConfirm(String action) {
    return 'Are you sure you want to close the store $action screen?';
  }

  @override
  String get r3bCollectionCreatedToast => 'Collection Created';

  @override
  String get r3bCollectionUpdatedToast => 'Collection Updated!';

  @override
  String get r3bCollections => 'Collections';

  @override
  String get r3bCouldNotCreateThread => 'Could not create or get thread';

  @override
  String get r3bCouldNotLogin => 'Could not login';

  @override
  String get r3bCouldNotVerifyTx => 'Could not verify transaction.';

  @override
  String get r3bCreateAuctionHouse => 'Create Auction House';

  @override
  String get r3bCreateCollectionsHint => 'Now you can create collections and then add listings to them.';

  @override
  String get r3bCreateListingsHint => 'Now you can create listings for the NFTs you own.';

  @override
  String get r3bCreateNewCollection => 'Create New Collection';

  @override
  String get r3bCurrentBidPrice => 'Current Bid Price:';

  @override
  String get r3bCurrentBids => 'Current Bids';

  @override
  String get r3bDay => 'Day';

  @override
  String get r3bDays => 'Days';

  @override
  String get r3bDeleteListingConfirm => 'Are you sure you want to delete this listing?';

  @override
  String get r3bDeleteShopConfirm => 'Are you sure you want to delete this shop?';

  @override
  String r3bDeleteShopConfirmPublished(String cost) {
    return 'Are you sure you want to delete this shop? There is a cost of $cost VFX to delete this from the network.';
  }

  @override
  String get r3bEditAuctionHouse => 'Edit Auction House';

  @override
  String get r3bEnableOneOption => 'Enable at least one of the options (Gallery, Buy Now, or Auction)';

  @override
  String get r3bEndDateAfterStart => 'End date must be after the start date';

  @override
  String get r3bEndsIn => 'Ends in';

  @override
  String get r3bErrorGeneratingScData => 'Error generating smart contract data';

  @override
  String get r3bFailedParseFee => 'Failed to parse fee';

  @override
  String get r3bFailedParseHash => 'Failed to parse hash';

  @override
  String get r3bFailedRetrieveNonce => 'Failed to retrieve nonce';

  @override
  String get r3bFailedRetrieveTimestamp => 'Failed to retrieve timestamp';

  @override
  String get r3bIdentifier => 'Identifier';

  @override
  String get r3bImportAndPublish => 'Import & Publish';

  @override
  String get r3bImportShopBroadcastBody => 'Once the transaction relects on chain, your shop will appear here.';

  @override
  String r3bImportShopConfirmBody(String cost) {
    return 'Are you sure you want to import this shop? A $cost VFX fee will be charged to publish this change to the network.\n\nThis is a destructive action and will not carry over your collections and listings.';
  }

  @override
  String r3bIncorrectLoginDetails(String address) {
    return 'Incorrect login details for $address.';
  }

  @override
  String get r3bIncrementAmount => 'Increment Amount:';

  @override
  String get r3bInfinite => 'Infinite';

  @override
  String r3bLabelCopied(String label) {
    return '$label copied to clipboard';
  }

  @override
  String get r3bLoggedInSuccess => 'Logged in successfully';

  @override
  String get r3bMintedBy => 'Minted By';

  @override
  String get r3bMinterAddress => 'Minter Address';

  @override
  String get r3bMyShopSuffix => ' [My Shop]';

  @override
  String get r3bNftFeatures => 'NFT Features:';

  @override
  String get r3bNftMustBeSet => 'The NFT must be set';

  @override
  String get r3bNoAddress => 'No address.';

  @override
  String get r3bNoAuctionHouses => 'No Auction Houses';

  @override
  String get r3bNoBids => 'No bids.';

  @override
  String get r3bNoCollections => 'No Collections';

  @override
  String get r3bNoListings => 'No Listings';

  @override
  String get r3bNoPrivateKey => 'No private key.';

  @override
  String get r3bNoPublicKey => 'No public key.';

  @override
  String get r3bNotAuthorized => 'Not Authorized';

  @override
  String r3bNotOwnerLoginAs(String address) {
    return 'You are not the owner of this shop. Please login as $address';
  }

  @override
  String get r3bOffline => 'Offline';

  @override
  String get r3bOnline => 'Online';

  @override
  String get r3bOr => 'or';

  @override
  String get r3bOwnedBy => 'Owned by';

  @override
  String get r3bPrivateTag => '[Private]';

  @override
  String r3bPublishShopBody(String cost) {
    return 'There is a cost of $cost VFX to publish your shop to the network (plus the transaction fee).';
  }

  @override
  String get r3bReadyToImport => 'Ready to Import';

  @override
  String get r3bReserveGteFloor => 'The reserve price must be greater or equal to the floor price.';

  @override
  String get r3bReserveMet => 'Reserve Met:';

  @override
  String get r3bSaleCompleted => 'Sale has Completed';

  @override
  String get r3bSalePending => 'Sale is Pending';

  @override
  String get r3bSaveChanges => 'Save Changes';

  @override
  String get r3bSetupAuctionHouse => 'Setup Auction House';

  @override
  String get r3bSetupAuctionHousePrompt => 'First, setup your auction house / gallery.\nThen you\'ll be able to create collections and add listings to them.';

  @override
  String get r3bShareListing => 'Share Listing';

  @override
  String get r3bShareUrlCopied => 'Share url copied to clipboard';

  @override
  String get r3bShopDeleteBroadcast => 'Shop Delete transaction broadcasted to the network';

  @override
  String get r3bShopIsOffline => 'Shop is offline.';

  @override
  String get r3bShopNotFound => 'Shop Not Found';

  @override
  String get r3bShopPublishBroadcast => 'Shop Publish transaction broadcasted to the network';

  @override
  String get r3bShopUpdateBroadcast => 'Shop Update transaction broadcasted to the network';

  @override
  String get r3bShopUrlImportPrompt => 'What is the shop URL you\'d like to import?';

  @override
  String get r3bShopUrlNotAvailable => 'Shop URL is not available.';

  @override
  String get r3bSignInToAuthorize => 'To authorize this transaction, you must sign in as';

  @override
  String get r3bSignatureNotValidPrimary => 'Signature not valid (primary)';

  @override
  String r3bSmartContractId(String id) {
    return 'Smart Contract ID: $id';
  }

  @override
  String get r3bStartBeforeEnd => 'The start date must be before the end date.';

  @override
  String get r3bSubscribeUpdatesBody => 'In order for the web wallet to provide notifications about bids/purchases for you to sign the transactions, an email address is required.';

  @override
  String get r3bThisIsPermanent => 'This is permanent';

  @override
  String get r3bThisIsYourShop => 'This is your own shop.';

  @override
  String get r3bTransactionSent => 'Transaction Sent.';

  @override
  String get r3bUnpublished => 'Unpublished';

  @override
  String r3bUpdateShopBody(String cost) {
    return 'There is a cost of $cost VFX to update your shop on the network (plus the transaction fee).';
  }

  @override
  String get r3bUpdateShopTitle => 'Update Shop?';

  @override
  String get r3bWalletNotSyncedBody => 'Since your wallet is not synced there may be some issues viewing the data in this shop. Continue anyway?';

  @override
  String get r3bWillNotBeNotified => 'You will not be notified. You can update this setting on the dashboard if you change your mind.';

  @override
  String get r3bYouAreShopOwner => 'You are the owner of this shop.';

  @override
  String r3cCallbackFromDetails(String text, String amount, String address) {
    return '$text [$amount VFX from $address]';
  }

  @override
  String get r3cNoTransactionsFound => 'No Transactions Found';

  @override
  String get r3cNoTransactionsFoundFiltered => 'No Transactions Found\n[with current filters]';

  @override
  String get r3cPriceHistoryBtc => 'BTC Price History';

  @override
  String get r3cPriceHistoryVfx => 'VFX Price History';

  @override
  String get r3cStatusCalledBack => 'Called Back';

  @override
  String get r3cStatusFail => 'Fail';

  @override
  String get r3cStatusRecovered => 'Recovered';

  @override
  String get r3cTypeAdnr => 'ADNR';

  @override
  String get r3cTypeAdnrCreate => 'ADNR Create';

  @override
  String get r3cTypeAdnrDelete => 'ADNR Delete';

  @override
  String get r3cTypeAdnrTransfer => 'ADNR Transfer';

  @override
  String get r3cTypeAuctionHouseCreate => 'P2P Auction House (Create)';

  @override
  String get r3cTypeAuctionHouseDelete => 'P2P Auction House (Delete)';

  @override
  String get r3cTypeAuctionHouseUpdate => 'P2P Auction House (Update)';

  @override
  String get r3cTypeBtcAdnrCreate => 'BTC ADNR Create';

  @override
  String get r3cTypeBtcAdnrDelete => 'BTC ADNR Delete';

  @override
  String get r3cTypeBtcAdnrTransfer => 'BTC ADNR Transfer';

  @override
  String get r3cTypeDstRegistration => 'DST Registration';

  @override
  String get r3cTypeFungibleBanAddress => 'Fungible Token Ban Address';

  @override
  String get r3cTypeFungibleBurn => 'Fungible Token Burn';

  @override
  String get r3cTypeFungibleDeploy => 'Fungible Token Deploy';

  @override
  String get r3cTypeFungibleMint => 'Fungible Token Mint';

  @override
  String get r3cTypeFungibleOwnershipChange => 'Fungible Token Ownership Change';

  @override
  String get r3cTypeFungiblePause => 'Fungible Token Pause';

  @override
  String get r3cTypeFungibleResume => 'Fungible Token Resume';

  @override
  String get r3cTypeFungibleTopicCreated => 'Fungible Token Topic Created';

  @override
  String get r3cTypeFungibleTransfer => 'Fungible Token Transfer';

  @override
  String get r3cTypeFungibleTx => 'Fungible Token TX';

  @override
  String get r3cTypeFungibleVoteCast => 'Fungible Token Vote Cast';

  @override
  String get r3cTypeNftBurn => 'NFT Burn';

  @override
  String get r3cTypeNftEvolution => 'NFT Evolution';

  @override
  String get r3cTypeNftMint => 'NFT Mint';

  @override
  String get r3cTypeNftMintTokenized => 'NFT Mint (Tokenized)';

  @override
  String get r3cTypeNftSale => 'NFT Sale';

  @override
  String get r3cTypeNftSaleComplete => 'NFT Sale Complete';

  @override
  String get r3cTypeNftSaleCompleteManual => 'NFT Sale Complete (Manual)';

  @override
  String get r3cTypeNftSaleCompleteParen => 'NFT Sale (Complete)';

  @override
  String get r3cTypeNftSaleStart => 'NFT Sale Start';

  @override
  String get r3cTypeNftSaleStartManual => 'NFT Sale Start (Manual)';

  @override
  String get r3cTypeNftTransfer => 'NFT Transfer';

  @override
  String get r3cTypeNftTx => 'NFT Tx';

  @override
  String get r3cTypeNode => 'Node';

  @override
  String get r3cTypeSmartContractBurn => 'Smart Contract Burn';

  @override
  String get r3cTypeSmartContractMint => 'Smart Contract Mint';

  @override
  String get r3cTypeSmartContractTx => 'Smart Contract TX';

  @override
  String get r3cTypeTokenizationBurn => 'Tokenization Burn';

  @override
  String get r3cTypeTokenizationMint => 'Tokenization Mint';

  @override
  String get r3cTypeTokenizationTx => 'Tokenization TX';

  @override
  String get r3cTypeTokenizationWithdrawalComplete => 'Tokenization Withdrawal Complete';

  @override
  String get r3cTypeTokenizationWithdrawalRequest => 'Tokenization Withdrawal Request';

  @override
  String get r3cTypeTopicCreate => 'Topic Create';

  @override
  String get r3cTypeTopicVote => 'Topic Vote';

  @override
  String get r3cTypeTx => 'Tx';

  @override
  String get r3cTypeValidatorHeartbeat => 'Validator Heartbeat';

  @override
  String get r3cTypeValidatorRegistration => 'Validator Registration';

  @override
  String get r3cTypeVault => 'Vault';

  @override
  String get r3cTypeVaultCallback => 'Vault (Callback)';

  @override
  String get r3cTypeVaultRecover => 'Vault (Recover)';

  @override
  String get r3cTypeVaultRegister => 'Vault (Register)';

  @override
  String get r3cTypeVbtcBridgeLock => 'vBTC Bridge Lock';

  @override
  String get r3cTypeVbtcBridgeUnlock => 'vBTC Bridge Unlock';

  @override
  String get r3cTypeVbtcBulkTransfer => 'vBTC Bulk Transfer';

  @override
  String get r3cTypeVbtcBurn => 'vBTC Burn';

  @override
  String get r3cTypeVbtcContractCreate => 'vBTC Contract Create';

  @override
  String get r3cTypeVbtcContractMint => 'vBTC Contract Mint';

  @override
  String get r3cTypeVbtcMint => 'vBTC Mint';

  @override
  String get r3cTypeVbtcPrivateTransfer => 'vBTC Private Transfer';

  @override
  String get r3cTypeVbtcShield => 'vBTC Shield';

  @override
  String get r3cTypeVbtcTokenOwnershipTransfer => 'vBTC Token Ownership Transfer';

  @override
  String get r3cTypeVbtcTransfer => 'vBTC Transfer';

  @override
  String get r3cTypeVbtcTransferCoin => 'vBTC Transfer Coin';

  @override
  String get r3cTypeVbtcTx => 'vBTC TX';

  @override
  String get r3cTypeVbtcUnshield => 'vBTC Unshield';

  @override
  String get r3cTypeVbtcValidatorExit => 'vBTC Validator Exit';

  @override
  String get r3cTypeVbtcValidatorHeartbeat => 'vBTC Validator Heartbeat';

  @override
  String get r3cTypeVbtcValidatorRegister => 'vBTC Validator Register';

  @override
  String get r3cTypeVbtcWithdrawalArb => 'vBTC Withdrawal (Arb)';

  @override
  String get r3cTypeVbtcWithdrawalCancel => 'vBTC Withdrawal Cancel';

  @override
  String get r3cTypeVbtcWithdrawalComplete => 'vBTC Withdrawal Complete';

  @override
  String get r3cTypeVbtcWithdrawalOwner => 'vBTC Withdrawal (Owner)';

  @override
  String get r3cTypeVbtcWithdrawalRequest => 'vBTC Withdrawal Request';

  @override
  String get r3cTypeVbtcWithdrawalVote => 'vBTC Withdrawal Vote';

  @override
  String get r3cTypeVfxPrivateTransfer => 'VFX Private Transfer';

  @override
  String get r3cTypeVfxShield => 'VFX Shield';

  @override
  String get r3cTypeVfxUnshield => 'VFX Unshield';

  @override
  String get r3dActivate => 'Activate';

  @override
  String r3dActivateVaultBody(String cost) {
    return 'There is a cost of $cost VFX to activate your Vault Account which is burned.\n\nContinue?';
  }

  @override
  String get r3dActivateVaultTitle => 'Activate Vault Account?';

  @override
  String get r3dActivationTxBroadcasted => 'Activation transaction broadcasted';

  @override
  String get r3dActivity => 'Activity';

  @override
  String get r3dAddressRequired => 'Address Required.';

  @override
  String get r3dAttemptingSaleCompleteTx => 'Attempting to send sale complete TX.';

  @override
  String get r3dAuctionAlreadyStarted => 'The auction has already started.';

  @override
  String get r3dAwaitingPayment => 'Awaiting Payment';

  @override
  String get r3dBackupAddress => 'Address:';

  @override
  String get r3dBackupPrivateKey => 'Private Key:';

  @override
  String get r3dBackupRecoveryAddress => 'Recovery Address:';

  @override
  String get r3dBackupRecoveryPrivateKey => 'Recovery Private Key:';

  @override
  String get r3dBackupRestoreCode => 'Restore Code:';

  @override
  String get r3dBeingClaimed => 'Being Claimed';

  @override
  String get r3dBtcExplorer => 'BTC Explorer';

  @override
  String r3dBuyNowPriceLabel(String price) {
    return 'Buy Now: $price VFX';
  }

  @override
  String get r3dCantDeleteAuctionStarted => 'You can\'t delete this listing because the auction has already started.';

  @override
  String get r3dChat => 'Chat';

  @override
  String get r3dChooseNft => 'Choose NFT';

  @override
  String get r3dClaimed => 'Claimed';

  @override
  String get r3dCliRestartBody => 'A CLI restart is required for this change to take effect. Would you like to restart now?';

  @override
  String get r3dCloseCollectionCreationConfirm => 'Are you sure you want to close the collection creation screen?';

  @override
  String get r3dCloseCollectionEditingConfirm => 'Are you sure you want to close the collection editing screen?';

  @override
  String get r3dCloseListingCreationConfirm => 'Are you sure you want to close the listing creation screen?';

  @override
  String get r3dCloseListingEditingConfirm => 'Are you sure you want to close the listing editing screen?';

  @override
  String get r3dCloseShopCreationConfirm => 'Are you sure you want to close the shop creation screen?';

  @override
  String get r3dCloseShopEditingConfirm => 'Are you sure you want to close the shop editing screen?';

  @override
  String get r3dCloseStoreCreationConfirm => 'Are you sure you want to close the store creation screen?';

  @override
  String get r3dCloseStoreEditingConfirm => 'Are you sure you want to close the store editing screen?';

  @override
  String get r3dCollectionLiveHelp => 'When this is enabled, this collection will be visible to other users when they connect to your shop';

  @override
  String get r3dConfirmDeleteListing => 'Are you sure you want to delete this listing?';

  @override
  String r3dConfirmDeletePublishedShop(String cost) {
    return 'Are you sure you want to delete this shop from the network? There is a cost of $cost VFX plus TX fee to perform this operation.';
  }

  @override
  String get r3dConfirmDeleteUnpublishedShop => 'Are you sure you want to delete your unpublished shop?';

  @override
  String get r3dConfirmDetails => 'Confirm Details';

  @override
  String get r3dConfirmDiscardListing => 'Are you sure you want to discard the listing?';

  @override
  String get r3dCopyLink => 'Copy Link';

  @override
  String get r3dCraftTime => 'Craft Time';

  @override
  String get r3dCreate => 'Create';

  @override
  String get r3dCreateAuctionHouse => 'Create Auction House';

  @override
  String get r3dCreateCollectionsPrompt => 'Now you can create collections and then add listings to them.';

  @override
  String get r3dCreateFirstListing => 'Create First Listing';

  @override
  String get r3dCreateLink => 'Create Link';

  @override
  String get r3dCreateListingsForNfts => 'Now you can create listings for the NFTs you own.';

  @override
  String get r3dCreateNewCollection => 'Create New Collection';

  @override
  String get r3dCreatePaymentLink => 'Create Payment Link';

  @override
  String get r3dCreatingNewCollectionBody => 'You are creating a new collection in your auction house.\nAfter creating the new collection you will be able to create listings.';

  @override
  String get r3dDeleteTxBroadcasted => 'Delete TX broadcasted.';

  @override
  String get r3dEditAuctionHouse => 'Edit Auction House';

  @override
  String get r3dEnableAtLeastOneOption => 'Enable at least one of the options (Gallery, Buy Now, or Auction)';

  @override
  String get r3dEndDateAfterStartDate => 'End date must be after start date';

  @override
  String get r3dEstimatedFee => 'Estimated Fee';

  @override
  String get r3dFailedCreatePaymentLink => 'Failed to create payment link. Please try again.';

  @override
  String get r3dFailedParseFee => 'Failed to parse fee';

  @override
  String get r3dFailedParseHash => 'Failed to parse hash';

  @override
  String get r3dFailedRetrieveNonce => 'Failed to retrieve nonce';

  @override
  String get r3dFailedRetrieveTimestamp => 'Failed to retrieve timestamp';

  @override
  String get r3dFailedSendVfxEscrow => 'Failed to send VFX to escrow. Please try again.';

  @override
  String get r3dFloorPriceGreaterThanZero => 'The floor price must be greater than zero.';

  @override
  String r3dFloorPriceValue(String price) {
    return 'Floor: $price VFX';
  }

  @override
  String get r3dGalleryListing => 'Gallery Listing';

  @override
  String get r3dHdAccountRestored => 'HD Account restored. Keys will now be generated deterministically based on phrase.';

  @override
  String get r3dHidden => 'Hidden';

  @override
  String get r3dHideCollectionBody => 'Are you sure you want to hide this collection? It won\'t be visible to other users when they connect to your shop.';

  @override
  String get r3dHideCollectionTitle => 'Hide Collection?';

  @override
  String get r3dInputRecoverPhrase => 'Input Recover Phrase';

  @override
  String get r3dInsufficientBalancePublish => 'This wallet doesn\'t have the minimmun balance send a publish tx';

  @override
  String get r3dInsufficientBalanceUpdate => 'This wallet doesn\'t have the minimmun balance send an update tx';

  @override
  String get r3dLabelHash => 'Hash';

  @override
  String get r3dLinkCopiedClipboard => 'Link copied to clipboard!';

  @override
  String get r3dLive => 'Live';

  @override
  String get r3dLocalChangesSaved => 'Local changes saved!';

  @override
  String get r3dMakeCollectionLiveBody => 'Are you sure you want to make this collection live? This collection will be visible to other users when they connect to your shop.';

  @override
  String get r3dMakeCollectionLiveTitle => 'Make Collection Live?';

  @override
  String get r3dMakeLive => 'Make Live';

  @override
  String get r3dMessage => 'Message';

  @override
  String get r3dNftMustBeSet => 'The NFT must be set';

  @override
  String get r3dNftTransferStarted => 'Success: NFT Transfer has been started.';

  @override
  String get r3dNotOneOfYourAddresses => 'This is not one of your addresses';

  @override
  String get r3dNumberOfTxs => '# of Txs';

  @override
  String get r3dOr => 'or';

  @override
  String get r3dPaymentCaptured => 'Payment Captured';

  @override
  String get r3dPaymentFromVfxWallet => 'Payment from VFX Wallet';

  @override
  String get r3dPaymentLinkCreatedSuccess => 'Payment link created successfully!';

  @override
  String get r3dPaymentLinkReady => 'Payment Link Ready!';

  @override
  String get r3dPaymentNotAvailable => 'Payment not available in this environment';

  @override
  String get r3dPaymentProcessed => 'Payment Processed';

  @override
  String get r3dPendingDeposit => 'Pending Deposit';

  @override
  String get r3dPriceGreaterThanZero => 'Price must be greater than zero';

  @override
  String get r3dPublish => 'Publish';

  @override
  String get r3dPublishChanges => 'Publish Changes';

  @override
  String get r3dPublishIpChange => 'Publish IP Change';

  @override
  String r3dPublishShopCostBody(String cost) {
    return 'There is a cost of $cost VFX to publish your shop to the network (plus the transaction fee).';
  }

  @override
  String get r3dPublishTransactionSent => 'Publish Transaction Sent!';

  @override
  String r3dPublishUpdateCostBody(String cost) {
    return 'There is a cost of $cost VFX to publish your shop changes to the network (plus the transaction fee).';
  }

  @override
  String get r3dPublishUpdatesBody => 'Your local changes were saved successfully. Would you like to publish this to the network?';

  @override
  String get r3dPublishUpdatesBodyWithCost => 'Your local changes were saved successfully. Would you like to publish this to the network?\n\n1 VFX is required since you have already published within the past 24 hours.';

  @override
  String get r3dReadyToClaim => 'Ready to Claim';

  @override
  String r3dRecipientWillReceive(String amount) {
    return 'The recipient will receive $amount VFX when they claim the link.';
  }

  @override
  String get r3dRecoveryInProgress => 'Recovery In Progress';

  @override
  String get r3dRefreshStatus => 'Refresh Status';

  @override
  String get r3dRefreshingStatus => 'Refreshing status...';

  @override
  String get r3dReservePriceGteFloor => 'The reserve price must be greater or equal to the floor price.';

  @override
  String r3dReservePriceValue(String price) {
    return 'Reserve: $price VFX';
  }

  @override
  String get r3dRestoreHdAccount => 'Restore HD Account';

  @override
  String get r3dSaleCompleteTxFailed => 'Sale Complete TX Failed';

  @override
  String get r3dSaveChanges => 'Save Changes';

  @override
  String r3dSecondsValue(String seconds) {
    return '$seconds seconds';
  }

  @override
  String get r3dSendingVfx => 'Sending VFX';

  @override
  String get r3dSendingVfxEllipsis => 'Sending VFX...';

  @override
  String get r3dSetOfflineBody => 'Are you sure you want to set this store offline?';

  @override
  String get r3dSetOfflineTitle => 'Set Offline?';

  @override
  String get r3dSetOnlineBody => 'Are you sure you want to set this store online?';

  @override
  String get r3dSetOnlineTitle => 'Set Online?';

  @override
  String get r3dSetupAuctionHouse => 'Setup Auction House';

  @override
  String get r3dSetupAuctionHousePrompt => 'First, setup your auction house / gallery.\nThen you\'ll be able to create collections and add listings to them.';

  @override
  String get r3dShareLink => 'Share Link';

  @override
  String get r3dShareLinkInstructions => 'Share this link with the recipient.\nThey can claim the VFX without needing a wallet.';

  @override
  String get r3dShopDeleted => 'Shop Deleted';

  @override
  String get r3dShopImported => 'Shop Imported';

  @override
  String get r3dShopOffline => 'Shop Offline';

  @override
  String get r3dShopOnline => 'Shop Online';

  @override
  String get r3dShopUrlCopied => 'Shop URL copied to clipboard';

  @override
  String r3dShopUrlLabel(String url) {
    return 'URL: $url';
  }

  @override
  String get r3dSignatureGenerationFailed => 'Signature generation failed.';

  @override
  String get r3dSignatureNotValid => 'Signature not valid';

  @override
  String get r3dSize => 'Size';

  @override
  String get r3dStartDateBeforeEndDate => 'The start date must be before the end date.';

  @override
  String get r3dStatusInitialized => 'Initialized';

  @override
  String get r3dStatusQuoted => 'Quoted';

  @override
  String get r3dTimeoutDepositConfirmation => 'Timeout waiting for deposit confirmation. The link was created but may need manual verification.';

  @override
  String get r3dTotalAmount => 'Total Amount';

  @override
  String get r3dTotalReward => 'Total Reward';

  @override
  String get r3dTransactionNotValid => 'Transaction not valid';

  @override
  String get r3dTransactionSettled => 'Transaction Settled';

  @override
  String get r3dTryAgain => 'Try Again';

  @override
  String get r3dValidatedBy => 'Validated By';

  @override
  String get r3dVaultAccountsIntroPost => '] is a Cold Storage and On-Chain Escrow Feature to keep your VFX Funds and your Digital Assets Safe.\n\n';

  @override
  String get r3dVaultAccountsIntroPre => 'Vault Accounts [';

  @override
  String get r3dVaultActivationNote => 'Note: Activating this feature requires a 5 VFX deposit, 4 of which will be burned upon activation.';

  @override
  String get r3dVaultFeatureDescription => 'This feature is separate from your VFX instant settlement address and enables both recovery and call-back on-chain escrow features that allows you to be able to recover funds and assets back to your Vault Account in the event of theft, misplacement, or from a recipient that requires trustless escrow within 24 hours of occurrence or within a user pre-set defined time.\n\n';

  @override
  String get r3dVaultFeaturesOnChain => 'These features are all on-chain and all peers are aware of their current state.\n';

  @override
  String get r3dVaultNoFungibleTokens => 'Your Vault Account has no Fungible Tokens.';

  @override
  String get r3dVaultNoVbtcTokens => 'Your Vault Account has no vBTC Tokens.';

  @override
  String get r3dVaultNotActivatedWarning => 'Your vault account is not activated yet. To protect funds and assets securely, please activate first.';

  @override
  String get r3dVfxExplorer => 'VFX Explorer';

  @override
  String r3dVfxForUsd(String vfx, String usd) {
    return '$vfx VFX for \$$usd USD';
  }

  @override
  String get r3dViewTxs => 'View Txs';

  @override
  String get r3dWaitingDepositConfirmation => 'Waiting for deposit confirmation...\nThis may take up to 20 seconds.';

  @override
  String get r3dWaitingForConfirmation => 'Waiting for Confirmation';

  @override
  String get r3eAccountRequiredExplanation => 'An account is required to continue.\nPlease create your account now with your email address and a password.';

  @override
  String get r3eAgree => 'Agree';

  @override
  String get r3eAgreeDisclaimer => 'I have read and agree to the disclaimer.';

  @override
  String r3eBlockLabel(String block) {
    return 'Block: $block';
  }

  @override
  String get r3eBtcDomainBroadcasted => 'BTC Domain Transaction has been broadcasted. See log for hash.';

  @override
  String r3eBtcDomainValidBody(String domain, String amount, String fee, String total) {
    return 'The BTC Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: $domain\nAmount: $amount VFX\nFee: $fee VFX\nTotal: $total VFX';
  }

  @override
  String get r3eBtcExplorer => 'BTC Explorer';

  @override
  String get r3eButterflyDescDesktop => 'Butterfly makes sending payments simple. Save, Spend, and Pay Anyone, Anywhere, Anytime. Instantly. No Borders, No Restrictions, No Limits, and No Accounts Needed… Be Free!\n\nAuto-login with this account?';

  @override
  String get r3eButterflyDescMobile => 'Butterfly makes sending payments simple. Save, Spend, and Pay Anyone, Anywhere, Anytime. Instantly.\n\nAuto-login with this account?';

  @override
  String get r3eCannotLockWhileValidating => 'You can not lock your wallet while validating.';

  @override
  String get r3eCantFindPrivateKey => 'Can\'t find private key';

  @override
  String get r3eCantFindPublicKey => 'Can\'t find public key';

  @override
  String get r3eCloseWallet => 'Close Wallet';

  @override
  String get r3eCoinPrices => 'Coin Prices';

  @override
  String get r3eCollapse => 'Collapse';

  @override
  String get r3eConfirmEncryptionPassword => 'Please confirm your encryption password.';

  @override
  String get r3eCopySignature => 'Copy Signature';

  @override
  String r3eCostToDelete(String cost) {
    return 'There is a cost of $cost VFX to delete a BTC Domain.';
  }

  @override
  String get r3eCouldNotGenerateSignature => 'Could not generate signature';

  @override
  String get r3eCouldNotImportMedia => 'Could not import media';

  @override
  String get r3eCreateAccount => 'Create Account';

  @override
  String get r3eCreateBtcDomainDesc => 'Create a BTC Domain as an alias to your account\'s address for receiving funds.';

  @override
  String get r3eDebugData => 'Debug Data';

  @override
  String get r3eDebugDataCopied => 'Debug data copied to clipboard';

  @override
  String get r3eDecryptAccountPasswordBody => 'Enter the password for this account to decrypt its private keys.';

  @override
  String r3eDeleteBtcDomainBody(String costLine) {
    return 'Are you sure you want to delete this BTC Domain?\n$costLine\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.';
  }

  @override
  String get r3eDisclaimer => 'Disclaimer';

  @override
  String get r3eDoNotCloseWallet => 'Please do not close your wallet.';

  @override
  String r3eDoesNotOwnBody(String address, String scId) {
    return '$address\ndoes NOT own\n$scId';
  }

  @override
  String get r3eEmailPasswordSeedInfo => 'Your email and password is used to seed your private key which is processed in this browser and will never be transmitted across the internet.';

  @override
  String get r3eEncryptAccountKeys => 'Encrypt Account Keys';

  @override
  String get r3eEncryptAccountPasswordBody => 'Enter a password to encrypt this account\'s private keys.';

  @override
  String get r3eEncryptWallet => 'Encrypt Wallet';

  @override
  String get r3eEncryptWalletBody => 'This function will encrypt ALL private keys in this wallet. Please ensure you have ALL private keys in this wallet backed up before proceeding.\n\nThis is an irreversible action and the password that you create will be the only way to gain access to this wallet once you complete this encryption.\n\nIt is also recommended to backup your password in addition to your private keys.';

  @override
  String get r3eEnterPasswordBackup => 'Enter your password to backup your keys.';

  @override
  String get r3eExportNftMedia => 'Export NFT Media';

  @override
  String get r3eFailedDecryptKeys => 'Failed to decrypt account keys. Check your password.';

  @override
  String r3eFailedDeleteDb(String path) {
    return 'Failed to delete $path — folder still exists after delete';
  }

  @override
  String r3eFailedDownloadFile(String filename, String attempts) {
    return 'Failed to download $filename after $attempts attempts';
  }

  @override
  String get r3eFaucetIntro => 'The community has allocated some VFX to lower the barrier to entry for trying out this feature. In order to prevent abuse, a phone number is required for an SMS authorization. Only a hash of your phone number will be stored.';

  @override
  String r3eFaucetSuccess(String result) {
    return 'Success! Funds are on their way. TX Hash: $result';
  }

  @override
  String r3eFilesOnDiskMismatch(String count, String total) {
    return 'Only $count of $total files on disk after download';
  }

  @override
  String get r3eGetBtc => 'Get BTC';

  @override
  String get r3eImportMedia => 'Import Media';

  @override
  String get r3eImportSnapshot => 'Import Snapshot';

  @override
  String get r3eIncorrectDecryptionPassword => 'Incorrect decryption password.';

  @override
  String get r3eIncorrectPassword => 'Incorrect password';

  @override
  String get r3eInvalidHexColor => 'Invalid hex color';

  @override
  String get r3eInvalidOwnershipSig => 'Invalid ownership verification signature';

  @override
  String get r3eJustTakeMeThere => 'Just Take Me There';

  @override
  String get r3eLaunchButterfly => 'Launch Butterfly';

  @override
  String get r3eLocalHeightAhead => 'Your local blockheight is further along than the snapshot.';

  @override
  String get r3eLockNow => 'Lock Now';

  @override
  String get r3eLogin => 'Login';

  @override
  String get r3eLoginWithThisAccount => 'Login with this Account';

  @override
  String r3eMaxAmount(String amount) {
    return 'Max Amount: $amount VFX';
  }

  @override
  String get r3eMediaBackedUp => 'Media backed up successfully.';

  @override
  String get r3eMediaImported => 'Media Imported Successfully';

  @override
  String get r3eMustAgreeTerms => 'You must agree to the terms before proceeding.';

  @override
  String get r3eNewPassword => 'New Password';

  @override
  String get r3eNoAccountSelected => 'No Account Selected';

  @override
  String get r3eNoBtcTransactions => 'No BTC Transactions Found';

  @override
  String get r3eNoCostToDelete => 'There is no cost to delete and BTC Domain (aside from the TX fee).';

  @override
  String get r3eNoKeysToEncrypt => 'No keys to encrypt.';

  @override
  String get r3eNoNotValidating => 'NO you are NOT Validating';

  @override
  String get r3eNoVfxTransactions => 'No VFX Transactions Found';

  @override
  String get r3eNotValidatingTitle => 'Not Validating ❌';

  @override
  String get r3eOpenDbFolder => 'Open DB Folder';

  @override
  String get r3eOpenExplorer => 'Open Explorer';

  @override
  String get r3eOpenLog => 'Open Log';

  @override
  String get r3eOwnershipNotVerified => 'Ownership NOT Verified';

  @override
  String get r3eOwnershipVerificationSignature => 'Ownership Verification Signature';

  @override
  String r3eOwnsBody(String address, String scId) {
    return '$address\nOWNS\n$scId';
  }

  @override
  String get r3ePasswordConfirmFailed => 'Password confirmation failed';

  @override
  String get r3ePasswordEncryptKeys => 'This password will be used to encrypt your keys.';

  @override
  String get r3ePasswordsDoNotMatchRetry => 'Your passwords do not match. Please try again.';

  @override
  String get r3ePasteSignature => 'Paste in the signature provided by the owner to validate its ownership.';

  @override
  String get r3ePhoneNumberRequired => 'Phone Number is required';

  @override
  String get r3ePrintAddresses => 'Print Addresses';

  @override
  String get r3ePrintValidators => 'Print Validators';

  @override
  String get r3eProblemLocalHeight => 'Problem fetching local block height. Please try again.';

  @override
  String get r3eProblemSnapshotHeight => 'Problem fetching snapshot block height. Please try again.';

  @override
  String r3eProgressLabel(String percent) {
    return 'Progress: $percent';
  }

  @override
  String get r3eReadLess => 'Read Less';

  @override
  String get r3eReadMore => 'Read More';

  @override
  String get r3eRecentTransactions => 'Recent Transactions';

  @override
  String r3eRecoveryBody(String hash) {
    return 'Your Reserve (Protected) Account is being recovered to your recovery address.\n\nTransaction Hash: $hash\n\nAll non-settled transactions for funds and assets will be transferred as well as your current available balance. \n\nIt is recommended you import your recovery private key into a new machine. NFT media will not be transferred over so please export them by clicking the button below and import them to your new environment.';
  }

  @override
  String get r3eRecoveryStartedTitle => 'Recovery process has started';

  @override
  String get r3eRestart => 'Restart';

  @override
  String get r3eRestartCliConfirm => 'Are you sure you want to restart the CLI?';

  @override
  String r3eSavedTo(String data) {
    return 'Saved to $data';
  }

  @override
  String get r3eSendOwnershipSignature => 'Send this ownership validation signature to prove you are the owner.';

  @override
  String get r3eSensitiveOperationPassword => 'Enter your password to continue with this sensitive operation.';

  @override
  String get r3eSessionTimeoutBody => 'Your session will be locked due to inactivity. Do you want to stay logged in?\n\nThis dialog will auto-lock in 15 seconds.';

  @override
  String get r3eSessionTimeoutWarning => 'Session Timeout Warning';

  @override
  String get r3eSetPassword => 'Set Password';

  @override
  String get r3eShowDebugData => 'Show Debug Data';

  @override
  String get r3eSignatureCopied => 'Signature Verification copied to clipboard.';

  @override
  String get r3eSnapshotNoUrls => 'Snapshot has no download URLs';

  @override
  String get r3eStatusLog => 'Status Log';

  @override
  String get r3eStayLoggedIn => 'Stay Logged In';

  @override
  String get r3eSyncingState => 'Syncing state treis due to improper shutdown';

  @override
  String r3eUnexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get r3eUnlockWallet => 'Unlock Wallet';

  @override
  String get r3eValidatingCheckProblem => 'A problem occurred checking your validating status. Please restart your wallet and try again.';

  @override
  String get r3eValidatingTitle => 'Validating ✅';

  @override
  String get r3eValidatorCheck => 'Validator Check';

  @override
  String get r3eValueRequired => 'Value is required';

  @override
  String get r3eVerifyNftOwnership => 'Verify NFT Ownership';

  @override
  String r3eVfxAddress(String address) {
    return 'VFX Address: $address';
  }

  @override
  String r3eVfxDomainValidBody(String domain, String amount, String fee, String total) {
    return 'The VFX Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: $domain\nAmount: $amount VFX\nFee: $fee VFX\nTotal: $total VFX';
  }

  @override
  String get r3eVfxExplorer => 'VFX Explorer';

  @override
  String get r3eViewAll => 'View All';

  @override
  String get r3eViewChart => 'View Chart';

  @override
  String get r3eWalletEncrypted => 'Your wallet is now encrypted.';

  @override
  String get r3eWalletLocked => 'Your wallet is now locked.';

  @override
  String get r3eWalletUnlocked => 'Wallet has been unlocked.';

  @override
  String get r3eWalletUnlocked10Min => 'Wallet has been unlocked for 10 minutes.';

  @override
  String get r3eWebWalletEncryptionBody => 'The web wallet now uses encryption to protect your keys. In order to add an additional account you must fully sign out of the wallet and login again. Please make sure all your existing login details / keys are backed up before proceeding.';

  @override
  String get r3eWebWalletEncryptionTitle => 'Web Wallet Now Uses Encryption';

  @override
  String get r3eWhichVfxManageDomain => 'What VFX address will manage this BTC domain?';

  @override
  String get r3eYesValidating => 'YES you are Validating!';

  @override
  String get r3fAProblemOccurred => 'A Problem Occurred';

  @override
  String r3fAddressCopied(String address) {
    return 'Address $address copied to clipboard';
  }

  @override
  String get r3fAnErrorOccurred => 'And error occurred';

  @override
  String get r3fAutoActivateBody => 'Would you like to activate the account automatically once the funding is complete?';

  @override
  String get r3fBridgeHistoryUnavailable => 'Bridge history is unavailable.';

  @override
  String get r3fBridgeStatusAwaitingSignatures => 'Awaiting signatures';

  @override
  String get r3fBridgeStatusExiting => 'Exiting';

  @override
  String get r3fBridgeStatusExpired => 'Expired';

  @override
  String get r3fBridgeStatusLocking => 'Locking';

  @override
  String get r3fBridgeStatusMinted => 'Minted';

  @override
  String get r3fBridgeStatusMinting => 'Minting';

  @override
  String get r3fBridgeStatusReturned => 'Returned';

  @override
  String get r3fBridgeStatusUnknown => 'Unknown';

  @override
  String get r3fBridgeUnreachable => 'Couldn\'t reach the bridge service.';

  @override
  String r3fBulkConfirmBody(String amount, String address) {
    return 'Would you like to send a total of $amount vBTC to $address';
  }

  @override
  String get r3fBulkMinTwoTokens => 'At least two tokens are required to do a bulk vBTC transaction';

  @override
  String r3fBulkSentToast(String amount, String address) {
    return '$amount vBTC has been sent to $address.';
  }

  @override
  String get r3fCliRestartRequired => 'CLI restart required for changes to take effect.';

  @override
  String get r3fConfirmingBalance => 'Confirming Balance...';

  @override
  String r3fCopiedToClipboard(String value) {
    return '\'$value\' Copied to clipboard';
  }

  @override
  String r3fErrorColon(String msg) {
    return 'Error: $msg';
  }

  @override
  String get r3fErrorHasOccurred => 'An error has occurred';

  @override
  String get r3fFailedCancelWithdrawal => 'Failed to cancel withdrawal.';

  @override
  String get r3fFailedCeremonyStatus => 'Failed to get ceremony status.';

  @override
  String get r3fFailedCompleteWithdrawal => 'Failed to complete withdrawal.';

  @override
  String get r3fFailedCreateContract => 'Failed to create contract.';

  @override
  String get r3fFailedInitiateCeremony => 'Failed to initiate ceremony.';

  @override
  String get r3fFailedParseFee => 'Failed to parse fee';

  @override
  String get r3fFailedParseHash => 'Failed to parse hash';

  @override
  String get r3fFailedRequestWithdrawal => 'Failed to request withdrawal.';

  @override
  String get r3fFailedRetrieveNonce => 'Failed to retrieve nonce';

  @override
  String get r3fFailedRetrieveTimestamp => 'Failed to retrieve timestamp';

  @override
  String get r3fFailedTransferOwnership => 'Failed to transfer ownership.';

  @override
  String get r3fFailedTransferVbtc => 'Failed to transfer vBTC.';

  @override
  String get r3fFeePresetCustom => 'Custom';

  @override
  String get r3fFeePresetEconomy => 'Economy';

  @override
  String get r3fFeePresetFastest => 'Fastest';

  @override
  String get r3fFeePresetHalfHour => 'Half Hour';

  @override
  String get r3fFeePresetHour => 'Hour';

  @override
  String get r3fFeePresetMinimum => 'Minimum';

  @override
  String r3fFundConfirmBody(String address) {
    return 'Would you like to send 5 VFX from $address?';
  }

  @override
  String r3fFundSentToast(String address) {
    return '5 VFX sent to $address';
  }

  @override
  String get r3fInputAmountsPerToken => 'Input Amounts for each token:';

  @override
  String get r3fInsufficientVfxBalance => 'Selected VFX account doesn\'t have enough balance';

  @override
  String r3fMaxAmountIs(String amount) {
    return 'Maximum amount is $amount vBTC';
  }

  @override
  String r3fMaxLabel(String amount) {
    return '(MAX: $amount vBTC)';
  }

  @override
  String r3fMyBalanceLabel(String balance, String usd) {
    return 'My Balance: $balance vBTC$usd';
  }

  @override
  String get r3fNftNotTransferred => 'NFT assets have not been transferred to the VFX Web Account.';

  @override
  String get r3fNoAdditionalMedia => 'This token does not contain any additional media.';

  @override
  String get r3fNoBtcTransactions => 'No BTC Transactions';

  @override
  String get r3fNoRequestHash => 'No request hash returned from withdrawal request.';

  @override
  String get r3fNotGenerated => 'Not Generated';

  @override
  String get r3fOnboardFaucetDetails => 'The community has provided a faucet to withdraw a minimal amount of VFX from in order to try out this feature. A phone number is required for verification purposes and to reduce the chance of abuse. Please note that only a hash of the phone number is stored with the faucet. Alternatively, you are welcome to purchase VFX via an exchange on on-ramp if you like.';

  @override
  String get r3fOnboardTokenizeDetails => 'Time to tokenize a vBTC token. The following fields are all optional!';

  @override
  String get r3fOnboardTransferBtcDetails => 'Looks like this account doesn\'t have any BTC. Please transfer BTC to this account to continue.';

  @override
  String get r3fOnboardTransferToVbtcDetails => 'Now you are ready to transfer BTC to your vBTC token. Select the amount and Fee Rate below';

  @override
  String r3fPrivateKeyImportedSync(String time) {
    return 'Private Key Imported! Please wait until $time for the balance to sync.';
  }

  @override
  String get r3fProblemRecoverySigScript => 'Problem generating RecoverySigScript';

  @override
  String get r3fQrScannerUnavailable => 'QR Scanner not available on this platform';

  @override
  String r3fRecoverBody(String address) {
    return 'This is a destructive function that will callback all pending transactions and assets and move everything to this recovery address:\n\n$address';
  }

  @override
  String get r3fRestartNow => 'Restart Now';

  @override
  String get r3fRestoreBody => 'Importing an existing Vault Account will replace the current one tied to your login. To revert you can logout and login again.\n\nContinue?';

  @override
  String get r3fRestoreCodePrompt => 'Paste in your RESTORE CODE to import your existing Vault Account.';

  @override
  String get r3fRevealPrivateKeyBody => 'Are you sure you want to reveal your private key?';

  @override
  String get r3fSelectTokensToTransfer => 'Select the tokens you\'d like to transfer from:';

  @override
  String get r3fTokenMedia => 'Token Media';

  @override
  String r3fTokenTotalBalanceTooltip(String balance, String usd) {
    return 'Token Total Balance: $balance vBTC$usd';
  }

  @override
  String r3fTransactionCompleted(String txHash) {
    return 'Transaction completed: $txHash';
  }

  @override
  String get r3fTxTypeMultiSig => 'Multi-signature';

  @override
  String get r3fTxTypeReplace => 'Replace';

  @override
  String get r3fTxTypeSameAccount => 'Same Account TX';

  @override
  String get r3fWaitingTokenization => 'Waiting for vBTC Tokenization to compile.';

  @override
  String get r3gAccountUnlocked => 'Account unlocked.';

  @override
  String get r3gAccountUnlocked10Min => 'Account unlocked for 10 minutes.';

  @override
  String get r3gActiveColon => 'Active:';

  @override
  String get r3gAdditionalAssetsColon => 'Additional Assets:';

  @override
  String get r3gAddressCopiedDot => 'Address copied to clipboard.';

  @override
  String r3gAdnrCreateConfirmBody(String currency, String domain, String amount, String fee, String total) {
    return 'The $currency Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: $domain\nAmount: $amount VFX\nFee: $fee VFX\nTotal: $total VFX';
  }

  @override
  String r3gAdnrDeleteBody(String costLine) {
    return 'Are you sure you want to delete this VFX Domain?\n$costLine\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.';
  }

  @override
  String get r3gAdnrDeleteNoCost => 'There is no cost to delete and VFX Domain (aside from the TX fee).';

  @override
  String r3gAdnrDeleteWithCost(String cost) {
    return 'There is a cost of $cost RBX to delete an RBX Domain.';
  }

  @override
  String r3gAssetListedInAuctionHouse(String assetType) {
    return 'This $assetType is listed in your auction house. Please remove the listing before transferring.';
  }

  @override
  String r3gAssetTransferSentSuccess(String assetType, String address) {
    return '$assetType Transfer sent successfully to $address!';
  }

  @override
  String r3gAuctionBegins(String date, String time) {
    return 'Begins: $date $time';
  }

  @override
  String get r3gAuctionEnds => 'Auction Ends';

  @override
  String get r3gAuctionHasEnded => 'Auction Has Ended';

  @override
  String get r3gAuctionStarts => 'Auction Starts';

  @override
  String get r3gAuctionUpcoming => 'Auction Upcoming';

  @override
  String get r3gBackupUrlRequired => 'Backup URL required';

  @override
  String r3gBackupUrlTitle(String optional) {
    return 'Backup URL $optional';
  }

  @override
  String get r3gBaselineAsset => 'Baseline Asset';

  @override
  String get r3gBidAmount => 'Bid Amount';

  @override
  String r3gBidGreaterThanHighest(String price) {
    return 'Your bid must be greater than the current highest bid ($price VFX)';
  }

  @override
  String get r3gBidResent => 'Bid Resent!';

  @override
  String get r3gBidSent => 'Bid sent. Please check the Bid History to see if it\'s been accepted or rejected.';

  @override
  String get r3gBurnSentSuccess => 'Burn transaction sent successfully!';

  @override
  String get r3gBuyNowSentSuccess => 'Buy Now transaction sent successfully. Please wait for confirmation.';

  @override
  String get r3gChain => 'Chain';

  @override
  String get r3gCollectionError => 'Collection Error';

  @override
  String r3gConfirmBurnName(String name) {
    return 'Are you sure you want to burn $name';
  }

  @override
  String r3gConfirmBuyNowBody(String price) {
    return 'Are you sure you want to buy now for $price VFX?';
  }

  @override
  String get r3gConfirmDevolveOneStage => 'Are you sure you want to devolve this NFT one stage?';

  @override
  String get r3gConfirmEvolveOneStage => 'Are you sure you want to evolve this NFT one stage?';

  @override
  String r3gConfirmEvolveToStage(String index) {
    return 'Are you sure you want to evolve to stage $index?';
  }

  @override
  String r3gConfirmPlaceBidBody(String amount, String maxSuffix) {
    return 'Are you sure you want to place a bid of $amount VFX$maxSuffix?';
  }

  @override
  String r3gConfirmSellNftBody(String address, String amount) {
    return 'Please confirm you want to sell the NFT to \"$address\" for $amount VFX.';
  }

  @override
  String r3gConfirmSendAssetBody(String assetType, String address, String warning) {
    return 'Please confirm you want to send the $assetType to \"$address\".$warning';
  }

  @override
  String get r3gConnect => 'Connect';

  @override
  String get r3gConnectToAuctionHouseTitle => 'Connect to Auction House?';

  @override
  String r3gConnectToShopBody(String name, String url) {
    return 'Would you like to connect to $name ($url)?';
  }

  @override
  String r3gConnectedFetchingData(String url) {
    return 'Connected to $url. Fetching data...';
  }

  @override
  String get r3gConnectingToShop => 'Connecting to shop...';

  @override
  String get r3gCopyMessage => 'Copy Message';

  @override
  String get r3gCouldNotConnectOffline => 'Could not connect to shop because it\'s offline.';

  @override
  String r3gCouldNotFindShop(String url) {
    return 'Could not find auction house with url of $url';
  }

  @override
  String get r3gCurrentBidPrice => 'Current Bid Price:';

  @override
  String get r3gCurrentBids => 'Current Bids';

  @override
  String r3gCurrentStage(String name) {
    return 'Current Stage: $name';
  }

  @override
  String get r3gDevolve => 'Devolve';

  @override
  String get r3gEncryptionPasswordRequired => 'Encryption Password Required to continue validating.';

  @override
  String get r3gEndsIn => 'Ends in';

  @override
  String get r3gEvolution => 'Evolution';

  @override
  String r3gEvolveBlockHeightLabel(String blockHeight, String description) {
    return 'Evolve Block Height: $blockHeight\n$description';
  }

  @override
  String r3gEvolveDateLabel(String date, String time, String tz, String description) {
    return 'Evolve Date: $date $time $tz \n$description';
  }

  @override
  String get r3gEvolveSyncBody => 'This screen will reflect the change once the block is crafted and block height has synced with this transaction.';

  @override
  String r3gFeeRateEstimateCustom(String fee, String feeBtc, String feeEstimate, String feeEstimateBtc) {
    return 'Fee Rate: $fee SATS /byte [$feeBtc BTC /byte]\nFee Estimate: $feeEstimate SATS [~$feeEstimateBtc BTC]';
  }

  @override
  String r3gFeeRateEstimatePreset(String fee, String feeBtc, String feeEstimate, String feeEstimateBtc) {
    return 'Fee Rate: $fee SATS /byte [$feeBtc BTC /byte]\nFee Estimate: ~$feeEstimate SATS [~$feeEstimateBtc BTC]    ';
  }

  @override
  String get r3gGettingCollections => 'Getting collections and listings...';

  @override
  String get r3gIncorrectDecryptionPassword => 'Incorrect decryption password.';

  @override
  String get r3gIncrementAmount => 'Increment Amount:';

  @override
  String r3gLabelCopiedToClipboard(String label) {
    return '$label copied to clipboard';
  }

  @override
  String get r3gManageEvolution => 'Manage Evolution';

  @override
  String r3gManagingName(String name) {
    return 'Managing $name';
  }

  @override
  String r3gMaxBidSuffix(String max) {
    return ' with a max bid of $max VFX';
  }

  @override
  String get r3gMediaFilesNotFound => 'Media files not found on this machine.';

  @override
  String get r3gMessageCopied => 'Message copied to clipboard.';

  @override
  String r3gMinIncrementAmount(String increment, String minBid) {
    return 'The minimum increment amount is $increment VFX. A bid grater than $minBid VFX is required.';
  }

  @override
  String get r3gMinted => 'Minted';

  @override
  String get r3gMintedBy => 'Minted By';

  @override
  String r3gMintedByName(String name) {
    return 'Minted By: $name';
  }

  @override
  String get r3gMinting => 'Minting...';

  @override
  String r3gMustBeGreaterThanBid(String minBid) {
    return 'Must be greater than $minBid VFX';
  }

  @override
  String get r3gNextOwner => 'Next Owner';

  @override
  String get r3gNftAssetsNotTransferred => 'NFT assets have not been transferred to the VFX Web Wallet.';

  @override
  String get r3gNftFeaturesColon => 'NFT Features:';

  @override
  String get r3gNftListedBeforeBurning => 'This NFT is listed in your auction house. Please remove the listing before burning.';

  @override
  String get r3gNoBids => 'No bids.';

  @override
  String get r3gNoFeatures => 'No features';

  @override
  String get r3gNoMintedNfts => 'No minted NFTs with management capabilities.';

  @override
  String get r3gNoNftsFound => 'No NFTs found.';

  @override
  String r3gNoRecoveryWarning(String assetType) {
    return '\n\nIf this address is not correct, there will be no way to recover the ownership of the $assetType.';
  }

  @override
  String get r3gNotEnoughBalanceDot => 'Not enough balance.';

  @override
  String get r3gNotEnoughBalanceValidating => 'Not enough balance since you are validating.';

  @override
  String get r3gOptionalParenthetical => '(Optional)';

  @override
  String get r3gPasteZipfileUrl => 'Paste in a public URL to a hosted zipfile containing the assets.';

  @override
  String get r3gPropertiesColon => 'Properties:';

  @override
  String get r3gPropertySingular => 'Property';

  @override
  String get r3gPurchasedBy => 'Purchased by: ';

  @override
  String get r3gPurchasedFor => 'for ';

  @override
  String r3gRemoveShopBody(String url) {
    return 'Are you sure you want to remove $url from your saved shops?';
  }

  @override
  String get r3gRemoveShopTitle => 'Remove shop?';

  @override
  String get r3gResendMessage => 'Resend Message';

  @override
  String get r3gReserveMet => 'Reserve Met:';

  @override
  String get r3gSellNftPrompt => 'How much are you selling this NFT for?';

  @override
  String get r3gShopCurrentlyOffline => 'This shop is currently offline.';

  @override
  String get r3gShopError => 'Shop Error';

  @override
  String get r3gShopIsOffline => 'Shop is offline.';

  @override
  String get r3gShopOfflineWarning => 'Warning: This shop is currently offline so the information may not be up to date.';

  @override
  String get r3gSmartContractIdCopied => 'Smart Contract Identifier copied to clipboard';

  @override
  String get r3gStartSale => 'Start Sale';

  @override
  String get r3gStepAmountAddressDesc => 'Input the percentage amount to be paid to the VFX address defined in the next field.';

  @override
  String get r3gStepAmountAddressTitle => 'Amount & Address';

  @override
  String get r3gStepEvolutionModeDesc => 'Decide whether you want the evolution to be controlled by the issuer or by the owner of the NFT.';

  @override
  String get r3gStepEvolutionModeTitle => 'Evolution Mode';

  @override
  String get r3gStepEvolutionStagesDesc => 'Create multiple evolution stages based on the variables provided previously. Give each stage a name, description and optionally override the asset.';

  @override
  String get r3gStepEvolutionStagesTitle => 'Evolution Stages';

  @override
  String get r3gStepEvolutionTypeDesc => 'Configure whether you want the NFT to evolve automatically by date/time, block height, or only manually.';

  @override
  String get r3gStepEvolutionTypeTitle => 'Evolution Type';

  @override
  String get r3gStepMetadataDesc => 'Start by providing the name, minter, and description of the smart contract.';

  @override
  String get r3gStepMetadataTitle => 'Metadata';

  @override
  String get r3gStepMintDesc => 'Click the compile button to generate the Trilliam code that represents the smart contract then click mint to deploy it to the chain.';

  @override
  String get r3gStepMintTitle => 'Mint';

  @override
  String get r3gStepPrimaryAssetDesc => 'Choose the primary asset for the smart contract. This can be an image, audio file, video, or any digital file.';

  @override
  String get r3gStepRoyaltyFeeDesc => 'The fee is calculated from the sale proceeds and settled on transaction finality. For flat fees, the NFT can\'t be sold for less than the enforced royalty.';

  @override
  String get r3gStepRoyaltyFeeTitle => 'Royalty Fee';

  @override
  String get r3gStepRoyaltyTypeDesc => 'Choose either a flat fee or percentage based royalty enforced by the on the chain upon any trade.';

  @override
  String get r3gTplBaselineDesc => 'Create a baseline smart contract with an asset and metadata and mint it to the chain';

  @override
  String get r3gTplBaselineName => 'Baseline Smart Contract';

  @override
  String get r3gTplEvolvingDesc => 'Generate a smart contract that can evolve based on time or on-chain variables';

  @override
  String get r3gTplEvolvingName => 'Evolving Smart Contract';

  @override
  String get r3gTplRoyaltyDesc => 'Create a smart contract that includes a royalty that is enforced on-chain upon any trade';

  @override
  String get r3gTplRoyaltyName => 'Royalty Smart Contract';

  @override
  String r3gTransferAssetTitle(String assetType) {
    return 'Transfer $assetType';
  }

  @override
  String get r3gTransferInProgress => 'Transfer in Progress';

  @override
  String r3gTransferInProgressBody(String assetType) {
    return 'Please ensure to keep your wallet open until this $assetType transfer transaction appears in your transaction list.\n\nTo monitor the asset transfer progress, open your \'sclog.txt\' in your databases folder.';
  }

  @override
  String get r3gUnlockAccount => 'Unlock Account';

  @override
  String r3gUrlOptionalLabel(String optional) {
    return 'URL $optional';
  }

  @override
  String r3gValueCopiedToClipboard(String value) {
    return '$value copied to clipboard';
  }

  @override
  String get r3gVaultCannotBurnNfts => 'Vault Accounts cannot burn NFTs';

  @override
  String get r3hAccountIsValidating => 'This account is validating';

  @override
  String r3hActiveValidators(String count) {
    return 'Active Validators: $count';
  }

  @override
  String get r3hAdditionalLinksOptional => 'Additional Link(s) (Optional)';

  @override
  String get r3hAddressInvalid => 'Invalid Address.';

  @override
  String get r3hAddressOrDomainRequired => 'Address or VFX domain required';

  @override
  String get r3hAddressRequired => 'Address required';

  @override
  String get r3hAddressToBan => 'Address to Ban';

  @override
  String get r3hAdjVoteInDetails => 'Adj Vote In Details';

  @override
  String get r3hAdjVoteInTooLong => 'The \'Vote Adjudicator In\' submission is too long. Please reduce the content.';

  @override
  String get r3hAllowVotingLabel => 'Allow Voting:';

  @override
  String r3hAvailableBalance(String balance) {
    return 'Available: $balance VFX';
  }

  @override
  String get r3hBalanceRequired => 'A balance is required';

  @override
  String get r3hBandwidthHint => '0 for unlimited';

  @override
  String get r3hBandwidthTb => 'Bandwidth (in TB)';

  @override
  String get r3hCannotHideValidating => 'You can\'t hide an account that is validating';

  @override
  String get r3hCompileMintBody => 'Are you sure you want to proceed?\nOnce compiled you will not be able to make any changes\nand the smart contract/token will be deployed to the chain.';

  @override
  String get r3hConfirmVoteNoBody => 'Are you sure you want to vote NO on this topic?';

  @override
  String get r3hConfirmVoteNoTitle => 'Confirm Vote [NO]';

  @override
  String get r3hConfirmVoteYesBody => 'Are you sure you want to vote YES on this topic?';

  @override
  String get r3hConfirmVoteYesTitle => 'Confirm Vote [YES]';

  @override
  String r3hCopiedToClipboard(String label) {
    return '$label copied to clipboard';
  }

  @override
  String get r3hCpu => 'CPU';

  @override
  String get r3hCpuCores => 'CPU Cores';

  @override
  String get r3hCpuHint => 'ie. Intel';

  @override
  String get r3hCpuThreads => 'CPU Threads';

  @override
  String get r3hDecimalPlacesLabel => 'Decimal Places:';

  @override
  String get r3hDescRequired => 'The description is required';

  @override
  String get r3hDescTooLong => 'The description exceeds the maximum character length';

  @override
  String get r3hDescTooManyWords => 'The description exceeds the maximum word count';

  @override
  String get r3hDescriptionColon => 'Description:';

  @override
  String get r3hDescriptionOptionalLabel => 'Description (Optional):';

  @override
  String get r3hDnrAlphaNumeric => 'A DNR may only contain letters and numbers.';

  @override
  String get r3hEmailInvalid => 'Invalid email.';

  @override
  String get r3hEmailRequired => 'Email required.';

  @override
  String get r3hErrorBanning => 'Error banning address';

  @override
  String get r3hErrorBurning => 'Error burning token';

  @override
  String get r3hErrorChangingOwnership => 'Error changing ownership';

  @override
  String get r3hErrorCreatingTopic => 'Error creating topic';

  @override
  String get r3hErrorMinting => 'Error minting token';

  @override
  String get r3hErrorPausing => 'Error pausing/unpausing token';

  @override
  String get r3hErrorTransferring => 'Error transferring token';

  @override
  String r3hFieldInvalid(String label) {
    return 'Invalid $label.';
  }

  @override
  String r3hFieldRequired(String label) {
    return '$label is required.';
  }

  @override
  String get r3hGithubLinkOptional => 'Github Link (Optional)';

  @override
  String get r3hHdSize => 'HD Size';

  @override
  String get r3hHdSizeSpecifier => 'HD Size Specifier';

  @override
  String get r3hHours24Minimum => 'Hours (24 Minimum)';

  @override
  String get r3hInsufficientBalanceForTopic => 'Balance will not be sufficent to validate due to the cost of creating a topic (1 VFX + fee)';

  @override
  String get r3hInternetSpeedDown => 'Internet Speed Down (in Gbps)';

  @override
  String get r3hInternetSpeedUp => 'Internet Speed Up (in Gbps)';

  @override
  String get r3hInvalid => 'Invalid';

  @override
  String get r3hIsBurnableLabel => 'Is Burnable:';

  @override
  String get r3hLabelMinTokenRequirement => 'Minimum Token Requirement';

  @override
  String get r3hLogoutConfirmBody => 'Are you sure you want to logout of the VFX Web Wallet?';

  @override
  String get r3hMachineOs => 'Machine OS';

  @override
  String get r3hMachineProvider => 'Machine Provider';

  @override
  String get r3hMachineType => 'Machine Type';

  @override
  String get r3hMachineTypeHint => 'ie. Server, Desktop, Laptop, etc.';

  @override
  String get r3hManageToken => 'Manage Token';

  @override
  String get r3hMaxPercent => 'Can not be more than 100%';

  @override
  String get r3hMinPercent => 'Must be more than 0%';

  @override
  String get r3hMintBroadcastedBody => 'Token Smart Contract mint transaction has been broadcasted.\n\nThe Fungible Token screen will reflect the change once the block is crafted and block height has synced with this transaction.';

  @override
  String r3hMintedByBody(String address) {
    return 'This will be minted by $address';
  }

  @override
  String get r3hMustBeValidatorToCreateTopic => 'Your active account must be a validator to create a topic.';

  @override
  String get r3hMustSelectAccountToVote => 'Must have an account selected to vote.';

  @override
  String get r3hNameRequired => 'The name is required';

  @override
  String get r3hNameTooLong => 'The name exceeds the maximum character length';

  @override
  String get r3hNewOwnerAddress => 'New Owner\'s Address';

  @override
  String get r3hNoActiveTopics => 'No Active Topics';

  @override
  String get r3hNoCreatedTopics => 'You haven\'t created any topics.';

  @override
  String get r3hNoInactiveTopics => 'No Inactive Topics';

  @override
  String get r3hNoTokensInAccounts => 'No tokens in any of your accounts.';

  @override
  String get r3hNoUpper => 'NO';

  @override
  String get r3hNoVotingTopics => 'No Voting Topics';

  @override
  String get r3hNodeNameTaken => 'Node name already taken.';

  @override
  String get r3hNotAuthorizedAddress => 'Not authorized (incorrect address).';

  @override
  String get r3hNotAuthorizedToken => 'Not authorized (token invalid).';

  @override
  String get r3hNotVotedAnyTopics => 'You haven\'t voted on any topics.';

  @override
  String get r3hOneActiveTopicPerAddress => 'Only one active topic per address is allowed.';

  @override
  String get r3hOptional => 'Optional';

  @override
  String get r3hPasswordRequired => 'Password required.';

  @override
  String get r3hPasswordWeak => 'Password not strong enough.';

  @override
  String get r3hPause => 'Pause';

  @override
  String get r3hPauseTokenTransactions => 'Pause Token Transactions';

  @override
  String get r3hPauseTokenTxConfirmBody => 'Are you sure you want to pause token transactions? This will prevent transfers and burning of this token until resumed.';

  @override
  String get r3hPauseTransactions => 'Pause Transactions';

  @override
  String get r3hPauseTxConfirmBody => 'Are you sure you want to pause all transactions with this token?';

  @override
  String get r3hPauseTxs => 'Pause TXs';

  @override
  String get r3hPendingPause => 'Pending Pause';

  @override
  String get r3hPendingResume => 'Pending Resume';

  @override
  String get r3hPhoneInvalid => 'Invalid Phone Number.';

  @override
  String get r3hPhoneRequired => 'Phone Number required.';

  @override
  String get r3hProblemOccurred => 'A problem occurred.';

  @override
  String get r3hRamGb => 'RAM (in GB)';

  @override
  String get r3hReasonToBecomeAdj => 'Reason To Become Adjudicator';

  @override
  String get r3hReplaceTokenIcon => 'Replace Token Icon';

  @override
  String get r3hRequired => 'Required';

  @override
  String get r3hResume => 'Resume';

  @override
  String get r3hResumeTokenTransactions => 'Resume Token Transactions';

  @override
  String get r3hResumeTokenTxConfirmBody => 'Are you sure you want to resume token transactions?';

  @override
  String get r3hResumeTransactions => 'Resume Transactions';

  @override
  String get r3hResumeTxConfirmBody => 'Are you sure you want resume transactions with this token?';

  @override
  String get r3hResumeTxs => 'Resume TXs';

  @override
  String get r3hSeparateWithCommas => 'Separate multiple with commas';

  @override
  String get r3hTechnicalBackground => 'Technical Background';

  @override
  String get r3hTokenAccounts => 'Token Accounts';

  @override
  String get r3hTokenHasFixedSupply => 'Token Has Fixed Supply:';

  @override
  String get r3hTokenIconUrlLabel => 'Token Icon URL:';

  @override
  String get r3hTokenNameFieldLabel => 'Token Name:';

  @override
  String get r3hTokenNameHelper => 'The name of this new token.';

  @override
  String get r3hTokenOwnerLabel => 'Token Owner: ';

  @override
  String get r3hTokenPauseBroadcasted => 'Token pause transaction broadcasted';

  @override
  String get r3hTokenResumeBroadcasted => 'Token resume transaction broadcasted';

  @override
  String get r3hTokenTickerFieldLabel => 'Token Ticker:';

  @override
  String get r3hTokenTickerHelper => 'The ticker for this new token.';

  @override
  String get r3hTotalSupplyLabel => 'Total Supply:';

  @override
  String get r3hUploadTokenIcon => 'Upload Token Icon';

  @override
  String get r3hUseZeroForInfinite => 'Use 0 for Infinite (allows minting)';

  @override
  String get r3hUsernameInvalid => 'Username not valid.';

  @override
  String get r3hUsernameRequired => 'Username required.';

  @override
  String get r3hVaultActionNotAllowedBody => 'Vault Account owned tokens can not perform this action. Please change the ownership to a standard VFX account to continue.';

  @override
  String r3hVaultKeypairNotFound(String address) {
    return 'Could not locate vault keypair for address $address.';
  }

  @override
  String get r3hVfxAddressToNominate => 'VFX Address to Nominate';

  @override
  String get r3hVoteNoUpper => 'Vote NO';

  @override
  String get r3hVoteYesUpper => 'Vote YES';

  @override
  String get r3hVotedAllTopics => 'You have voted on all topics.';

  @override
  String r3hVotingEndedOn(String date) {
    return 'Voting Ended on $date.';
  }

  @override
  String r3hVotingEndsOn(String date) {
    return 'Voting ends $date.';
  }

  @override
  String get r3hWalletSyncWait => 'Please wait until your wallet is synced with the network';

  @override
  String get r3hWalletSynced => 'Wallet Synced';

  @override
  String get r3hYesUpper => 'YES';

  @override
  String r3hYouVotedOnBlock(String vote, String block) {
    return 'You voted $vote on block $block';
  }

  @override
  String r3hYouVotedPending(String vote) {
    return 'You voted $vote. Transaction is pending.';
  }

  @override
  String get r3aAccountUnlockTime => 'Account Unlock Time';

  @override
  String get r3aAddRarity => 'Add Rarity';

  @override
  String get r3aAdditionalAsset => 'Additional Asset';

  @override
  String get r3aAdditionalAssets => 'Additional Assets';

  @override
  String get r3aAllowedAssetExtensionTypes => 'Allowed Asset Extension Types';

  @override
  String get r3aAutoDownloadNftAsset => 'Auto Download NFT Asset';

  @override
  String get r3aBackupUrlBody => 'Paste in a public URL to a hosted zipfile containing the assets.';

  @override
  String get r3aBlockHeightVariable => 'Block Height Variable';

  @override
  String get r3aBurnNft => 'Burn NFT';

  @override
  String get r3aChooseFile => 'Choose File';

  @override
  String get r3aCompile => 'Compile';

  @override
  String get r3aCompileMintBodySimple => 'Are you sure you want to proceed?\nOnce compiled you will not be able to make any changes\nand the smart contract will be deployed to the chain.';

  @override
  String get r3aCompilingMinting => 'Compiling & Minting';

  @override
  String get r3aCompilingMintingEllipsis => 'Compiling & Minting…';

  @override
  String get r3aConfiguration => 'Configuration';

  @override
  String get r3aCreateBlueprint => 'Create Blueprint';

  @override
  String get r3aCreateCollectionBlueprint => 'Create Collection Blueprint';

  @override
  String get r3aCreateFirstInstance => 'Create First Instance';

  @override
  String get r3aDateTimeVariable => 'Date/Time Variable';

  @override
  String get r3aDeleteDraft => 'Delete Draft';

  @override
  String get r3aDeleteDraftConfirm => 'Are you sure you wan\'t to delete this smart contract draft?';

  @override
  String get r3aDeleteQuestion => 'Delete?';

  @override
  String get r3aDeleteThisConfirm => 'Are you sure you want to delete this?';

  @override
  String get r3aDraftDeleted => 'Draft Delete';

  @override
  String get r3aDraftSaved => 'Draft saved!';

  @override
  String get r3aDuplicate => 'Duplicate';

  @override
  String get r3aEditInstance => 'Edit Instance';

  @override
  String get r3aEvolutionMode => 'Evolution Mode';

  @override
  String get r3aEvolvePhase => 'Evolve Phase';

  @override
  String get r3aEvolvePhases => 'Evolve Phases';

  @override
  String get r3aEvolveStagesInPast => 'Evolve stage(s) in the past';

  @override
  String get r3aEvolveStagesInPastBody => 'One or more of your evolve stages will have already evolved at the time of minting.\n\nAre your sure you want to proceed?';

  @override
  String get r3aFeatures => 'Features';

  @override
  String get r3aHelpBodyAllowedExt => 'This will remove extension types to the already defined list and will allow any NFT assets with these known extension types to be downloaded \nEx: pdf,doc,xls \n\nDefault value: (leave blank)';

  @override
  String get r3aHelpBodyApiCallUrl => 'This URL is used to send incoming transactions to an outside URL. This is something used for like incoming deposits or other notification. services. \n\nDefault value: null';

  @override
  String get r3aHelpBodyApiPort => 'This is the port to call the API. This may be changed to whatever you want. \n\nDefault value: 7292';

  @override
  String get r3aHelpBodyAutoDownload => 'This will control whether or not an NFT\'s asset is automatically downloaded \n\nDefault value: true';

  @override
  String get r3aHelpBodyBaseline => 'Fill out the baseline info required by all smart contracts. Choose a name, the minter\'s name (optional), and the account you want to use. Then, give your smart contract/NFT a detailed description.';

  @override
  String get r3aHelpBodyBurn => 'Burn (destroy) this NFT permanently.';

  @override
  String get r3aHelpBodyCompile => 'Compile the Trilliam code based on the parameters you\'ve configured and then mint when ready.';

  @override
  String get r3aHelpBodyConfiguration => 'This values will modify the config.txt file located in the CLIs database, for this changes to take effect the CLI needs to be restarted';

  @override
  String get r3aHelpBodyDelete => 'Delete your smart contract';

  @override
  String get r3aHelpBodyDescription => 'Provide a text-based description of your smart contract/NFT. This field is required and will be publicly visible.';

  @override
  String get r3aHelpBodyEvolveAsset => 'Overide the asset when the smart contract evolves to this stage. This field is optional.';

  @override
  String get r3aHelpBodyEvolveBlockHeight => 'The smart contract will evolve when the VFX chain reaches this block height.';

  @override
  String get r3aHelpBodyEvolveDatetime => 'The date and time the smart contract will evolve (UTC).';

  @override
  String get r3aHelpBodyEvolveMode => 'You decide how the evolution will be controlled.\n\nIssuer/Minter Controlled: The minter will be able to evolve/devolve the smart contract at any point.\n\nAutomated/Application Controlled: Automatically evolves based on time/date, on-chain variables, and/or application induced variables.';

  @override
  String get r3aHelpBodyEvolveStageDescription => 'Provide a description for this evolution stage.';

  @override
  String get r3aHelpBodyEvolveStageName => 'Provide a name for this evolution stage.';

  @override
  String get r3aHelpBodyEvolveType => 'Choose the variable type that can dynamically affect the evolution state.\n\nDate/Time: The smart contract will automatically evolve at a certain point of time.\n\nBlock Height: The smart contract will evolve when the chain reaches a particular block height.\n\nManual Only: The smart contract will not evolve unless manually told to by the issuer or user/application (depending on which mode is selected).';

  @override
  String get r3aHelpBodyFeatures => 'Add a feature to your smart contract such as royalties or evolving functionality.';

  @override
  String get r3aHelpBodyIgnoreIncoming => 'This will control whether or not incoming NFTs are processed or just added as a TX record \n\nDefault value: false';

  @override
  String get r3aHelpBodyManageProperties => 'Create label & value pairs.\nFor example:\n\nLabel: Color\nValue: Blue';

  @override
  String get r3aHelpBodyMint => 'Mint and deploy the smart contract to the chain.';

  @override
  String get r3aHelpBodyMintQuantity => 'The number of Smart Contracts / NFTs you want to mint from this template.';

  @override
  String get r3aHelpBodyMinterName => 'This field is optional but will be displayed publicly if set. This can be your name/persona, or just leave it blank.';

  @override
  String get r3aHelpBodyMinting => 'This action occurs after you have successfully compiled and minted but requires the transaction to be authenticated by the network which takes approximately 30 seconds for finality as well as your wallet to be synced with the block that includes this transaction.';

  @override
  String get r3aHelpBodyMotherAddress => 'The IP address of the HOST wallet. \n\n Default value: (leave blank)';

  @override
  String get r3aHelpBodyMotherPassword => 'The password set in your HOST wallet when configuring MOTHER.\n\n Default value: (leave blank)';

  @override
  String get r3aHelpBodyNftTimeout => 'This will control the timeout for processing an incoming NFT \n\nDefault value: 15';

  @override
  String get r3aHelpBodyOwnerAddress => 'This should be the account address that will be used to compile and mint the smart contract.';

  @override
  String get r3aHelpBodyPasswordClearTime => 'This will control the clear time for an ecrypted wallets password \n\nDefault value: 10';

  @override
  String get r3aHelpBodyPrimaryAsset => 'This is the primary file asset contained in the smart contract/NFT. It can be an image, audio, video or any file.';

  @override
  String get r3aHelpBodyProperties => 'Define and assign values to assets in your smart contract. This can be a rare trait as an example.';

  @override
  String get r3aHelpBodyPropertyTypes => 'Define the kind of value that your property will have \nThis types are: \n- Text: alphanumeric value \n- Number: numerical value \n- Color: Hexadecimal value of a color of your choice';

  @override
  String r3aHelpBodyRejectExt(String exts) {
    return 'This will add extension types to the already defined list and will reject any NFT assets with these known extension types \nEx: exe,zip,pdf... (ensure there are no spaces between types) \n\nDefault value: (leave blank)\n\nIf left blank, this is the default:\n$exts';
  }

  @override
  String get r3aHelpBodyRoyaltyAddress => 'Provide the VFX public address that the royalty will be paid to upon transaction finality.';

  @override
  String get r3aHelpBodyRoyaltyFlat => 'Type in the amount of VFX that will be paid to the address provided and is enforced on-chain upon any trade. This fee is remitted to the royalty holder upon transaction finality.';

  @override
  String get r3aHelpBodyRoyaltyPercent => 'Type in the percent that will be paid to the address provided and is enforced on-chain upon any trade. This fee is remitted to the royalty holder upon transaction finality.';

  @override
  String get r3aHelpBodySaveAsDraft => 'Save your smart contract as a draft locally to come back and work on it later.';

  @override
  String get r3aHelpBodyScName => 'Name your smart contract. This field is required and is publicly visible.';

  @override
  String get r3aHelpBodySetEvolution => 'With an NFT that has more than 2 phases the user can go directly from one stage to another with the “Set Evolution” button instead of evolving and devolving stage by stage';

  @override
  String get r3aHelpBodySmartContract => 'Configure the parameters of your smart contract then compile and mint it.';

  @override
  String get r3aHelpBodyTransfer => 'Transfer this NFT to another account.';

  @override
  String get r3aHelpBodyWalletUnlockTime => 'This is the amount of time once a password has been entered the wallet will remain unlocked and not need password again \n\nDefault value: 15';

  @override
  String get r3aIgnoreIncomingNfts => 'Ignore Incoming NFTs';

  @override
  String r3aMaxMintAtOnce(String max) {
    return 'The maxium number you can mint at one time is $max.';
  }

  @override
  String get r3aMintBroadcastedBody => 'Smart Contract mint transaction has been broadcasted.\n\nThe NFTs screen will reflect the change once the block is crafted and block height has synced with this transaction.';

  @override
  String get r3aMintTxSent => 'Mint transaction sent successfully. Please wait until the the smart contract is minted on-chain.';

  @override
  String get r3aMinterCreatorName => 'Minter/Creator Name';

  @override
  String get r3aMinterName => 'Minter Name';

  @override
  String get r3aMinting => 'Minting';

  @override
  String get r3aMintingEllipsis => 'Minting…';

  @override
  String get r3aMotherAddress => 'Mother Address';

  @override
  String get r3aMotherPassword => 'Mother Password';

  @override
  String get r3aNftSaleTransferStarted => 'Success: NFT Sale Transfer has been started.';

  @override
  String get r3aNftTimeout => 'Nft Timeout';

  @override
  String get r3aNftTransferStarted => 'Success: NFT Transfer has been started.';

  @override
  String get r3aPasswordClearTime => 'Password Clear Time';

  @override
  String get r3aPayeeAddress => 'Payee Address';

  @override
  String get r3aProblemCompilingSc => 'A problem occurred compiling this smart contract.';

  @override
  String get r3aProblemMintingSc => 'A problem occurred minting this smart contract.';

  @override
  String get r3aProperty => 'Property';

  @override
  String get r3aPropertyTypes => 'Property Types';

  @override
  String get r3aRarities => 'Rarities';

  @override
  String get r3aRejectAssetExtensionTypes => 'Reject Asset Extension Types';

  @override
  String get r3aRoyaltyFlatFeeAmount => 'Royalty Flat Fee Amount';

  @override
  String get r3aRoyaltyPercentageFeeAmount => 'Royalty Percentage Fee Amount';

  @override
  String get r3aRoyaltyTo => 'Royalty to';

  @override
  String get r3aSaleCompleteTxSent => 'Sale Complete TX Sent';

  @override
  String get r3aSaveAsDraft => 'Save as Draft';

  @override
  String get r3aScMintedSuccessfully => 'Smart Contract minted successfully.';

  @override
  String get r3aSetEvolution => 'Set Evolution';

  @override
  String get r3aSmartContract => 'Smart Contract';

  @override
  String get r3aSmartContractName => 'Smart Contract Name';

  @override
  String get r3aStat => 'Stat';

  @override
  String get r3aStatType => 'Stat Type';

  @override
  String get r3aTransferNft => 'Transfer NFT';

  @override
  String get r3aUntitled => 'Untitled';

  @override
  String get r3aValue => 'Value';
}
