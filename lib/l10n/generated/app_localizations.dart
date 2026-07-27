import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Application title shown in window titles and browser tab.
  ///
  /// In en, this message translates to:
  /// **'VFX Wallet'**
  String get appTitle;

  /// Primary navigation label for the dashboard / home screen.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Primary navigation label for the transactions list.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// Primary navigation label for the wallet section.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// Primary navigation label for the NFTs section.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get navNfts;

  /// Primary navigation label for VFX domains (ADNR).
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get navDomains;

  /// Primary navigation label for settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Send funds / send transaction button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get actionSend;

  /// Receive funds button.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get actionReceive;

  /// Generic copy-to-clipboard action.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Generic paste-from-clipboard action.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get actionPaste;

  /// Confirm action — submits or approves the current step.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// Cancel action — dismisses the current action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Close action — closes a dialog or panel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Save action — persists current form state.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Delete action — destructive, removes an item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Search action or search field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// Continue action — proceeds past a confirmation prompt.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Clear action — resets a form.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Done action — dismisses a completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Import action — imports a wallet or key.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// Affirmative response in a confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// Negative response in a confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// Generic loading indicator text.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get statusLoading;

  /// Pending status for transactions or operations.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Confirmed status for a transaction.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// Failed status for a transaction.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// Successful status — used in the transactions tab label.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get statusSuccessful;

  /// Form label for an amount field.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// Form label for a wallet address field.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// Wallet balance label.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get labelBalance;

  /// Available (spendable) balance label.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get labelAvailable;

  /// Generic total label.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get labelTotal;

  /// Locked balance label in the send form.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get labelLocked;

  /// Transaction or network fee label.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get labelFee;

  /// From address label in a transaction.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get labelFrom;

  /// To address label in a transaction.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get labelTo;

  /// Create a new wallet call-to-action.
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get walletCreate;

  /// Import an existing wallet call-to-action.
  ///
  /// In en, this message translates to:
  /// **'Import Wallet'**
  String get walletImport;

  /// Label for a private key field.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get walletPrivateKey;

  /// Label for a wallet recovery / seed phrase.
  ///
  /// In en, this message translates to:
  /// **'Recovery Phrase'**
  String get walletRecoveryPhrase;

  /// Empty state for search or list views.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get messageNoResults;

  /// Transient toast shown after a copy action.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get messageCopiedToClipboard;

  /// Transient toast shown after copying a wallet address.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get messageAddressCopied;

  /// Transient toast shown after copying a private key.
  ///
  /// In en, this message translates to:
  /// **'Private Key copied to clipboard'**
  String get messagePrivateKeyCopied;

  /// Empty-state message shown when the user has no wallet/account selected.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get messageNoAccountSelected;

  /// Error toast shown when clipboard contents cannot be pasted as an address.
  ///
  /// In en, this message translates to:
  /// **'Clipboard text is invalid'**
  String get messageClipboardInvalid;

  /// Toast shown after a successful send transaction, with the sent amount.
  ///
  /// In en, this message translates to:
  /// **'Sent {amount} VFX'**
  String sentAmount(String amount);

  /// Send screen app bar title — currency is VFX or BTC.
  ///
  /// In en, this message translates to:
  /// **'Send {currency}'**
  String sendAppBarTitle(String currency);

  /// Recipient label (with colon) in the send form.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get sendFormLabelTo;

  /// Sender label (with colon) in the send form.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get sendFormLabelFrom;

  /// Amount label (with colon) in the send form.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get sendFormLabelAmount;

  /// Fee rate label (with colon) in the BTC send form.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate:'**
  String get sendFormLabelFeeRate;

  /// Placeholder text for the recipient address field in the send form.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s Account Address'**
  String get sendRecipientHint;

  /// Placeholder for the amount field in the send form.
  ///
  /// In en, this message translates to:
  /// **'Amount of {currency} to send'**
  String sendAmountHint(String currency);

  /// Warning badge shown when a Vault account is not yet activated.
  ///
  /// In en, this message translates to:
  /// **'Not Activated'**
  String get sendBadgeNotActivated;

  /// Title of the dialog used to pick one of the user's own addresses as recipient.
  ///
  /// In en, this message translates to:
  /// **'Choose an address'**
  String get sendChooseAddressTitle;

  /// Call-to-action that opens the Butterfly payment-link flow.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Link'**
  String get sendPaymentLinkCta;

  /// Helper text beneath the recipient address field on non-macOS platforms. Intentionally ends with a trailing space — followed inline by 'here' link and period.
  ///
  /// In en, this message translates to:
  /// **'Use ctrl+v to paste or click '**
  String get sendPasteHelperCtrl;

  /// Helper text beneath the recipient address field on macOS. Intentionally ends with a trailing space.
  ///
  /// In en, this message translates to:
  /// **'Use cmd+v to paste or click '**
  String get sendPasteHelperCmd;

  /// Inline clickable link in the paste helper text (reads as 'click here').
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get sendPasteHelperHereLink;

  /// Receive screen app bar title — currency is VFX or BTC.
  ///
  /// In en, this message translates to:
  /// **'Receive {currency}'**
  String receiveAppBarTitle(String currency);

  /// Subtitle above the currently selected VFX receive address. vaultSuffix is either empty or ' Vault Account'.
  ///
  /// In en, this message translates to:
  /// **'Your Selected VFX{vaultSuffix} Address'**
  String receiveSelectedVfxAddress(String vaultSuffix);

  /// Subtitle above the currently selected BTC receive address.
  ///
  /// In en, this message translates to:
  /// **'Your Selected BTC Address'**
  String get receiveSelectedBtcAddress;

  /// Error toast when attempting to copy an inactive Vault account address.
  ///
  /// In en, this message translates to:
  /// **'This Vault Account has not been activated yet.'**
  String get receiveVaultNotActivatedToast;

  /// Two-line vertical button label on the receive screen. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Copy\nAddress'**
  String get receiveActionCopyAddress;

  /// Two-line vertical button label on the receive screen. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'New\nAccount'**
  String get receiveActionNewAccount;

  /// Two-line vertical button label on the receive screen. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Import\nKey'**
  String get receiveActionImportKey;

  /// Confirmation dialog title asking whether to rescan the chain after importing a key.
  ///
  /// In en, this message translates to:
  /// **'Rescan Blocks?'**
  String get receiveRescanDialogTitle;

  /// Confirmation dialog body explaining the rescan prompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to rescan the chain to include any transactions relevant to this key?'**
  String get receiveRescanDialogBody;

  /// Dialog title shown after a new BTC account is generated.
  ///
  /// In en, this message translates to:
  /// **'BTC Account Created'**
  String get receiveBtcAccountCreatedTitle;

  /// Body text urging the user to back up the newly generated BTC private key.
  ///
  /// In en, this message translates to:
  /// **'Here are your BTC account details. Please ensure to back up your private key in a safe place.'**
  String get receiveBtcAccountCreatedBody;

  /// Dialog title for the BTC private key import form.
  ///
  /// In en, this message translates to:
  /// **'Import BTC Private Key'**
  String get receiveBtcImportKeyDialogTitle;

  /// Instruction in the BTC private key import dialog.
  ///
  /// In en, this message translates to:
  /// **'Paste in your BTC private key to import your account.'**
  String get receiveBtcImportKeyDialogBody;

  /// Transactions screen title when viewing both VFX and BTC.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get txAppBarAll;

  /// Transactions screen title when filtered to VFX.
  ///
  /// In en, this message translates to:
  /// **'VFX Transactions'**
  String get txAppBarVfx;

  /// Transactions screen title when filtered to BTC.
  ///
  /// In en, this message translates to:
  /// **'BTC Transactions'**
  String get txAppBarBtc;

  /// Transactions tab label for the full list.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get txTabAll;

  /// Transactions tab label for pending transactions.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get txTabPending;

  /// Transactions tab label for successful transactions.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get txTabSuccessful;

  /// Transactions tab label for failed transactions.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get txTabFailed;

  /// Transactions tab label for Vault-account transactions.
  ///
  /// In en, this message translates to:
  /// **'Vaulted'**
  String get txTabVaulted;

  /// BTC transactions tab label (sibling of 'Inputs').
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get txTabTransactions;

  /// BTC inputs (UTXO) tab label.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get txTabInputs;

  /// Web-only section heading above the keygen CTA on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get homeKeysHeading;

  /// Two-line vertical button label on the dashboard common actions. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Send\nCoin'**
  String get homeActionSendCoin;

  /// Two-line vertical button label on the dashboard common actions. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Receive\nCoin'**
  String get homeActionReceiveCoin;

  /// Abbreviated label for the transactions shortcut tile on the dashboard. Kept short to fit a tight tile.
  ///
  /// In en, this message translates to:
  /// **'TXs'**
  String get homeActionTxs;

  /// Call-to-action button on the dashboard that opens the buy/faucet options.
  ///
  /// In en, this message translates to:
  /// **'Get \$VFX/\$BTC Now'**
  String get homeGetVfxBtcCta;

  /// Shortened CTA variant for the dashboard (VFX only).
  ///
  /// In en, this message translates to:
  /// **'Get \$VFX'**
  String get homeGetVfxCta;

  /// App bar title for the advanced CLI configuration screen.
  ///
  /// In en, this message translates to:
  /// **'CLI Configuration'**
  String get configAppBarTitle;

  /// Confirm dialog title when the user tries to close the config screen with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the configuration screen?'**
  String get configCloseDialogTitle;

  /// Confirm dialog body warning that unsaved config changes are lost on close.
  ///
  /// In en, this message translates to:
  /// **'All unsaved changes will be lost.'**
  String get configCloseDialogBody;

  /// App bar action to open the raw config file in the OS file viewer.
  ///
  /// In en, this message translates to:
  /// **'Open Config'**
  String get configButtonOpenConfig;

  /// App bar action to open the external config documentation URL.
  ///
  /// In en, this message translates to:
  /// **'View Docs'**
  String get configButtonViewDocs;

  /// Warning banner above the advanced CLI config form.
  ///
  /// In en, this message translates to:
  /// **'Warning: These are advanced options. Proceed with caution.'**
  String get configWarningAdvanced;

  /// Toast shown after saving config changes that require a CLI restart.
  ///
  /// In en, this message translates to:
  /// **'CLI restart is required for changes to propagate.'**
  String get configRestartRequiredToast;

  /// Section header in settings for the UI language / locale picker.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// Language-picker option that follows the OS / browser locale.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystemDefault;

  /// English language option in the language picker. Shown in the locale's own script — NOT translated.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Spanish language option in the language picker. Shown in the locale's own script — NOT translated.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// App bar title for the accounts management screen.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get walletAccountsTitle;

  /// Label above the wallet selector when prompting the user to choose a different account.
  ///
  /// In en, this message translates to:
  /// **'Change Account:'**
  String get walletChangeAccount;

  /// Field label for the private key input/display.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get walletPrivateKeyLabel;

  /// Generic Import button label in wallet flows.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get walletImportLabel;

  /// Heading for the bulk private-key import modal.
  ///
  /// In en, this message translates to:
  /// **'Bulk Account Importer'**
  String get walletBulkImportTitle;

  /// Hint inside the bulk-import textarea.
  ///
  /// In en, this message translates to:
  /// **'Paste in your private keys. Each key should be a separate line.'**
  String get walletBulkImportHint;

  /// Confirm dialog title before importing private keys in bulk.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get walletConfirmImportTitle;

  /// Confirm dialog body for bulk private-key import.
  ///
  /// In en, this message translates to:
  /// **'Would you like to proceed with importing {label}?'**
  String walletConfirmImportBody(String label);

  /// Pluralized count of keypairs being imported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 keypair} other{{count} keypairs}}'**
  String walletKeypairsLabel(int count);

  /// Confirm dialog title asking whether to rescan the chain after import.
  ///
  /// In en, this message translates to:
  /// **'Rescan Blocks?'**
  String get walletRescanBlocksTitle;

  /// Bulk-import variant of the rescan confirmation body.
  ///
  /// In en, this message translates to:
  /// **'Would you like to rescan the chain to include any transactions relevant to these keys?'**
  String get walletRescanBlocksBodyKeys;

  /// Single-import variant of the rescan confirmation body.
  ///
  /// In en, this message translates to:
  /// **'Would you like to rescan the chain to include any transactions relevant to this key?'**
  String get walletRescanBlocksBodyKey;

  /// Toast confirming a private key import.
  ///
  /// In en, this message translates to:
  /// **'{label} imported!'**
  String walletImportedToast(String label);

  /// Toast shown after copying a specific address to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'{address} copied to clipboard'**
  String walletAddressCopiedToast(String address);

  /// Toast confirming a private key was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Private Key copied to clipboard'**
  String get walletPrivateKeyCopiedToast;

  /// Tooltip on the copy icon next to the active VFX address in the wallet selector.
  ///
  /// In en, this message translates to:
  /// **'Copy VFX Address'**
  String get walletCopyVfxAddressTooltip;

  /// Tooltip on the copy icon next to the active BTC address in the wallet selector.
  ///
  /// In en, this message translates to:
  /// **'Copy BTC Address'**
  String get walletCopyBtcAddressTooltip;

  /// Placeholder shown in the wallet selector when no account is currently active.
  ///
  /// In en, this message translates to:
  /// **'VFX/BTC Account Addresses'**
  String get walletAddressesPlaceholder;

  /// Title of the prompt-modal used to import a wallet via private key.
  ///
  /// In en, this message translates to:
  /// **'Import Wallet'**
  String get walletImportTitle;

  /// Inline link in the import-wallet modal to switch to bulk import.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import'**
  String get walletBulkImportLabel;

  /// Menu item to create a new VFX account.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get walletNewAccount;

  /// Menu item to import a BTC private key (WIF).
  ///
  /// In en, this message translates to:
  /// **'Import BTC Wallet'**
  String get walletImportBtcWallet;

  /// Dialog title for the BTC private-key import flow.
  ///
  /// In en, this message translates to:
  /// **'Import BTC Private Key'**
  String get walletImportBtcDialogTitle;

  /// Dialog body for the BTC private-key import flow.
  ///
  /// In en, this message translates to:
  /// **'Paste in your BTC private key to import your account.'**
  String get walletImportBtcDialogBody;

  /// Menu item to create a new BTC account.
  ///
  /// In en, this message translates to:
  /// **'New BTC Account'**
  String get walletNewBtcAccount;

  /// Dialog title shown after a new BTC account is generated.
  ///
  /// In en, this message translates to:
  /// **'BTC Account Created'**
  String get walletBtcAccountCreatedTitle;

  /// Dialog body shown after a new BTC account is generated.
  ///
  /// In en, this message translates to:
  /// **'Here are your BTC account details. Please ensure to back up your private key in a safe place.'**
  String get walletBtcAccountCreatedBody;

  /// Field label for an address input/display.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get walletAddressLabel;

  /// Menu item to open the manage-wallets bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get walletManageAccounts;

  /// Toast confirming a BTC private key was imported.
  ///
  /// In en, this message translates to:
  /// **'Private Key Imported!'**
  String get walletPrivateKeyImportedToast;

  /// Toast for BTC private key import when account balance is still syncing.
  ///
  /// In en, this message translates to:
  /// **'Private Key Imported! Please wait until {nextSync} for the balance to sync.'**
  String walletPrivateKeyImportedSyncToast(String nextSync);

  /// Button to reveal the private key for an account.
  ///
  /// In en, this message translates to:
  /// **'Reveal Private Key'**
  String get walletRevealPrivateKey;

  /// Confirm dialog title when hiding an account from the GUI.
  ///
  /// In en, this message translates to:
  /// **'Hide Account'**
  String get walletHideAccountTitle;

  /// Confirm dialog body when hiding an account from the GUI.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to hide this account?'**
  String get walletHideAccountBody;

  /// Button label confirming the hide-account action.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get walletHideLabel;

  /// Status label shown next to a Vault account that is network-protected.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get walletStatusActivated;

  /// Header button that opens the hidden-accounts restorer.
  ///
  /// In en, this message translates to:
  /// **'Restore Hidden Accounts'**
  String get walletRestoreHidden;

  /// Empty-state message in the hidden-accounts restore dialog.
  ///
  /// In en, this message translates to:
  /// **'You have no hidden accounts.'**
  String get walletNoHiddenAccounts;

  /// Title of the hidden-accounts restore dialog when there are none.
  ///
  /// In en, this message translates to:
  /// **'No Accounts to Restore'**
  String get walletNoHiddenAccountsTitle;

  /// Generic acknowledgment button label.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get walletOkay;

  /// Title of the restore dialog when hidden accounts exist.
  ///
  /// In en, this message translates to:
  /// **'Select Account(s) to Restore'**
  String get walletSelectToRestore;

  /// Button to restore every hidden account.
  ///
  /// In en, this message translates to:
  /// **'Restore All'**
  String get walletRestoreAll;

  /// Button to restore the checked hidden accounts.
  ///
  /// In en, this message translates to:
  /// **'Restore Selected'**
  String get walletRestoreSelected;

  /// Label for the friendly-name input when renaming a wallet.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get walletNameLabel;

  /// Title of the rename-wallet prompt.
  ///
  /// In en, this message translates to:
  /// **'Rename {label}'**
  String walletRenameTitle(String label);

  /// Wallet context-menu item to rename the wallet.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get walletRename;

  /// Wallet context-menu item to delete the wallet.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get walletDelete;

  /// Form-validator name passed to formValidatorNotEmpty for the private-key field.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get walletPrivateKeyValidatorLabel;

  /// Generic Done button label used in wallet flows.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get walletDoneLabel;

  /// Title of the dialog shown after a Vault (reserve) account is created.
  ///
  /// In en, this message translates to:
  /// **'Vault Account Created'**
  String get walletVaultAccountCreatedTitle;

  /// Banner inside the Vault Account Created dialog about backing up the restore code.
  ///
  /// In en, this message translates to:
  /// **'🚨 Make sure to backup your RESTORE CODE somewhere safe. 🚨'**
  String get walletRestoreCodeWarning;

  /// Field label for the Vault account restore code.
  ///
  /// In en, this message translates to:
  /// **'Restore Code'**
  String get walletRestoreCodeLabel;

  /// Button label to copy all Vault-account backup data.
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get walletCopyAll;

  /// Button label to export Vault-account backup data as a file.
  ///
  /// In en, this message translates to:
  /// **'Save as File'**
  String get walletSaveAsFile;

  /// Toast shown after copying the full Vault-account backup data.
  ///
  /// In en, this message translates to:
  /// **'Vault Account Data copied to clipboard'**
  String get walletVaultDataCopiedToast;

  /// Toast shown after saving Vault-account backup as a file.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String walletSavedToToast(String path);

  /// Toast shown after copying the Vault-account restore code.
  ///
  /// In en, this message translates to:
  /// **'Restore Code copied to clipboard'**
  String get walletRestoreCodeCopiedToast;

  /// Field label for the Vault account recovery address.
  ///
  /// In en, this message translates to:
  /// **'Recovery Address'**
  String get walletRecoveryAddressLabel;

  /// Toast shown after copying the Vault-account recovery address.
  ///
  /// In en, this message translates to:
  /// **'Recovery Address copied to clipboard'**
  String get walletRecoveryAddressCopiedToast;

  /// Field label for the Vault account recovery private key.
  ///
  /// In en, this message translates to:
  /// **'Recovery Private Key'**
  String get walletRecoveryPrivateKeyLabel;

  /// Toast shown after copying the Vault-account recovery private key.
  ///
  /// In en, this message translates to:
  /// **'Recovery Private Key copied to clipboard'**
  String get walletRecoveryPrivateKeyCopiedToast;

  /// Confirm dialog title asking the user to confirm they have backed up their codes.
  ///
  /// In en, this message translates to:
  /// **'Backed up?'**
  String get walletBackupConfirmTitle;

  /// Confirm dialog body for the backup confirmation.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you have backed up your RESTORE CODE as well as your PASSWORD.'**
  String get walletBackupConfirmBody;

  /// Confirm button label for the backup confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'I\'m Backed Up'**
  String get walletBackupConfirmYes;

  /// Helper note inside the Vault Account Created dialog.
  ///
  /// In en, this message translates to:
  /// **'You will need the Restore Code and Password to Recover any transaction. It is highly advised to copy all and store safely as you would for any private key.'**
  String get walletRestoreCodeNote;

  /// Title of the welcome dialog shown to new web-wallet users.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the VerifiedX Web Wallet!'**
  String get authWelcomeTitle;

  /// First paragraph of the welcome dialog.
  ///
  /// In en, this message translates to:
  /// **'The network does NOT store your email/password or mnemonic. They are used as seeds to generate your accounts\' keypairs.'**
  String get authWelcomeBodyOne;

  /// Second paragraph of the welcome dialog.
  ///
  /// In en, this message translates to:
  /// **'This includes your VFX account, Vault account, and Bitcoin account.'**
  String get authWelcomeBodyTwo;

  /// Third paragraph of the welcome dialog.
  ///
  /// In en, this message translates to:
  /// **'We recommend backing up all private keys however, when generating with an email/password or mnemonic, your VFX private key will restore all three accounts.'**
  String get authWelcomeBodyThree;

  /// Welcome dialog action that opens the backup keys flow.
  ///
  /// In en, this message translates to:
  /// **'Backup Keys'**
  String get authBackupKeys;

  /// Caption above the address being unlocked on the auth screen.
  ///
  /// In en, this message translates to:
  /// **'Unlock wallet for:'**
  String get authUnlockWalletFor;

  /// Fallback shown when the stored primary address is missing.
  ///
  /// In en, this message translates to:
  /// **'Unknown Address'**
  String get authUnknownAddress;

  /// Button and prompt-title to enter the wallet password.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get authEnterPassword;

  /// Body text shown in the password prompt to decrypt stored keys.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to decrypt your stored keys.'**
  String get authEnterPasswordBody;

  /// Toast shown when key decryption fails on the auth screen.
  ///
  /// In en, this message translates to:
  /// **'Failed to decrypt keys'**
  String get authDecryptFailed;

  /// Logout button on the web auth screen.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// Primary CTA on the web auth screen to log in or create an account.
  ///
  /// In en, this message translates to:
  /// **'Login / Create Account'**
  String get authLoginCreateAccount;

  /// Button to resume an in-memory session on the web auth screen.
  ///
  /// In en, this message translates to:
  /// **'Resume Session'**
  String get authResumeSession;

  /// Subtitle under the VerifiedX wordmark on the auth screen.
  ///
  /// In en, this message translates to:
  /// **'Web Wallet {version}'**
  String authWebWalletSubtitle(String version);

  /// Auth-type modal option for email + password login.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get authTypeEmailPassword;

  /// Auth-type modal option for mnemonic / HD wallet login.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic (HD account)'**
  String get authTypeMnemonic;

  /// Auth-type modal option for VFX private-key login.
  ///
  /// In en, this message translates to:
  /// **'VFX Private Key'**
  String get authTypeVfxPrivateKey;

  /// Auth-type modal option for BTC private-key login.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin Private Key / WIF Key'**
  String get authTypeBtcPrivateKey;

  /// Auth-type modal option for the VerifiedX browser extension.
  ///
  /// In en, this message translates to:
  /// **'VFX Extension'**
  String get authTypeVfxExtension;

  /// App bar title on the vBTC onboarding screens.
  ///
  /// In en, this message translates to:
  /// **'vBTC Onboard'**
  String get btcVbtcOnboardTitle;

  /// Confirm dialog title when leaving the vBTC onboarding flow.
  ///
  /// In en, this message translates to:
  /// **'Exit vBTC Onboarding?'**
  String get btcExitOnboardingTitle;

  /// Confirm dialog body when leaving the vBTC onboarding flow.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel setting up your account with Tokenized Bitcoin?'**
  String get btcExitOnboardingBody;

  /// Status text on the final onboarding step when vBTC token is funded.
  ///
  /// In en, this message translates to:
  /// **'Your vBTC token is ready and funded.'**
  String get btcVbtcReady;

  /// Button to navigate to the newly minted vBTC token detail.
  ///
  /// In en, this message translates to:
  /// **'View Token'**
  String get btcViewToken;

  /// Toast when the requested vBTC token cannot be located.
  ///
  /// In en, this message translates to:
  /// **'Token not found'**
  String get btcTokenNotFoundToast;

  /// Empty-state shown when neither a BTC account nor a token is available.
  ///
  /// In en, this message translates to:
  /// **'No BTC account / Token Found.'**
  String get btcNoBtcAccountOrToken;

  /// Button to reset the onboarding flow.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get btcStartOver;

  /// Label showing the sending BTC address.
  ///
  /// In en, this message translates to:
  /// **'From: {address}'**
  String btcFromAddress(String address);

  /// Label showing the receiving BTC address.
  ///
  /// In en, this message translates to:
  /// **'To: {address}'**
  String btcToAddress(String address);

  /// Field label for the amount of BTC to send during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Amount to Send (BTC)'**
  String get btcAmountToSendLabel;

  /// Inline label for the fee-rate selector in BTC flows.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate:'**
  String get btcFeeRateLabel;

  /// Button to start a BTC transfer during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Initiate Transfer'**
  String get btcInitiateTransfer;

  /// Toast shown when the entered BTC amount is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get btcInvalidAmountToast;

  /// Field label for a BTC address input/display.
  ///
  /// In en, this message translates to:
  /// **'BTC Address'**
  String get btcAddressLabel;

  /// Toast confirming a BTC deposit address was copied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard!'**
  String get btcAddressCopiedToast;

  /// Confirmation button when the user sent BTC manually.
  ///
  /// In en, this message translates to:
  /// **'I\'ve sent this manually!'**
  String get btcSentManually;

  /// Empty-state shown when the user has no BTC account.
  ///
  /// In en, this message translates to:
  /// **'No BTC Account Found.'**
  String get btcNoBtcAccount;

  /// Toast confirming a WIF private key was copied.
  ///
  /// In en, this message translates to:
  /// **'WIF private key copied to clipboard'**
  String get btcWifCopiedToast;

  /// Final-step button label on BTC onboarding flows.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get btcDoneExclamation;

  /// Button to import an existing wallet/account during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Import Existing'**
  String get btcImportExisting;

  /// Button to create a new account during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get btcCreateNew;

  /// Info dialog title when a balance is detected on imported VFX account.
  ///
  /// In en, this message translates to:
  /// **'Balance Found!'**
  String get btcBalanceFoundTitle;

  /// Toast confirming a VFX account import succeeded.
  ///
  /// In en, this message translates to:
  /// **'VFX Account Imported Successfully'**
  String get btcVfxAccountImportedToast;

  /// Toast confirming a VFX account was created.
  ///
  /// In en, this message translates to:
  /// **'VFX account Created Successfully'**
  String get btcVfxAccountCreatedToast;

  /// Helper text above the VFX account picker during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Or use one of your existing VFX Accounts:'**
  String get btcUseExistingVfxAccount;

  /// Helper text above the BTC account picker during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Or use one of your existing BTC Accounts:'**
  String get btcUseExistingBtcAccount;

  /// Empty-state shown when the user has no VFX account.
  ///
  /// In en, this message translates to:
  /// **'No VFX Account Found.'**
  String get btcNoVfxAccount;

  /// Button to request VFX from the testnet faucet during onboarding.
  ///
  /// In en, this message translates to:
  /// **'Use Faucet'**
  String get btcUseFaucet;

  /// Prompt title asking for the user's phone number for the faucet.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get btcPhoneNumberTitle;

  /// Phone-number field label for the faucet.
  ///
  /// In en, this message translates to:
  /// **'Your Phone Number'**
  String get btcPhoneNumberLabel;

  /// Toast shown when the entered phone number is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Phone Number'**
  String get btcInvalidPhoneToast;

  /// Prompt title for the SMS verification code.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code sent to {phone}'**
  String btcVerificationCodeTitle(String phone);

  /// Field label for the SMS verification code.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get btcVerificationCodeLabel;

  /// Helper text introducing the manual-send option in onboarding.
  ///
  /// In en, this message translates to:
  /// **'Alternatively, you can send the BTC manually to your token\'s deposit address.'**
  String get btcManualSendBody;

  /// Toast shown when the BTC account does not have enough balance.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance in BTC account to send {amount} BTC'**
  String btcNotEnoughBalance(String amount);

  /// Toast shown when faucet funds were broadcast.
  ///
  /// In en, this message translates to:
  /// **'Success! Funds are on their way. TX Hash: {hash}'**
  String btcFundsSuccessToast(String hash);

  /// Button to switch the user to the manual transfer flow.
  ///
  /// In en, this message translates to:
  /// **'Transfer Manually'**
  String get btcTransferManually;

  /// App bar title for the bulk vBTC transfer screen.
  ///
  /// In en, this message translates to:
  /// **'Bulk vBTC Transfer'**
  String get btcBulkTransferTitle;

  /// Label for the maximum transferable vBTC amount.
  ///
  /// In en, this message translates to:
  /// **'Maximum Transfer Amount:'**
  String get btcBulkMaxTransferAmount;

  /// Button to continue from the bulk vBTC selection step.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btcBulkContinue;

  /// Toast when the user tries to continue without selecting any tokens.
  ///
  /// In en, this message translates to:
  /// **'No tokens selected.'**
  String get btcBulkNoTokensSelected;

  /// Hint for the per-token amount field in the bulk transfer screen.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get btcBulkAmountHint;

  /// Helper label showing the maximum transferable amount for a token.
  ///
  /// In en, this message translates to:
  /// **'(MAX: {amount} vBTC)'**
  String btcBulkMaxLabel(String amount);

  /// Total transfer amount label.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} vBTC'**
  String btcBulkTotalLabel(String amount);

  /// Field label for the VFX recipient in the bulk transfer screen.
  ///
  /// In en, this message translates to:
  /// **'Transfer To VFX Address'**
  String get btcBulkTransferToLabel;

  /// Hint for the VFX recipient field in the bulk transfer screen.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s VFX Account Address'**
  String get btcBulkTransferToHint;

  /// Confirm dialog title for the bulk vBTC transfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Bulk Tx'**
  String get btcBulkConfirmTxTitle;

  /// Toast confirming the bulk vBTC transfer was broadcast.
  ///
  /// In en, this message translates to:
  /// **'vBTC Bulk Transfer TX broadcasted'**
  String get btcBulkBroadcastedToast;

  /// Toast shown when the user has not selected a VFX account.
  ///
  /// In en, this message translates to:
  /// **'No VFX account selected'**
  String get btcBulkNoVfxSelectedToast;

  /// App bar title for the manual vBTC mint screen.
  ///
  /// In en, this message translates to:
  /// **'Tokenize BTC (vBTC)'**
  String get btcTokenizeTitle;

  /// Hint shown in the vBTC token name fields.
  ///
  /// In en, this message translates to:
  /// **'vBTC Token'**
  String get btcVbtcTokenHint;

  /// Hint shown in the vBTC ticker field.
  ///
  /// In en, this message translates to:
  /// **'vBTC'**
  String get btcVbtcHint;

  /// Button to view the in-progress MPC ceremony.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get btcViewProgress;

  /// Button label that compiles and mints the vBTC token contract.
  ///
  /// In en, this message translates to:
  /// **'Compile & Mint'**
  String get btcCompileMint;

  /// Info dialog title shown after a vBTC transaction is broadcast.
  ///
  /// In en, this message translates to:
  /// **'Transaction Broadcasted'**
  String get btcTransactionBroadcastedTitle;

  /// Button label to mint and deploy the vBTC contract.
  ///
  /// In en, this message translates to:
  /// **'Mint & Deploy'**
  String get btcMintAndDeploy;

  /// Toast shown when no VFX address is selected during mint.
  ///
  /// In en, this message translates to:
  /// **'A VFX address is required'**
  String get btcVfxAddressRequired;

  /// Confirm dialog title for creating the vBTC token.
  ///
  /// In en, this message translates to:
  /// **'Create vBTC Token?'**
  String get btcCreateVbtcTitle;

  /// Confirm dialog body line about the MPC ceremony.
  ///
  /// In en, this message translates to:
  /// **'This will start an MPC ceremony to create your vBTC token.'**
  String get btcMpcStartBody;

  /// Confirm dialog body line about the network fee for vBTC mint.
  ///
  /// In en, this message translates to:
  /// **'A network fee of ~0.000028 VFX is required.'**
  String get btcNetworkFeeBody;

  /// Confirm dialog label showing the chosen VFX account.
  ///
  /// In en, this message translates to:
  /// **'VFX Account: {address}'**
  String btcVfxAccountLabel(String address);

  /// Inline label above the wallet selector in the mint dialog.
  ///
  /// In en, this message translates to:
  /// **'Change Account:'**
  String get btcChangeAccountLabel;

  /// Inline label for the chosen VFX address in the mint dialog.
  ///
  /// In en, this message translates to:
  /// **'VFX Address:'**
  String get btcVfxAddressLabel;

  /// Confirm dialog body asking whether to continue.
  ///
  /// In en, this message translates to:
  /// **'Continue?'**
  String get btcContinueQuestion;

  /// App bar title for the tokenized BTC list screen.
  ///
  /// In en, this message translates to:
  /// **'Tokenized Bitcoin (vBTC)'**
  String get btcVbtcListTitle;

  /// Button to open the bulk vBTC transfer screen.
  ///
  /// In en, this message translates to:
  /// **'Bulk vBTC Transfer'**
  String get btcBulkTransferLabel;

  /// Toast shown when no vBTC tokens have a balance for transfer.
  ///
  /// In en, this message translates to:
  /// **'No vBTC tokens with a balance'**
  String get btcNoVbtcWithBalance;

  /// Button to start creating a vBTC token.
  ///
  /// In en, this message translates to:
  /// **'Create Verified BTC Token'**
  String get btcCreateVerifiedToken;

  /// Info dialog title when a funded VFX address is required.
  ///
  /// In en, this message translates to:
  /// **'VFX Address with Balance Required'**
  String get btcVfxBalanceRequiredTitle;

  /// Button to launch the guided vBTC wizard.
  ///
  /// In en, this message translates to:
  /// **'Use Wizard'**
  String get btcUseWizard;

  /// Generic vBTC label used as a list-tile title in the tokenized BTC list.
  ///
  /// In en, this message translates to:
  /// **'vBTC'**
  String get btcVbtcLabel;

  /// Empty-state for the tokenized-BTC list.
  ///
  /// In en, this message translates to:
  /// **'No Tokenized Bitcoin found in account.'**
  String get btcNoTokenizedBtc;

  /// Button label to open the details view of a token.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get btcDetailsLabel;

  /// Empty-state for the BTC transactions list.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get btcNoTransactions;

  /// Inline message shown when a vBTC token is missing.
  ///
  /// In en, this message translates to:
  /// **'Token Not Found'**
  String get btcTokenNotFoundLabel;

  /// Token detail field label for name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get btcDetailNameLabel;

  /// Token detail field label for description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get btcDetailDescriptionLabel;

  /// Token detail field label for owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get btcDetailOwnerLabel;

  /// Token detail field label for smart contract owner.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract Owner'**
  String get btcDetailScOwnerLabel;

  /// Token detail field label for smart contract owner address (web variant).
  ///
  /// In en, this message translates to:
  /// **'SmartContract Owner Address'**
  String get btcDetailScOwnerAddressLabel;

  /// Token detail field label for the BTC deposit address.
  ///
  /// In en, this message translates to:
  /// **'BTC Deposit Address'**
  String get btcDetailDepositAddressLabel;

  /// Token detail field label for smart contract id.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract ID'**
  String get btcDetailScIdLabel;

  /// Token detail field label for the current account's vBTC balance.
  ///
  /// In en, this message translates to:
  /// **'My Balance'**
  String get btcDetailMyBalanceLabel;

  /// Token detail field label for the global token balance.
  ///
  /// In en, this message translates to:
  /// **'Token Total Balance'**
  String get btcDetailTotalBalanceLabel;

  /// Helper text shown to non-owners viewing token media.
  ///
  /// In en, this message translates to:
  /// **'Only the token owner can view the additional media.'**
  String get btcDetailOwnerOnlyMedia;

  /// Button to broadcast a transfer-now call on a vBTC token.
  ///
  /// In en, this message translates to:
  /// **'Transfer Now'**
  String get btcDetailTransferNow;

  /// Toast shown after broadcasting a vBTC transfer-now call.
  ///
  /// In en, this message translates to:
  /// **'Transfer request has been broadcasted. Your assets should be available soon.'**
  String get btcTransferNowToast;

  /// Toast confirming a labelled value was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String btcLabelCopiedToast(String label);

  /// Generic retry button label used in BTC flows.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btcRetry;

  /// Status badge shown for a confirmed BTC transaction.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get btcConfirmedLabel;

  /// Status badge shown for a pending BTC transaction.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get btcPendingLabel;

  /// Button to bump fee on a pending BTC transaction.
  ///
  /// In en, this message translates to:
  /// **'Replace By Fee'**
  String get btcReplaceByFee;

  /// Prompt title for the replace-by-fee fee-rate input.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate'**
  String get btcRbfFeeRateTitle;

  /// Field label for the replace-by-fee fee-rate input.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate (SATS /byte)'**
  String get btcRbfFeeRateLabel;

  /// Button to copy the vBTC deposit address.
  ///
  /// In en, this message translates to:
  /// **'Copy Deposit Address'**
  String get btcCopyDepositAddress;

  /// Toast shown after copying a BTC address.
  ///
  /// In en, this message translates to:
  /// **'BTC Address copied to clipboard'**
  String get btcAddressCopiedShort;

  /// Button to fund a vBTC token.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get btcFundLabel;

  /// Prompt title for an amount entry that exposes current balance.
  ///
  /// In en, this message translates to:
  /// **'Amount (Balance: {balance} BTC)'**
  String btcAmountWithBalanceTitle(String balance);

  /// Generic confirm dialog title used in vBTC flows.
  ///
  /// In en, this message translates to:
  /// **'Please Confirm'**
  String get btcPleaseConfirmTitle;

  /// Button to open a transaction in the BTC explorer.
  ///
  /// In en, this message translates to:
  /// **'Open in BTC Explorer'**
  String get btcOpenInExplorer;

  /// Modal title for the manual-send option in vBTC flows.
  ///
  /// In en, this message translates to:
  /// **'Manual Send'**
  String get btcManualSendTitle;

  /// Button to withdraw vBTC back to BTC.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get btcWithdrawLabel;

  /// Field label for the withdrawal amount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawl Amount'**
  String get btcWithdrawAmountLabel;

  /// Field label for the receiving address on a withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Receiving Address'**
  String get btcReceivingAddressLabel;

  /// Generic info-dialog title for a response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get btcResponseTitle;

  /// Button to transfer ownership of a vBTC token.
  ///
  /// In en, this message translates to:
  /// **'Transfer Ownership'**
  String get btcTransferOwnership;

  /// Toast shown when attempting to transfer a token with zero balance.
  ///
  /// In en, this message translates to:
  /// **'vBTC tokens with no balance can not be transferred'**
  String get btcVbtcNoBalanceTransfer;

  /// Prompt title for entering a transfer-to address.
  ///
  /// In en, this message translates to:
  /// **'Transfer to'**
  String get btcTransferToTitle;

  /// Generic Transfer button label used in vBTC flows.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get btcTransferLabel;

  /// Button to prove ownership of a vBTC token.
  ///
  /// In en, this message translates to:
  /// **'Prove Ownership'**
  String get btcProveOwnership;

  /// Button label for borrow/lend feature.
  ///
  /// In en, this message translates to:
  /// **'Borrow/Lend'**
  String get btcBorrowLend;

  /// Toast shown when an unavailable action is attempted.
  ///
  /// In en, this message translates to:
  /// **'Action Not Available Yet.'**
  String get btcActionNotAvailable;

  /// Cancel button used in BTC flows.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btcCancelLabel;

  /// Toast shown when an entered amount is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get btcInvalidAmount;

  /// Toast shown when the account has insufficient balance.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance'**
  String get btcNotEnoughBalanceShort;

  /// Modal title for adding a BTC account.
  ///
  /// In en, this message translates to:
  /// **'Add BTC Account (Segwit)'**
  String get btcAddBtcAccount;

  /// Modal option to generate a random BTC keypair.
  ///
  /// In en, this message translates to:
  /// **'Generate Keypair'**
  String get btcGenerateKeypair;

  /// Subtitle for the generate-keypair option.
  ///
  /// In en, this message translates to:
  /// **'Generate a random BTC keypair.'**
  String get btcGenerateKeypairSubtitle;

  /// Modal option to import a BTC WIF private key.
  ///
  /// In en, this message translates to:
  /// **'Import WIF Private Key'**
  String get btcImportWifTitle;

  /// Subtitle for the import-WIF option.
  ///
  /// In en, this message translates to:
  /// **'Import your BTC WIF private key'**
  String get btcImportWifSubtitle;

  /// Badge label for a pending BTC domain creation.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Pending'**
  String get btcDomainPending;

  /// Badge label for a pending BTC domain transfer.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Transfer Pending'**
  String get btcDomainTransferPending;

  /// Badge label for a pending BTC domain deletion.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Delete Pending'**
  String get btcDomainDeletePending;

  /// Button to create a new BTC domain.
  ///
  /// In en, this message translates to:
  /// **'Create Domain'**
  String get btcCreateDomain;

  /// Prompt title for transferring a BTC domain.
  ///
  /// In en, this message translates to:
  /// **'Transfer BTC Domain'**
  String get btcTransferBtcDomain;

  /// Prompt title for the VFX owner step in BTC domain transfer.
  ///
  /// In en, this message translates to:
  /// **'VFX Owner'**
  String get btcVfxOwnerTitle;

  /// VFX address field label as used in the BTC domain transfer prompt (preserves trailing comma).
  ///
  /// In en, this message translates to:
  /// **'VFX Address,'**
  String get btcVfxAddressLabelComma;

  /// Toast shown when transaction data is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction data.'**
  String get btcInvalidTxData;

  /// Confirm dialog title shown when a transaction is valid.
  ///
  /// In en, this message translates to:
  /// **'Valid Transaction'**
  String get btcValidTxTitle;

  /// Toast shown when a transaction is cancelled by the user.
  ///
  /// In en, this message translates to:
  /// **'Transaction Cancelled'**
  String get btcTxCancelledToast;

  /// Confirm dialog title for deleting a BTC domain.
  ///
  /// In en, this message translates to:
  /// **'Delete BTC Domain?'**
  String get btcDeleteDomainTitle;

  /// Generic Status field label used in BTC tx tile.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get btcStatusLabel;

  /// Generic Fee field label used in BTC tx tile.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get btcFeeLabel;

  /// Block-time field label in BTC tx tile.
  ///
  /// In en, this message translates to:
  /// **'Block Time'**
  String get btcBlockTimeLabel;

  /// Block-height field label in BTC tx tile.
  ///
  /// In en, this message translates to:
  /// **'Block Height'**
  String get btcBlockHeightLabel;

  /// Empty-state shown when no BTC address is available on the web wallet.
  ///
  /// In en, this message translates to:
  /// **'No BTC Address'**
  String get btcWebNoBtcAddress;

  /// Empty-state for the transactions list of a specific BTC address.
  ///
  /// In en, this message translates to:
  /// **'No Transactions found for {address}.'**
  String btcWebNoTransactionsForAddress(String address);

  /// Inline error label used on the BTC web detail screen.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get btcWebError;

  /// App bar title for the manage Vault accounts screen.
  ///
  /// In en, this message translates to:
  /// **'Manage Vault Accounts'**
  String get reserveManageTitle;

  /// Button to set up a new Vault account.
  ///
  /// In en, this message translates to:
  /// **'Setup New Account'**
  String get reserveSetupNewAccount;

  /// Button to restore a previously created Vault account.
  ///
  /// In en, this message translates to:
  /// **'Restore Vault Account'**
  String get reserveRestoreVaultAccount;

  /// Empty-state on the manage Vault accounts screen.
  ///
  /// In en, this message translates to:
  /// **'No Vault Accounts'**
  String get reserveNoVaultAccounts;

  /// Inline label for the Vault account address row.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get reserveAddressColon;

  /// Inline label for the available-balance row.
  ///
  /// In en, this message translates to:
  /// **'Available Balance:'**
  String get reserveAvailableBalanceColon;

  /// Inline label for the status row.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get reserveStatusColon;

  /// Button to send funds from a Vault account.
  ///
  /// In en, this message translates to:
  /// **'Send Funds'**
  String get reserveSendFunds;

  /// Button/title for the manage-assets sheet.
  ///
  /// In en, this message translates to:
  /// **'Manage Assets'**
  String get reserveManageAssets;

  /// Manage-assets option label for NFTs.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get reserveAssetsNfts;

  /// Manage-assets option label for fungible tokens.
  ///
  /// In en, this message translates to:
  /// **'Fungible Tokens'**
  String get reserveAssetsTokens;

  /// Manage-assets option label for vBTC.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin (vBTC)'**
  String get reserveAssetsBtc;

  /// Toast shown when the Vault account has no assets/NFTs.
  ///
  /// In en, this message translates to:
  /// **'This account has no assets/NFTS.'**
  String get reserveNoAssetsToast;

  /// Transfer button label inside the manage-assets sheet.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get reserveTransferLabel;

  /// View-details button label inside the manage-assets sheet.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get reserveViewDetailsLabel;

  /// Toast shown when the Vault account has no vBTC tokens.
  ///
  /// In en, this message translates to:
  /// **'This account has no vBTC Tokens'**
  String get reserveNoVbtcTokens;

  /// Button to switch to the receive tab for a Vault account.
  ///
  /// In en, this message translates to:
  /// **'Receive Assets'**
  String get reserveReceiveAssets;

  /// Two-line vertical icon-button label for activating a Vault account. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Activate\nAccount'**
  String get reserveActivateAccountAction;

  /// App bar title for the Vault accounts overview screen.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts'**
  String get reserveOverviewTitle;

  /// Inline help link in the app-bar of the Vault overview screen.
  ///
  /// In en, this message translates to:
  /// **'What are Vault Accounts?'**
  String get reserveWhatIsVault;

  /// Subtitle showing available VFX for a Vault account.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount} VFX'**
  String reserveAvailableLabel(String amount);

  /// Status badge for an activated Vault account.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get reserveActivated;

  /// Status badge for a pending activation.
  ///
  /// In en, this message translates to:
  /// **'Activation Pending'**
  String get reserveActivationPending;

  /// Status button shown when a Vault account is below the activation minimum.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Funds'**
  String get reserveAwaitingFunds;

  /// Button to activate a Vault account now.
  ///
  /// In en, this message translates to:
  /// **'Activate Now'**
  String get reserveActivateNow;

  /// Button to start the Vault account recovery flow.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get reserveRecoverLabel;

  /// Confirm dialog title for the Vault recovery flow.
  ///
  /// In en, this message translates to:
  /// **'Recover Funds & NFTs'**
  String get reserveRecoverTitle;

  /// Confirm dialog body for the Vault recovery flow.
  ///
  /// In en, this message translates to:
  /// **'This is a destructive function that will callback all pending transactions and assets and move everything to this recovery account:\n\n{address}'**
  String reserveRecoverBody(String address);

  /// Confirm button label for the Vault recovery flow.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get reserveRecoverProceed;

  /// Confirm dialog title asking whether to back up NFT media.
  ///
  /// In en, this message translates to:
  /// **'Backup Media'**
  String get reserveBackupMediaTitle;

  /// Confirm dialog body for backing up NFT media.
  ///
  /// In en, this message translates to:
  /// **'NFT Media will not be transferred in this process. Would you like to export a backup now now so you can import into your new environment?'**
  String get reserveBackupMediaBody;

  /// Confirm button label for the backup-media dialog.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get reserveBackupAction;

  /// Button on the overview screen to navigate to the manage screen.
  ///
  /// In en, this message translates to:
  /// **'Manage Vault Accounts'**
  String get reserveManageVaultAccounts;

  /// Section title above the list of existing Vault accounts.
  ///
  /// In en, this message translates to:
  /// **'Existing Accounts'**
  String get reserveExistingAccounts;

  /// App bar title for the web Vault overview screen.
  ///
  /// In en, this message translates to:
  /// **'Your Vault Account'**
  String get reserveWebTitle;

  /// Empty-state on the web Vault overview screen.
  ///
  /// In en, this message translates to:
  /// **'No Vault Account Found'**
  String get reserveWebNoAccount;

  /// Button on the web Vault overview screen to reveal the account keys.
  ///
  /// In en, this message translates to:
  /// **'Reveal Keys'**
  String get reserveWebRevealKeys;

  /// Info dialog title for the web Vault balance breakdown.
  ///
  /// In en, this message translates to:
  /// **'Vault Account Balance'**
  String get reserveWebVaultBalanceTitle;

  /// Toast shown when the web Vault account has no NFTs to manage.
  ///
  /// In en, this message translates to:
  /// **'Your Vault Account has no NFTS.'**
  String get reserveWebNoNftsToast;

  /// Button to call back a transaction from a Vault account.
  ///
  /// In en, this message translates to:
  /// **'Callback'**
  String get reserveCallbackLabel;

  /// Prompt title for the callback action.
  ///
  /// In en, this message translates to:
  /// **'Callback Transaction'**
  String get reserveCallbackTitle;

  /// Prompt body for the callback action.
  ///
  /// In en, this message translates to:
  /// **'Callbacks can be used to return the funds/assets to the same account for escrow purposes. Input your password to callback this transaction.'**
  String get reserveCallbackBody;

  /// Field label for password entry in the callback flow.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get reservePasswordLabel;

  /// Toast shown after a callback transaction is broadcast.
  ///
  /// In en, this message translates to:
  /// **'Callback TX sent with hash of {hash}'**
  String reserveCallbackSentToast(String hash);

  /// App bar title for the validator pool / node list screen.
  ///
  /// In en, this message translates to:
  /// **'Validator Pool'**
  String get nodePoolTitle;

  /// Hint inside the validator-name search field.
  ///
  /// In en, this message translates to:
  /// **'Search by validator name...'**
  String get nodeSearchHint;

  /// Helper note under the validator search field.
  ///
  /// In en, this message translates to:
  /// **'* Must be the name exactly'**
  String get nodeSearchExactNote;

  /// Section heading above the user's own validator entries.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get nodeValidatorHeading;

  /// Badge label for an active validator/masternode.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get nodeStatusActive;

  /// Badge label for an inactive validator/masternode.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get nodeStatusInactive;

  /// Section heading above the peer info list.
  ///
  /// In en, this message translates to:
  /// **'Peer Info'**
  String get nodePeerInfoHeading;

  /// Field label for a peer's IP address.
  ///
  /// In en, this message translates to:
  /// **'IP:'**
  String get nodeIpLabel;

  /// Field label for a peer's block height.
  ///
  /// In en, this message translates to:
  /// **'Height:'**
  String get nodeHeightLabel;

  /// Field label for a peer's latency.
  ///
  /// In en, this message translates to:
  /// **'Latency:'**
  String get nodeLatencyLabel;

  /// Field label for the last-checked timestamp in node info.
  ///
  /// In en, this message translates to:
  /// **'Last Checked:'**
  String get nodeLastCheckedLabel;

  /// Connection-date label for a node card.
  ///
  /// In en, this message translates to:
  /// **'Connected: {date}'**
  String nodeConnectedLabel(String date);

  /// Wallet-version label for a node card.
  ///
  /// In en, this message translates to:
  /// **'Wallet Version: {version}'**
  String nodeWalletVersionLabel(String version);

  /// Connection-date label for a masternode card.
  ///
  /// In en, this message translates to:
  /// **'Connection Date: {date}'**
  String nodeConnectionDateLabel(String date);

  /// Block count label for a masternode card.
  ///
  /// In en, this message translates to:
  /// **'Blocks: {count}'**
  String nodeBlocksLabel(String count);

  /// App bar title for the validator screen.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get validatorTitle;

  /// Empty-state shown when no wallet is selected on the validator screen.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get validatorNoAccountSelected;

  /// Warning shown when the chosen account is not eligible to validate.
  ///
  /// In en, this message translates to:
  /// **'{label} can not validate.'**
  String validatorCannotValidate(String label);

  /// Helper note explaining that only one account can validate at a time.
  ///
  /// In en, this message translates to:
  /// **'You can only validate with one account.'**
  String get validatorOnlyOneAccount;

  /// Card body explaining the minimum balance required to validate.
  ///
  /// In en, this message translates to:
  /// **'Validating requires {amount} VFX.'**
  String validatorRequirementHint(String amount);

  /// Helper note above the wallet selector when current account is below the validator threshold.
  ///
  /// In en, this message translates to:
  /// **'Please choose another account:'**
  String get validatorChooseAccount;

  /// Helper note suggesting topping up the current account.
  ///
  /// In en, this message translates to:
  /// **'Or transfer {amount} VFX to {address}.'**
  String validatorTransferHint(String amount, String address);

  /// Card body describing the validator port and balance requirements.
  ///
  /// In en, this message translates to:
  /// **'You must have port {port}, {port2}, and {port3} open to external networks with a balance of {amount} VFX in order to validate.'**
  String validatorPortInstructions(String port, String port2, String port3, String amount);

  /// Button to start validating with the current account.
  ///
  /// In en, this message translates to:
  /// **'Start Validating'**
  String get validatorStartValidating;

  /// Toast shown when the current balance falls below the validator threshold.
  ///
  /// In en, this message translates to:
  /// **'Balance not currently sufficient to validate. {amount} VFX required.'**
  String validatorBalanceInsufficient(String amount);

  /// Prompt title for naming a validator.
  ///
  /// In en, this message translates to:
  /// **'Name your validator'**
  String get validatorNamePromptTitle;

  /// Field label for the validator name.
  ///
  /// In en, this message translates to:
  /// **'Validator Name'**
  String get validatorNameLabel;

  /// Toast confirming validation has started.
  ///
  /// In en, this message translates to:
  /// **'{name} [{label}] is now validating.'**
  String validatorNowValidating(String name, String label);

  /// Heading shown when the current account is not actively validating.
  ///
  /// In en, this message translates to:
  /// **'{label} is NOT Validating...'**
  String validatorNotValidating(String label);

  /// Button to refresh the validating-status check.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get validatorCheckAgain;

  /// Active-validator headline shown beside the rotating gear.
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get validatorActive;

  /// Address row in the active-validator card.
  ///
  /// In en, this message translates to:
  /// **'Address: {label}'**
  String validatorAddressLabel(String label);

  /// Tooltip on the rename-validator icon button.
  ///
  /// In en, this message translates to:
  /// **'Rename Validator'**
  String get validatorRenameTooltip;

  /// Prompt title used when renaming a validator.
  ///
  /// In en, this message translates to:
  /// **'Validator Name'**
  String get validatorNamePromptTitleAlt;

  /// Form-validator name passed to formValidatorNotEmpty for the validator-name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get validatorNameField;

  /// Field label for the rename-validator input.
  ///
  /// In en, this message translates to:
  /// **'New Validator Name'**
  String get validatorNewNameLabel;

  /// Toast confirming a validator was renamed.
  ///
  /// In en, this message translates to:
  /// **'Validator name changed to {name}.'**
  String validatorRenamedToast(String name);

  /// Confirm dialog title asking whether to restart the CLI.
  ///
  /// In en, this message translates to:
  /// **'Restart CLI'**
  String get validatorRestartCliTitle;

  /// Confirm dialog body for the CLI-restart prompt.
  ///
  /// In en, this message translates to:
  /// **'In order for the name to be reflected,\na restart of the CLI is required.\n\nRestart now?'**
  String get validatorRestartCliBody;

  /// Confirm button label for the CLI-restart prompt.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get validatorRestartCliConfirm;

  /// Toast shown while the CLI restart is in progress.
  ///
  /// In en, this message translates to:
  /// **'Restarting CLI...'**
  String get validatorRestartingToast;

  /// Button to stop validating.
  ///
  /// In en, this message translates to:
  /// **'Stop Validating'**
  String get validatorStopValidating;

  /// Confirm dialog body for stopping validation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop validating?'**
  String get validatorStopValidatingBody;

  /// Confirm button label when stopping validation.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get validatorStopLabel;

  /// Toast confirming validation has stopped.
  ///
  /// In en, this message translates to:
  /// **'{label} has stopped validating.'**
  String validatorStoppedToast(String label);

  /// Section heading showing the number of blocks the validator has produced.
  ///
  /// In en, this message translates to:
  /// **'Blocks Validated ({count})'**
  String validatorBlocksValidatedHeading(String count);

  /// Empty-state shown when the validator has not produced any blocks yet.
  ///
  /// In en, this message translates to:
  /// **'No Validated Blocks'**
  String get validatorNoValidatedBlocks;

  /// Title for the block detail dialog opened from a validated-block tile.
  ///
  /// In en, this message translates to:
  /// **'Block {height}'**
  String validatorBlockTitle(String height);

  /// App bar title for the combined domains screen (any currency).
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get adnrTitleAny;

  /// App bar title when filtered to VFX domains.
  ///
  /// In en, this message translates to:
  /// **'VFX Domains'**
  String get adnrTitleVfx;

  /// App bar title when filtered to BTC domains.
  ///
  /// In en, this message translates to:
  /// **'BTC Domains'**
  String get adnrTitleBtc;

  /// Marketing copy on the all-domains tab.
  ///
  /// In en, this message translates to:
  /// **'Create a domain as an alias to your address for receiving funds.'**
  String get adnrCreateAnyHeading;

  /// Marketing copy on the VFX-domains tab.
  ///
  /// In en, this message translates to:
  /// **'Create a VFX domain as an alias to your address for receiving funds.'**
  String get adnrCreateVfxHeading;

  /// Marketing copy on the BTC-domains tab.
  ///
  /// In en, this message translates to:
  /// **'Create a BTC domain as an alias to your BTC address for receiving funds.'**
  String get adnrCreateBtcHeading;

  /// Cost note on the all-domains tab.
  ///
  /// In en, this message translates to:
  /// **'Domains cost {cost} VFX plus the transaction fee.'**
  String adnrCostNoteAny(String cost);

  /// Cost note on the VFX-domains tab.
  ///
  /// In en, this message translates to:
  /// **'VFX domains cost {cost} VFX plus the transaction fee.'**
  String adnrCostNoteVfx(String cost);

  /// Cost note on the BTC-domains tab.
  ///
  /// In en, this message translates to:
  /// **'BTC domains cost {cost} VFX plus the transaction fee.'**
  String adnrCostNoteBtc(String cost);

  /// Subtitle shown when an account has no domain registered.
  ///
  /// In en, this message translates to:
  /// **'No Domain'**
  String get adnrNoDomain;

  /// Button to create a new domain.
  ///
  /// In en, this message translates to:
  /// **'Create Domain'**
  String get adnrCreateDomain;

  /// Button to transfer a domain.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get adnrTransfer;

  /// Button to delete a domain.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adnrDelete;

  /// Badge for a pending VFX domain creation.
  ///
  /// In en, this message translates to:
  /// **'Creation Pending'**
  String get adnrCreatePending;

  /// Badge for a pending VFX domain transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer Pending'**
  String get adnrTransferPending;

  /// Badge for a pending VFX domain deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete Pending'**
  String get adnrDeletePending;

  /// Section heading on the web ADNR screen for VFX domains.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain'**
  String get adnrVfxDomainBadge;

  /// Section heading on the web ADNR screen for BTC domains.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain'**
  String get adnrBtcDomainBadge;

  /// Badge for a pending VFX domain creation on the web.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain Pending'**
  String get adnrVfxDomainPending;

  /// Badge for a pending VFX domain transfer on the web.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain Transfer Pending'**
  String get adnrVfxDomainTransferPending;

  /// Badge for a pending VFX domain deletion on the web.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain Delete Pending'**
  String get adnrVfxDomainDeletePending;

  /// Marketing copy on the web ADNR VFX section.
  ///
  /// In en, this message translates to:
  /// **'Create a VFX Domain as an alias to your account\'s address for receiving funds.'**
  String get adnrCreateVfxOnAccount;

  /// Prompt title for transferring a VFX domain.
  ///
  /// In en, this message translates to:
  /// **'Transfer VFX Domain'**
  String get adnrTransferDomainTitle;

  /// Prompt body for transferring a VFX domain.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to transfer a VFX Domain.'**
  String adnrTransferDomainBody(String cost);

  /// Field label for the destination VFX address in the transfer prompt.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adnrAddressFieldLabel;

  /// Toast when the account does not have enough VFX to broadcast a domain transfer.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX in this account to create a transaction.'**
  String get adnrInsufficientFundsTransfer;

  /// Toast when the account does not have enough VFX to create a BTC domain.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX in your account to create a BTC domain. {cost} VFX required (plus TX fee).'**
  String adnrInsufficientFundsCreateBtc(String cost);

  /// Toast when the account does not have enough VFX to create a VFX domain.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX in this account to create a VFX domain. {cost} VFX required (plus TX fee).'**
  String adnrInsufficientFundsCreateVfx(String cost);

  /// Toast when the wallet does not have enough VFX to transfer a VFX domain.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX in this wallet to transfer a VFX domain. {cost} VFX required (plus TX fee).'**
  String adnrInsufficientFundsCreateInWallet(String cost);

  /// Toast when the wallet does not have enough VFX to delete a VFX domain.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX in this wallet to delete a VFX domain.'**
  String get adnrInsufficientFundsDeleteInWallet;

  /// Toast confirming a VFX domain transaction was broadcast.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain Transaction has been broadcasted. See log for hash.'**
  String get adnrTxBroadcastedToast;

  /// Toast confirming a BTC domain transaction was broadcast.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Transaction has been broadcasted. See log for hash.'**
  String get adnrBtcTxBroadcastedToast;

  /// Toast confirming a VFX domain transfer was broadcast.
  ///
  /// In en, this message translates to:
  /// **'VFX domain transfer transaction has been broadcasted. Check logs for tx hash'**
  String get adnrTransferTxBroadcastedToast;

  /// Toast confirming a VFX domain delete was broadcast.
  ///
  /// In en, this message translates to:
  /// **'VFX domain delete transaction has been broadcasted. Check logs for tx hash'**
  String get adnrDeleteTxBroadcastedToast;

  /// Confirm dialog title for deleting a VFX domain.
  ///
  /// In en, this message translates to:
  /// **'Delete VFX Domain?'**
  String get adnrDeleteTitle;

  /// Title of the fund-account dialog used in the ADNR card.
  ///
  /// In en, this message translates to:
  /// **'Fund Account'**
  String get adnrFundAccountTitle;

  /// Button to copy the address shown in the fund-account dialog.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get adnrFundCopyAddress;

  /// Toast confirming the address was copied (with trailing period; matches existing copy in this dialog).
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard.'**
  String get adnrAddressCopiedToast;

  /// Info dialog title shown after auto-sending funds to enable a domain creation.
  ///
  /// In en, this message translates to:
  /// **'Funds Sent'**
  String get adnrFundsSentTitle;

  /// Info dialog body shown after auto-sending funds to enable a domain creation.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX has been sent to {address}.\n\nPlease wait for transaction to reflect and then you can get your domain.'**
  String adnrFundsSentBody(String amount, String address);

  /// Title for the create-VFX-domain dialog.
  ///
  /// In en, this message translates to:
  /// **'New VFX Domain'**
  String get adnrCreateDialogTitleVfx;

  /// Title for the create-BTC-domain dialog.
  ///
  /// In en, this message translates to:
  /// **'New BTC Domain'**
  String get adnrCreateDialogTitleBtc;

  /// Cost line in the create-domain dialog (VFX).
  ///
  /// In en, this message translates to:
  /// **'VFX Domains cost {cost} VFX.'**
  String adnrCreateDialogCostVfx(String cost);

  /// Cost line in the create-domain dialog (BTC).
  ///
  /// In en, this message translates to:
  /// **'BTC Domains cost {cost} VFX.'**
  String adnrCreateDialogCostBtc(String cost);

  /// Helper line under the input describing automatic .vfx suffix.
  ///
  /// In en, this message translates to:
  /// **'Your domain must only contain letters and numbers and will automatically be appended with \".vfx\" upon verification'**
  String get adnrCreateDialogSuffixHelpVfx;

  /// Helper line under the input describing automatic .btc suffix.
  ///
  /// In en, this message translates to:
  /// **'Your domain must only contain letters and numbers and will automatically be appended with \".btc\" upon verification'**
  String get adnrCreateDialogSuffixHelpBtc;

  /// Field label for the domain-name input.
  ///
  /// In en, this message translates to:
  /// **'Domain Name'**
  String get adnrDomainNameLabel;

  /// Confirm button label in the create-domain dialog.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get adnrCreateButton;

  /// Title of the faucet-required dialog when creating a BTC domain.
  ///
  /// In en, this message translates to:
  /// **'{cost} VFX Required'**
  String adnrFaucetRequiredTitle(String cost);

  /// Body of the faucet-required dialog. Preserves original typo 'Woud' to match existing copy.
  ///
  /// In en, this message translates to:
  /// **'There is a {cost} VFX cost (plus TX fee) to create a BTC domain.\n\nThe community has allocated some VFX to lower the barrier to entry for trying out this feature. In order to prevent abuse, a phone number is required for an SMS authorization. Only a hash of your phone number will be stored.\n\nWoud you like to proceed?'**
  String adnrFaucetRequiredBody(String cost);

  /// Confirm button on the faucet-required dialog.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get adnrFaucetContinue;

  /// Cancel button on the faucet-required dialog.
  ///
  /// In en, this message translates to:
  /// **'No Thanks'**
  String get adnrFaucetNoThanks;

  /// Title of the faucet form modal opened from the create-domain dialog.
  ///
  /// In en, this message translates to:
  /// **'VFX Faucet'**
  String get adnrFaucetTitle;

  /// Toast shown after a faucet request, asking the user to wait for funds.
  ///
  /// In en, this message translates to:
  /// **'Please wait for your balance to arrive before continuing.'**
  String get adnrFaucetWaitToast;

  /// Toast shown when the entered domain name exceeds the maximum length.
  ///
  /// In en, this message translates to:
  /// **'Maximum characters for domain is 65'**
  String get adnrMaxLengthToast;

  /// Toast shown when the entered domain is already registered.
  ///
  /// In en, this message translates to:
  /// **'This {currency} Domain already exists'**
  String adnrAlreadyExistsToast(String currency);

  /// Toast shown when no BTC address is available during BTC domain creation.
  ///
  /// In en, this message translates to:
  /// **'No BTC Address Found'**
  String get adnrNoBtcAddress;

  /// Toast shown when no BTC WIF key is available during BTC domain creation.
  ///
  /// In en, this message translates to:
  /// **'No BTC WIF Private Key Found'**
  String get adnrNoBtcWif;

  /// Toast shown when no VFX account is available during a domain action.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get adnrNoAccountToast;

  /// Log entry written when a VFX domain transfer is broadcast.
  ///
  /// In en, this message translates to:
  /// **'VFX domain transfer transaction broadcasted. Tx Hash: {hash}'**
  String adnrLogTransferEntry(String hash);

  /// Log entry written when a VFX domain delete is broadcast.
  ///
  /// In en, this message translates to:
  /// **'VFX domain delete transaction broadcasted. Tx Hash: {hash}'**
  String adnrLogDeleteEntry(String hash);

  /// Log entry written when an ADNR create is broadcast.
  ///
  /// In en, this message translates to:
  /// **'ADNR create transaction broadcasted. Tx Hash: {hash}'**
  String adnrLogCreateEntry(String hash);

  /// App bar title for the NFTs list screen.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get nftListTitle;

  /// Button to import an NFT by smart-contract identifier.
  ///
  /// In en, this message translates to:
  /// **'Import NFT'**
  String get nftImportLabel;

  /// Prompt title for entering a smart-contract identifier.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract Identifier'**
  String get nftImportPromptTitle;

  /// Prompt body for entering a smart-contract identifier.
  ///
  /// In en, this message translates to:
  /// **'Paste in the smart contract\'s unique identifier.'**
  String get nftImportPromptBody;

  /// Field label for the smart-contract-identifier input.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get nftImportFieldLabel;

  /// Toast confirming a smart contract was imported from the network.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract imported from network'**
  String get nftImportedToast;

  /// Tab label for the user's NFTs list.
  ///
  /// In en, this message translates to:
  /// **'My NFTs'**
  String get nftTabMyNfts;

  /// Tab label for managing minted NFTs.
  ///
  /// In en, this message translates to:
  /// **'Manage Minted NFTs'**
  String get nftTabManageMinted;

  /// Badge shown on an NFT card when the NFT has been transferred away.
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get nftBadgeTransferred;

  /// Badge shown on an NFT card when the NFT is listed for sale.
  ///
  /// In en, this message translates to:
  /// **'Listed'**
  String get nftBadgeListed;

  /// Overlay text shown over an NFT being sold.
  ///
  /// In en, this message translates to:
  /// **'Sale in Progress...'**
  String get nftSaleInProgress;

  /// Overlay text shown over a burned NFT.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get nftBurnedOverlay;

  /// Badge shown on a locked NFT.
  ///
  /// In en, this message translates to:
  /// **'NFT Locked'**
  String get nftLockedBadge;

  /// Default label used by the TransferingOverlay widget.
  ///
  /// In en, this message translates to:
  /// **'Transferring...'**
  String get nftTransferringDefault;

  /// Title of the media-upload-progress modal.
  ///
  /// In en, this message translates to:
  /// **'Media Upload Progress'**
  String get nftMediaUploadProgress;

  /// Button to copy a media-backup URL.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get nftCopyUrl;

  /// Toast confirming a URL was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get nftUrlCopiedToast;

  /// Button to save the QR code image.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get nftQrSave;

  /// Button to open the QR code's link in a browser.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get nftQrOpen;

  /// Cancel button in the learn-more-content modal.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get nftLearnMoreCancel;

  /// Create button in the learn-more-content modal.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get nftLearnMoreCreate;

  /// App bar title fallback for the NFT detail screen when no NFT is loaded yet.
  ///
  /// In en, this message translates to:
  /// **'NFT'**
  String get nftDetailFallback;

  /// Field label for the minter address row on the NFT detail screen.
  ///
  /// In en, this message translates to:
  /// **'Minter Address'**
  String get nftMinterAddressLabel;

  /// Section heading for NFT properties.
  ///
  /// In en, this message translates to:
  /// **'Properties:'**
  String get nftPropertiesHeading;

  /// Section heading for NFT features.
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get nftFeaturesHeading;

  /// Button to reveal the evolve stages of an NFT.
  ///
  /// In en, this message translates to:
  /// **'Reveal Evolve Stages'**
  String get nftRevealEvolveStages;

  /// Button to prove ownership of an NFT.
  ///
  /// In en, this message translates to:
  /// **'Prove Ownership'**
  String get nftProveOwnership;

  /// Generic Transfer button label on NFT detail.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get nftTransfer;

  /// Button to start selling an NFT.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get nftSell;

  /// Toast shown when an action is coming soon.
  ///
  /// In en, this message translates to:
  /// **'Activating soon!'**
  String get nftActivatingSoonToast;

  /// Toast shown when no account is selected.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get nftNoAccountSelectedToast;

  /// Toast shown when a vault account attempts to sell an NFT.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts can not sell NFTs.'**
  String get nftVaultCannotSellToast;

  /// Toast shown when the account has insufficient balance for an NFT transaction.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance for transaction'**
  String get nftNotEnoughBalanceToast;

  /// Toast shown when local NFT media files cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Media files not found on this machine.'**
  String get nftMediaNotFoundToast;

  /// Prompt title for the sell-NFT flow.
  ///
  /// In en, this message translates to:
  /// **'Sell NFT'**
  String get nftSellTitle;

  /// Field label for the buyer's VFX address.
  ///
  /// In en, this message translates to:
  /// **'VFX Address'**
  String get nftSellAddressLabel;

  /// Toast shown when an invalid VFX address is entered.
  ///
  /// In en, this message translates to:
  /// **'Invalid Address'**
  String get nftInvalidAddressToast;

  /// Prompt title for the sale amount.
  ///
  /// In en, this message translates to:
  /// **'Sale Amount'**
  String get nftSellAmountTitle;

  /// Field label for the sale amount (preserves stray closing parenthesis from existing copy).
  ///
  /// In en, this message translates to:
  /// **'VFX Amount)'**
  String get nftSellAmountLabel;

  /// Toast shown when the sale amount is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get nftSellInvalidAmountToast;

  /// Prompt title for the optional backup URL.
  ///
  /// In en, this message translates to:
  /// **'Backup URL (Optional)'**
  String get nftBackupUrlTitle;

  /// Field label for the optional backup URL.
  ///
  /// In en, this message translates to:
  /// **'URL (Optional)'**
  String get nftBackupUrlLabel;

  /// Confirm dialog title before starting an NFT sale.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sale Start'**
  String get nftConfirmSaleStartTitle;

  /// Manage button on the NFT detail screen.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get nftManage;

  /// Button to view the smart-contract code for an NFT.
  ///
  /// In en, this message translates to:
  /// **'View Code'**
  String get nftViewCode;

  /// Button to sync remote NFT media.
  ///
  /// In en, this message translates to:
  /// **'Sync Media'**
  String get nftSyncMedia;

  /// Button to burn an NFT.
  ///
  /// In en, this message translates to:
  /// **'Burn'**
  String get nftBurn;

  /// Confirm dialog title before burning an NFT.
  ///
  /// In en, this message translates to:
  /// **'Burn NFT?'**
  String get nftBurnTitle;

  /// Button to broadcast a web NFT transfer-now.
  ///
  /// In en, this message translates to:
  /// **'Transfer Now'**
  String get nftTransferNow;

  /// Button to decrypt encrypted NFT data.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get nftDecrypt;

  /// Status text shown when NFT data is decrypted.
  ///
  /// In en, this message translates to:
  /// **'Decrypted'**
  String get nftDecrypted;

  /// Inline label for the media backup URL on the NFT detail screen.
  ///
  /// In en, this message translates to:
  /// **'Media Backup URL'**
  String get nftMediaBackupUrl;

  /// Confirm dialog title before evolving an NFT.
  ///
  /// In en, this message translates to:
  /// **'Evolve?'**
  String get nftEvolveTitle;

  /// Confirm dialog title before devolving an NFT.
  ///
  /// In en, this message translates to:
  /// **'Devolve?'**
  String get nftDevolveTitle;

  /// Toast confirming an evolve transaction was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Evolve transaction sent successfully!'**
  String get nftEvolveSentToast;

  /// Toast confirming a devolve transaction was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Devolve transaction sent successfully!'**
  String get nftDevolveSentToast;

  /// Info dialog title shown after an evolve transaction is broadcast.
  ///
  /// In en, this message translates to:
  /// **'Evolve transaction sent successfully'**
  String get nftEvolveSentTitle;

  /// Close button used on the NFT-management modal.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get nftClose;

  /// Button to view the NFT detail.
  ///
  /// In en, this message translates to:
  /// **'View NFT'**
  String get nftViewLabel;

  /// Badge shown on the NFT-management modal when the user owns the NFT.
  ///
  /// In en, this message translates to:
  /// **'Owned by Me'**
  String get nftOwnedByMe;

  /// Button to associate a media file with an evolve phase.
  ///
  /// In en, this message translates to:
  /// **'Associate'**
  String get nftAssociate;

  /// Button to open the associated media file.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get nftOpenFile;

  /// Phase name label inside the NFT management modal.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String nftPhaseNameLabel(String name);

  /// Button to evolve an NFT phase.
  ///
  /// In en, this message translates to:
  /// **'Evolve'**
  String get nftEvolve;

  /// App bar title for the Smart Contracts screen.
  ///
  /// In en, this message translates to:
  /// **'Smart Contracts'**
  String get scTitle;

  /// App bar title for the My Smart Contracts screen.
  ///
  /// In en, this message translates to:
  /// **'My Smart Contracts'**
  String get scMyTitle;

  /// App bar title for the templates chooser.
  ///
  /// In en, this message translates to:
  /// **'Smart Contracts Templates'**
  String get scTemplatesTitle;

  /// Tab label for compiled smart contracts.
  ///
  /// In en, this message translates to:
  /// **'Compiled'**
  String get scTabCompiled;

  /// Tab label for smart-contract drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get scTabDrafts;

  /// Empty-state for the smart-contract drafts list.
  ///
  /// In en, this message translates to:
  /// **'No Smart Contracts Drafts Found'**
  String get scNoDrafts;

  /// Empty-state for the compiled-smart-contracts list.
  ///
  /// In en, this message translates to:
  /// **'No Smart Contracts Found'**
  String get scNoCompiled;

  /// Big-button title to start creating and minting a smart contract.
  ///
  /// In en, this message translates to:
  /// **'Create a Smart Contract & Mint'**
  String get scCreateAndMintTitle;

  /// Big-button body for the create-and-mint action.
  ///
  /// In en, this message translates to:
  /// **'Start with a baseline smart contract and add customized features'**
  String get scCreateAndMintBody;

  /// Big-button title to mint an NFT collection.
  ///
  /// In en, this message translates to:
  /// **'Mint NFT Collection'**
  String get scMintCollectionTitle;

  /// Big-button body for the mint-collection action.
  ///
  /// In en, this message translates to:
  /// **'Mint multiple Smart Contracts into a collection'**
  String get scMintCollectionBody;

  /// Big-button title to launch the Trillium IDE.
  ///
  /// In en, this message translates to:
  /// **'Launch IDE'**
  String get scLaunchIdeTitle;

  /// Big-button body for the launch-IDE action.
  ///
  /// In en, this message translates to:
  /// **'Open the online IDE to write your own Trillium code for your smart contract'**
  String get scLaunchIdeBody;

  /// Toast shown when a BTC account is selected when starting to create a contract.
  ///
  /// In en, this message translates to:
  /// **'Please choose a VFX account to begin creating a smart contract.'**
  String get scChooseVfxToast;

  /// Toast shown when a vault account attempts to mint a smart contract.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts cannot mint smart contracts'**
  String get scVaultCannotMintToast;

  /// Heading on the smart-contract templates chooser.
  ///
  /// In en, this message translates to:
  /// **'Choose a Smart Contract & Add Features'**
  String get scTemplatesHeading;

  /// Create button on a template card.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get scCreateButton;

  /// Button to open the learn-more modal for a template.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get scLearnMore;

  /// App bar title for the fungible tokens list.
  ///
  /// In en, this message translates to:
  /// **'Fungible Tokens'**
  String get tokenListTitle;

  /// Button to create a new fungible token.
  ///
  /// In en, this message translates to:
  /// **'Create New Token'**
  String get tokenCreateNew;

  /// App bar title for the create-token screen.
  ///
  /// In en, this message translates to:
  /// **'Create Fungible Token'**
  String get tokenCreateTitle;

  /// App bar title for the token topic creation screen.
  ///
  /// In en, this message translates to:
  /// **'Create Token Topic'**
  String get tokenTopicCreateTitle;

  /// Title shown when a token operation is not supported on a vault account.
  ///
  /// In en, this message translates to:
  /// **'Not Supported by Vault Account'**
  String get tokenNotSupportedByVault;

  /// Button to prove ownership of a fungible token.
  ///
  /// In en, this message translates to:
  /// **'Prove Ownership'**
  String get tokenProveOwnership;

  /// Button/section header for the voting feature on a token.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get tokenVoting;

  /// List option to view existing voting topics.
  ///
  /// In en, this message translates to:
  /// **'View Topics'**
  String get tokenViewTopics;

  /// Info dialog title when a token has no voting topics.
  ///
  /// In en, this message translates to:
  /// **'No Topics'**
  String get tokenNoTopicsTitle;

  /// Info dialog body when a token has no voting topics. Apostrophe escaped per ICU.
  ///
  /// In en, this message translates to:
  /// **'This token doesn\'\'t have any voting topics yet.'**
  String get tokenNoTopicsBody;

  /// Button to list banned addresses on a token.
  ///
  /// In en, this message translates to:
  /// **'List Bans'**
  String get tokenListBans;

  /// Info dialog title showing banned token addresses.
  ///
  /// In en, this message translates to:
  /// **'Banned Addresses'**
  String get tokenBannedAddressesTitle;

  /// Field label for the smart contract UID in token management.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract UID'**
  String get tokenScUidLabel;

  /// Field label for a token's name.
  ///
  /// In en, this message translates to:
  /// **'Token Name'**
  String get tokenNameLabel;

  /// Field label for a token's lifetime supply cap.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Cap'**
  String get tokenLifetimeCapLabel;

  /// Field label indicating whether the token is mintable.
  ///
  /// In en, this message translates to:
  /// **'Mintable'**
  String get tokenMintableLabel;

  /// Field label for the token owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get tokenOwnerLabel;

  /// Field label for the token ticker.
  ///
  /// In en, this message translates to:
  /// **'Token Ticker'**
  String get tokenTickerLabel;

  /// Field label for the token's circulating supply.
  ///
  /// In en, this message translates to:
  /// **'Circulating Supply'**
  String get tokenCirculatingSupplyLabel;

  /// Field label for the burned token amount.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get tokenBurnedLabel;

  /// Field label indicating whether the token can be burned.
  ///
  /// In en, this message translates to:
  /// **'Burnable'**
  String get tokenBurnableLabel;

  /// Field label showing when a voting topic was created.
  ///
  /// In en, this message translates to:
  /// **'Topic Created'**
  String get tokenTopicCreatedLabel;

  /// Field label showing when voting on a topic ends.
  ///
  /// In en, this message translates to:
  /// **'Voting Ends'**
  String get tokenVotingEndsLabel;

  /// Button to vote yes on a token topic.
  ///
  /// In en, this message translates to:
  /// **'Vote Yes'**
  String get tokenVoteYes;

  /// Button to vote no on a token topic.
  ///
  /// In en, this message translates to:
  /// **'Vote No'**
  String get tokenVoteNo;

  /// Confirm dialog title before casting a YES vote.
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote [YES]'**
  String get tokenConfirmVoteYes;

  /// Confirm dialog title before casting a NO vote.
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote [NO]'**
  String get tokenConfirmVoteNo;

  /// Toast shown when the token's owner could not be determined.
  ///
  /// In en, this message translates to:
  /// **'Could not get owner of token'**
  String get tokenNoOwnerToast;

  /// Toast confirming a vote was cast.
  ///
  /// In en, this message translates to:
  /// **'Vote casted'**
  String get tokenVoteCastedToast;

  /// Button to open the voting history view.
  ///
  /// In en, this message translates to:
  /// **'Vote History'**
  String get tokenVoteHistory;

  /// Toast shown when there are no votes to display.
  ///
  /// In en, this message translates to:
  /// **'No Votes'**
  String get tokenNoVotesToast;

  /// Subtitle showing the block height for a vote.
  ///
  /// In en, this message translates to:
  /// **'Block {height}'**
  String tokenVoteBlockSubtitle(String height);

  /// Button to ban an address from holding a token.
  ///
  /// In en, this message translates to:
  /// **'Ban Address'**
  String get tokenBanAddress;

  /// Prompt title when banning a token address.
  ///
  /// In en, this message translates to:
  /// **'Address To Ban'**
  String get tokenBanAddressTitle;

  /// Generic Address field label used in token flows.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get tokenAddressFieldLabel;

  /// Toast confirming a ban transaction was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Token address ban transaction broadcasted'**
  String get tokenBanBroadcastedToast;

  /// Button to burn tokens.
  ///
  /// In en, this message translates to:
  /// **'Burn'**
  String get tokenBurn;

  /// Toast shown when burning is attempted on a non-burnable token.
  ///
  /// In en, this message translates to:
  /// **'This token is not burnable'**
  String get tokenNotBurnableToast;

  /// Prompt title for the burn amount.
  ///
  /// In en, this message translates to:
  /// **'Amount to Burn'**
  String get tokenAmountToBurnTitle;

  /// Generic Amount field label used in token flows.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get tokenAmountLabel;

  /// Toast shown when the entered token amount is invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get tokenInvalidAmountToast;

  /// Toast shown when balance is insufficient for a token transaction.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance to perform this transaction'**
  String get tokenInsufficientBalanceToast;

  /// Toast confirming a token burn was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Token burn transaction broadcasted'**
  String get tokenBurnBroadcastedToast;

  /// Button to change token ownership.
  ///
  /// In en, this message translates to:
  /// **'Change Ownership'**
  String get tokenChangeOwnership;

  /// Prompt title for the destination address when changing token ownership.
  ///
  /// In en, this message translates to:
  /// **'Transfer To Address'**
  String get tokenTransferToAddressTitle;

  /// Field label for the destination address in token transfers.
  ///
  /// In en, this message translates to:
  /// **'To Address'**
  String get tokenToAddressLabel;

  /// Toast confirming an ownership change was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Token ownership change transaction broadcasted'**
  String get tokenOwnershipBroadcastedToast;

  /// Button to start creating a fungible token.
  ///
  /// In en, this message translates to:
  /// **'Create Token'**
  String get tokenCreateButton;

  /// Hint inside the manage-tokens search field.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get tokenSearchHint;

  /// Pagination button: previous page.
  ///
  /// In en, this message translates to:
  /// **'Prev Page'**
  String get tokenPrevPage;

  /// Pagination button: next page.
  ///
  /// In en, this message translates to:
  /// **'Next Page'**
  String get tokenNextPage;

  /// Button to mint additional tokens.
  ///
  /// In en, this message translates to:
  /// **'Mint Tokens'**
  String get tokenMintTokens;

  /// Prompt title for the mint amount.
  ///
  /// In en, this message translates to:
  /// **'Amount to Mint'**
  String get tokenAmountToMintTitle;

  /// Toast confirming a mint transaction was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Token mint transaction broadcasted'**
  String get tokenMintBroadcastedToast;

  /// Toast shown when a token pause/state change is pending.
  ///
  /// In en, this message translates to:
  /// **'Token state change is pending. Please wait'**
  String get tokenStateChangePendingToast;

  /// Toast confirming an address was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard ({address})'**
  String tokenAddressCopiedToast(String address);

  /// Hint shown in the token name field.
  ///
  /// In en, this message translates to:
  /// **'MyToken'**
  String get tokenFormNameHint;

  /// Hint shown in the token ticker field.
  ///
  /// In en, this message translates to:
  /// **'ABC'**
  String get tokenFormTickerHint;

  /// Confirm button label in the token create form.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tokenFormCreate;

  /// Cancel button label in the token create form.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tokenFormCancel;

  /// Toast shown when no account is selected during token creation.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get tokenFormNoAccountSelectedToast;

  /// Toast shown when no icon image was selected during token creation.
  ///
  /// In en, this message translates to:
  /// **'Icon Image Required'**
  String get tokenFormIconRequiredToast;

  /// Confirm dialog title before compiling and minting a token contract.
  ///
  /// In en, this message translates to:
  /// **'Compile & Mint Token Smart Contract?'**
  String get tokenFormCompileMintTitle;

  /// Confirm dialog title shown to verify the deploy address.
  ///
  /// In en, this message translates to:
  /// **'Confirm Address'**
  String get tokenFormConfirmAddressTitle;

  /// Title shown while a token transaction is being processed.
  ///
  /// In en, this message translates to:
  /// **'Stand by'**
  String get tokenFormStandByTitle;

  /// Button to transfer tokens.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get tokenTransfer;

  /// Prompt title for the transfer amount.
  ///
  /// In en, this message translates to:
  /// **'Amount to Transfer'**
  String get tokenAmountToTransferTitle;

  /// Toast confirming a token transfer was broadcast.
  ///
  /// In en, this message translates to:
  /// **'Token transfer transaction broadcasted'**
  String get tokenTransferBroadcastedToast;

  /// Prompt title for entering a destination address.
  ///
  /// In en, this message translates to:
  /// **'Transfer to'**
  String get tokenTransferTo;

  /// Toast shown when the web account does not have enough tokens to perform an action. Apostrophe escaped per ICU.
  ///
  /// In en, this message translates to:
  /// **'This address\'\'s ({address}) {ticker} balance is insufficient.'**
  String tokenWebInsufficient(String address, String ticker);

  /// Modal title for creating a new voting topic.
  ///
  /// In en, this message translates to:
  /// **'Create New Voting Topic'**
  String get tokenCreateNewVotingTopic;

  /// Modal body text for the create-voting-topic option.
  ///
  /// In en, this message translates to:
  /// **'As the token owner, you can create topics for other holders to vote on.'**
  String get tokenCreateNewVotingTopicBody;

  /// Button to list banned addresses, showing the count.
  ///
  /// In en, this message translates to:
  /// **'List Bans ({count})'**
  String tokenListBansWithCount(String count);

  /// App bar title for the P2P auctions / dst landing screen.
  ///
  /// In en, this message translates to:
  /// **'P2P Auctions'**
  String get dstAuctionsTitle;

  /// Big-button title to connect to a remote auction house.
  ///
  /// In en, this message translates to:
  /// **'Connect to Auction House'**
  String get dstConnectToAuctionHouse;

  /// Big-button body text for connecting to an auction house.
  ///
  /// In en, this message translates to:
  /// **'Connect to a remote auction house to trade NFTs.'**
  String get dstConnectToAuctionHouseBody;

  /// Big-button title to manage the user's own auction house.
  ///
  /// In en, this message translates to:
  /// **'Manage my Auction House'**
  String get dstManageMyAuctionHouse;

  /// Big-button body for the manage-my-auction-house action. Apostrophe escaped per ICU.
  ///
  /// In en, this message translates to:
  /// **'Manage your account\'\'s auction house and trade NFTs.'**
  String get dstManageMyAuctionHouseBody;

  /// Big-button body for the manage-my-auction-house action on the web wallet. Apostrophe escaped per ICU.
  ///
  /// In en, this message translates to:
  /// **'Manage your wallet\'\'s auction house and trade NFTs.'**
  String get dstManageMyAuctionHouseBodyWeb;

  /// App bar title for the user's auction house screen.
  ///
  /// In en, this message translates to:
  /// **'My Auction House'**
  String get dstMyAuctionHouseTitle;

  /// Button to edit auction-house details.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get dstEditDetails;

  /// Button to delete an auction house.
  ///
  /// In en, this message translates to:
  /// **'Delete Shop'**
  String get dstDeleteShop;

  /// Confirm dialog title for deleting a collection.
  ///
  /// In en, this message translates to:
  /// **'Delete Collection'**
  String get dstDeleteCollection;

  /// Button to import an auction house by VFX address.
  ///
  /// In en, this message translates to:
  /// **'Import Shop'**
  String get dstImportShop;

  /// Field label for the VFX address when importing an auction house.
  ///
  /// In en, this message translates to:
  /// **'Your VFX Address'**
  String get dstImportShopAddressLabel;

  /// Button to discard unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get dstDiscardChanges;

  /// Confirm dialog title before publishing shop updates.
  ///
  /// In en, this message translates to:
  /// **'Publish Updates?'**
  String get dstPublishUpdatesTitle;

  /// Confirm dialog title shown when the CLI must be restarted.
  ///
  /// In en, this message translates to:
  /// **'CLI Restart Required'**
  String get dstCliRestartTitle;

  /// Section heading for the auction activity tab.
  ///
  /// In en, this message translates to:
  /// **'Auction Activity'**
  String get dstAuctionActivity;

  /// Status label for a completed auction.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dstCompleted;

  /// Confirm-close dialog title for the shop create/edit container.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the shop {mode} screen?'**
  String dstCloseShopEditConfirm(String mode);

  /// Confirm-close dialog title for the store create/edit container.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the store {mode} screen?'**
  String dstCloseStoreEditConfirm(String mode);

  /// Confirm-close dialog title for the collection create/edit container.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the collection {mode} screen?'**
  String dstCloseCollectionEditConfirm(String mode);

  /// Confirm-close dialog title for the listing create/edit container.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the listing {mode} screen?'**
  String dstCloseListingEditConfirm(String mode);

  /// Confirm dialog title for discarding listing changes.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard the listing?'**
  String get dstDiscardListingTitle;

  /// Inline word inserted into close-confirm titles when editing existing items.
  ///
  /// In en, this message translates to:
  /// **'editing'**
  String get dstModeEditing;

  /// Inline word inserted into close-confirm titles when creating new items.
  ///
  /// In en, this message translates to:
  /// **'creation'**
  String get dstModeCreation;

  /// App bar title for the auction houses list.
  ///
  /// In en, this message translates to:
  /// **'Auction Houses'**
  String get shopAuctionHousesTitle;

  /// App bar title for the user's auction houses list.
  ///
  /// In en, this message translates to:
  /// **'My Auction Houses'**
  String get shopMyAuctionHousesTitle;

  /// Prompt title for entering a shop URL.
  ///
  /// In en, this message translates to:
  /// **'Shop URL'**
  String get shopUrlPromptTitle;

  /// Validation message when no shop URL is entered.
  ///
  /// In en, this message translates to:
  /// **'Shop URL required'**
  String get shopUrlRequired;

  /// Field label for the shop URL input.
  ///
  /// In en, this message translates to:
  /// **'Input Shop Name Only'**
  String get shopUrlLabel;

  /// Confirm dialog title shown when the wallet is not synced.
  ///
  /// In en, this message translates to:
  /// **'Wallet Not Synced'**
  String get shopWalletNotSyncedTitle;

  /// Confirm dialog body for the wallet-not-synced warning.
  ///
  /// In en, this message translates to:
  /// **'Since your wallet is not synced there may be some issues viewing the data in this shop. Continue anyway?'**
  String get shopWalletNotSyncedBody;

  /// Button to connect to a remote shop.
  ///
  /// In en, this message translates to:
  /// **'Connect to a Shop'**
  String get shopConnectToShop;

  /// Button to share a shop URL.
  ///
  /// In en, this message translates to:
  /// **'Share Shop'**
  String get shopShareShop;

  /// Button to share a collection URL.
  ///
  /// In en, this message translates to:
  /// **'Share Collection'**
  String get shopShareCollection;

  /// Button to create a new listing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get shopCreateListing;

  /// Button to create a new collection.
  ///
  /// In en, this message translates to:
  /// **'Create Collection'**
  String get shopCreateCollection;

  /// Status label for a published shop.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get shopPublished;

  /// Button to publish a shop.
  ///
  /// In en, this message translates to:
  /// **'Publish Shop'**
  String get shopPublishShop;

  /// Confirm dialog title before publishing a shop.
  ///
  /// In en, this message translates to:
  /// **'Publish Shop?'**
  String get shopPublishShopTitle;

  /// Confirm dialog title before deleting a shop.
  ///
  /// In en, this message translates to:
  /// **'Delete shop?'**
  String get shopDeleteShopTitle;

  /// Confirm dialog body for deleting a collection.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this collection?'**
  String get shopDeleteCollectionConfirm;

  /// Generic Error placeholder used in shop screens.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get shopErrorTitle;

  /// Loading placeholder used in shop screens.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get shopLoading;

  /// Empty-state for the listings list.
  ///
  /// In en, this message translates to:
  /// **'No Active Listings'**
  String get shopNoActiveListings;

  /// Empty-state for the collections list.
  ///
  /// In en, this message translates to:
  /// **'No Active Collections'**
  String get shopNoActiveCollections;

  /// App bar title for the build-sale-start-tx screen.
  ///
  /// In en, this message translates to:
  /// **'Send Sale Start TX'**
  String get shopSendSaleStartTx;

  /// Button to sign in for the build-sale-start-tx screen.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get shopSignIn;

  /// Button to start a sale transaction.
  ///
  /// In en, this message translates to:
  /// **'Start Transaction'**
  String get shopStartTransaction;

  /// Hint inside the auction-house search field.
  ///
  /// In en, this message translates to:
  /// **'Search for auction house...'**
  String get shopSearchAuctionHouseHint;

  /// Status label for a sent bid.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get shopBidSent;

  /// Status label for a received bid.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get shopBidReceived;

  /// Status label for a purchased item.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get shopBidPurchased;

  /// Status label for an accepted bid.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get shopBidAccepted;

  /// Status label for a rejected bid.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get shopBidRejected;

  /// Button to resend a previously sent bid.
  ///
  /// In en, this message translates to:
  /// **'Resend Bid'**
  String get shopResendBid;

  /// Label for the listing price column.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get shopPriceLabel;

  /// Button to buy the listing immediately.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get shopBuyNow;

  /// Label for the floor-price column.
  ///
  /// In en, this message translates to:
  /// **'Floor Price'**
  String get shopFloorPriceLabel;

  /// Label for the highest-bid column.
  ///
  /// In en, this message translates to:
  /// **'Highest Bid'**
  String get shopHighestBidLabel;

  /// Button to place a bid.
  ///
  /// In en, this message translates to:
  /// **'Bid Now'**
  String get shopBidNow;

  /// Button label to open auction-detail dialog.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get shopDetailsLabel;

  /// Dialog title for auction details.
  ///
  /// In en, this message translates to:
  /// **'Auction Details'**
  String get shopAuctionDetailsTitle;

  /// Button to open the bid-history modal.
  ///
  /// In en, this message translates to:
  /// **'Bid History'**
  String get shopBidHistory;

  /// App bar title for the Butterfly payment link screen.
  ///
  /// In en, this message translates to:
  /// **'Payment Link'**
  String get paymentLinkTitle;

  /// Section heading for past payment links.
  ///
  /// In en, this message translates to:
  /// **'Payment Link History'**
  String get paymentLinkHistory;

  /// Empty-state for the payment links list.
  ///
  /// In en, this message translates to:
  /// **'No payment links yet'**
  String get paymentLinkNoneYet;

  /// Helper text introducing Butterfly payment links.
  ///
  /// In en, this message translates to:
  /// **'Use Butterfly to create a payment link, claimable by anyone you send the link to.'**
  String get paymentLinkIntro;

  /// Field label for the payment amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (VFX)'**
  String get paymentAmountLabel;

  /// Hint inside the payment amount field.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get paymentAmountHint;

  /// Field label for the optional message attached to a payment link.
  ///
  /// In en, this message translates to:
  /// **'Message (Optional)'**
  String get paymentMessageLabel;

  /// Hint inside the optional message field. Apostrophe escaped per ICU.
  ///
  /// In en, this message translates to:
  /// **'What\'\'s this payment for?'**
  String get paymentMessageHint;

  /// Button to create a payment link.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Link'**
  String get paymentCreateLinkLabel;

  /// Validation message when amount is empty.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get paymentAmountRequired;

  /// Validation message when amount is not a number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get paymentValidAmount;

  /// Validation message when amount exceeds the available balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get paymentInsufficientBalance;

  /// Validation message for the minimum payment amount.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is 0.0001 VFX'**
  String get paymentMinimumAmount;

  /// Helper showing the available VFX balance.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount} VFX'**
  String paymentAvailableLabel(String amount);

  /// Button to pay using Crypto.com onramp.
  ///
  /// In en, this message translates to:
  /// **'Pay with Crypto.com'**
  String get paymentPayWithCryptoCom;

  /// Button to pay using a credit card onramp.
  ///
  /// In en, this message translates to:
  /// **'Pay with Credit Card'**
  String get paymentPayWithCard;

  /// Cancel button label inside the on-ramp initializer.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get paymentCancel;

  /// Side-nav label for the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navMenuDashboard;

  /// Side-nav label for the Vault accounts screen.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts'**
  String get navMenuVaultAccounts;

  /// Side-nav label for the send screen.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get navMenuSend;

  /// Side-nav label for the receive screen.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get navMenuReceive;

  /// Side-nav label for the transactions screen.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navMenuTransactions;

  /// Side-nav label for the validator screen.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get navMenuValidator;

  /// Side-nav label for the domains screen.
  ///
  /// In en, this message translates to:
  /// **'VFX/BTC Domains'**
  String get navMenuDomains;

  /// Side-nav label for the tokenize-Bitcoin (vBTC) section.
  ///
  /// In en, this message translates to:
  /// **'Tokenize Bitcoin'**
  String get navMenuTokenizeBitcoin;

  /// Side-nav label for the smart contracts section.
  ///
  /// In en, this message translates to:
  /// **'Smart Contracts'**
  String get navMenuSmartContracts;

  /// Side-nav label for the fungible tokens section.
  ///
  /// In en, this message translates to:
  /// **'Fungible Tokens'**
  String get navMenuFungibleTokens;

  /// Side-nav label for the NFTs section.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get navMenuNfts;

  /// Side-nav label for the P2P auctions section.
  ///
  /// In en, this message translates to:
  /// **'P2P Auctions'**
  String get navMenuP2PAuctions;

  /// Toast shown when navigation is attempted without a selected account.
  ///
  /// In en, this message translates to:
  /// **'An account is required to access this section.'**
  String get navMenuAccountRequiredToast;

  /// Drawer item to logout of the web wallet.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get navMenuLogout;

  /// Button to add a new account in the wallet selector list.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get navAddAccount;

  /// Badge label shown when a wallet update is available.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get statusUpdateAvailable;

  /// Status row label for the blockchain version.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Version'**
  String get statusBlockchainVersion;

  /// Status row label for the CLI version.
  ///
  /// In en, this message translates to:
  /// **'CLI Version'**
  String get statusCliVersion;

  /// Status row label for the current block height.
  ///
  /// In en, this message translates to:
  /// **'Block Height'**
  String get statusBlockHeight;

  /// Status row label for peer count (incoming / outgoing).
  ///
  /// In en, this message translates to:
  /// **'Peers (In / Out)'**
  String get statusPeers;

  /// Status row label for the wallet startup time.
  ///
  /// In en, this message translates to:
  /// **'Wallet Started'**
  String get statusWalletStarted;

  /// Status row label for the network metrics dialog button.
  ///
  /// In en, this message translates to:
  /// **'Network Metrics'**
  String get statusNetworkMetrics;

  /// Status badge shown when the CLI is not running.
  ///
  /// In en, this message translates to:
  /// **'CLI Inactive'**
  String get statusCliInactive;

  /// Status badge shown while connection is initializing.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get statusLoadingLabel;

  /// Status badge shown when VFX is online.
  ///
  /// In en, this message translates to:
  /// **'VFX Online'**
  String get statusVfxOnline;

  /// Status badge shown when VFX is offline.
  ///
  /// In en, this message translates to:
  /// **'VFX Offline'**
  String get statusVfxOffline;

  /// Status badge shown while BTC node is connecting.
  ///
  /// In en, this message translates to:
  /// **'BTC Loading'**
  String get statusBtcLoading;

  /// Status badge shown when BTC node is online.
  ///
  /// In en, this message translates to:
  /// **'BTC Online'**
  String get statusBtcOnline;

  /// Status badge shown when BTC node is offline.
  ///
  /// In en, this message translates to:
  /// **'BTC Offline'**
  String get statusBtcOffline;

  /// Empty-state shown on web when no wallet is loaded.
  ///
  /// In en, this message translates to:
  /// **'No Wallet detected.'**
  String get webNoWalletDetected;

  /// Button to start the web wallet setup flow.
  ///
  /// In en, this message translates to:
  /// **'Setup Wallet'**
  String get webSetupWallet;

  /// Badge for a Vault account whose activation is in progress on the web.
  ///
  /// In en, this message translates to:
  /// **'Pending Activation'**
  String get webPendingActivation;

  /// Button to activate the Vault account on the web.
  ///
  /// In en, this message translates to:
  /// **'Activate Now'**
  String get webActivateNow;

  /// Button to restore a Vault account on the web.
  ///
  /// In en, this message translates to:
  /// **'Restore Vault Account'**
  String get webRestoreVaultAccount;

  /// Field label for the Vault restore code input on the web.
  ///
  /// In en, this message translates to:
  /// **'Restore Code'**
  String get webRestoreCodeLabel;

  /// Toast confirming a Vault account was restored on the web.
  ///
  /// In en, this message translates to:
  /// **'Vault Account restored'**
  String get webVaultRestoredToast;

  /// Button to recover a Vault account on the web.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get webRecover;

  /// Confirm dialog title for the web Vault recovery flow.
  ///
  /// In en, this message translates to:
  /// **'Recover Funds & NFTs'**
  String get webRecoverFundsTitle;

  /// Toast confirming a recovery transaction was broadcast on the web.
  ///
  /// In en, this message translates to:
  /// **'Recovery transaction broadcasted.'**
  String get webRecoveryBroadcasted;

  /// Button to call back a transaction on the web.
  ///
  /// In en, this message translates to:
  /// **'Callback'**
  String get webCallback;

  /// Prompt title for the web callback flow.
  ///
  /// In en, this message translates to:
  /// **'Callback Transaction'**
  String get webCallbackTitle;

  /// Toast confirming a callback transaction was broadcast on the web.
  ///
  /// In en, this message translates to:
  /// **'Callback TX broadcasted'**
  String get webCallbackBroadcasted;

  /// Confirm dialog title before revealing a private key on the web wallet details.
  ///
  /// In en, this message translates to:
  /// **'Reveal Private Key?'**
  String get webRevealPrivateKeyTitle;

  /// Toast confirming a wallet address was copied on the web wallet details.
  ///
  /// In en, this message translates to:
  /// **'Address {address} copied to clipboard'**
  String webAddressCopiedToast(String address);

  /// Currency selector label for All.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get webCurrencyAll;

  /// Currency selector label for VFX.
  ///
  /// In en, this message translates to:
  /// **'VFX'**
  String get webCurrencyVfx;

  /// Currency selector label for Vault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get webCurrencyVault;

  /// Currency selector label for BTC.
  ///
  /// In en, this message translates to:
  /// **'BTC'**
  String get webCurrencyBtc;

  /// Button to fund a Vault account on the web.
  ///
  /// In en, this message translates to:
  /// **'Fund Account'**
  String get webFundAccount;

  /// Dialog title for funding the Vault account on the web.
  ///
  /// In en, this message translates to:
  /// **'Fund Your Vault Account'**
  String get webFundVaultTitle;

  /// Dialog title asking whether to auto-activate after funding.
  ///
  /// In en, this message translates to:
  /// **'Automatically Activate?'**
  String get webAutoActivateTitle;

  /// Prompt title for importing a wallet via private key on the web keygen flow.
  ///
  /// In en, this message translates to:
  /// **'Import Wallet'**
  String get keygenImportWalletTitle;

  /// Field label for the private key input.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get keygenPrivateKeyLabel;

  /// Prompt title for the email-address step of the keygen flow.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get keygenEmailAddressTitle;

  /// Field label for the email input.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get keygenEmailLabel;

  /// Prompt title for entering a recovery mnemonic.
  ///
  /// In en, this message translates to:
  /// **'Input Recovery Mnemonic'**
  String get keygenRecoveryMnemonicTitle;

  /// Field label for the recovery mnemonic input.
  ///
  /// In en, this message translates to:
  /// **'Recovery Mnemonic'**
  String get keygenRecoveryMnemonicLabel;

  /// Dialog title shown after a key is generated.
  ///
  /// In en, this message translates to:
  /// **'Key Generated'**
  String get keygenKeyGeneratedTitle;

  /// Dialog body shown after a key is generated.
  ///
  /// In en, this message translates to:
  /// **'Here is your account details. Please ensure to back up your private key in a safe place.'**
  String get keygenKeyGeneratedBody;

  /// Field label for the generated address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get keygenAddressLabel;

  /// Toast confirming the mnemonic was copied.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic copied to clipboard'**
  String get keygenMnemonicCopiedToast;

  /// Toast confirming the public key was copied.
  ///
  /// In en, this message translates to:
  /// **'Public key copied to clipboard'**
  String get keygenPublicKeyCopiedToast;

  /// Toast confirming the private key was copied.
  ///
  /// In en, this message translates to:
  /// **'Private key copied to clipboard'**
  String get keygenPrivateKeyCopiedToast;

  /// Done button label on the keygen result dialog.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get keygenDone;

  /// Button to import a private key from the keygen CTA.
  ///
  /// In en, this message translates to:
  /// **'Import Private Key'**
  String get keygenImportPrivateKey;

  /// Button to generate a new keypair from the keygen CTA.
  ///
  /// In en, this message translates to:
  /// **'Generate Keypair'**
  String get keygenGenerateKeypair;

  /// Button to recover an account via mnemonic from the keygen CTA.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get keygenRecoverAccount;

  /// App bar title for the validator voting topics list.
  ///
  /// In en, this message translates to:
  /// **'Validator Voting Topics'**
  String get votingTitle;

  /// Button to create a new validator voting topic.
  ///
  /// In en, this message translates to:
  /// **'Create Topic'**
  String get votingCreateTopic;

  /// Tab label for active topics.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get votingTabActive;

  /// Tab label for inactive topics.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get votingTabInactive;

  /// Tab label for topics the user has voted on.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get votingTabVoted;

  /// Tab label for topics the user has not voted on.
  ///
  /// In en, this message translates to:
  /// **'Not Voted'**
  String get votingTabNotVoted;

  /// Tab label showing all topics.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get votingTabAll;

  /// Tab label for topics the user has created.
  ///
  /// In en, this message translates to:
  /// **'My Topics'**
  String get votingTabMyTopics;

  /// App bar title for the create-topic screen.
  ///
  /// In en, this message translates to:
  /// **'Create Topic'**
  String get votingCreateTopicTitle;

  /// Generic Error placeholder for the voting topic detail.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get votingError;

  /// App bar title for the chats list.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatTitle;

  /// App bar title for a single chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitleSingle;

  /// App bar title showing the chat counterparty.
  ///
  /// In en, this message translates to:
  /// **'Chatting with {name}'**
  String chatChattingWith(String name);

  /// Web seller chat title showing the buyer address.
  ///
  /// In en, this message translates to:
  /// **'Chat with {address}'**
  String chatWithAddress(String address);

  /// Empty-state for the chats list.
  ///
  /// In en, this message translates to:
  /// **'No Chats'**
  String get chatNoChats;

  /// Hint inside the message-compose field.
  ///
  /// In en, this message translates to:
  /// **'Send message...'**
  String get chatSendHint;

  /// Confirm dialog title for deleting a chat thread.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat Thread'**
  String get chatDeleteThread;

  /// Generic Error placeholder used in chat screens.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get chatErrorTitle;

  /// App bar title for the beacons list.
  ///
  /// In en, this message translates to:
  /// **'Beacons'**
  String get beaconTitle;

  /// Button to add a remote beacon.
  ///
  /// In en, this message translates to:
  /// **'Add Remote Beacon'**
  String get beaconAddRemote;

  /// Button to create or host a local beacon.
  ///
  /// In en, this message translates to:
  /// **'Create / Host Beacon'**
  String get beaconCreateHost;

  /// Heading for the add-beacon modal.
  ///
  /// In en, this message translates to:
  /// **'Add Beacon'**
  String get beaconAddTitle;

  /// Heading for the create-beacon modal.
  ///
  /// In en, this message translates to:
  /// **'Create Beacon'**
  String get beaconCreateTitle;

  /// Confirm dialog title shown after a beacon is created.
  ///
  /// In en, this message translates to:
  /// **'Beacon Created'**
  String get beaconCreatedTitle;

  /// Field label for the beacon name input.
  ///
  /// In en, this message translates to:
  /// **'Beacon Name'**
  String get beaconNameLabel;

  /// Field label for the beacon IP address input.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get beaconIpLabel;

  /// Field label for the beacon port input.
  ///
  /// In en, this message translates to:
  /// **'Port (leave blank for default)'**
  String get beaconPortLabel;

  /// Field label for retention days in the create-beacon modal.
  ///
  /// In en, this message translates to:
  /// **'Days to retain files (0 for unlimited)'**
  String get beaconRetainDaysLabel;

  /// Switch label to make the beacon private.
  ///
  /// In en, this message translates to:
  /// **'Make Private'**
  String get beaconMakePrivate;

  /// Switch label to auto-delete files after download.
  ///
  /// In en, this message translates to:
  /// **'Auto Delete After Download'**
  String get beaconAutoDelete;

  /// Cancel button label in the beacon modals.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get beaconCancel;

  /// Confirm button to add a remote beacon.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get beaconAdd;

  /// Confirm button to create a beacon.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get beaconCreate;

  /// Context-menu item to remove a beacon.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get beaconRemove;

  /// Confirm dialog title for removing a beacon.
  ///
  /// In en, this message translates to:
  /// **'Remove Beacon'**
  String get beaconRemoveTitle;

  /// Empty-state for the beacons list.
  ///
  /// In en, this message translates to:
  /// **'No Beacons'**
  String get beaconNoBeacons;

  /// Badge label shown on a remote beacon list tile.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get beaconRemoteBadge;

  /// App bar title for the VFX faucet screen.
  ///
  /// In en, this message translates to:
  /// **'VFX Faucet'**
  String get faucetTitle;

  /// Empty-state shown when no VFX account is selected on the faucet screen.
  ///
  /// In en, this message translates to:
  /// **'Please choose a VFX account to continue'**
  String get faucetChooseAccount;

  /// Field label for the SMS verification code input.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get faucetVerificationCodeLabel;

  /// Button to verify the faucet SMS code.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get faucetVerify;

  /// Field label for the faucet amount input.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get faucetAmountLabel;

  /// Inline label showing the forced faucet amount when fixed.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} VFX'**
  String faucetAmountSuffix(String amount);

  /// Field label for the faucet phone number input.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get faucetPhoneLabel;

  /// Cancel button label inside the faucet form.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get faucetCancel;

  /// Button to submit a faucet request.
  ///
  /// In en, this message translates to:
  /// **'Request VFX'**
  String get faucetRequestVfx;

  /// Toast confirming the account was unlocked.
  ///
  /// In en, this message translates to:
  /// **'Account unlocked!'**
  String get encryptUnlockedToast;

  /// Toast shown when the entered password is incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect account decryption password'**
  String get encryptIncorrectPasswordToast;

  /// Hint inside the unlock-wallet password field.
  ///
  /// In en, this message translates to:
  /// **'Account Password'**
  String get encryptPasswordHint;

  /// App bar title for the MOTHER dashboard.
  ///
  /// In en, this message translates to:
  /// **'MOTHER Dashboard'**
  String get motherDashboardTitle;

  /// Dialog title for adding a MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Add Host'**
  String get motherAddHostTitle;

  /// Dialog body for adding a MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Set the IP address and password set of your MOTHER HOST.'**
  String get motherAddHostBody;

  /// Field label for the MOTHER host IP address.
  ///
  /// In en, this message translates to:
  /// **'IP Address of HOST'**
  String get motherIpHostLabel;

  /// Field label for the password set on the MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Password set on HOST'**
  String get motherPasswordHostLabel;

  /// Field label for the MOTHER host name.
  ///
  /// In en, this message translates to:
  /// **'Host Name'**
  String get motherHostNameLabel;

  /// Field label for creating a password when launching a MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get motherCreatePasswordLabel;

  /// Confirm dialog title shown when MOTHER setup requires a CLI restart.
  ///
  /// In en, this message translates to:
  /// **'CLI Restart Required'**
  String get motherCliRestartTitle;

  /// Detail row label for child balance on the MOTHER dashboard.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get motherChildBalance;

  /// Detail row label for child IP address.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get motherChildIpAddress;

  /// Detail row label for child block height.
  ///
  /// In en, this message translates to:
  /// **'Block Height'**
  String get motherChildBlockHeight;

  /// Detail row label asking whether the child is validating.
  ///
  /// In en, this message translates to:
  /// **'Is Validating?'**
  String get motherChildIsValidating;

  /// Detail row label for connection status to MOTHER.
  ///
  /// In en, this message translates to:
  /// **'Is Connected to Mother?'**
  String get motherChildIsConnected;

  /// Button to open the child wallet in an explorer.
  ///
  /// In en, this message translates to:
  /// **'Open in Explorer'**
  String get motherOpenInExplorer;

  /// Close button label in MOTHER modal.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get motherClose;

  /// List-tile title to launch the MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Launch MOTHER'**
  String get motherLaunchHost;

  /// List-tile title to stop the MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Stop Host'**
  String get motherStopHost;

  /// Confirm dialog title for stopping the MOTHER host.
  ///
  /// In en, this message translates to:
  /// **'Stop MOTHER Host?'**
  String get motherStopHostConfirmTitle;

  /// List-tile title to set the wallet as remote.
  ///
  /// In en, this message translates to:
  /// **'Set Wallet as Remote'**
  String get motherSetWalletRemote;

  /// List-tile title to stop using the wallet as remote.
  ///
  /// In en, this message translates to:
  /// **'Stop Remote'**
  String get motherStopRemote;

  /// AppBar title for the adjudicator screen.
  ///
  /// In en, this message translates to:
  /// **'Adjudicator'**
  String get adjudicatorTitle;

  /// Empty state shown on the adjudicator screen when no account is selected.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get adjudicatorNoAccountSelected;

  /// Button label to start adjudicating.
  ///
  /// In en, this message translates to:
  /// **'Start Adjudicating'**
  String get adjudicatorStart;

  /// Button label to stop adjudicating.
  ///
  /// In en, this message translates to:
  /// **'Stop Adjudicating'**
  String get adjudicatorStop;

  /// Status text shown while a wallet is adjudicating.
  ///
  /// In en, this message translates to:
  /// **'{label}  is Adjudicating...'**
  String adjudicatorIsAdjudicating(String label);

  /// Toast shown when the adjudicator port is reachable.
  ///
  /// In en, this message translates to:
  /// **'Port {port} is open!'**
  String adjudicatorPortOpen(String port);

  /// Toast shown when the adjudicator port is not reachable.
  ///
  /// In en, this message translates to:
  /// **'Port {port} is NOT open. Please configure your firewall.'**
  String adjudicatorPortClosed(String port);

  /// AppBar title for the data node screen.
  ///
  /// In en, this message translates to:
  /// **'Datanode'**
  String get datanodeTitle;

  /// Body text shown on the data node placeholder screen.
  ///
  /// In en, this message translates to:
  /// **'Activating soon.'**
  String get datanodeActivatingSoon;

  /// AppBar title for the operations screen.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operationsTitle;

  /// Heading for the activity log column on the operations screen.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get operationsActivityLog;

  /// Heading for the status column on the operations screen.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get operationsStatus;

  /// Link label to the docs site.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get operationsDocs;

  /// Status item label: blockchain version.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Version'**
  String get operationsBlockchainVersion;

  /// Status item label: CLI version.
  ///
  /// In en, this message translates to:
  /// **'CLI Version'**
  String get operationsCliVersion;

  /// Status item label: block height.
  ///
  /// In en, this message translates to:
  /// **'Block Height'**
  String get operationsBlockHeight;

  /// Status item label: peer counts.
  ///
  /// In en, this message translates to:
  /// **'Peers (In / Out)'**
  String get operationsPeers;

  /// Status item label: wallet start time.
  ///
  /// In en, this message translates to:
  /// **'Wallet Started'**
  String get operationsWalletStarted;

  /// Status item label and dialog title for network metrics.
  ///
  /// In en, this message translates to:
  /// **'Network Metrics'**
  String get operationsNetworkMetrics;

  /// Inline action to open the network metrics dialog.
  ///
  /// In en, this message translates to:
  /// **'View Metrics'**
  String get operationsViewMetrics;

  /// Network metrics row showing active validator count.
  ///
  /// In en, this message translates to:
  /// **'Active Validators: {value}'**
  String operationsActiveValidators(String value);

  /// Error shown when a non-validator tries to create a topic.
  ///
  /// In en, this message translates to:
  /// **'Your active account must be a validator to create a topic.'**
  String get votingMustBeValidatorToCreate;

  /// Error shown when an address already has an active topic.
  ///
  /// In en, this message translates to:
  /// **'Only one active topic per address is allowed.'**
  String get votingOnlyOneActive;

  /// Error shown when balance is missing for topic creation.
  ///
  /// In en, this message translates to:
  /// **'A balance is required'**
  String get votingBalanceRequired;

  /// Error shown when balance won't cover the topic-creation cost.
  ///
  /// In en, this message translates to:
  /// **'Balance will not be sufficient to validate due to the cost of creating a topic (1 VFX + fee)'**
  String get votingInsufficientForValidate;

  /// Field label for voting topic category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get votingCategoryLabel;

  /// Field label for voting end-date selector.
  ///
  /// In en, this message translates to:
  /// **'Voting Ends'**
  String get votingEndsLabel;

  /// Input label for the topic name.
  ///
  /// In en, this message translates to:
  /// **'Topic Name'**
  String get votingTopicNameLabel;

  /// Input label for the topic description.
  ///
  /// In en, this message translates to:
  /// **'Topic Description'**
  String get votingTopicDescriptionLabel;

  /// Helper text indicating a 128-character maximum.
  ///
  /// In en, this message translates to:
  /// **'128 character limit'**
  String get votingCharLimit128;

  /// Helper text for the topic description length limit.
  ///
  /// In en, this message translates to:
  /// **'1,600 character limit including provided links'**
  String get votingCharLimit1600;

  /// Title of the discard-topic confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get votingDiscardTitle;

  /// Body for the discard topic confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this new topic?'**
  String get votingDiscardBody;

  /// Body of the create-topic confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to create a topic.'**
  String votingCreateTopicConfirmBody(String cost);

  /// Confirm button label to create a topic.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get votingCreateAction;

  /// Toast shown after successfully creating a topic.
  ///
  /// In en, this message translates to:
  /// **'Topic created'**
  String get votingTopicCreatedToast;

  /// Hint text for the topic search input.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get votingSearchHint;

  /// Message shown when a vote has ended.
  ///
  /// In en, this message translates to:
  /// **'Voting Ended on {date}.'**
  String votingEndedOn(String date);

  /// Error shown when no account is selected for voting.
  ///
  /// In en, this message translates to:
  /// **'Must have an account selected to vote.'**
  String get votingMustHaveAccountToVote;

  /// Error shown when a non-validator tries to vote.
  ///
  /// In en, this message translates to:
  /// **'You must be a validator to vote.'**
  String get votingMustBeValidatorToVote;

  /// Message shown when the user already voted and the tx is pending.
  ///
  /// In en, this message translates to:
  /// **'You voted {label}. Transaction is pending.'**
  String votingAlreadyVotedPending(String label);

  /// Message shown when the user already voted on a topic.
  ///
  /// In en, this message translates to:
  /// **'You voted {label} on block {block}'**
  String votingAlreadyVoted(String label, String block);

  /// Message shown when a vote transaction is pending.
  ///
  /// In en, this message translates to:
  /// **'Vote transaction pending.'**
  String get votingPendingTx;

  /// Heading prompting the user to cast their vote.
  ///
  /// In en, this message translates to:
  /// **'Cast Your Vote'**
  String get votingCastYourVote;

  /// Button to vote Yes.
  ///
  /// In en, this message translates to:
  /// **'Vote Yes'**
  String get votingVoteYes;

  /// Button to vote No.
  ///
  /// In en, this message translates to:
  /// **'Vote No'**
  String get votingVoteNo;

  /// Title of the confirm-Yes-vote dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote [YES]'**
  String get votingConfirmYesTitle;

  /// Body of the confirm-Yes-vote dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to vote YES on this topic?'**
  String get votingConfirmYesBody;

  /// Confirm button label to cast a Yes vote.
  ///
  /// In en, this message translates to:
  /// **'Vote YES'**
  String get votingConfirmYesAction;

  /// Title of the confirm-No-vote dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote [NO]'**
  String get votingConfirmNoTitle;

  /// Body of the confirm-No-vote dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to vote NO on this topic?'**
  String get votingConfirmNoBody;

  /// Confirm button label to cast a No vote.
  ///
  /// In en, this message translates to:
  /// **'Vote NO'**
  String get votingConfirmNoAction;

  /// Footnote indicating when voting ends.
  ///
  /// In en, this message translates to:
  /// **'Voting ends {date}.'**
  String votingEndsAt(String date);

  /// Empty state on a topic with no votes.
  ///
  /// In en, this message translates to:
  /// **'No votes yet.'**
  String get votingNoVotesYet;

  /// Heading for the vote counts table.
  ///
  /// In en, this message translates to:
  /// **'Vote Counts'**
  String get votingVoteCounts;

  /// Label for Yes vote count.
  ///
  /// In en, this message translates to:
  /// **'Votes Yes'**
  String get votingVotesYes;

  /// Label for No vote count.
  ///
  /// In en, this message translates to:
  /// **'Votes No'**
  String get votingVotesNo;

  /// Label for total vote count.
  ///
  /// In en, this message translates to:
  /// **'Total Votes'**
  String get votingTotalVotes;

  /// Heading for vote percentages table.
  ///
  /// In en, this message translates to:
  /// **'Percentages'**
  String get votingPercentages;

  /// Label for the result row in the percentages table.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get votingResult;

  /// Result label when a vote is still active.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get votingInProgress;

  /// Result label when a vote passed.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get votingPass;

  /// Result label when a vote failed.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get votingFail;

  /// Button to show vote history.
  ///
  /// In en, this message translates to:
  /// **'Show History'**
  String get votingShowHistory;

  /// Card label for the date the topic was created.
  ///
  /// In en, this message translates to:
  /// **'Topic Created'**
  String get votingTopicCreatedLabel;

  /// Selectable detail showing block height.
  ///
  /// In en, this message translates to:
  /// **'Block Height: {value}'**
  String votingBlockHeightDetail(String value);

  /// Detail label showing the topic owner's address.
  ///
  /// In en, this message translates to:
  /// **'Topic Owner: {address}'**
  String votingTopicOwner(String address);

  /// Selectable detail showing the topic UID.
  ///
  /// In en, this message translates to:
  /// **'UID: {uid}'**
  String votingUid(String uid);

  /// Voting topic category: General.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get votingCatGeneral;

  /// Voting topic category: Code Change.
  ///
  /// In en, this message translates to:
  /// **'Code Change'**
  String get votingCatCodeChange;

  /// Voting topic category: Add Developer.
  ///
  /// In en, this message translates to:
  /// **'Add Developer'**
  String get votingCatAddDeveloper;

  /// Voting topic category: Remove Developer.
  ///
  /// In en, this message translates to:
  /// **'Remove Developer'**
  String get votingCatRemoveDeveloper;

  /// Voting topic category: Network Change.
  ///
  /// In en, this message translates to:
  /// **'Network Change'**
  String get votingCatNetworkChange;

  /// Voting topic category: Adjudicator Vote In.
  ///
  /// In en, this message translates to:
  /// **'Adj Vote In'**
  String get votingCatAdjVoteIn;

  /// Voting topic category: Adjudicator Vote Out.
  ///
  /// In en, this message translates to:
  /// **'Adj Vote Out'**
  String get votingCatAdjVoteOut;

  /// Voting topic category: Validator Change.
  ///
  /// In en, this message translates to:
  /// **'Validator Change'**
  String get votingCatValidatorChange;

  /// Voting topic category: Block Modify.
  ///
  /// In en, this message translates to:
  /// **'Block Modify'**
  String get votingCatBlockModify;

  /// Voting topic category: Transaction Modify.
  ///
  /// In en, this message translates to:
  /// **'Transaction Modify'**
  String get votingCatTransactionModify;

  /// Voting topic category: Balance Correction.
  ///
  /// In en, this message translates to:
  /// **'Balance Correction'**
  String get votingCatBalanceCorrection;

  /// Voting topic category: Hack or Exploit Correction.
  ///
  /// In en, this message translates to:
  /// **'Hack or Exploit Correction'**
  String get votingCatHackOrExploit;

  /// Voting topic category: Other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get votingCatOther;

  /// Voting duration option: 30 days.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get votingDays30;

  /// Voting duration option: 60 days.
  ///
  /// In en, this message translates to:
  /// **'60 Days'**
  String get votingDays60;

  /// Voting duration option: 90 days.
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get votingDays90;

  /// Voting duration option: 180 days.
  ///
  /// In en, this message translates to:
  /// **'180 Days'**
  String get votingDays180;

  /// Adjudicator provider option: cloud VPS.
  ///
  /// In en, this message translates to:
  /// **'Online Cloud VPS'**
  String get votingProviderOnlineCloud;

  /// Adjudicator provider option: dedicated server.
  ///
  /// In en, this message translates to:
  /// **'Online Dedicated'**
  String get votingProviderOnlineDedicated;

  /// Adjudicator provider option: local dedicated machine.
  ///
  /// In en, this message translates to:
  /// **'Local Dedicated'**
  String get votingProviderLocalDedicated;

  /// Adjudicator provider option: home machine.
  ///
  /// In en, this message translates to:
  /// **'Home Machine'**
  String get votingProviderHomeMachine;

  /// Adjudicator provider option: office machine.
  ///
  /// In en, this message translates to:
  /// **'Office Machine'**
  String get votingProviderOfficeMachine;

  /// Operating system option: Linux.
  ///
  /// In en, this message translates to:
  /// **'Linux'**
  String get votingOsLinux;

  /// Operating system option: Windows.
  ///
  /// In en, this message translates to:
  /// **'Windows'**
  String get votingOsWindows;

  /// Operating system option: Mac.
  ///
  /// In en, this message translates to:
  /// **'Mac'**
  String get votingOsMac;

  /// Confirmation body for removing a remote beacon.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this beacon?'**
  String get beaconRemoveBody;

  /// Confirmation body for removing a self-hosted beacon.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this beacon?\n\nA CLI restart is required.'**
  String get beaconRemoveSelfBody;

  /// Confirm button label to remove a beacon and restart the CLI.
  ///
  /// In en, this message translates to:
  /// **'Remove & Restart CLI'**
  String get beaconRemoveAndRestart;

  /// Explanation text for the create-beacon modal.
  ///
  /// In en, this message translates to:
  /// **'Create a beacon if you want to be the owner of the relay of assets. Setup your wallet as a beacon to participate in media transferring on the VFX network. The name is a friendly name only visible to you. You can configure a specific port or just use the default setting. You can also configure whether your beacon is private and how long assets should remain cached.'**
  String get beaconCreateBodyExplanation;

  /// Explanation text for the add-beacon modal.
  ///
  /// In en, this message translates to:
  /// **'Add an existing beacon to foreign nodes to use that relay instead of default ones on the VFX network. Configure your wallet to use a remote beacon for media transferring rather than using the default VFX network beacons. You will need to know the IP address of the remote beacon. If that beacon is using the non-default port, provide that as well. The beacon name is a friendly name visible only to you.'**
  String get beaconAddBodyExplanation;

  /// Body text after a beacon is created, prompting CLI restart.
  ///
  /// In en, this message translates to:
  /// **'A CLI restart is required for this to take effect.\n\nRestart Now?'**
  String get beaconCreatedBody;

  /// Status badge: beacon active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get beaconActiveBadge;

  /// Status badge: beacon inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get beaconInactiveBadge;

  /// Error when trying to create more than one beacon per wallet.
  ///
  /// In en, this message translates to:
  /// **'Only one beacon per wallet allowed.'**
  String get beaconErrorOnePerWallet;

  /// Confirm button label to restart the CLI now.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get beaconRestartNow;

  /// Cancel button label to defer the action.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get beaconLater;

  /// Subtitle label describing whether assets are auto-deleted.
  ///
  /// In en, this message translates to:
  /// **'Auto Delete Assets'**
  String get beaconAutoDeleteAssets;

  /// Subtitle label describing the asset cache duration.
  ///
  /// In en, this message translates to:
  /// **'Asset Cache'**
  String get beaconAssetCache;

  /// Cache duration label meaning no expiration.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get beaconCacheInfinite;

  /// Suffix shown next to a beacon name when private.
  ///
  /// In en, this message translates to:
  /// **'[Private]'**
  String get beaconPrivateLabel;

  /// Side nav label for Butterfly payments.
  ///
  /// In en, this message translates to:
  /// **'Pay /w Butterfly'**
  String get navMenuPayWithButterfly;

  /// Side nav label for Crypto.com onramp.
  ///
  /// In en, this message translates to:
  /// **'Crypto.com'**
  String get navMenuCryptoCom;

  /// Side nav label for Operations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get navMenuOperations;

  /// Side nav label for sign out (web).
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get navMenuSignOut;

  /// Side nav label for vault account (web, single).
  ///
  /// In en, this message translates to:
  /// **'Vault Account'**
  String get navMenuVaultAccountSingular;

  /// Confirmation dialog title for signing out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get navSignOutTitle;

  /// Body for the sign-out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout of the VFX Web Wallet?'**
  String get navSignOutBody;

  /// Label above the latest transaction widget.
  ///
  /// In en, this message translates to:
  /// **'Latest TX:'**
  String get navLatestTx;

  /// Inline action to view all transactions.
  ///
  /// In en, this message translates to:
  /// **'View All Txs'**
  String get navViewAllTxs;

  /// Empty state when there are no transactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get navNoTransactions;

  /// Status label for confirmed transactions.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get navConfirmedStatus;

  /// Status label for pending transactions.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get navPendingStatus;

  /// Vertical icon button label: view current address.
  ///
  /// In en, this message translates to:
  /// **'View\nAddress'**
  String get navViewAddress;

  /// Vertical icon button label: view all addresses.
  ///
  /// In en, this message translates to:
  /// **'View\nAddresses'**
  String get navViewAddresses;

  /// Vertical icon button label: create new address.
  ///
  /// In en, this message translates to:
  /// **'New\nAddress'**
  String get navNewAddress;

  /// Vertical icon button label: acquire VFX.
  ///
  /// In en, this message translates to:
  /// **'Get\nVFX'**
  String get navGetVfx;

  /// Vertical icon button label: acquire BTC.
  ///
  /// In en, this message translates to:
  /// **'Get\nBTC'**
  String get navGetBtc;

  /// Address count (singular).
  ///
  /// In en, this message translates to:
  /// **'{count} Address'**
  String navAddressSingular(String count);

  /// Address count (plural).
  ///
  /// In en, this message translates to:
  /// **'{count} Addresses'**
  String navAddressPlural(String count);

  /// Vault address count (singular).
  ///
  /// In en, this message translates to:
  /// **'{count} Vault Address'**
  String navVaultAddressSingular(String count);

  /// Vault address count (plural).
  ///
  /// In en, this message translates to:
  /// **'{count} Vault Addresses'**
  String navVaultAddressPlural(String count);

  /// Account count (singular).
  ///
  /// In en, this message translates to:
  /// **'{count} Account'**
  String navAccountSingular(String count);

  /// Account count (plural).
  ///
  /// In en, this message translates to:
  /// **'{count} Accounts'**
  String navAccountPlural(String count);

  /// Empty state when no VFX accounts exist.
  ///
  /// In en, this message translates to:
  /// **'No VFX Accounts'**
  String get navNoVfxAccounts;

  /// Empty state when no BTC accounts exist.
  ///
  /// In en, this message translates to:
  /// **'No BTC Accounts'**
  String get navNoBtcAccounts;

  /// Empty state when no accounts exist.
  ///
  /// In en, this message translates to:
  /// **'No Accounts'**
  String get navNoAccounts;

  /// Badge shown next to brand-new menu items.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get navNew;

  /// Confirmation body before revealing a private key.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reveal your private key?'**
  String get webRevealPrivateKeyBody;

  /// Confirmation body before revealing the key for a specific account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reveal your private key for this account?'**
  String get webRevealPrivateKeyAccountBody;

  /// Confirm button to reveal a key.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get webReveal;

  /// Body asking the user to confirm sending 5 VFX from an address.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send 5 VFX from {address}?'**
  String webFundVaultBody(String address);

  /// Body asking whether to auto-activate after funding.
  ///
  /// In en, this message translates to:
  /// **'Would you like to activate the account automatically once the funding is complete?'**
  String get webAutoActivateBody;

  /// Toast confirming 5 VFX were sent.
  ///
  /// In en, this message translates to:
  /// **'5 VFX sent to {address}'**
  String webSent5Vfx(String address);

  /// Body explaining the recovery process.
  ///
  /// In en, this message translates to:
  /// **'This is a destructive function that will callback all pending transactions and assets and move everything to this recovery address:\n\n{address}'**
  String webRecoverFundsBody(String address);

  /// Confirm button: proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get webProceed;

  /// Body for the restore Vault account dialog.
  ///
  /// In en, this message translates to:
  /// **'Importing an existing Vault Account will replace the current one tied to your login. To revert you can logout and login again.\n\nContinue?'**
  String get webRestoreVaultBody;

  /// Body for the restore code prompt.
  ///
  /// In en, this message translates to:
  /// **'Paste in your RESTORE CODE to import your existing Vault Account.'**
  String get webRestoreCodeBody;

  /// Status label for a transaction that has been called back.
  ///
  /// In en, this message translates to:
  /// **'Called Back'**
  String get webCalledBack;

  /// Body for the callback confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to callback this transaction?'**
  String get webCallbackBody;

  /// Error: timestamp retrieval failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve timestamp'**
  String get webErrorTimestamp;

  /// Error: nonce retrieval failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve nonce'**
  String get webErrorNonce;

  /// Error: fee parsing failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse fee'**
  String get webErrorFee;

  /// Error: hash parsing failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse hash'**
  String get webErrorHash;

  /// Error: signature generation failed.
  ///
  /// In en, this message translates to:
  /// **'Signature generation failed.'**
  String get webErrorSignatureGen;

  /// Error: signature invalid.
  ///
  /// In en, this message translates to:
  /// **'Signature not valid'**
  String get webErrorSignatureInvalid;

  /// Error: transaction invalid.
  ///
  /// In en, this message translates to:
  /// **'Transaction not valid'**
  String get webErrorTxInvalid;

  /// Error: recovery sig script generation failed.
  ///
  /// In en, this message translates to:
  /// **'Problem generating RecoverySigScript'**
  String get webErrorRecoverySig;

  /// Placeholder when no account is selected.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get webSelectAccount;

  /// Menu item: add a BTC account.
  ///
  /// In en, this message translates to:
  /// **'Add BTC Account'**
  String get webAddBtcAccount;

  /// Title for import-BTC-WIF dialog.
  ///
  /// In en, this message translates to:
  /// **'Import BTC WIF Private Key'**
  String get webImportBtcWifTitle;

  /// Input label for a BTC WIF private key.
  ///
  /// In en, this message translates to:
  /// **'WIF Private Key'**
  String get webWifPrivateKey;

  /// Confirm button: import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get webImport;

  /// Toast: BTC account imported.
  ///
  /// In en, this message translates to:
  /// **'BTC Account Imported'**
  String get webBtcAccountImported;

  /// Title and button: manage accounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get webManageAccounts;

  /// Default name for a single account.
  ///
  /// In en, this message translates to:
  /// **'Default Account'**
  String get webDefaultAccount;

  /// Default account name template.
  ///
  /// In en, this message translates to:
  /// **'Account {id}'**
  String webAccountN(String id);

  /// Title for rename-account dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename Account'**
  String get webRenameAccountTitle;

  /// Input label for account name.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get webAccountName;

  /// Body for the rename-account dialog.
  ///
  /// In en, this message translates to:
  /// **'What would you like to name this account?'**
  String get webRenameAccountBody;

  /// Menu item: lock the wallet.
  ///
  /// In en, this message translates to:
  /// **'Lock Wallet'**
  String get webLockWallet;

  /// Title for forget-account confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Forget Account {id}'**
  String webForgetTitle(String id);

  /// Body for forget-account confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this account from your wallet?'**
  String get webForgetBody;

  /// Body for forget-account dialog when this is the last account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this account from your wallet? Since you have no other accounts, you will be logged out.'**
  String get webForgetBodyLastAccount;

  /// Confirm button: forget account.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get webForget;

  /// Confirm button: forget last account and log out.
  ///
  /// In en, this message translates to:
  /// **'Forget & Logout'**
  String get webForgetAndLogout;

  /// Button: backup account keys.
  ///
  /// In en, this message translates to:
  /// **'Backup Keys'**
  String get webBackupKeys;

  /// Button: set account as active.
  ///
  /// In en, this message translates to:
  /// **'Set Active'**
  String get webSetActive;

  /// Heading shown when the camera fails.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get webScanCameraError;

  /// Button: retry camera scan.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get webScanRetry;

  /// Status while scanning a QR code.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get webScanScanning;

  /// Error: camera access required.
  ///
  /// In en, this message translates to:
  /// **'Camera access required to scan QR codes'**
  String get webScanCameraRequired;

  /// Instruction to align a QR code.
  ///
  /// In en, this message translates to:
  /// **'Position QR code within the frame to scan'**
  String get webScanInstruction;

  /// Tooltip showing wallet balance breakdown.
  ///
  /// In en, this message translates to:
  /// **'Available: {available} VFX\nLocked: {locked} VFX \nTotal: {total} RBX'**
  String webBalanceTooltip(String available, String locked, String total);

  /// Section title for the MOTHER feature.
  ///
  /// In en, this message translates to:
  /// **'Monitor Of The Roster'**
  String get motherTitle;

  /// Short description of MOTHER.
  ///
  /// In en, this message translates to:
  /// **'MOTHER is a tool for monitoring the state of your remote validators.'**
  String get motherDescription;

  /// Status section heading in MOTHER modal.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get motherStatusHeading;

  /// Status row indicating host state.
  ///
  /// In en, this message translates to:
  /// **'Is Host: {value}'**
  String motherIsHostRow(String value);

  /// Status row indicating remote state.
  ///
  /// In en, this message translates to:
  /// **'Is Remote: {value}'**
  String motherIsRemoteRow(String value);

  /// Status row showing child node count.
  ///
  /// In en, this message translates to:
  /// **'Children: {count}'**
  String motherChildrenRow(String count);

  /// Affirmative status value (uppercase).
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get motherYes;

  /// Negative status value (uppercase).
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get motherNo;

  /// Affirmative answer in child cards.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get motherChildYes;

  /// Negative answer in child cards.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get motherChildNo;

  /// Action: update host info.
  ///
  /// In en, this message translates to:
  /// **'Update Host Info'**
  String get motherUpdateHostInfo;

  /// Action: make this wallet the host.
  ///
  /// In en, this message translates to:
  /// **'Set Wallet as Host'**
  String get motherSetWalletHost;

  /// Confirm button: stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get motherStop;

  /// Body of the stop-host confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop running this wallet as a MOTHER host?'**
  String get motherStopHostBody;

  /// Body asking whether to restart the CLI now.
  ///
  /// In en, this message translates to:
  /// **'Would you like to restart now?'**
  String get motherCliRestartBody;

  /// Body asking the user to confirm stopping the remote node.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this node as a REMOTE?\n\nA CLI restart will be required.'**
  String get motherStopRemoteBody;

  /// Confirm button: stop remote and restart CLI.
  ///
  /// In en, this message translates to:
  /// **'Stop Remote & Restart CLI'**
  String get motherStopRemoteAction;

  /// Toast: remote node removed from MOTHER.
  ///
  /// In en, this message translates to:
  /// **'REMOTE node has been removed from MOTHER'**
  String get motherRemoteRemoved;

  /// Action: open the info dialog about MOTHER.
  ///
  /// In en, this message translates to:
  /// **'What is MOTHER?'**
  String get motherWhatIs;

  /// Long explanation of the MOTHER feature.
  ///
  /// In en, this message translates to:
  /// **'MOTHER is a tool for monitoring the state of your remote validators.\n\nFirst you must setup one of your wallets as the HOST and then add your additional node as a REMOTE.\n\nWhen adding a REMOTE node, you will need to know the IP address and the password for the HOST.\n\nOnce complete, you\'ll be able to view a dashboard tracking all of your node\'s activity from one wallet.\n\nNote: you must have port \'{port}\' open on the HOST machine.'**
  String motherInfoBody(String port);

  /// Validation: IP address required.
  ///
  /// In en, this message translates to:
  /// **'IP Address Required'**
  String get motherIpRequired;

  /// Validation: password required.
  ///
  /// In en, this message translates to:
  /// **'Password Required'**
  String get motherPasswordRequired;

  /// Validation: name required.
  ///
  /// In en, this message translates to:
  /// **'Name Required'**
  String get motherNameRequired;

  /// Note: required port must be open on host.
  ///
  /// In en, this message translates to:
  /// **'You must have port \'{port}\' open on the HOST machine.'**
  String motherPortNote(String port);

  /// Toast: host successfully created.
  ///
  /// In en, this message translates to:
  /// **'Host Created'**
  String get motherHostCreated;

  /// Action: open MOTHER dashboard in browser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get motherOpenInBrowser;

  /// Dashboard shortcut button for the Tokens screen.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get homeActionTokens;

  /// Dashboard shortcut button that opens video tutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get homeActionTutorials;

  /// Two-line vertical button label on the dashboard. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Get\nHelp'**
  String get homeActionGetHelp;

  /// Two-line vertical button label on the dashboard. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Open\nExplorer'**
  String get homeActionOpenExplorer;

  /// Two-line vertical button label on the dashboard. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Verify\nOwner'**
  String get homeActionVerifyOwner;

  /// Two-line vertical button label on the dashboard. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Sign\nOut'**
  String get homeActionSignOut;

  /// Title for the Get Help bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get homeGetHelpTitle;

  /// Get Help option: join the Discord server.
  ///
  /// In en, this message translates to:
  /// **'Join Discord'**
  String get homeJoinDiscord;

  /// Get Help option: visit the VerifiedX website.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get homeVisitWebsite;

  /// Get Help option: open the documentation.
  ///
  /// In en, this message translates to:
  /// **'Read Docs'**
  String get homeReadDocs;

  /// Title for the verify-ownership prompt dialog.
  ///
  /// In en, this message translates to:
  /// **'Validate Ownership'**
  String get homeValidateOwnership;

  /// Body for the verify-ownership prompt dialog.
  ///
  /// In en, this message translates to:
  /// **'Paste in the signature provided by the owner to validate its ownership.'**
  String get homeValidateOwnershipBody;

  /// Input label and validator name for the ownership signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get homeSignatureLabel;

  /// Toast shown when the ownership verification signature is malformed.
  ///
  /// In en, this message translates to:
  /// **'Invalid ownership verification signature'**
  String get homeInvalidSignature;

  /// Dialog title when ownership is verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get homeVerified;

  /// Dialog title when ownership is NOT verified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get homeNotVerified;

  /// Subtitle when ownership is verified.
  ///
  /// In en, this message translates to:
  /// **'Ownership Verified'**
  String get homeOwnershipVerified;

  /// Subtitle when ownership is NOT verified.
  ///
  /// In en, this message translates to:
  /// **'Ownership NOT Verified'**
  String get homeOwnershipNotVerified;

  /// Connector word between address and smartContractId when ownership is verified.
  ///
  /// In en, this message translates to:
  /// **'OWNS'**
  String get homeOwns;

  /// Connector phrase between address and smartContractId when ownership is NOT verified.
  ///
  /// In en, this message translates to:
  /// **'does NOT own'**
  String get homeDoesNotOwn;

  /// Tab label for the addresses panel at the bottom-left of the web dashboard.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get webAddressesLabel;

  /// Short label for a Vault address row.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get webVaultLabel;

  /// Status text shown when a Vault account has been recovered and deactivated.
  ///
  /// In en, this message translates to:
  /// **'Recovered & Deactivated'**
  String get webRecoveredDeactivated;

  /// Popup menu item to copy an address.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get webCopyAddressPopup;

  /// Popup menu item to reveal a private key.
  ///
  /// In en, this message translates to:
  /// **'Reveal Private Key'**
  String get webRevealPrivateKeyPopup;

  /// Label showing the latest block height in the bottom-right corner.
  ///
  /// In en, this message translates to:
  /// **'Block {height}'**
  String webBlockHeight(String height);

  /// Label showing the number of tokens.
  ///
  /// In en, this message translates to:
  /// **'{count} Tokens'**
  String webTokensCount(String count);

  /// Two-line vertical button label on the dashboard balance card. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Copy\nAddress'**
  String get dashCopyAddress;

  /// Two-line vertical button label to copy the Vault address. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Vault\nAddress'**
  String get dashVaultAddress;

  /// Two-line vertical button label to buy VFX. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Get\nVFX'**
  String get dashGetVfx;

  /// Two-line vertical button label to buy BTC. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Get\nBTC'**
  String get dashGetBtc;

  /// Two-line vertical button label to sell BTC. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Off Ramp\nBTC'**
  String get dashOffRampBtc;

  /// Two-line vertical button label to view vBTC tokens. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'vBTC\nTokens'**
  String get dashVbtcTokens;

  /// Two-line vertical button label to learn about vBTC. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'What\'s\nvBTC'**
  String get dashWhatsVbtc;

  /// Success status for a completed transaction.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get statusSuccess;

  /// From label with colon and address for transaction display.
  ///
  /// In en, this message translates to:
  /// **'From: {address}'**
  String txFromColonAddress(String address);

  /// To label with colon and address for transaction display.
  ///
  /// In en, this message translates to:
  /// **'To: {address}'**
  String txToColonAddress(String address);

  /// Toast shown after copying an address from the addresses panel (with period).
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard.'**
  String get webAddressesAddressCopiedDot;

  /// Title for the Butterfly password creation dialog.
  ///
  /// In en, this message translates to:
  /// **'Create Butterfly Password'**
  String get butterflyCreatePassword;

  /// Body text for the Butterfly password creation dialog.
  ///
  /// In en, this message translates to:
  /// **'Create a password to securely transfer your credentials to Butterfly. You will need to enter this same password on the Butterfly website.'**
  String get butterflyPasswordMessage;

  /// Confirmation dialog title for Butterfly login.
  ///
  /// In en, this message translates to:
  /// **'Login to Butterfly'**
  String get butterflyLoginTitle;

  /// Confirmation dialog body for Butterfly login.
  ///
  /// In en, this message translates to:
  /// **'You are about to open Butterfly and log in with:\n\n{address}\n\nContinue?'**
  String butterflyLoginBody(String address);

  /// Confirm button to open Butterfly.
  ///
  /// In en, this message translates to:
  /// **'Open Butterfly'**
  String get butterflyOpenButton;

  /// Error toast when no wallet is selected for Butterfly login.
  ///
  /// In en, this message translates to:
  /// **'No wallet selected. Please create or import a wallet first.'**
  String get butterflyNoWalletError;

  /// Error toast when Butterfly login URL generation fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate login URL: {error}'**
  String butterflyLoginUrlError(String error);

  /// Error toast when private key is not available.
  ///
  /// In en, this message translates to:
  /// **'Private key not available.'**
  String get navPrivateKeyNotAvailable;

  /// Button label to add a new account.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get webAddAccount;

  /// Menu item label for the language picker.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get webLanguageLabel;

  /// Label below address on the receive screen.
  ///
  /// In en, this message translates to:
  /// **'Your Address'**
  String get webYourAddress;

  /// Label below domain on the receive screen.
  ///
  /// In en, this message translates to:
  /// **'Your Domain'**
  String get webYourDomain;

  /// Two-line button label on the receive screen. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'Copy\nLink'**
  String get webCopyLink;

  /// Two-line button label on the receive screen. Newline must be preserved.
  ///
  /// In en, this message translates to:
  /// **'QR\nCode'**
  String get webQrCode;

  /// Dialog title for requesting funds via link.
  ///
  /// In en, this message translates to:
  /// **'Request Funds'**
  String get webRequestFunds;

  /// Dialog body explaining the request funds flow.
  ///
  /// In en, this message translates to:
  /// **'Generate a URL to send to another user.'**
  String get webRequestFundsBody;

  /// Label for the amount input in the request funds dialog.
  ///
  /// In en, this message translates to:
  /// **'Amount to request'**
  String get webAmountToRequest;

  /// Button label to generate a request funds link.
  ///
  /// In en, this message translates to:
  /// **'Generate Link'**
  String get webGenerateLink;

  /// Toast shown after copying a request funds link.
  ///
  /// In en, this message translates to:
  /// **'Request funds link copied to clipboard'**
  String get webRequestLinkCopied;

  /// Toast shown after copying a value to clipboard.
  ///
  /// In en, this message translates to:
  /// **'\'{value}\' Copied to clipboard'**
  String webCopiedToClipboard(String value);

  /// Error toast for invalid amount input.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get webInvalidAmount;

  /// Segmented button label for showing all currency types.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get segmentAll;

  /// Segmented button label for vault accounts.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get segmentVault;

  /// Default close button text in InfoDialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// Default confirm button text in ConfirmDialog.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get dialogYes;

  /// Default cancel button text in ConfirmDialog.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dialogNo;

  /// Default submit button text in PromptModal.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get dialogSubmit;

  /// No description provided for @govAdjAdditionalLinksLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Links: '**
  String get govAdjAdditionalLinksLabel;

  /// No description provided for @govAdjBandwidthLabel.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth (TB): '**
  String get govAdjBandwidthLabel;

  /// No description provided for @govAdjBandwidthUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get govAdjBandwidthUnlimited;

  /// No description provided for @govAdjCpuCoresLabel.
  ///
  /// In en, this message translates to:
  /// **'CPU Cores: '**
  String get govAdjCpuCoresLabel;

  /// No description provided for @govAdjCpuLabel.
  ///
  /// In en, this message translates to:
  /// **'CPU: '**
  String get govAdjCpuLabel;

  /// No description provided for @govAdjCpuThreadsLabel.
  ///
  /// In en, this message translates to:
  /// **'CPU Threads: '**
  String get govAdjCpuThreadsLabel;

  /// No description provided for @govAdjGithubLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Github Link: '**
  String get govAdjGithubLinkLabel;

  /// No description provided for @govAdjHdSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'HD Size: '**
  String get govAdjHdSizeLabel;

  /// No description provided for @govAdjInternetDownLabel.
  ///
  /// In en, this message translates to:
  /// **'Internet Speed down(Gbps): '**
  String get govAdjInternetDownLabel;

  /// No description provided for @govAdjInternetUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Internet Speed up(Gbps): '**
  String get govAdjInternetUpLabel;

  /// No description provided for @govAdjIpAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Adjudicator to be Ip Address: '**
  String get govAdjIpAddressLabel;

  /// No description provided for @govAdjMachineProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Machine Provider: '**
  String get govAdjMachineProviderLabel;

  /// No description provided for @govAdjMachineTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Machine type: '**
  String get govAdjMachineTypeLabel;

  /// No description provided for @govAdjOperatingSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating System: '**
  String get govAdjOperatingSystemLabel;

  /// No description provided for @govAdjRamLabel.
  ///
  /// In en, this message translates to:
  /// **'RAM (GB): '**
  String get govAdjRamLabel;

  /// No description provided for @govAdjReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reasons to be added as adjudicator: '**
  String get govAdjReasonLabel;

  /// No description provided for @govAdjTechnicalBackgroundLabel.
  ///
  /// In en, this message translates to:
  /// **'Technical background: '**
  String get govAdjTechnicalBackgroundLabel;

  /// No description provided for @govAdjVfxAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Adjudicator to be VFX Address: '**
  String get govAdjVfxAddressLabel;

  /// No description provided for @govVoteBlock.
  ///
  /// In en, this message translates to:
  /// **'Block {height}'**
  String govVoteBlock(int height);

  /// No description provided for @hnavActivatingSoon.
  ///
  /// In en, this message translates to:
  /// **'Activating soon.'**
  String get hnavActivatingSoon;

  /// No description provided for @hnavAgreeAndClose.
  ///
  /// In en, this message translates to:
  /// **'Agree and Close'**
  String get hnavAgreeAndClose;

  /// No description provided for @hnavAllMyTokens.
  ///
  /// In en, this message translates to:
  /// **'All My Tokens'**
  String get hnavAllMyTokens;

  /// No description provided for @hnavBackupKeysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export and save all your VFX{vaultSuffix} and BTC private keys & addresses to a text file.'**
  String hnavBackupKeysSubtitle(String vaultSuffix);

  /// No description provided for @hnavBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get hnavBackupLabel;

  /// No description provided for @hnavBackupMediaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Zip and export your NFT media assets.'**
  String get hnavBackupMediaSubtitle;

  /// No description provided for @hnavBlockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block {height}'**
  String hnavBlockNumber(String height);

  /// No description provided for @hnavBtcInactive.
  ///
  /// In en, this message translates to:
  /// **'BTC Inactive'**
  String get hnavBtcInactive;

  /// No description provided for @hnavBtcLoading.
  ///
  /// In en, this message translates to:
  /// **'BTC Loading'**
  String get hnavBtcLoading;

  /// No description provided for @hnavBtcLoginWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Although if you login with a BTC Private key, if this key was generated originally with a different login mechanism, your VFX/Vault account keypairs will not match with your previous login since private keys are not reversable.'**
  String get hnavBtcLoginWarningBody;

  /// No description provided for @hnavBtcOffline.
  ///
  /// In en, this message translates to:
  /// **'BTC Offline'**
  String get hnavBtcOffline;

  /// No description provided for @hnavBtcOnline.
  ///
  /// In en, this message translates to:
  /// **'BTC Online'**
  String get hnavBtcOnline;

  /// No description provided for @hnavCliInactive.
  ///
  /// In en, this message translates to:
  /// **'CLI Inactive'**
  String get hnavCliInactive;

  /// No description provided for @hnavCloseRecoveryPhraseBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you have copied your recovery phrase to a secure location?'**
  String get hnavCloseRecoveryPhraseBody;

  /// No description provided for @hnavCloseRecoveryPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Close Recovery Phrase?'**
  String get hnavCloseRecoveryPhraseTitle;

  /// No description provided for @hnavConfigAccountUnlockTime.
  ///
  /// In en, this message translates to:
  /// **'Account Unlock Time'**
  String get hnavConfigAccountUnlockTime;

  /// No description provided for @hnavConfigAllowedExtensionTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed Extension Types'**
  String get hnavConfigAllowedExtensionTypes;

  /// No description provided for @hnavConfigApiCallUrl.
  ///
  /// In en, this message translates to:
  /// **'Api Call Url'**
  String get hnavConfigApiCallUrl;

  /// No description provided for @hnavConfigApiPort.
  ///
  /// In en, this message translates to:
  /// **'Api Port'**
  String get hnavConfigApiPort;

  /// No description provided for @hnavConfigAutoDownloadNft.
  ///
  /// In en, this message translates to:
  /// **'Auto Download NFT Assets'**
  String get hnavConfigAutoDownloadNft;

  /// No description provided for @hnavConfigHeader.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get hnavConfigHeader;

  /// No description provided for @hnavConfigIgnoreIncomingNfts.
  ///
  /// In en, this message translates to:
  /// **'Ignore Incoming NFTs'**
  String get hnavConfigIgnoreIncomingNfts;

  /// No description provided for @hnavConfigMotherAddress.
  ///
  /// In en, this message translates to:
  /// **'Mother Address'**
  String get hnavConfigMotherAddress;

  /// No description provided for @hnavConfigMotherPassword.
  ///
  /// In en, this message translates to:
  /// **'Mother Password'**
  String get hnavConfigMotherPassword;

  /// No description provided for @hnavConfigNftTimeout.
  ///
  /// In en, this message translates to:
  /// **'NFT Timeout'**
  String get hnavConfigNftTimeout;

  /// No description provided for @hnavConfigPasswordClearTime.
  ///
  /// In en, this message translates to:
  /// **'Password Clear Time'**
  String get hnavConfigPasswordClearTime;

  /// No description provided for @hnavConfigRejectedExtensionTypes.
  ///
  /// In en, this message translates to:
  /// **'Rejected Asset Extension Types'**
  String get hnavConfigRejectedExtensionTypes;

  /// No description provided for @hnavConfirmCreateMnemonicBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to create a Mnemonic account?'**
  String get hnavConfirmCreateMnemonicBody;

  /// No description provided for @hnavCopyRecoveryPhraseInstruction.
  ///
  /// In en, this message translates to:
  /// **'Copy your recovery phrase to a secure location.'**
  String get hnavCopyRecoveryPhraseInstruction;

  /// No description provided for @hnavCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get hnavCopyToClipboard;

  /// No description provided for @hnavCouldNotGenerateKeypair.
  ///
  /// In en, this message translates to:
  /// **'Could not generate keypair'**
  String get hnavCouldNotGenerateKeypair;

  /// No description provided for @hnavCreateNewMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Create New Mnemonic'**
  String get hnavCreateNewMnemonic;

  /// No description provided for @hnavCurrencyAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hnavCurrencyAll;

  /// No description provided for @hnavDecryptAccountKeysBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the password for this account to decrypt and view its private keys.'**
  String get hnavDecryptAccountKeysBody;

  /// No description provided for @hnavDecryptionFailedCheckPassword.
  ///
  /// In en, this message translates to:
  /// **'Decryption failed. Check your password.'**
  String get hnavDecryptionFailedCheckPassword;

  /// No description provided for @hnavEncryptGeneratedMnemonicMessage.
  ///
  /// In en, this message translates to:
  /// **'This password will encrypt your generated mnemonic keys.'**
  String get hnavEncryptGeneratedMnemonicMessage;

  /// No description provided for @hnavEncryptImportedBtcPrivateKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'This password will encrypt your imported BTC private key.'**
  String get hnavEncryptImportedBtcPrivateKeyMessage;

  /// No description provided for @hnavEncryptImportedPrivateKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'This password will encrypt your imported private key.'**
  String get hnavEncryptImportedPrivateKeyMessage;

  /// No description provided for @hnavEncryptRecoveredMnemonicMessage.
  ///
  /// In en, this message translates to:
  /// **'This password will encrypt your recovered mnemonic keys.'**
  String get hnavEncryptRecoveredMnemonicMessage;

  /// No description provided for @hnavEnterAccountPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Account Password'**
  String get hnavEnterAccountPasswordTitle;

  /// No description provided for @hnavEnterBtcAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your BTC address'**
  String get hnavEnterBtcAddressHint;

  /// No description provided for @hnavEnterBtcPrivateKeyOrWif.
  ///
  /// In en, this message translates to:
  /// **'Enter your BTC Private Key or WIF Key:'**
  String get hnavEnterBtcPrivateKeyOrWif;

  /// No description provided for @hnavEnterPrivateKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your private key'**
  String get hnavEnterPrivateKeyHint;

  /// No description provided for @hnavEnterWalletPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Wallet Password'**
  String get hnavEnterWalletPasswordTitle;

  /// No description provided for @hnavExtensionDecryptPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the password you used in the VFX Extension to decrypt your private key.'**
  String get hnavExtensionDecryptPasswordBody;

  /// No description provided for @hnavExtensionNotDetected.
  ///
  /// In en, this message translates to:
  /// **'VFX Extension not detected'**
  String get hnavExtensionNotDetected;

  /// No description provided for @hnavExtensionUnlockFirst.
  ///
  /// In en, this message translates to:
  /// **'Please unlock your extension wallet first'**
  String get hnavExtensionUnlockFirst;

  /// No description provided for @hnavExtensionWebOnly.
  ///
  /// In en, this message translates to:
  /// **'VFX Extension is only available on web'**
  String get hnavExtensionWebOnly;

  /// No description provided for @hnavFailedDecryptAccountKeys.
  ///
  /// In en, this message translates to:
  /// **'Failed to decrypt account keys. Check your password.'**
  String get hnavFailedDecryptAccountKeys;

  /// No description provided for @hnavFungibleToken.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token'**
  String get hnavFungibleToken;

  /// No description provided for @hnavFungibleTokenWithBalance.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token ({balance} {ticker})'**
  String hnavFungibleTokenWithBalance(String balance, String ticker);

  /// No description provided for @hnavHd12Words.
  ///
  /// In en, this message translates to:
  /// **'12 Words'**
  String get hnavHd12Words;

  /// No description provided for @hnavHd24Words.
  ///
  /// In en, this message translates to:
  /// **'24 Words'**
  String get hnavHd24Words;

  /// No description provided for @hnavHdAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'HD Account'**
  String get hnavHdAccountTitle;

  /// No description provided for @hnavHdCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create HD Account'**
  String get hnavHdCreateAccount;

  /// No description provided for @hnavHdEncryptedError.
  ///
  /// In en, this message translates to:
  /// **'You can not create an HD account with an encrypted wallet.'**
  String get hnavHdEncryptedError;

  /// No description provided for @hnavHdExplanation1.
  ///
  /// In en, this message translates to:
  /// **'By creating an HD account you are creating a function to recover your private keys by use of recovery phrase.'**
  String get hnavHdExplanation1;

  /// No description provided for @hnavHdExplanation2.
  ///
  /// In en, this message translates to:
  /// **'Once generated, any keys you create will use this phrase to seed the private key generation. Therefore, you will only need to remember this to deterministically recover your keys.'**
  String get hnavHdExplanation2;

  /// No description provided for @hnavHdExplanation3.
  ///
  /// In en, this message translates to:
  /// **'This is an advanced feature and is not recommended unless you are familiar with Hierarchical Deterministic concepts.\n\nAny keys created prior to this will not be recoverable through this phrase so please ensure they are backed up as well.'**
  String get hnavHdExplanation3;

  /// No description provided for @hnavHdGenerateStrength.
  ///
  /// In en, this message translates to:
  /// **'Generate with strength:'**
  String get hnavHdGenerateStrength;

  /// No description provided for @hnavIDontKnow.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get hnavIDontKnow;

  /// No description provided for @hnavImportBtcPrivateKeyOrWifTitle.
  ///
  /// In en, this message translates to:
  /// **'Import BTC Private Key or WIF Key'**
  String get hnavImportBtcPrivateKeyOrWifTitle;

  /// No description provided for @hnavInvalidBtcAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid BTC Address'**
  String get hnavInvalidBtcAddress;

  /// No description provided for @hnavInvalidPrivateKeyOrWif.
  ///
  /// In en, this message translates to:
  /// **'Not a valid Private Key or WIF Key. Should be 64 or 52 characters'**
  String get hnavInvalidPrivateKeyOrWif;

  /// No description provided for @hnavIsAdjudicating.
  ///
  /// In en, this message translates to:
  /// **'{label} is Adjudicating...'**
  String hnavIsAdjudicating(String label);

  /// No description provided for @hnavKeysBackedUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Keys backed up successfully.'**
  String get hnavKeysBackedUpSuccess;

  /// No description provided for @hnavMediaBackedUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Media backed up successfully.'**
  String get hnavMediaBackedUpSuccess;

  /// No description provided for @hnavMempool.
  ///
  /// In en, this message translates to:
  /// **'Mempool'**
  String get hnavMempool;

  /// No description provided for @hnavMempoolEmpty.
  ///
  /// In en, this message translates to:
  /// **'Mempool is empty.'**
  String get hnavMempoolEmpty;

  /// No description provided for @hnavMnemonicTitle.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic'**
  String get hnavMnemonicTitle;

  /// No description provided for @hnavNoTokensEmptyState.
  ///
  /// In en, this message translates to:
  /// **'You have no vBTC Tokens, Fungible Tokens, or Non-Fungible Tokens'**
  String get hnavNoTokensEmptyState;

  /// No description provided for @hnavNoWalletDetected.
  ///
  /// In en, this message translates to:
  /// **'No Wallet detected.'**
  String get hnavNoWalletDetected;

  /// No description provided for @hnavNonFungibleToken.
  ///
  /// In en, this message translates to:
  /// **'Non-Fungible Token'**
  String get hnavNonFungibleToken;

  /// No description provided for @hnavNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get hnavNoticeTitle;

  /// No description provided for @hnavPasteBtcAddress.
  ///
  /// In en, this message translates to:
  /// **'Paste your BTC address:'**
  String get hnavPasteBtcAddress;

  /// No description provided for @hnavPortNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Port {port} is NOT open. Please configure your firewall.'**
  String hnavPortNotOpen(String port);

  /// No description provided for @hnavPortOpen.
  ///
  /// In en, this message translates to:
  /// **'Port {port} is open!'**
  String hnavPortOpen(String port);

  /// No description provided for @hnavProposalsVoting.
  ///
  /// In en, this message translates to:
  /// **'Proposals & Voting'**
  String get hnavProposalsVoting;

  /// No description provided for @hnavRecoverFromMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Recover From Mnemonic'**
  String get hnavRecoverFromMnemonic;

  /// No description provided for @hnavRecoveryPhraseGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Phrase Generated'**
  String get hnavRecoveryPhraseGeneratedTitle;

  /// No description provided for @hnavRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get hnavRequestCancelled;

  /// No description provided for @hnavRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get hnavRequestTimedOut;

  /// No description provided for @hnavReserveAccountsNotExported.
  ///
  /// In en, this message translates to:
  /// **'Please note that Reserve/Protected Accounts will not be exported.'**
  String get hnavReserveAccountsNotExported;

  /// No description provided for @hnavRestoreHiddenBracket.
  ///
  /// In en, this message translates to:
  /// **'[Restore Hidden]'**
  String get hnavRestoreHiddenBracket;

  /// No description provided for @hnavResyncing.
  ///
  /// In en, this message translates to:
  /// **'Resyncing...'**
  String get hnavResyncing;

  /// No description provided for @hnavRevealPrivateKeysPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to reveal private keys.'**
  String get hnavRevealPrivateKeysPasswordMessage;

  /// No description provided for @hnavRevealVaultKeysPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to reveal Vault account private keys.'**
  String get hnavRevealVaultKeysPasswordMessage;

  /// No description provided for @hnavSectionAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get hnavSectionAccountSecurity;

  /// No description provided for @hnavSectionDiagnose.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get hnavSectionDiagnose;

  /// No description provided for @hnavSectionTokensNfts.
  ///
  /// In en, this message translates to:
  /// **'Tokens / NFTs'**
  String get hnavSectionTokensNfts;

  /// No description provided for @hnavSectionValidator.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get hnavSectionValidator;

  /// No description provided for @hnavSelectAddressType.
  ///
  /// In en, this message translates to:
  /// **'Select your address type:'**
  String get hnavSelectAddressType;

  /// No description provided for @hnavSelectedBtcAccountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selected BTC Account'**
  String get hnavSelectedBtcAccountTooltip;

  /// No description provided for @hnavSelectedVfxAddressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Selected VFX Address'**
  String get hnavSelectedVfxAddressTooltip;

  /// No description provided for @hnavSetEncryptionPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Encryption Password'**
  String get hnavSetEncryptionPasswordTitle;

  /// No description provided for @hnavShowKeysAccountDetailsBody.
  ///
  /// In en, this message translates to:
  /// **'Here are your{currencySuffix} account details. Please ensure to back up your private key in a safe place.'**
  String hnavShowKeysAccountDetailsBody(String currencySuffix);

  /// No description provided for @hnavSnapshotAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get hnavSnapshotAllDone;

  /// No description provided for @hnavSnapshotDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get hnavSnapshotDownloading;

  /// No description provided for @hnavSnapshotDownloadingFile.
  ///
  /// In en, this message translates to:
  /// **'Downloading: {file}'**
  String hnavSnapshotDownloadingFile(String file);

  /// No description provided for @hnavSnapshotError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please restart and try again.'**
  String get hnavSnapshotError;

  /// No description provided for @hnavSnapshotImported.
  ///
  /// In en, this message translates to:
  /// **'Database Snapshot Imported.'**
  String get hnavSnapshotImported;

  /// No description provided for @hnavSnapshotInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get hnavSnapshotInitializing;

  /// No description provided for @hnavSnapshotShuttingDown.
  ///
  /// In en, this message translates to:
  /// **'Shutting down CLI...'**
  String get hnavSnapshotShuttingDown;

  /// No description provided for @hnavSnapshotStartingUp.
  ///
  /// In en, this message translates to:
  /// **'Starting up CLI now...'**
  String get hnavSnapshotStartingUp;

  /// No description provided for @hnavStartAdjudicating.
  ///
  /// In en, this message translates to:
  /// **'Start Adjudicating'**
  String get hnavStartAdjudicating;

  /// No description provided for @hnavStopAdjudicating.
  ///
  /// In en, this message translates to:
  /// **'Stop Adjudicating'**
  String get hnavStopAdjudicating;

  /// No description provided for @hnavSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get hnavSynced;

  /// No description provided for @hnavSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get hnavSyncing;

  /// No description provided for @hnavValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get hnavValidating;

  /// No description provided for @hnavVaultAccountDetailsBody.
  ///
  /// In en, this message translates to:
  /// **'Here are your Vault Account details. Please ensure to back up your private key in a safe place.'**
  String get hnavVaultAccountDetailsBody;

  /// No description provided for @hnavVaultAccountDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vault Account Details'**
  String get hnavVaultAccountDetailsTitle;

  /// No description provided for @hnavVaultSuffix.
  ///
  /// In en, this message translates to:
  /// **' Vault'**
  String get hnavVaultSuffix;

  /// No description provided for @hnavVbtcTokenWithBalance.
  ///
  /// In en, this message translates to:
  /// **'vBTC Token ({balance} vBTC)'**
  String hnavVbtcTokenWithBalance(String balance);

  /// No description provided for @hnavVfxCliLoading.
  ///
  /// In en, this message translates to:
  /// **'VFX CLI Loading'**
  String get hnavVfxCliLoading;

  /// No description provided for @hnavVfxCliOffline.
  ///
  /// In en, this message translates to:
  /// **'VFX CLI Offline'**
  String get hnavVfxCliOffline;

  /// No description provided for @hnavVfxOnline.
  ///
  /// In en, this message translates to:
  /// **'VFX Online'**
  String get hnavVfxOnline;

  /// No description provided for @hnavWalletPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet Password'**
  String get hnavWalletPasswordLabel;

  /// No description provided for @hnavWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get hnavWarningTitle;

  /// No description provided for @mktAddReservePrice.
  ///
  /// In en, this message translates to:
  /// **'Add Reserve Price'**
  String get mktAddReservePrice;

  /// No description provided for @mktAuction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get mktAuction;

  /// No description provided for @mktAuctionActivityForTitle.
  ///
  /// In en, this message translates to:
  /// **'Auction Activity for {name}'**
  String mktAuctionActivityForTitle(String name);

  /// No description provided for @mktAuctionAlreadyStartedToast.
  ///
  /// In en, this message translates to:
  /// **'The auction has already started.'**
  String get mktAuctionAlreadyStartedToast;

  /// No description provided for @mktAuctionFloorPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Auction Floor Price'**
  String get mktAuctionFloorPriceLabel;

  /// No description provided for @mktAuctionNotLiveToast.
  ///
  /// In en, this message translates to:
  /// **'Auction is not live'**
  String get mktAuctionNotLiveToast;

  /// No description provided for @mktAuctionOverToast.
  ///
  /// In en, this message translates to:
  /// **'Auction is over'**
  String get mktAuctionOverToast;

  /// No description provided for @mktAuctionReservePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Auction Reserve Price'**
  String get mktAuctionReservePriceLabel;

  /// No description provided for @mktAuctionStartedDatesLocked.
  ///
  /// In en, this message translates to:
  /// **'Auction has started so the dates & times can\'t be updated.'**
  String get mktAuctionStartedDatesLocked;

  /// No description provided for @mktAuctionStartedPricingLocked.
  ///
  /// In en, this message translates to:
  /// **'Auction has started so the pricing can\'t be updated.'**
  String get mktAuctionStartedPricingLocked;

  /// No description provided for @mktBidAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Bid Amount (VFX)'**
  String get mktBidAmountLabel;

  /// No description provided for @mktBidIncrementToast.
  ///
  /// In en, this message translates to:
  /// **'The minimum increment amount is {increment} VFX. A bid greater than {minimum} VFX is required.'**
  String mktBidIncrementToast(String increment, String minimum);

  /// No description provided for @mktBidInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough balance to cover this bid.\n\nWould you like to pay with a Credit Card or another crypto token?'**
  String get mktBidInsufficientBody;

  /// No description provided for @mktBidMustBeGreaterFooter.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than {minimum} VFX'**
  String mktBidMustBeGreaterFooter(String minimum);

  /// No description provided for @mktBidMustBeGreaterToast.
  ///
  /// In en, this message translates to:
  /// **'Your bid must be greater than the current highest bid ({price} VFX)'**
  String mktBidMustBeGreaterToast(String price);

  /// No description provided for @mktBidSubmittedToast.
  ///
  /// In en, this message translates to:
  /// **'Bid Submitted'**
  String get mktBidSubmittedToast;

  /// No description provided for @mktBuyNowConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to buy now for {price} VFX?'**
  String mktBuyNowConfirmBody(String price);

  /// No description provided for @mktBuyNowInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'This NFT has a buy now price of {price} VFX and you don\'t have enough balance to cover it.\n\nWould you like to pay with a Credit Card or another crypto token?'**
  String mktBuyNowInsufficientBody(String price);

  /// No description provided for @mktBuyNowPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy Now Price'**
  String get mktBuyNowPriceLabel;

  /// No description provided for @mktBuyNowTxBroadcastedTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy Now TX broadcasted.'**
  String get mktBuyNowTxBroadcastedTitle;

  /// No description provided for @mktBuyNowTxBroadcastedToast.
  ///
  /// In en, this message translates to:
  /// **'Buy Now TX broadcasted. Please wait for it to be accepted by the shop owner'**
  String get mktBuyNowTxBroadcastedToast;

  /// No description provided for @mktChooseAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an Address'**
  String get mktChooseAddressTitle;

  /// No description provided for @mktCloseCreateListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the listing creation screen?'**
  String get mktCloseCreateListingTitle;

  /// No description provided for @mktCloseEditListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the listing editing screen?'**
  String get mktCloseEditListingTitle;

  /// No description provided for @mktCollectionDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Collection deleted.'**
  String get mktCollectionDeletedToast;

  /// No description provided for @mktCollectionDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection Description'**
  String get mktCollectionDescriptionLabel;

  /// No description provided for @mktCollectionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection Name'**
  String get mktCollectionNameLabel;

  /// No description provided for @mktCouldNotGenerateHashToast.
  ///
  /// In en, this message translates to:
  /// **'Could not generate hash'**
  String get mktCouldNotGenerateHashToast;

  /// No description provided for @mktCouldNotGetFeeToast.
  ///
  /// In en, this message translates to:
  /// **'Could not get fee'**
  String get mktCouldNotGetFeeToast;

  /// No description provided for @mktCouldNotGetNonceToast.
  ///
  /// In en, this message translates to:
  /// **'Could not get nonce'**
  String get mktCouldNotGetNonceToast;

  /// No description provided for @mktCouldNotGetTimestampToast.
  ///
  /// In en, this message translates to:
  /// **'Could not get timestamp'**
  String get mktCouldNotGetTimestampToast;

  /// No description provided for @mktCouldNotProduceSignatureToast.
  ///
  /// In en, this message translates to:
  /// **'Could not produce signature'**
  String get mktCouldNotProduceSignatureToast;

  /// No description provided for @mktCouldNotVerifyTransactionToast.
  ///
  /// In en, this message translates to:
  /// **'Could not verify transaction'**
  String get mktCouldNotVerifyTransactionToast;

  /// No description provided for @mktCreateAuctionHouseBody.
  ///
  /// In en, this message translates to:
  /// **'Create your auction house / gallery and publish it to the network.\nThen you\'ll be able to create collections and add listings to them.'**
  String get mktCreateAuctionHouseBody;

  /// No description provided for @mktDatesHeading.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get mktDatesHeading;

  /// No description provided for @mktDeleteChatThreadBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat thread?'**
  String get mktDeleteChatThreadBody;

  /// No description provided for @mktDeleteChatThreadLocalBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat thread locally?'**
  String get mktDeleteChatThreadLocalBody;

  /// No description provided for @mktDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get mktDeleteListing;

  /// No description provided for @mktDeleteStoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this store?'**
  String get mktDeleteStoreConfirmBody;

  /// No description provided for @mktEditCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit Collection'**
  String get mktEditCollection;

  /// No description provided for @mktEditListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get mktEditListing;

  /// No description provided for @mktEnableAuction.
  ///
  /// In en, this message translates to:
  /// **'Enable Auction?'**
  String get mktEnableAuction;

  /// No description provided for @mktEnableBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Enable Buy Now?'**
  String get mktEnableBuyNow;

  /// No description provided for @mktEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get mktEndDateLabel;

  /// No description provided for @mktEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get mktEndTimeLabel;

  /// No description provided for @mktErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get mktErrorOccurred;

  /// No description provided for @mktGalleryOnly.
  ///
  /// In en, this message translates to:
  /// **'Gallery Only?'**
  String get mktGalleryOnly;

  /// No description provided for @mktInsufficientBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance'**
  String get mktInsufficientBalanceTitle;

  /// No description provided for @mktListingForTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing for {name}'**
  String mktListingForTitle(String name);

  /// No description provided for @mktNftAlreadyListedToast.
  ///
  /// In en, this message translates to:
  /// **'This NFT is already listed. Please choose another'**
  String get mktNftAlreadyListedToast;

  /// No description provided for @mktNftColonLabel.
  ///
  /// In en, this message translates to:
  /// **'NFT:'**
  String get mktNftColonLabel;

  /// No description provided for @mktNftNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NFT: {name}'**
  String mktNftNameLabel(String name);

  /// No description provided for @mktNoAccountToast.
  ///
  /// In en, this message translates to:
  /// **'No Account'**
  String get mktNoAccountToast;

  /// No description provided for @mktNoAuctionToast.
  ///
  /// In en, this message translates to:
  /// **'No auction'**
  String get mktNoAuctionToast;

  /// No description provided for @mktNoBalanceToast.
  ///
  /// In en, this message translates to:
  /// **'No Balance'**
  String get mktNoBalanceToast;

  /// No description provided for @mktNoBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No Bids Yet.'**
  String get mktNoBidsYet;

  /// No description provided for @mktNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get mktNoMessagesYet;

  /// No description provided for @mktNoShopToast.
  ///
  /// In en, this message translates to:
  /// **'No shop'**
  String get mktNoShopToast;

  /// No description provided for @mktNoThreadToast.
  ///
  /// In en, this message translates to:
  /// **'No Thread'**
  String get mktNoThreadToast;

  /// No description provided for @mktNotEnoughBalanceToast.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance.'**
  String get mktNotEnoughBalanceToast;

  /// No description provided for @mktNotEnoughBalanceValidatingToast.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance since you are validating.'**
  String get mktNotEnoughBalanceValidatingToast;

  /// No description provided for @mktNotNotifiedToast.
  ///
  /// In en, this message translates to:
  /// **'You will not be notified. You can update this setting on the dashboard if you change your mind.'**
  String get mktNotNotifiedToast;

  /// No description provided for @mktOptionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get mktOptionsHeading;

  /// No description provided for @mktOwnersAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner\'s Address'**
  String get mktOwnersAddressLabel;

  /// No description provided for @mktPayWithCardCryptoTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with Credit Card / Crypto'**
  String get mktPayWithCardCryptoTitle;

  /// No description provided for @mktPlaceBid.
  ///
  /// In en, this message translates to:
  /// **'Place Bid'**
  String get mktPlaceBid;

  /// No description provided for @mktPlaceBidConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to place a bid of {amount} VFX?'**
  String mktPlaceBidConfirmBody(String amount);

  /// No description provided for @mktPresignProblemToast.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred presigning the sale transaction. Please try again'**
  String get mktPresignProblemToast;

  /// No description provided for @mktProblemOccurredToast.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred'**
  String get mktProblemOccurredToast;

  /// No description provided for @mktPublishLive.
  ///
  /// In en, this message translates to:
  /// **'Publish Live'**
  String get mktPublishLive;

  /// No description provided for @mktReplaceNft.
  ///
  /// In en, this message translates to:
  /// **'Replace NFT'**
  String get mktReplaceNft;

  /// No description provided for @mktReservePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reserve Price'**
  String get mktReservePriceLabel;

  /// No description provided for @mktSelectNft.
  ///
  /// In en, this message translates to:
  /// **'Select NFT'**
  String get mktSelectNft;

  /// No description provided for @mktSelectOwnerAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Select an address from the list to be the shop owner.'**
  String get mktSelectOwnerAddressHint;

  /// No description provided for @mktShopDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop Description'**
  String get mktShopDescriptionLabel;

  /// No description provided for @mktShopIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop Identifier'**
  String get mktShopIdentifierLabel;

  /// No description provided for @mktShopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get mktShopNameLabel;

  /// No description provided for @mktSignatureNotValidPrimaryToast.
  ///
  /// In en, this message translates to:
  /// **'Signature not valid (primary)'**
  String get mktSignatureNotValidPrimaryToast;

  /// No description provided for @mktStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get mktStartDateLabel;

  /// No description provided for @mktStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get mktStartTimeLabel;

  /// No description provided for @mktSubscribeUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'In order for the web wallet to provide notifications to auction winners to sign transactions, an email address is required.'**
  String get mktSubscribeUpdatesBody;

  /// No description provided for @mktSubscribeUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for updates?'**
  String get mktSubscribeUpdatesTitle;

  /// No description provided for @mktSubscribedToast.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get mktSubscribedToast;

  /// No description provided for @mktThirdPartySaleStartNote.
  ///
  /// In en, this message translates to:
  /// **'Because this auction house is hosted on the VFX Web Wallet, the seller will need to authorize the Sale Start transaction. You will see that in your transaction list once it\'s been sent.'**
  String get mktThirdPartySaleStartNote;

  /// No description provided for @mktTxBroadcastedToast.
  ///
  /// In en, this message translates to:
  /// **'TX Broadcasted'**
  String get mktTxBroadcastedToast;

  /// No description provided for @mktWaitForFinalizeBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the transaction to be finalized.'**
  String get mktWaitForFinalizeBody;

  /// No description provided for @scwAddAFeature.
  ///
  /// In en, this message translates to:
  /// **'Add a Feature'**
  String get scwAddAFeature;

  /// No description provided for @scwAddCreatorName.
  ///
  /// In en, this message translates to:
  /// **'Add Creator Name'**
  String get scwAddCreatorName;

  /// No description provided for @scwAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Add Description'**
  String get scwAddDescription;

  /// No description provided for @scwAddEvolvingPhase.
  ///
  /// In en, this message translates to:
  /// **'Add evolving phase'**
  String get scwAddEvolvingPhase;

  /// No description provided for @scwAddName.
  ///
  /// In en, this message translates to:
  /// **'Add Name'**
  String get scwAddName;

  /// No description provided for @scwAddProperty.
  ///
  /// In en, this message translates to:
  /// **'Add property'**
  String get scwAddProperty;

  /// No description provided for @scwAddPropertyButton.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get scwAddPropertyButton;

  /// No description provided for @scwAddRoyalty.
  ///
  /// In en, this message translates to:
  /// **'Add Royalty'**
  String get scwAddRoyalty;

  /// No description provided for @scwAddStat.
  ///
  /// In en, this message translates to:
  /// **'Add Stat'**
  String get scwAddStat;

  /// No description provided for @scwAdditionalAssets.
  ///
  /// In en, this message translates to:
  /// **'Additional Assets'**
  String get scwAdditionalAssets;

  /// No description provided for @scwAllowVoting.
  ///
  /// In en, this message translates to:
  /// **'Allow Voting'**
  String get scwAllowVoting;

  /// No description provided for @scwBeneficiaryAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Address (Optional)'**
  String get scwBeneficiaryAddressOptional;

  /// No description provided for @scwBlockHeightValue.
  ///
  /// In en, this message translates to:
  /// **'Block Height Value'**
  String get scwBlockHeightValue;

  /// No description provided for @scwCantAddEvolveBody.
  ///
  /// In en, this message translates to:
  /// **'You already have an evolve feature in this smart contract. Edit the existing evolving feature to add more stages.'**
  String get scwCantAddEvolveBody;

  /// No description provided for @scwCantAddEvolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t add Evolve'**
  String get scwCantAddEvolveTitle;

  /// No description provided for @scwCantAddMultiAssetBody.
  ///
  /// In en, this message translates to:
  /// **'You already have a multi asset feature in this smart contract. Edit the existing multi asset feature to add more assets.'**
  String get scwCantAddMultiAssetBody;

  /// No description provided for @scwCantAddMultiAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t add Multi Asset'**
  String get scwCantAddMultiAssetTitle;

  /// No description provided for @scwCantAddRoyaltyBody.
  ///
  /// In en, this message translates to:
  /// **'You already have a royalty feature in this smart contract.'**
  String get scwCantAddRoyaltyBody;

  /// No description provided for @scwCantAddRoyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t add Royalty'**
  String get scwCantAddRoyaltyTitle;

  /// No description provided for @scwCantAddSoulBoundBody.
  ///
  /// In en, this message translates to:
  /// **'You already have a soul bound feature in this smart contract.'**
  String get scwCantAddSoulBoundBody;

  /// No description provided for @scwCantAddSoulBoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t add Soul Bound'**
  String get scwCantAddSoulBoundTitle;

  /// No description provided for @scwChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get scwChoose;

  /// No description provided for @scwChooseAnAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose an address'**
  String get scwChooseAnAddress;

  /// No description provided for @scwCollectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Collection Description'**
  String get scwCollectionDescription;

  /// No description provided for @scwCollectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection Name'**
  String get scwCollectionName;

  /// No description provided for @scwCollectionThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Collection Thumbnail'**
  String get scwCollectionThumbnail;

  /// No description provided for @scwCollectionWizard.
  ///
  /// In en, this message translates to:
  /// **'Collection Wizard'**
  String get scwCollectionWizard;

  /// No description provided for @scwColorProperty.
  ///
  /// In en, this message translates to:
  /// **'Color Property'**
  String get scwColorProperty;

  /// No description provided for @scwCreateAndMintBody.
  ///
  /// In en, this message translates to:
  /// **'Start with a baseline smart contract and add customized features'**
  String get scwCreateAndMintBody;

  /// No description provided for @scwCreateAndMintTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Smart Contract & Mint'**
  String get scwCreateAndMintTitle;

  /// No description provided for @scwCreateSmartContractTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Smart Contract'**
  String get scwCreateSmartContractTitle;

  /// No description provided for @scwCreatorName.
  ///
  /// In en, this message translates to:
  /// **'Creator Name'**
  String get scwCreatorName;

  /// No description provided for @scwCreatorRetainedOwnership.
  ///
  /// In en, this message translates to:
  /// **'Creator’s Retained Ownership'**
  String get scwCreatorRetainedOwnership;

  /// No description provided for @scwCreatorValue.
  ///
  /// In en, this message translates to:
  /// **'Creator: {name}'**
  String scwCreatorValue(String name);

  /// No description provided for @scwDeletePrimaryAssetBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the primary asset?'**
  String get scwDeletePrimaryAssetBody;

  /// No description provided for @scwDeletePrimaryAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Primary Asset?'**
  String get scwDeletePrimaryAssetTitle;

  /// No description provided for @scwDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get scwDescription;

  /// No description provided for @scwDescriptionOfPhysicalDigitalGood.
  ///
  /// In en, this message translates to:
  /// **'Description of Physical/Digital Good'**
  String get scwDescriptionOfPhysicalDigitalGood;

  /// No description provided for @scwDownloadExampleCsv.
  ///
  /// In en, this message translates to:
  /// **'Download Example CSV'**
  String get scwDownloadExampleCsv;

  /// No description provided for @scwDownloadExampleJson.
  ///
  /// In en, this message translates to:
  /// **'Download Example JSON'**
  String get scwDownloadExampleJson;

  /// No description provided for @scwEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get scwEdit;

  /// No description provided for @scwEditCreatorName.
  ///
  /// In en, this message translates to:
  /// **'Edit Creator Name'**
  String get scwEditCreatorName;

  /// No description provided for @scwEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get scwEditDescription;

  /// No description provided for @scwEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get scwEditName;

  /// No description provided for @scwEventAddress.
  ///
  /// In en, this message translates to:
  /// **'Event Address'**
  String get scwEventAddress;

  /// No description provided for @scwEventCode.
  ///
  /// In en, this message translates to:
  /// **'Event Code'**
  String get scwEventCode;

  /// No description provided for @scwEventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get scwEventDate;

  /// No description provided for @scwEventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get scwEventDescription;

  /// No description provided for @scwEventName.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get scwEventName;

  /// No description provided for @scwEventTime.
  ///
  /// In en, this message translates to:
  /// **'Event Time'**
  String get scwEventTime;

  /// No description provided for @scwEventUrl.
  ///
  /// In en, this message translates to:
  /// **'Event URL'**
  String get scwEventUrl;

  /// No description provided for @scwEvolutionDate.
  ///
  /// In en, this message translates to:
  /// **'Evolution Date'**
  String get scwEvolutionDate;

  /// No description provided for @scwEvolutionTime.
  ///
  /// In en, this message translates to:
  /// **'Evolution Time ({timezone})'**
  String scwEvolutionTime(String timezone);

  /// No description provided for @scwEvolve.
  ///
  /// In en, this message translates to:
  /// **'Evolve'**
  String get scwEvolve;

  /// No description provided for @scwEvolveOnRedeem.
  ///
  /// In en, this message translates to:
  /// **'Evolve on Redeem?'**
  String get scwEvolveOnRedeem;

  /// No description provided for @scwEvolveStageAsset.
  ///
  /// In en, this message translates to:
  /// **'Evolve Stage Asset'**
  String get scwEvolveStageAsset;

  /// No description provided for @scwEvolveStageDescription.
  ///
  /// In en, this message translates to:
  /// **'Evolve Stage Description'**
  String get scwEvolveStageDescription;

  /// No description provided for @scwEvolveStageName.
  ///
  /// In en, this message translates to:
  /// **'Evolve Stage Name'**
  String get scwEvolveStageName;

  /// No description provided for @scwEvolveType.
  ///
  /// In en, this message translates to:
  /// **'Evolve Type'**
  String get scwEvolveType;

  /// No description provided for @scwEvolveTypeBlockHeight.
  ///
  /// In en, this message translates to:
  /// **'Block Height'**
  String get scwEvolveTypeBlockHeight;

  /// No description provided for @scwEvolveTypeDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get scwEvolveTypeDateTime;

  /// No description provided for @scwEvolveTypeManualOnly.
  ///
  /// In en, this message translates to:
  /// **'Manual Only'**
  String get scwEvolveTypeManualOnly;

  /// No description provided for @scwEvolveWithType.
  ///
  /// In en, this message translates to:
  /// **'Evolve ({type})'**
  String scwEvolveWithType(String type);

  /// No description provided for @scwEvolvingPhase.
  ///
  /// In en, this message translates to:
  /// **'Evolving phase'**
  String get scwEvolvingPhase;

  /// No description provided for @scwExpireDate.
  ///
  /// In en, this message translates to:
  /// **'Expire Date'**
  String get scwExpireDate;

  /// No description provided for @scwExpireTime.
  ///
  /// In en, this message translates to:
  /// **'Expire Time'**
  String get scwExpireTime;

  /// No description provided for @scwFractionalInterest.
  ///
  /// In en, this message translates to:
  /// **'Fractional Interest'**
  String get scwFractionalInterest;

  /// No description provided for @scwFractionalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Fractionalization'**
  String get scwFractionalizationTitle;

  /// No description provided for @scwFullDescription.
  ///
  /// In en, this message translates to:
  /// **'Full Description'**
  String get scwFullDescription;

  /// No description provided for @scwImages.
  ///
  /// In en, this message translates to:
  /// **'Image(s)'**
  String get scwImages;

  /// No description provided for @scwImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing'**
  String get scwImporting;

  /// No description provided for @scwLaunchIdeBody.
  ///
  /// In en, this message translates to:
  /// **'Open the online IDE to write your own Trillium code for your smart contract'**
  String get scwLaunchIdeBody;

  /// No description provided for @scwLaunchIdeMobileBody.
  ///
  /// In en, this message translates to:
  /// **'The IDE is optimized for larger screens. Would you like to proceed?'**
  String get scwLaunchIdeMobileBody;

  /// No description provided for @scwLaunchIdeMobileTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch IDE on mobile?'**
  String get scwLaunchIdeMobileTitle;

  /// No description provided for @scwLaunchIdeTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch IDE'**
  String get scwLaunchIdeTitle;

  /// No description provided for @scwLaunchWizard.
  ///
  /// In en, this message translates to:
  /// **'Launch Wizard'**
  String get scwLaunchWizard;

  /// No description provided for @scwMaxQuantity.
  ///
  /// In en, this message translates to:
  /// **'Max quantity is 100.'**
  String get scwMaxQuantity;

  /// No description provided for @scwMetadataUrl.
  ///
  /// In en, this message translates to:
  /// **'Metadata URL'**
  String get scwMetadataUrl;

  /// No description provided for @scwMinQuantity.
  ///
  /// In en, this message translates to:
  /// **'Min quantity is 1.'**
  String get scwMinQuantity;

  /// No description provided for @scwMintNftCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'Mint multiple Smart Contracts into a collection'**
  String get scwMintNftCollectionBody;

  /// No description provided for @scwMintNftCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mint NFT Collection'**
  String get scwMintNftCollectionTitle;

  /// No description provided for @scwName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get scwName;

  /// No description provided for @scwNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get scwNetwork;

  /// No description provided for @scwNetworkContractAddress.
  ///
  /// In en, this message translates to:
  /// **'{network} Contract Address'**
  String scwNetworkContractAddress(String network);

  /// No description provided for @scwNoProperties.
  ///
  /// In en, this message translates to:
  /// **'No Properties'**
  String get scwNoProperties;

  /// No description provided for @scwNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented.'**
  String get scwNotImplemented;

  /// No description provided for @scwNumericalProperty.
  ///
  /// In en, this message translates to:
  /// **'Numerical Property'**
  String get scwNumericalProperty;

  /// No description provided for @scwOtherOptions.
  ///
  /// In en, this message translates to:
  /// **'Other Options'**
  String get scwOtherOptions;

  /// No description provided for @scwOwnerAddress.
  ///
  /// In en, this message translates to:
  /// **'Owner Address'**
  String get scwOwnerAddress;

  /// No description provided for @scwPairWrapTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair/Wrap with Existing NFT'**
  String get scwPairWrapTitle;

  /// No description provided for @scwPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get scwPercentage;

  /// No description provided for @scwPercentageRequiredForVotingApproval.
  ///
  /// In en, this message translates to:
  /// **'Percentage Required for Voting Approval'**
  String get scwPercentageRequiredForVotingApproval;

  /// No description provided for @scwPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase #{number}: {name}'**
  String scwPhaseLabel(int number, String name);

  /// No description provided for @scwPhysicalDigitalGoodName.
  ///
  /// In en, this message translates to:
  /// **'Physical/Digital Good Name'**
  String get scwPhysicalDigitalGoodName;

  /// No description provided for @scwPrimaryAsset.
  ///
  /// In en, this message translates to:
  /// **'Primary Asset'**
  String get scwPrimaryAsset;

  /// No description provided for @scwProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get scwProperties;

  /// No description provided for @scwPropertiesOptional.
  ///
  /// In en, this message translates to:
  /// **'Properties (Optional)'**
  String get scwPropertiesOptional;

  /// No description provided for @scwPropertyName.
  ///
  /// In en, this message translates to:
  /// **'Property Name'**
  String get scwPropertyName;

  /// No description provided for @scwPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get scwPropertyType;

  /// No description provided for @scwPropertyTypeColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get scwPropertyTypeColor;

  /// No description provided for @scwPropertyTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get scwPropertyTypeNumber;

  /// No description provided for @scwPropertyTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get scwPropertyTypeText;

  /// No description provided for @scwPropertyValue.
  ///
  /// In en, this message translates to:
  /// **'Property Value'**
  String get scwPropertyValue;

  /// No description provided for @scwProvenanceFilesOptional.
  ///
  /// In en, this message translates to:
  /// **'Provenance Files (Optional)'**
  String get scwProvenanceFilesOptional;

  /// No description provided for @scwQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get scwQuantity;

  /// No description provided for @scwQuantityToMint.
  ///
  /// In en, this message translates to:
  /// **'Quantity to Mint'**
  String get scwQuantityToMint;

  /// No description provided for @scwQuantityValue.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {quantity}'**
  String scwQuantityValue(int quantity);

  /// No description provided for @scwReasonForPairingWrapping.
  ///
  /// In en, this message translates to:
  /// **'Reason for Pairing/Wrapping'**
  String get scwReasonForPairingWrapping;

  /// No description provided for @scwRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get scwRemove;

  /// No description provided for @scwRemoveAssetBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this additional asset?'**
  String get scwRemoveAssetBody;

  /// No description provided for @scwRemoveAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Asset?'**
  String get scwRemoveAssetTitle;

  /// No description provided for @scwRemovePhaseBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this evolution phase?'**
  String get scwRemovePhaseBody;

  /// No description provided for @scwRemovePhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Phase?'**
  String get scwRemovePhaseTitle;

  /// No description provided for @scwRemovePropertyBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this property?'**
  String get scwRemovePropertyBody;

  /// No description provided for @scwRemovePropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Property?'**
  String get scwRemovePropertyTitle;

  /// No description provided for @scwRemoveRoyaltyBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the royalty?'**
  String get scwRemoveRoyaltyBody;

  /// No description provided for @scwRemoveRoyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Royalty?'**
  String get scwRemoveRoyaltyTitle;

  /// No description provided for @scwRoyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Royalty'**
  String get scwRoyaltyTitle;

  /// No description provided for @scwRoyaltyToAddress.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {address}'**
  String scwRoyaltyToAddress(String amount, String address);

  /// No description provided for @scwRoyaltyType.
  ///
  /// In en, this message translates to:
  /// **'Royalty Type'**
  String get scwRoyaltyType;

  /// No description provided for @scwRoyaltyTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get scwRoyaltyTypeFixed;

  /// No description provided for @scwRoyaltyTypePercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get scwRoyaltyTypePercent;

  /// No description provided for @scwSeatingInfo.
  ///
  /// In en, this message translates to:
  /// **'Seating Info'**
  String get scwSeatingInfo;

  /// No description provided for @scwSoulBoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Soul Bound'**
  String get scwSoulBoundTitle;

  /// No description provided for @scwStatTypeString.
  ///
  /// In en, this message translates to:
  /// **'Type: String'**
  String get scwStatTypeString;

  /// No description provided for @scwStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get scwStats;

  /// No description provided for @scwTextProperty.
  ///
  /// In en, this message translates to:
  /// **'Text Property'**
  String get scwTextProperty;

  /// No description provided for @scwTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get scwTicketTitle;

  /// No description provided for @scwTicketType.
  ///
  /// In en, this message translates to:
  /// **'Ticket Type'**
  String get scwTicketType;

  /// No description provided for @scwTokenIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Token ID (Optional)'**
  String get scwTokenIdOptional;

  /// No description provided for @scwTokenStandardOptional.
  ///
  /// In en, this message translates to:
  /// **'Token Standard (Optional)'**
  String get scwTokenStandardOptional;

  /// No description provided for @scwTokenizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Tokenization'**
  String get scwTokenizationTitle;

  /// No description provided for @scwUploadCsv.
  ///
  /// In en, this message translates to:
  /// **'Upload CSV'**
  String get scwUploadCsv;

  /// No description provided for @scwUploadJson.
  ///
  /// In en, this message translates to:
  /// **'Upload JSON'**
  String get scwUploadJson;

  /// No description provided for @scwUploadJsonCsv.
  ///
  /// In en, this message translates to:
  /// **'Upload JSON / CSV'**
  String get scwUploadJsonCsv;

  /// No description provided for @scwUploadJsonCsvBody.
  ///
  /// In en, this message translates to:
  /// **'Create a collection with a JSON or CSV file. See the example files below and use them as a template. Upon uploading the file you will be able to configure and tweak the settings through the wizard\'s UI.\n\nThis is an advanced feature for users who want to compile and mint collections outside of the graphical user interface.'**
  String get scwUploadJsonCsvBody;

  /// No description provided for @scwUseMyAddress.
  ///
  /// In en, this message translates to:
  /// **'Use My Address'**
  String get scwUseMyAddress;

  /// No description provided for @scwVotingDescription.
  ///
  /// In en, this message translates to:
  /// **'Voting Description'**
  String get scwVotingDescription;

  /// No description provided for @tkbAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0.0 BTC'**
  String get tkbAmountGreaterThanZero;

  /// No description provided for @tkbAmountOfVbtcTo.
  ///
  /// In en, this message translates to:
  /// **'Amount of vBTC to {action}'**
  String tkbAmountOfVbtcTo(String action);

  /// No description provided for @tkbAssociateLocalFile.
  ///
  /// In en, this message translates to:
  /// **'Associate Local File'**
  String get tkbAssociateLocalFile;

  /// No description provided for @tkbAssociateMedia.
  ///
  /// In en, this message translates to:
  /// **'Associate Media'**
  String get tkbAssociateMedia;

  /// No description provided for @tkbAuthorizeNow.
  ///
  /// In en, this message translates to:
  /// **'Authorize Now'**
  String get tkbAuthorizeNow;

  /// No description provided for @tkbBalanceFoundBody.
  ///
  /// In en, this message translates to:
  /// **'A balance of {balance} VFX was found in this account. Skipping to step 3.'**
  String tkbBalanceFoundBody(String balance);

  /// No description provided for @tkbBalanceValue.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance}'**
  String tkbBalanceValue(String balance);

  /// No description provided for @tkbBlockHeightValue.
  ///
  /// In en, this message translates to:
  /// **'Block Height: {height}'**
  String tkbBlockHeightValue(String height);

  /// No description provided for @tkbBtcAddressGenerated.
  ///
  /// In en, this message translates to:
  /// **'BTC Address generated ({address})'**
  String tkbBtcAddressGenerated(String address);

  /// No description provided for @tkbBtcAddressPending.
  ///
  /// In en, this message translates to:
  /// **'BTC Address Pending'**
  String get tkbBtcAddressPending;

  /// No description provided for @tkbBtcAmount.
  ///
  /// In en, this message translates to:
  /// **'BTC Amount'**
  String get tkbBtcAmount;

  /// No description provided for @tkbBtcSentTo.
  ///
  /// In en, this message translates to:
  /// **'{amount} BTC has been sent to {address}.'**
  String tkbBtcSentTo(String amount, String address);

  /// No description provided for @tkbBtcTransferBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'BTC Transfer TX Broadcasted successfully.'**
  String get tkbBtcTransferBroadcasted;

  /// No description provided for @tkbBtcWithdrawalBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'BTC Withdrawl TX Broadcasted successfully. Hash: {hash}'**
  String tkbBtcWithdrawalBroadcasted(String hash);

  /// No description provided for @tkbCallMedia.
  ///
  /// In en, this message translates to:
  /// **'Call Media'**
  String get tkbCallMedia;

  /// No description provided for @tkbCallMediaFromBeacon.
  ///
  /// In en, this message translates to:
  /// **'Call Media from Beacon'**
  String get tkbCallMediaFromBeacon;

  /// No description provided for @tkbCallToBeaconStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Please be patient while ALL assets associated with the NFT are called and downloaded.\n\nDo not close your wallet or attempt to call again.'**
  String get tkbCallToBeaconStartedBody;

  /// No description provided for @tkbCallToBeaconStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Call to beacon process has started.'**
  String get tkbCallToBeaconStartedTitle;

  /// No description provided for @tkbCallToBeaconStartedToast.
  ///
  /// In en, this message translates to:
  /// **'Call to beacon process has started. Please be patient while ALL assets associated with the NFT are called and downloaded.'**
  String get tkbCallToBeaconStartedToast;

  /// No description provided for @tkbCheckOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'Please check any other account with the same address for the media.'**
  String get tkbCheckOtherAccount;

  /// No description provided for @tkbChooseBtcAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose BTC Account to Send From'**
  String get tkbChooseBtcAccount;

  /// No description provided for @tkbChooseVaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose Vault Account'**
  String get tkbChooseVaultAccount;

  /// No description provided for @tkbComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get tkbComplete;

  /// No description provided for @tkbConfirmSendBtcBody.
  ///
  /// In en, this message translates to:
  /// **'Sending {amount} BTC from {from} to {to}.\n\nFee:\n{fee} BTC'**
  String tkbConfirmSendBtcBody(String amount, String from, String to, String fee);

  /// No description provided for @tkbConfirmTransaction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transaction'**
  String get tkbConfirmTransaction;

  /// No description provided for @tkbConfirmVoteNoBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to vote NO on this token topic?'**
  String get tkbConfirmVoteNoBody;

  /// No description provided for @tkbConfirmVoteYesBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to vote YES on this token topic?'**
  String get tkbConfirmVoteYesBody;

  /// No description provided for @tkbControlledBy.
  ///
  /// In en, this message translates to:
  /// **'Controlled by: {address}'**
  String tkbControlledBy(String address);

  /// No description provided for @tkbCouldNotResolveNft.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve nft from {id}'**
  String tkbCouldNotResolveNft(String id);

  /// No description provided for @tkbCreateBtcDomain.
  ///
  /// In en, this message translates to:
  /// **'Create BTC Domain'**
  String get tkbCreateBtcDomain;

  /// No description provided for @tkbCreateDomainFor.
  ///
  /// In en, this message translates to:
  /// **'Create Domain for {address}'**
  String tkbCreateDomainFor(String address);

  /// No description provided for @tkbCreateTokenTopicBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to create this token topic?'**
  String get tkbCreateTokenTopicBody;

  /// No description provided for @tkbCreationPending.
  ///
  /// In en, this message translates to:
  /// **'Creation Pending'**
  String get tkbCreationPending;

  /// No description provided for @tkbDeleteBtcDomainBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this BTC Domain?\n{costLine}\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.'**
  String tkbDeleteBtcDomainBody(String costLine);

  /// No description provided for @tkbDeleteDomainNoCost.
  ///
  /// In en, this message translates to:
  /// **'There is no cost to delete and VFX Domain (aside from the TX fee).'**
  String get tkbDeleteDomainNoCost;

  /// No description provided for @tkbDeleteDomainWithCost.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to delete an RBX Domain.'**
  String tkbDeleteDomainWithCost(String cost);

  /// No description provided for @tkbDeletePending.
  ///
  /// In en, this message translates to:
  /// **'Delete Pending'**
  String get tkbDeletePending;

  /// No description provided for @tkbDescriptionColon.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get tkbDescriptionColon;

  /// No description provided for @tkbDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get tkbDismiss;

  /// No description provided for @tkbDomainName.
  ///
  /// In en, this message translates to:
  /// **'Domain Name'**
  String get tkbDomainName;

  /// No description provided for @tkbDomainNameRule.
  ///
  /// In en, this message translates to:
  /// **'Your domain must only contain letters and numbers and will automatically be appended with \".btc\" upon verification'**
  String get tkbDomainNameRule;

  /// No description provided for @tkbDownloadAsset.
  ///
  /// In en, this message translates to:
  /// **'Download Asset'**
  String get tkbDownloadAsset;

  /// No description provided for @tkbError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get tkbError;

  /// No description provided for @tkbErrorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Data'**
  String get tkbErrorLoadingData;

  /// No description provided for @tkbFailedRequestWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Failed to request withdrawal.'**
  String get tkbFailedRequestWithdrawal;

  /// No description provided for @tkbFeeEstimate.
  ///
  /// In en, this message translates to:
  /// **'Fee Estimate: ~{feeEstimate} SATS | ~{feeEstimateBtc} BTC    ({fee} SATS /byte | {feeBtc} BTC /byte)'**
  String tkbFeeEstimate(String feeEstimate, String feeEstimateBtc, String fee, String feeBtc);

  /// No description provided for @tkbFeeRateHint.
  ///
  /// In en, this message translates to:
  /// **'Fee rate in satoshis'**
  String get tkbFeeRateHint;

  /// No description provided for @tkbFeeRatePerByte.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate: {sats} SATS per byte ({btc} BTC per byte)'**
  String tkbFeeRatePerByte(String sats, String btc);

  /// No description provided for @tkbFeeRateRequired.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate Required'**
  String get tkbFeeRateRequired;

  /// No description provided for @tkbFileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'File Name: {name}'**
  String tkbFileNameLabel(String name);

  /// No description provided for @tkbFileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get tkbFileSize;

  /// No description provided for @tkbFileType.
  ///
  /// In en, this message translates to:
  /// **'File Type'**
  String get tkbFileType;

  /// No description provided for @tkbFilenameCreator.
  ///
  /// In en, this message translates to:
  /// **'Filename: {filename} | Creator: {creator}'**
  String tkbFilenameCreator(String filename, String creator);

  /// No description provided for @tkbFixedSupply.
  ///
  /// In en, this message translates to:
  /// **'Fixed Supply'**
  String get tkbFixedSupply;

  /// No description provided for @tkbFungibleToken.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token'**
  String get tkbFungibleToken;

  /// No description provided for @tkbGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get tkbGenerate;

  /// No description provided for @tkbGenerateBtcAddress.
  ///
  /// In en, this message translates to:
  /// **'Generate BTC Address'**
  String get tkbGenerateBtcAddress;

  /// No description provided for @tkbGenerateBtcAddressBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to generate this token\'\'s BTC address?'**
  String get tkbGenerateBtcAddressBody;

  /// No description provided for @tkbImagePreviewNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found for preview.\nLikely this means this NFT no longer exists on this machine.\n'**
  String get tkbImagePreviewNotFound;

  /// No description provided for @tkbInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get tkbInProgress;

  /// No description provided for @tkbInfinite.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get tkbInfinite;

  /// No description provided for @tkbInsufficientBalanceAccount.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance to cover tx and fee. This account only has {balance} BTC.'**
  String tkbInsufficientBalanceAccount(String balance);

  /// No description provided for @tkbInvalidFeeRate.
  ///
  /// In en, this message translates to:
  /// **'Invalid Fee Rate. Must be atleast 1 satoshi.'**
  String get tkbInvalidFeeRate;

  /// No description provided for @tkbManualSendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send coin manually to this token\'\'s BTC deposit address'**
  String get tkbManualSendSubtitle;

  /// No description provided for @tkbMediaNotFound.
  ///
  /// In en, this message translates to:
  /// **'Media asset file not found on your machine ({fileName}).'**
  String tkbMediaNotFound(String fileName);

  /// No description provided for @tkbMinimumTokenRequirement.
  ///
  /// In en, this message translates to:
  /// **'Minimum Token Requirement'**
  String get tkbMinimumTokenRequirement;

  /// No description provided for @tkbMinimumTokenRequirementHelper.
  ///
  /// In en, this message translates to:
  /// **'The minimum token balance required to vote.'**
  String get tkbMinimumTokenRequirementHelper;

  /// No description provided for @tkbMinimumTokensToVote.
  ///
  /// In en, this message translates to:
  /// **'Minimum Tokens to Vote: {count}'**
  String tkbMinimumTokensToVote(String count);

  /// No description provided for @tkbMultiSigFeeCalculated.
  ///
  /// In en, this message translates to:
  /// **'This is a Multi-signature. The fee rate has been calculated for you.'**
  String get tkbMultiSigFeeCalculated;

  /// No description provided for @tkbNeedTokensToVote.
  ///
  /// In en, this message translates to:
  /// **'You need at least {count} tokens to vote.'**
  String tkbNeedTokensToVote(String count);

  /// No description provided for @tkbNoAddressesHolding.
  ///
  /// In en, this message translates to:
  /// **'None of your addresses are holding {ticker}'**
  String tkbNoAddressesHolding(String ticker);

  /// No description provided for @tkbNoFungibleTokens.
  ///
  /// In en, this message translates to:
  /// **'No Fungible Tokens'**
  String get tkbNoFungibleTokens;

  /// No description provided for @tkbNoFungibleTokensBody.
  ///
  /// In en, this message translates to:
  /// **'You have no fungible tokens with supply in any of your accounts.'**
  String get tkbNoFungibleTokensBody;

  /// No description provided for @tkbNoRequestHash.
  ///
  /// In en, this message translates to:
  /// **'No request hash returned.'**
  String get tkbNoRequestHash;

  /// No description provided for @tkbNoUpper.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get tkbNoUpper;

  /// No description provided for @tkbNoUtxos.
  ///
  /// In en, this message translates to:
  /// **'No UTXOs'**
  String get tkbNoUtxos;

  /// No description provided for @tkbNoVaultAccounts.
  ///
  /// In en, this message translates to:
  /// **'You don\'\'t have any Vault Accounts in this wallet'**
  String get tkbNoVaultAccounts;

  /// No description provided for @tkbNoVotesYet.
  ///
  /// In en, this message translates to:
  /// **'No votes yet.'**
  String get tkbNoVotesYet;

  /// No description provided for @tkbNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get tkbNone;

  /// No description provided for @tkbNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not Found.'**
  String get tkbNotFound;

  /// No description provided for @tkbOpenAsset.
  ///
  /// In en, this message translates to:
  /// **'Open Asset'**
  String get tkbOpenAsset;

  /// No description provided for @tkbOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get tkbOpenFolder;

  /// No description provided for @tkbOwnershipTransferInitiated.
  ///
  /// In en, this message translates to:
  /// **'Ownership transfer initiated.'**
  String get tkbOwnershipTransferInitiated;

  /// No description provided for @tkbPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get tkbPassword;

  /// No description provided for @tkbPendingWithdrawalBody.
  ///
  /// In en, this message translates to:
  /// **'You have a pending withdrawal of {amount} vBTC to {destination}.\n\nWould you like to complete it?'**
  String tkbPendingWithdrawalBody(String amount, String destination);

  /// No description provided for @tkbPendingWithdrawalContractBody.
  ///
  /// In en, this message translates to:
  /// **'You have a pending withdrawal for this contract. Would you like to complete it?'**
  String get tkbPendingWithdrawalContractBody;

  /// No description provided for @tkbPendingWithdrawalFound.
  ///
  /// In en, this message translates to:
  /// **'Pending Withdrawal Found'**
  String get tkbPendingWithdrawalFound;

  /// No description provided for @tkbPercentages.
  ///
  /// In en, this message translates to:
  /// **'Percentages'**
  String get tkbPercentages;

  /// No description provided for @tkbResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get tkbResult;

  /// No description provided for @tkbResultFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get tkbResultFail;

  /// No description provided for @tkbResultPass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get tkbResultPass;

  /// No description provided for @tkbSelectVfxAddress.
  ///
  /// In en, this message translates to:
  /// **'Select VFX Address'**
  String get tkbSelectVfxAddress;

  /// No description provided for @tkbSelectedAddress.
  ///
  /// In en, this message translates to:
  /// **'Selected Address:'**
  String get tkbSelectedAddress;

  /// No description provided for @tkbSendAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Send Automatically'**
  String get tkbSendAutomatically;

  /// No description provided for @tkbSendFundsTo.
  ///
  /// In en, this message translates to:
  /// **'Send funds to {address} (address copied to clipboard)'**
  String tkbSendFundsTo(String address);

  /// No description provided for @tkbSendManually.
  ///
  /// In en, this message translates to:
  /// **'Send Manually'**
  String get tkbSendManually;

  /// No description provided for @tkbSmartContractUidWithValue.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract UID: {uid}'**
  String tkbSmartContractUidWithValue(String uid);

  /// No description provided for @tkbToBtcAddress.
  ///
  /// In en, this message translates to:
  /// **'To BTC Address'**
  String get tkbToBtcAddress;

  /// No description provided for @tkbToVfxAddress.
  ///
  /// In en, this message translates to:
  /// **'To VFX Address'**
  String get tkbToVfxAddress;

  /// No description provided for @tkbTokenBalances.
  ///
  /// In en, this message translates to:
  /// **'Token Balances'**
  String get tkbTokenBalances;

  /// No description provided for @tkbTokenDetails.
  ///
  /// In en, this message translates to:
  /// **'Token Details'**
  String get tkbTokenDetails;

  /// No description provided for @tkbTokenTopicCreated.
  ///
  /// In en, this message translates to:
  /// **'Token Topic Created'**
  String get tkbTokenTopicCreated;

  /// No description provided for @tkbTopicUidLabel.
  ///
  /// In en, this message translates to:
  /// **'UID: {uid}'**
  String tkbTopicUidLabel(String uid);

  /// No description provided for @tkbTotalVotes.
  ///
  /// In en, this message translates to:
  /// **'Total Votes'**
  String get tkbTotalVotes;

  /// No description provided for @tkbTransactionBroadcastedBang.
  ///
  /// In en, this message translates to:
  /// **'Transaction Broadcasted!'**
  String get tkbTransactionBroadcastedBang;

  /// No description provided for @tkbTransactionHash.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get tkbTransactionHash;

  /// No description provided for @tkbTransactionHashCopied.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash copied to clipboard'**
  String get tkbTransactionHashCopied;

  /// No description provided for @tkbTransferBtc.
  ///
  /// In en, this message translates to:
  /// **'Transfer BTC'**
  String get tkbTransferBtc;

  /// No description provided for @tkbTransferDomainFrom.
  ///
  /// In en, this message translates to:
  /// **'Transfer Domain from {address}'**
  String tkbTransferDomainFrom(String address);

  /// No description provided for @tkbTransferOwnershipBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to transfer ownership of this vBTC token to {address}?'**
  String tkbTransferOwnershipBody(String address);

  /// No description provided for @tkbTransferOwnershipToReserve.
  ///
  /// In en, this message translates to:
  /// **'Transfer Ownership To Reserve/Protected Account'**
  String get tkbTransferOwnershipToReserve;

  /// No description provided for @tkbTransferOwnershipToReserveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer the ownership of this token to your reserve/protected account.'**
  String get tkbTransferOwnershipToReserveSubtitle;

  /// No description provided for @tkbTransferPending.
  ///
  /// In en, this message translates to:
  /// **'Transfer Pending'**
  String get tkbTransferPending;

  /// No description provided for @tkbTransferToken.
  ///
  /// In en, this message translates to:
  /// **'Transfer Token'**
  String get tkbTransferToken;

  /// No description provided for @tkbTransferTokenOwnership.
  ///
  /// In en, this message translates to:
  /// **'Transfer Token Ownership'**
  String get tkbTransferTokenOwnership;

  /// No description provided for @tkbTransferTokenOwnershipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer the ownership of this token to another VFX account.'**
  String get tkbTransferTokenOwnershipSubtitle;

  /// No description provided for @tkbTransferVbtc.
  ///
  /// In en, this message translates to:
  /// **'Transfer vBTC'**
  String get tkbTransferVbtc;

  /// No description provided for @tkbTransferVbtcBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to transfer {amount} vBTC to {address}?'**
  String tkbTransferVbtcBody(String amount, String address);

  /// No description provided for @tkbTransferVbtcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer a specific portion of the vBTC within the token to another VFX address.'**
  String get tkbTransferVbtcSubtitle;

  /// No description provided for @tkbTxBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'TX broadcasted!'**
  String get tkbTxBroadcasted;

  /// No description provided for @tkbUtxoAddress.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String tkbUtxoAddress(String address);

  /// No description provided for @tkbUtxoDetails.
  ///
  /// In en, this message translates to:
  /// **'TX ID: {txId}\nAmount:{amount}'**
  String tkbUtxoDetails(String txId, String amount);

  /// No description provided for @tkbUtxoUnused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get tkbUtxoUnused;

  /// No description provided for @tkbUtxoUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get tkbUtxoUsed;

  /// No description provided for @tkbVaultAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Vault Account Password'**
  String get tkbVaultAccountPassword;

  /// No description provided for @tkbVaultAuthorizeDownload.
  ///
  /// In en, this message translates to:
  /// **'Since this is a Vault Account you\'\'ll need to authorize the download.'**
  String get tkbVaultAuthorizeDownload;

  /// No description provided for @tkbVaultCannotWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts can not withdrawl. Please transfer vBTC to a standard VFX address'**
  String get tkbVaultCannotWithdraw;

  /// No description provided for @tkbVaultOwnedCannotAction.
  ///
  /// In en, this message translates to:
  /// **'Vault Account owned tokens can not perform this action.'**
  String get tkbVaultOwnedCannotAction;

  /// No description provided for @tkbVbtcTransferBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'vBTC V2 Transfer TX Broadcasted. Hash: {hash}'**
  String tkbVbtcTransferBroadcasted(String hash);

  /// No description provided for @tkbVbtcZeroBalance.
  ///
  /// In en, this message translates to:
  /// **'vBTC tokens with zero balance can not be transferred.'**
  String get tkbVbtcZeroBalance;

  /// No description provided for @tkbVfxWalletRequired.
  ///
  /// In en, this message translates to:
  /// **'An VFX wallet is required for this functionality.'**
  String get tkbVfxWalletRequired;

  /// No description provided for @tkbVoteCounts.
  ///
  /// In en, this message translates to:
  /// **'Vote Counts'**
  String get tkbVoteCounts;

  /// No description provided for @tkbVotedOnBlock.
  ///
  /// In en, this message translates to:
  /// **'You voted {label} on block {block}.'**
  String tkbVotedOnBlock(String label, String block);

  /// No description provided for @tkbVotesNo.
  ///
  /// In en, this message translates to:
  /// **'Votes No'**
  String get tkbVotesNo;

  /// No description provided for @tkbVotesYes.
  ///
  /// In en, this message translates to:
  /// **'Votes Yes'**
  String get tkbVotesYes;

  /// No description provided for @tkbWalletControlsDomain.
  ///
  /// In en, this message translates to:
  /// **'This wallet will control transfer/delete ownership over this new domain.'**
  String get tkbWalletControlsDomain;

  /// No description provided for @tkbWithdrawBtc.
  ///
  /// In en, this message translates to:
  /// **'Withdraw BTC'**
  String get tkbWithdrawBtc;

  /// No description provided for @tkbWithdrawBtcBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw {amount} BTC to {address}?'**
  String tkbWithdrawBtcBody(String amount, String address);

  /// No description provided for @tkbYesUpper.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get tkbYesUpper;

  /// No description provided for @tkbYouHaveVoted.
  ///
  /// In en, this message translates to:
  /// **'You have voted.'**
  String get tkbYouHaveVoted;

  /// No description provided for @tkbYourBalanceValue.
  ///
  /// In en, this message translates to:
  /// **'Your Balance: {balance}'**
  String tkbYourBalanceValue(String balance);

  /// No description provided for @tkbYourBalanceVbtc.
  ///
  /// In en, this message translates to:
  /// **'Your Balance: {balance} vBTC{usd}'**
  String tkbYourBalanceVbtc(String balance, String usd);

  /// No description provided for @txpAccountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get txpAccountBalance;

  /// No description provided for @txpAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get txpAccountCreated;

  /// No description provided for @txpActivateOnNetwork.
  ///
  /// In en, this message translates to:
  /// **'Activate on Network?'**
  String get txpActivateOnNetwork;

  /// No description provided for @txpActivateOnNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of 4 VFX (which is burned) plus TX fee to activate this Vault Account on the network.  Continue?'**
  String get txpActivateOnNetworkBody;

  /// No description provided for @txpAddBtcAccount.
  ///
  /// In en, this message translates to:
  /// **'Add BTC Account'**
  String get txpAddBtcAccount;

  /// No description provided for @txpAddNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get txpAddNewAccount;

  /// No description provided for @txpAddVfxAccount.
  ///
  /// In en, this message translates to:
  /// **'Add VFX Account'**
  String get txpAddVfxAccount;

  /// No description provided for @txpAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get txpAddressCopied;

  /// No description provided for @txpAddressCopiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard.'**
  String get txpAddressCopiedClipboard;

  /// No description provided for @txpAllAddresses.
  ///
  /// In en, this message translates to:
  /// **'All Addresses'**
  String get txpAllAddresses;

  /// No description provided for @txpAmountCopied.
  ///
  /// In en, this message translates to:
  /// **'Amount copied'**
  String get txpAmountCopied;

  /// No description provided for @txpAutoActivate.
  ///
  /// In en, this message translates to:
  /// **'Auto Activate?'**
  String get txpAutoActivate;

  /// No description provided for @txpAutoActivateBody.
  ///
  /// In en, this message translates to:
  /// **'Would you like to automatically activate this account once the funds are received?'**
  String get txpAutoActivateBody;

  /// No description provided for @txpAutoActivateQueued.
  ///
  /// In en, this message translates to:
  /// **'Auto activate queued.'**
  String get txpAutoActivateQueued;

  /// No description provided for @txpBlockDiffAvg.
  ///
  /// In en, this message translates to:
  /// **'Block Diff Avg: {value}'**
  String txpBlockDiffAvg(String value);

  /// No description provided for @txpBlockLastDelay.
  ///
  /// In en, this message translates to:
  /// **'Block Last Delay: {value}'**
  String txpBlockLastDelay(String value);

  /// No description provided for @txpBlockLastReceived.
  ///
  /// In en, this message translates to:
  /// **'Block Last Received: {value}'**
  String txpBlockLastReceived(String value);

  /// No description provided for @txpBlockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block Number'**
  String get txpBlockNumber;

  /// No description provided for @txpBlocksAveraged.
  ///
  /// In en, this message translates to:
  /// **'Blocks Averaged: {value}'**
  String txpBlocksAveraged(String value);

  /// No description provided for @txpBtcNoBalance.
  ///
  /// In en, this message translates to:
  /// **'BTC account has no balance'**
  String get txpBtcNoBalance;

  /// No description provided for @txpChooseCoinType.
  ///
  /// In en, this message translates to:
  /// **'Choose Coin Type'**
  String get txpChooseCoinType;

  /// No description provided for @txpChoosePaymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Gateway'**
  String get txpChoosePaymentGateway;

  /// No description provided for @txpClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get txpClearFilters;

  /// No description provided for @txpCompleteMoonpayDeposit.
  ///
  /// In en, this message translates to:
  /// **'Complete MoonPay Deposit'**
  String get txpCompleteMoonpayDeposit;

  /// No description provided for @txpCompleteSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get txpCompleteSale;

  /// No description provided for @txpCompleteSaleConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to complete the sale of {scId} for {amount} VFX?'**
  String txpCompleteSaleConfirmBody(String scId, String amount);

  /// No description provided for @txpConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get txpConfirmPassword;

  /// No description provided for @txpConfirmPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get txpConfirmPasswordBody;

  /// No description provided for @txpConfirmSend.
  ///
  /// In en, this message translates to:
  /// **'Confirm Send'**
  String get txpConfirmSend;

  /// No description provided for @txpConfirmSendBody.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} {currency}\nTo: {toAddress}\nFrom: {fromAddress}\nFee Rate: {feeRate} sats/vB'**
  String txpConfirmSendBody(String amount, String currency, String toAddress, String fromAddress, String feeRate);

  /// No description provided for @txpCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get txpCopyAddress;

  /// No description provided for @txpCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get txpCreate;

  /// No description provided for @txpCreateBtcAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Create a new BTC account'**
  String get txpCreateBtcAccountSub;

  /// No description provided for @txpCreateVfxAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Create a new VFX account'**
  String get txpCreateVfxAccountSub;

  /// No description provided for @txpCryptoDotComOnRamp.
  ///
  /// In en, this message translates to:
  /// **'Crypto.com On-Ramp'**
  String get txpCryptoDotComOnRamp;

  /// No description provided for @txpData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get txpData;

  /// No description provided for @txpDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txpDate;

  /// No description provided for @txpDepositAddressMoonpay.
  ///
  /// In en, this message translates to:
  /// **'Deposit Address (MoonPay)'**
  String get txpDepositAddressMoonpay;

  /// No description provided for @txpDisclaimerAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get txpDisclaimerAnd;

  /// No description provided for @txpDisclaimerIntro.
  ///
  /// In en, this message translates to:
  /// **'I understand that I will now be purchasing VFX or BTC native coin directly through {gateway} ('**
  String txpDisclaimerIntro(String gateway);

  /// No description provided for @txpDisclaimerMiddle.
  ///
  /// In en, this message translates to:
  /// **'), which is a third-party services platform. By proceeding and procuring services from {gateway}, you acknowledge that you have read and agreed to {gateway}’s '**
  String txpDisclaimerMiddle(String gateway);

  /// No description provided for @txpDisclaimerOutro.
  ///
  /// In en, this message translates to:
  /// **'. You additionally understand that the VerifiedX VFX Network is an autonomous and decentralized ecosystem and does not share in any fees whatsoever by you utilizing {gateway}’s services and does not take any responsibility for any issues that may affect your transaction with any third-party service provider at anytime. For any questions related to {gateway}’s services, please contact {gateway} at '**
  String txpDisclaimerOutro(String gateway);

  /// No description provided for @txpErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get txpErrorOccurred;

  /// No description provided for @txpFundAccount.
  ///
  /// In en, this message translates to:
  /// **'Fund Account'**
  String get txpFundAccount;

  /// No description provided for @txpFundVaultBody.
  ///
  /// In en, this message translates to:
  /// **'You must now fund your Vault Account with a minimum of 5 VFX. 4 VFX will be burned upon activation.'**
  String get txpFundVaultBody;

  /// No description provided for @txpFundVaultBodyShort.
  ///
  /// In en, this message translates to:
  /// **'You must now fund your Vault Account with a minimum of 5 VFX.'**
  String get txpFundVaultBodyShort;

  /// No description provided for @txpFundsSent.
  ///
  /// In en, this message translates to:
  /// **'Funds Sent'**
  String get txpFundsSent;

  /// No description provided for @txpFundsSentBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX has been sent to {address}.\n\nPlease wait for transaction to reflect and then activate your Vault Account.'**
  String txpFundsSentBody(String amount, String address);

  /// No description provided for @txpGetBtcNow.
  ///
  /// In en, this message translates to:
  /// **'Get \$BTC Now'**
  String get txpGetBtcNow;

  /// No description provided for @txpGetQuote.
  ///
  /// In en, this message translates to:
  /// **'Get Quote'**
  String get txpGetQuote;

  /// No description provided for @txpGetVfxNow.
  ///
  /// In en, this message translates to:
  /// **'Get \$VFX Now'**
  String get txpGetVfxNow;

  /// No description provided for @txpImportBtcKeySub.
  ///
  /// In en, this message translates to:
  /// **'Import an existing BTC private key'**
  String get txpImportBtcKeySub;

  /// No description provided for @txpImportVfxKeySub.
  ///
  /// In en, this message translates to:
  /// **'Import an existing VFX private key'**
  String get txpImportVfxKeySub;

  /// No description provided for @txpManualDeposit.
  ///
  /// In en, this message translates to:
  /// **'Manual Deposit'**
  String get txpManualDeposit;

  /// No description provided for @txpManualDepositBody.
  ///
  /// In en, this message translates to:
  /// **'You can send this from another wallet by sending the exact amount ({amount} {currency}) to the deposit address above.'**
  String txpManualDepositBody(String amount, String currency);

  /// No description provided for @txpMeMarker.
  ///
  /// In en, this message translates to:
  /// **'[ME]'**
  String get txpMeMarker;

  /// No description provided for @txpMinBalanceActivate.
  ///
  /// In en, this message translates to:
  /// **'A minimum balance of 5 VFX is required to activate.'**
  String get txpMinBalanceActivate;

  /// No description provided for @txpMoonpayManualMarked.
  ///
  /// In en, this message translates to:
  /// **'MoonPay transaction marked as manual deposit'**
  String get txpMoonpayManualMarked;

  /// No description provided for @txpMustConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'You must confirm your password.'**
  String get txpMustConfirmPassword;

  /// No description provided for @txpNativeMoonpaySoon.
  ///
  /// In en, this message translates to:
  /// **'Native Moonpay Integration Activating Soon.'**
  String get txpNativeMoonpaySoon;

  /// No description provided for @txpNoAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found'**
  String get txpNoAccountFound;

  /// No description provided for @txpNoAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'No address selected'**
  String get txpNoAddressSelected;

  /// No description provided for @txpNonce.
  ///
  /// In en, this message translates to:
  /// **'Nonce'**
  String get txpNonce;

  /// No description provided for @txpNotAvailableOnPlatform.
  ///
  /// In en, this message translates to:
  /// **'Not available on this platform'**
  String get txpNotAvailableOnPlatform;

  /// No description provided for @txpNotEnoughBtcFee.
  ///
  /// In en, this message translates to:
  /// **'Not enough BTC to cover transaction + fee'**
  String get txpNotEnoughBtcFee;

  /// No description provided for @txpNotVaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Not a Vault Account'**
  String get txpNotVaultAccount;

  /// No description provided for @txpOffRampInstructions.
  ///
  /// In en, this message translates to:
  /// **'To complete this off-ramp, send the exact BTC amount to the deposit address below:'**
  String get txpOffRampInstructions;

  /// No description provided for @txpOriginalTx.
  ///
  /// In en, this message translates to:
  /// **'Original TX'**
  String get txpOriginalTx;

  /// No description provided for @txpPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get txpPasswordsDoNotMatch;

  /// No description provided for @txpPleaseSendFundsTo.
  ///
  /// In en, this message translates to:
  /// **'Please send funds to {address}'**
  String txpPleaseSendFundsTo(String address);

  /// No description provided for @txpPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get txpPrivacyPolicy;

  /// No description provided for @txpRestoreCodeRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Paste in your RESTORE CODE to import the recovery account for this Vault Account.'**
  String get txpRestoreCodeRecoveryBody;

  /// No description provided for @txpScanAndPay.
  ///
  /// In en, this message translates to:
  /// **'Scan & Pay'**
  String get txpScanAndPay;

  /// No description provided for @txpSendManually.
  ///
  /// In en, this message translates to:
  /// **'I have/will send manually'**
  String get txpSendManually;

  /// No description provided for @txpSendNow.
  ///
  /// In en, this message translates to:
  /// **'Send Now'**
  String get txpSendNow;

  /// No description provided for @txpSendingConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Sending:\n{amount} VFX\n\nTo:\n{toAddress}\n\nFrom:\n{fromAddress}'**
  String txpSendingConfirmBody(String amount, String toAddress, String fromAddress);

  /// No description provided for @txpSentToAddress.
  ///
  /// In en, this message translates to:
  /// **'{amount} {currency} sent to {address}'**
  String txpSentToAddress(String amount, String currency, String address);

  /// No description provided for @txpSetupBtcAccount.
  ///
  /// In en, this message translates to:
  /// **'Setup a Bitcoin account'**
  String get txpSetupBtcAccount;

  /// No description provided for @txpSetupVaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Setup Vault Account'**
  String get txpSetupVaultAccount;

  /// No description provided for @txpSetupVaultAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Create a password to continue. You must remember this password as it will be required for any transaction with this Vault Account.'**
  String get txpSetupVaultAccountBody;

  /// No description provided for @txpSetupVfxAccount.
  ///
  /// In en, this message translates to:
  /// **'Setup a VerifiedX account'**
  String get txpSetupVfxAccount;

  /// No description provided for @txpStatusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String txpStatusWithValue(String value);

  /// No description provided for @txpStripeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Stripe (Credit Card)'**
  String get txpStripeCreditCard;

  /// No description provided for @txpSufficientBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'You have an account with a sufficient balance.\n\nWould you like to send 5 VFX from:\n{address}\n[Balance: {balance} VFX]?'**
  String txpSufficientBalanceBody(String address, String balance);

  /// No description provided for @txpTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get txpTermsOfUse;

  /// No description provided for @txpTestnetFaucet.
  ///
  /// In en, this message translates to:
  /// **'Testnet Faucet'**
  String get txpTestnetFaucet;

  /// No description provided for @txpTestnetFaucetNoTerms.
  ///
  /// In en, this message translates to:
  /// **'Testnet Faucet does not have any terms. Have fun!'**
  String get txpTestnetFaucetNoTerms;

  /// No description provided for @txpTileAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount: '**
  String get txpTileAmountLabel;

  /// No description provided for @txpTileDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String txpTileDateLabel(String date);

  /// No description provided for @txpTileHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Hash: {hash}'**
  String txpTileHashLabel(String hash);

  /// No description provided for @txpTileSettlementDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Settlement Date: {date}'**
  String txpTileSettlementDateLabel(String date);

  /// No description provided for @txpTileStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get txpTileStatusLabel;

  /// No description provided for @txpTileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: '**
  String get txpTileTypeLabel;

  /// No description provided for @txpTileViewData.
  ///
  /// In en, this message translates to:
  /// **'View Data'**
  String get txpTileViewData;

  /// No description provided for @txpTimeSinceLastBlock.
  ///
  /// In en, this message translates to:
  /// **'Time Since Last Block: {value}s'**
  String txpTimeSinceLastBlock(String value);

  /// No description provided for @txpTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction failed'**
  String get txpTransactionFailed;

  /// No description provided for @txpTransactionHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get txpTransactionHashLabel;

  /// No description provided for @txpTransactionSent.
  ///
  /// In en, this message translates to:
  /// **'Transaction Sent'**
  String get txpTransactionSent;

  /// No description provided for @txpTxDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Detail'**
  String get txpTxDetailTitle;

  /// No description provided for @txpTxFilters.
  ///
  /// In en, this message translates to:
  /// **'Transaction Filters'**
  String get txpTxFilters;

  /// No description provided for @txpTxHash.
  ///
  /// In en, this message translates to:
  /// **'Tx Hash'**
  String get txpTxHash;

  /// No description provided for @txpTxHashCopied.
  ///
  /// In en, this message translates to:
  /// **'Tx hash copied'**
  String get txpTxHashCopied;

  /// No description provided for @txpTxType.
  ///
  /// In en, this message translates to:
  /// **'Tx Type'**
  String get txpTxType;

  /// No description provided for @txpTxTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tx Type{suffix}:'**
  String txpTxTypeLabel(String suffix);

  /// No description provided for @txpValueCopied.
  ///
  /// In en, this message translates to:
  /// **'\'{value}\' Copied to clipboard'**
  String txpValueCopied(String value);

  /// No description provided for @txpVaultActivationSent.
  ///
  /// In en, this message translates to:
  /// **'Vault Account activation transaction sent.\n\nPlease wait for it to reflect as \"Activated\".'**
  String get txpVaultActivationSent;

  /// No description provided for @txpVfxAmount.
  ///
  /// In en, this message translates to:
  /// **'VFX Amount'**
  String get txpVfxAmount;

  /// No description provided for @txpVfxOffRampSoon.
  ///
  /// In en, this message translates to:
  /// **'VFX Off Ramp feature coming soon'**
  String get txpVfxOffRampSoon;

  /// No description provided for @txpVfxQuote.
  ///
  /// In en, this message translates to:
  /// **'VFX Quote'**
  String get txpVfxQuote;

  /// No description provided for @txpVfxQuoteBody.
  ///
  /// In en, this message translates to:
  /// **'{amountVfx} VFX for \${amountUsd} USD\nWould you like to continue?'**
  String txpVfxQuoteBody(String amountVfx, String amountUsd);

  /// No description provided for @txpWalletDetailsBackup.
  ///
  /// In en, this message translates to:
  /// **'Here are your wallet details. Please ensure to back up your private key in a safe place.'**
  String get txpWalletDetailsBackup;

  /// No description provided for @txpWalletVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'VFX Wallet{envTag}\nVersion {version} ({nickname})'**
  String txpWalletVersionInfo(String envTag, String version, String nickname);

  /// No description provided for @tkbHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Hash: {hash}'**
  String tkbHashLabel(String hash);

  /// No description provided for @tkbBulkTransferUnavailableWeb.
  ///
  /// In en, this message translates to:
  /// **'Bulk transfer is not yet available on the web wallet.'**
  String get tkbBulkTransferUnavailableWeb;

  /// No description provided for @tkbCreateVbtcToken.
  ///
  /// In en, this message translates to:
  /// **'Create vBTC Token'**
  String get tkbCreateVbtcToken;

  /// No description provided for @hnavSnapshotDownloadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading: {file} ({done}/{total})'**
  String hnavSnapshotDownloadingProgress(String file, int done, int total);

  /// No description provided for @tkbFundToken.
  ///
  /// In en, this message translates to:
  /// **'Fund Token'**
  String get tkbFundToken;

  /// No description provided for @tkbManualSendExchangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send BTC from any exchange or wallet to this token\'s deposit address'**
  String get tkbManualSendExchangeSubtitle;

  /// No description provided for @bw2AmountOfBtcToSend.
  ///
  /// In en, this message translates to:
  /// **'Amount of BTC to Send'**
  String get bw2AmountOfBtcToSend;

  /// No description provided for @bw2AnErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get bw2AnErrorOccurred;

  /// No description provided for @bw2BeaconUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Beacon upload failed'**
  String get bw2BeaconUploadFailed;

  /// No description provided for @bw2BlockConfirmTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Timed out waiting for block confirmation. You can retry later from the token detail screen.'**
  String get bw2BlockConfirmTimedOut;

  /// No description provided for @bw2BlockWithValue.
  ///
  /// In en, this message translates to:
  /// **'Block {height}'**
  String bw2BlockWithValue(String height);

  /// No description provided for @bw2BridgeToBase.
  ///
  /// In en, this message translates to:
  /// **'Bridge to Base'**
  String get bw2BridgeToBase;

  /// No description provided for @bw2BridgeVbtcToBase.
  ///
  /// In en, this message translates to:
  /// **'Bridge vBTC to Base (vBTC.b)'**
  String get bw2BridgeVbtcToBase;

  /// No description provided for @bw2BroadcastingRequest.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting Request'**
  String get bw2BroadcastingRequest;

  /// No description provided for @bw2BroadcastingWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting withdrawal request...'**
  String get bw2BroadcastingWithdrawal;

  /// No description provided for @bw2BtcAccountNoBalance.
  ///
  /// In en, this message translates to:
  /// **'This BTC account doesn\'t have a balance'**
  String get bw2BtcAccountNoBalance;

  /// No description provided for @bw2BtcAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'BTC Address'**
  String get bw2BtcAddressTitle;

  /// No description provided for @bw2BtcAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} BTC'**
  String bw2BtcAmount(String amount);

  /// No description provided for @bw2BtcFundsReceived.
  ///
  /// In en, this message translates to:
  /// **'BTC Funds Received!'**
  String get bw2BtcFundsReceived;

  /// No description provided for @bw2BtcTransactionLabel.
  ///
  /// In en, this message translates to:
  /// **'BTC Transaction:'**
  String get bw2BtcTransactionLabel;

  /// No description provided for @bw2BuyBtcOnRamp.
  ///
  /// In en, this message translates to:
  /// **'Buy BTC (On-Ramp)'**
  String get bw2BuyBtcOnRamp;

  /// No description provided for @bw2BuyBtcOnRampSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase BTC with fiat and send directly to this token'**
  String get bw2BuyBtcOnRampSubtitle;

  /// No description provided for @bw2CancelWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Cancel Withdrawal'**
  String get bw2CancelWithdrawal;

  /// No description provided for @bw2CancelWithdrawalBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this withdrawal request?'**
  String get bw2CancelWithdrawalBody;

  /// No description provided for @bw2CancelWithdrawalQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel Withdrawal?'**
  String get bw2CancelWithdrawalQuestion;

  /// No description provided for @bw2CancelWithdrawalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel withdrawal'**
  String get bw2CancelWithdrawalTooltip;

  /// No description provided for @bw2CancellationFailedError.
  ///
  /// In en, this message translates to:
  /// **'Cancellation failed: {error}'**
  String bw2CancellationFailedError(String error);

  /// No description provided for @bw2CancellationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Cancellation request submitted. Awaiting validator votes.'**
  String get bw2CancellationSubmitted;

  /// No description provided for @bw2Cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bw2Cancelled;

  /// No description provided for @bw2CeremonyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ceremony Completed'**
  String get bw2CeremonyCompleted;

  /// No description provided for @bw2CeremonyDismissHint.
  ///
  /// In en, this message translates to:
  /// **'You can dismiss this dialog. The ceremony will continue in the background.'**
  String get bw2CeremonyDismissHint;

  /// No description provided for @bw2CeremonyFailed.
  ///
  /// In en, this message translates to:
  /// **'Ceremony Failed'**
  String get bw2CeremonyFailed;

  /// No description provided for @bw2CeremonyFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Ceremony failed. Please try again.'**
  String get bw2CeremonyFailedRetry;

  /// No description provided for @bw2CeremonyTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Ceremony timed out. Please try again.'**
  String get bw2CeremonyTimedOut;

  /// No description provided for @bw2CeremonyTimedOutNetwork.
  ///
  /// In en, this message translates to:
  /// **'Ceremony timed out on the network. Please try again.'**
  String get bw2CeremonyTimedOutNetwork;

  /// No description provided for @bw2ConfirmSendBtcBody.
  ///
  /// In en, this message translates to:
  /// **'Sending:\n{amount} BTC\n\nTo:\n{toAddress} (Token Deposit Address)\n\nFrom:\n{fromAddress}\n\nFeeRate:\n{feeRate} SATS'**
  String bw2ConfirmSendBtcBody(String amount, String toAddress, String fromAddress, String feeRate);

  /// No description provided for @bw2ConfirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get bw2ConfirmTransfer;

  /// No description provided for @bw2ConfirmTransferBody.
  ///
  /// In en, this message translates to:
  /// **'Transfer {amount} vBTC to {address}?'**
  String bw2ConfirmTransferBody(String amount, String address);

  /// No description provided for @bw2ConfirmWithdrawalRequest.
  ///
  /// In en, this message translates to:
  /// **'Confirm Withdrawal Request'**
  String get bw2ConfirmWithdrawalRequest;

  /// No description provided for @bw2ConfirmedWhenIndexed.
  ///
  /// In en, this message translates to:
  /// **'This will be confirmed once indexed by the explorer.'**
  String get bw2ConfirmedWhenIndexed;

  /// No description provided for @bw2ContractCreated.
  ///
  /// In en, this message translates to:
  /// **'Contract Created'**
  String get bw2ContractCreated;

  /// No description provided for @bw2CouldNotConnectArbiter.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to arbiter. Try again later'**
  String get bw2CouldNotConnectArbiter;

  /// No description provided for @bw2CreatingContract.
  ///
  /// In en, this message translates to:
  /// **'Creating Contract'**
  String get bw2CreatingContract;

  /// No description provided for @bw2CreatingVbtcContract.
  ///
  /// In en, this message translates to:
  /// **'Creating vBTC contract on-chain...'**
  String get bw2CreatingVbtcContract;

  /// No description provided for @bw2DateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get bw2DateLabel;

  /// No description provided for @bw2DepositAddress.
  ///
  /// In en, this message translates to:
  /// **'Deposit Address'**
  String get bw2DepositAddress;

  /// No description provided for @bw2DepositAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Deposit address copied to clipboard'**
  String get bw2DepositAddressCopied;

  /// No description provided for @bw2DepositAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit Address:'**
  String get bw2DepositAddressLabel;

  /// No description provided for @bw2DepositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount'**
  String get bw2DepositAmount;

  /// No description provided for @bw2DkgStartHint.
  ///
  /// In en, this message translates to:
  /// **'This starts the distributed key generation process.'**
  String get bw2DkgStartHint;

  /// No description provided for @bw2DoNotCloseApp.
  ///
  /// In en, this message translates to:
  /// **'This may take a minute. Please do not close the application.'**
  String get bw2DoNotCloseApp;

  /// No description provided for @bw2DomainNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Domain Name Required'**
  String get bw2DomainNameRequired;

  /// No description provided for @bw2DomainTooLong.
  ///
  /// In en, this message translates to:
  /// **'Domain must be less than {max} charcters.'**
  String bw2DomainTooLong(String max);

  /// No description provided for @bw2FailedBroadcastBtc.
  ///
  /// In en, this message translates to:
  /// **'Failed to broadcast BTC transaction'**
  String get bw2FailedBroadcastBtc;

  /// No description provided for @bw2FailedBroadcastWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Failed to broadcast withdrawal request.'**
  String get bw2FailedBroadcastWithdrawal;

  /// No description provided for @bw2FailedCreateContract.
  ///
  /// In en, this message translates to:
  /// **'Failed to create contract. Please try again.'**
  String get bw2FailedCreateContract;

  /// No description provided for @bw2FailedCreateContractShort.
  ///
  /// In en, this message translates to:
  /// **'Failed to create contract.'**
  String get bw2FailedCreateContractShort;

  /// No description provided for @bw2FailedExecuteMpc.
  ///
  /// In en, this message translates to:
  /// **'Failed to execute MPC ceremony.'**
  String get bw2FailedExecuteMpc;

  /// No description provided for @bw2FailedInitiateMpc.
  ///
  /// In en, this message translates to:
  /// **'Failed to initiate MPC ceremony.'**
  String get bw2FailedInitiateMpc;

  /// No description provided for @bw2FailedPrepareCancellation.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare cancellation'**
  String get bw2FailedPrepareCancellation;

  /// No description provided for @bw2FailedPrepareContractCreation.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare contract creation.'**
  String get bw2FailedPrepareContractCreation;

  /// No description provided for @bw2FailedPrepareFrost.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare FROST signing'**
  String get bw2FailedPrepareFrost;

  /// No description provided for @bw2FailedPrepareMpc.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare MPC ceremony.'**
  String get bw2FailedPrepareMpc;

  /// No description provided for @bw2FailedPrepareOwnershipTransfer.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare ownership transfer'**
  String get bw2FailedPrepareOwnershipTransfer;

  /// No description provided for @bw2FailedPrepareTransfer.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare transfer'**
  String get bw2FailedPrepareTransfer;

  /// No description provided for @bw2FailedPrepareWithdrawalRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare withdrawal request'**
  String get bw2FailedPrepareWithdrawalRequest;

  /// No description provided for @bw2FailedSignBeacon.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign beacon upload'**
  String get bw2FailedSignBeacon;

  /// No description provided for @bw2FailedSignCeremony.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign ceremony messages.'**
  String get bw2FailedSignCeremony;

  /// No description provided for @bw2FailedSignContractTx.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign contract creation transaction.'**
  String get bw2FailedSignContractTx;

  /// No description provided for @bw2FailedSignFrost.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign FROST messages'**
  String get bw2FailedSignFrost;

  /// No description provided for @bw2FailedSignOwnershipProof.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign ownership proof.'**
  String get bw2FailedSignOwnershipProof;

  /// No description provided for @bw2FailedSignTransaction.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign transaction'**
  String get bw2FailedSignTransaction;

  /// No description provided for @bw2FailedStartFrost.
  ///
  /// In en, this message translates to:
  /// **'Failed to start FROST signing'**
  String get bw2FailedStartFrost;

  /// No description provided for @bw2FrostConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'This typically takes 10-20 seconds. The FROST signing will begin automatically once confirmed.'**
  String get bw2FrostConfirmHint;

  /// No description provided for @bw2FrostConfirmHintWeb.
  ///
  /// In en, this message translates to:
  /// **'This typically takes 10-20 seconds. FROST signing will begin automatically once confirmed.'**
  String get bw2FrostConfirmHintWeb;

  /// No description provided for @bw2FrostFailedOrTimedOut.
  ///
  /// In en, this message translates to:
  /// **'FROST signing failed or timed out. The withdrawal may still complete — check back shortly.'**
  String get bw2FrostFailedOrTimedOut;

  /// No description provided for @bw2FrostGroupKey.
  ///
  /// In en, this message translates to:
  /// **'FROST Group Key'**
  String get bw2FrostGroupKey;

  /// No description provided for @bw2FrostJobNotFound.
  ///
  /// In en, this message translates to:
  /// **'FROST signing job not found'**
  String get bw2FrostJobNotFound;

  /// No description provided for @bw2FrostSigning.
  ///
  /// In en, this message translates to:
  /// **'FROST Signing'**
  String get bw2FrostSigning;

  /// No description provided for @bw2FrostSigningFailed.
  ///
  /// In en, this message translates to:
  /// **'FROST signing failed'**
  String get bw2FrostSigningFailed;

  /// No description provided for @bw2FrostSigningFailedError.
  ///
  /// In en, this message translates to:
  /// **'FROST signing failed: {error}'**
  String bw2FrostSigningFailedError(String error);

  /// No description provided for @bw2FrostSigningInProgress.
  ///
  /// In en, this message translates to:
  /// **'FROST signing in progress...'**
  String get bw2FrostSigningInProgress;

  /// No description provided for @bw2FrostTimedOut.
  ///
  /// In en, this message translates to:
  /// **'FROST signing timed out. The withdrawal may still complete — check back shortly.'**
  String get bw2FrostTimedOut;

  /// No description provided for @bw2FrostValidatorsSigning.
  ///
  /// In en, this message translates to:
  /// **'Validators are signing the Bitcoin transaction. This may take a minute or two. Please do not close this window.'**
  String get bw2FrostValidatorsSigning;

  /// No description provided for @bw2FundVbtcToken.
  ///
  /// In en, this message translates to:
  /// **'Fund vBTC Token'**
  String get bw2FundVbtcToken;

  /// No description provided for @bw2FundViaManualSend.
  ///
  /// In en, this message translates to:
  /// **'Fund via Manual Send'**
  String get bw2FundViaManualSend;

  /// No description provided for @bw2HashWithValue.
  ///
  /// In en, this message translates to:
  /// **'Hash: {hash}'**
  String bw2HashWithValue(String hash);

  /// No description provided for @bw2HowMuchBtcWithdraw.
  ///
  /// In en, this message translates to:
  /// **'How much BTC do you want to withdraw?'**
  String get bw2HowMuchBtcWithdraw;

  /// No description provided for @bw2InitiatingMpc.
  ///
  /// In en, this message translates to:
  /// **'Initiating MPC ceremony...'**
  String get bw2InitiatingMpc;

  /// No description provided for @bw2InsufficientBalanceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. Available: {available} vBTC'**
  String bw2InsufficientBalanceAvailable(String available);

  /// No description provided for @bw2InvalidDomainLetters.
  ///
  /// In en, this message translates to:
  /// **'Invalid domain. Must only contain letters and/or numbers.'**
  String get bw2InvalidDomainLetters;

  /// No description provided for @bw2InvalidFeeRateWhole.
  ///
  /// In en, this message translates to:
  /// **'Invalid fee rate. Must be a whole number'**
  String get bw2InvalidFeeRateWhole;

  /// No description provided for @bw2InvalidSupplyAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Supply Amount'**
  String get bw2InvalidSupplyAmount;

  /// No description provided for @bw2LabelHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get bw2LabelHash;

  /// No description provided for @bw2LabelTransactionSignature.
  ///
  /// In en, this message translates to:
  /// **'Transaction Signature'**
  String get bw2LabelTransactionSignature;

  /// No description provided for @bw2LabelVfxAddress.
  ///
  /// In en, this message translates to:
  /// **'VFX Address'**
  String get bw2LabelVfxAddress;

  /// No description provided for @bw2Loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get bw2Loading;

  /// No description provided for @bw2LostConnectionCeremony.
  ///
  /// In en, this message translates to:
  /// **'Lost connection while monitoring ceremony. Please try again.'**
  String get bw2LostConnectionCeremony;

  /// No description provided for @bw2LostConnectionToast.
  ///
  /// In en, this message translates to:
  /// **'Lost connection to ceremony.'**
  String get bw2LostConnectionToast;

  /// No description provided for @bw2ManualSendInstructions.
  ///
  /// In en, this message translates to:
  /// **'Send BTC from any exchange or external wallet to the deposit address below.'**
  String get bw2ManualSendInstructions;

  /// No description provided for @bw2MediaColon.
  ///
  /// In en, this message translates to:
  /// **'Media:'**
  String get bw2MediaColon;

  /// No description provided for @bw2MediaOptional.
  ///
  /// In en, this message translates to:
  /// **'Media (Optional)'**
  String get bw2MediaOptional;

  /// No description provided for @bw2MpcCeremony.
  ///
  /// In en, this message translates to:
  /// **'MPC Ceremony'**
  String get bw2MpcCeremony;

  /// No description provided for @bw2MpcCeremonyCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'MPC ceremony completed successfully.'**
  String get bw2MpcCeremonyCompletedSuccess;

  /// No description provided for @bw2MpcCeremonyFailedToast.
  ///
  /// In en, this message translates to:
  /// **'MPC ceremony failed.'**
  String get bw2MpcCeremonyFailedToast;

  /// No description provided for @bw2MpcCeremonyInProgress.
  ///
  /// In en, this message translates to:
  /// **'MPC Ceremony in Progress'**
  String get bw2MpcCeremonyInProgress;

  /// No description provided for @bw2MpcCeremonyTimedOutToast.
  ///
  /// In en, this message translates to:
  /// **'MPC ceremony timed out.'**
  String get bw2MpcCeremonyTimedOutToast;

  /// No description provided for @bw2MultiSigHigherFee.
  ///
  /// In en, this message translates to:
  /// **'This is a Multi-signature transaction so a higher fee rate is recommended.'**
  String get bw2MultiSigHigherFee;

  /// No description provided for @bw2MyBalanceVbtc.
  ///
  /// In en, this message translates to:
  /// **'My Balance: {balance} vBTC'**
  String bw2MyBalanceVbtc(String balance);

  /// No description provided for @bw2MyTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'My Total Balance:'**
  String get bw2MyTotalBalance;

  /// No description provided for @bw2NoBtcAccountSelected.
  ///
  /// In en, this message translates to:
  /// **'No BTC Account selected'**
  String get bw2NoBtcAccountSelected;

  /// No description provided for @bw2NoBtcAddressInToken.
  ///
  /// In en, this message translates to:
  /// **'No BTC address in token'**
  String get bw2NoBtcAddressInToken;

  /// No description provided for @bw2NoBtcTokenSelected.
  ///
  /// In en, this message translates to:
  /// **'No BTC Token selected'**
  String get bw2NoBtcTokenSelected;

  /// No description provided for @bw2NoInitialIssuance.
  ///
  /// In en, this message translates to:
  /// **'No Initial Issuance'**
  String get bw2NoInitialIssuance;

  /// No description provided for @bw2NoKeypairFound.
  ///
  /// In en, this message translates to:
  /// **'No keypair found'**
  String get bw2NoKeypairFound;

  /// No description provided for @bw2NoKeypairFoundPeriod.
  ///
  /// In en, this message translates to:
  /// **'No keypair found.'**
  String get bw2NoKeypairFoundPeriod;

  /// No description provided for @bw2NoKeypairToSign.
  ///
  /// In en, this message translates to:
  /// **'No keypair found to sign transaction'**
  String get bw2NoKeypairToSign;

  /// No description provided for @bw2NoVbtcToBridge.
  ///
  /// In en, this message translates to:
  /// **'No vBTC available to bridge'**
  String get bw2NoVbtcToBridge;

  /// No description provided for @bw2NoVfxAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No VFX account found'**
  String get bw2NoVfxAccountFound;

  /// No description provided for @bw2NotEnoughBtcCoverFee.
  ///
  /// In en, this message translates to:
  /// **'Not enough BTC to cover this transaction + fee'**
  String get bw2NotEnoughBtcCoverFee;

  /// No description provided for @bw2NotEnoughVfxDeleteDomain.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX in your controlling account to delete a VFX domain. [{address}]'**
  String bw2NotEnoughVfxDeleteDomain(String address);

  /// No description provided for @bw2OnboardCreateVfxDetails.
  ///
  /// In en, this message translates to:
  /// **'First you\'ll need a VFX Wallet. You can either import an existing one or create one now.'**
  String get bw2OnboardCreateVfxDetails;

  /// No description provided for @bw2OnboardFaucetDetails.
  ///
  /// In en, this message translates to:
  /// **'The community has provided a faucet to withdraw a minimal amount of VFX from in order to try out this feature. A phone number is required for verification purposes and to reduce the chance of abuse. Please note that only a hash of the phone number is stored with the faucet. Alternatively, you are welcome to purchase VFX via an exchange or on-ramp if you like.'**
  String get bw2OnboardFaucetDetails;

  /// No description provided for @bw2OnboardImportBtcDetails.
  ///
  /// In en, this message translates to:
  /// **'Now you need a BTC account added to your wallet. You can either import a private key or generate a new one.'**
  String get bw2OnboardImportBtcDetails;

  /// No description provided for @bw2OnboardTokenizeDetails.
  ///
  /// In en, this message translates to:
  /// **'Time to tokenize a vBTC token. The following fields are all optional!'**
  String get bw2OnboardTokenizeDetails;

  /// No description provided for @bw2OnboardTransferBtcDetails.
  ///
  /// In en, this message translates to:
  /// **'Looks like this account doesn\'t have any BTC. Please transfer BTC to this account to continue.'**
  String get bw2OnboardTransferBtcDetails;

  /// No description provided for @bw2OnboardTransferToVbtcDetails.
  ///
  /// In en, this message translates to:
  /// **'Now you are ready to transfer BTC to your vBTC token. Select the amount and Fee Rate below'**
  String get bw2OnboardTransferToVbtcDetails;

  /// No description provided for @bw2OneVbtcEqualsBtc.
  ///
  /// In en, this message translates to:
  /// **'1 vBTC = 1 BTC'**
  String get bw2OneVbtcEqualsBtc;

  /// No description provided for @bw2OnlyOwnerCanAction.
  ///
  /// In en, this message translates to:
  /// **'Only the owner of this token can perform this action'**
  String get bw2OnlyOwnerCanAction;

  /// No description provided for @bw2OwnershipTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Ownership transfer failed: {error}'**
  String bw2OwnershipTransferFailed(String error);

  /// No description provided for @bw2PendingTapResume.
  ///
  /// In en, this message translates to:
  /// **'Pending — tap to resume'**
  String get bw2PendingTapResume;

  /// No description provided for @bw2PendingWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Pending Withdrawal'**
  String get bw2PendingWithdrawal;

  /// No description provided for @bw2PercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String bw2PercentComplete(String percent);

  /// No description provided for @bw2PreMintTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre Mint Initial Issuance?'**
  String get bw2PreMintTitle;

  /// No description provided for @bw2PreMintTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Pre Mint Initial Issuance? (Optional)'**
  String get bw2PreMintTitleOptional;

  /// No description provided for @bw2ProcessingWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Processing Withdrawal'**
  String get bw2ProcessingWithdrawal;

  /// No description provided for @bw2RbfFeeRateBody.
  ///
  /// In en, this message translates to:
  /// **'Input your desired fee rate (SATS /byte) for this transaction.'**
  String get bw2RbfFeeRateBody;

  /// No description provided for @bw2RebroadcastTx.
  ///
  /// In en, this message translates to:
  /// **'Rebroadcast TX'**
  String get bw2RebroadcastTx;

  /// No description provided for @bw2RebroadcastTxBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to rebroadcast this transaction?'**
  String get bw2RebroadcastTxBody;

  /// No description provided for @bw2RebroadcastedTx.
  ///
  /// In en, this message translates to:
  /// **'Rebroadcasted TX. ({hash})'**
  String bw2RebroadcastedTx(String hash);

  /// No description provided for @bw2ReceivingBtcAddress.
  ///
  /// In en, this message translates to:
  /// **'Receiving BTC Address'**
  String get bw2ReceivingBtcAddress;

  /// No description provided for @bw2RecipientVfxAddress.
  ///
  /// In en, this message translates to:
  /// **'Recipient VFX Address'**
  String get bw2RecipientVfxAddress;

  /// No description provided for @bw2ReplacedByFeeMessage.
  ///
  /// In en, this message translates to:
  /// **'Replaced by fee ({feeRate} SATS /byte) TX sent. Hash: {hash}'**
  String bw2ReplacedByFeeMessage(String feeRate, String hash);

  /// No description provided for @bw2RetrySigning.
  ///
  /// In en, this message translates to:
  /// **'Retry Signing'**
  String get bw2RetrySigning;

  /// No description provided for @bw2SatsAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} SATS'**
  String bw2SatsAmount(String amount);

  /// No description provided for @bw2SelectBtcAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Selecting a BTC address is required.'**
  String get bw2SelectBtcAddressRequired;

  /// No description provided for @bw2SelectVfxAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Selecting a VFX Address is required.'**
  String get bw2SelectVfxAddressRequired;

  /// No description provided for @bw2SigningThreshold.
  ///
  /// In en, this message translates to:
  /// **'Signing Threshold'**
  String get bw2SigningThreshold;

  /// No description provided for @bw2SmartContractIdColon.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract ID:'**
  String get bw2SmartContractIdColon;

  /// No description provided for @bw2StartingMpcCeremony.
  ///
  /// In en, this message translates to:
  /// **'Starting MPC Ceremony'**
  String get bw2StartingMpcCeremony;

  /// No description provided for @bw2StatusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String bw2StatusWithValue(String status);

  /// No description provided for @bw2StepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bw2StepCompleted;

  /// No description provided for @bw2StepCreateVfxAccount.
  ///
  /// In en, this message translates to:
  /// **'Create VFX Account'**
  String get bw2StepCreateVfxAccount;

  /// No description provided for @bw2StepGetVfx.
  ///
  /// In en, this message translates to:
  /// **'Get VFX'**
  String get bw2StepGetVfx;

  /// No description provided for @bw2StepImportBtcAccount.
  ///
  /// In en, this message translates to:
  /// **'Import BTC Account'**
  String get bw2StepImportBtcAccount;

  /// No description provided for @bw2StepInitiated.
  ///
  /// In en, this message translates to:
  /// **'Initiated'**
  String get bw2StepInitiated;

  /// No description provided for @bw2StepRound1.
  ///
  /// In en, this message translates to:
  /// **'Round 1'**
  String get bw2StepRound1;

  /// No description provided for @bw2StepRound2.
  ///
  /// In en, this message translates to:
  /// **'Round 2'**
  String get bw2StepRound2;

  /// No description provided for @bw2StepRound3.
  ///
  /// In en, this message translates to:
  /// **'Round 3'**
  String get bw2StepRound3;

  /// No description provided for @bw2StepTokenizedVbtc.
  ///
  /// In en, this message translates to:
  /// **'Tokenized vBTC'**
  String get bw2StepTokenizedVbtc;

  /// No description provided for @bw2StepTransferBtc.
  ///
  /// In en, this message translates to:
  /// **'Transfer BTC'**
  String get bw2StepTransferBtc;

  /// No description provided for @bw2StepTransferBtcToVbtc.
  ///
  /// In en, this message translates to:
  /// **'Transfer BTC to vBTC Token'**
  String get bw2StepTransferBtcToVbtc;

  /// No description provided for @bw2StepValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating'**
  String get bw2StepValidating;

  /// No description provided for @bw2SubmittingTxVfx.
  ///
  /// In en, this message translates to:
  /// **'Submitting a transaction to the VFX network.'**
  String get bw2SubmittingTxVfx;

  /// No description provided for @bw2SupplyAmount.
  ///
  /// In en, this message translates to:
  /// **'Supply Amount'**
  String get bw2SupplyAmount;

  /// No description provided for @bw2SupplyLabel.
  ///
  /// In en, this message translates to:
  /// **'Supply'**
  String get bw2SupplyLabel;

  /// No description provided for @bw2ToBtcAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'To BTC address required.'**
  String get bw2ToBtcAddressRequired;

  /// No description provided for @bw2ToVfxAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'To VFX address required.'**
  String get bw2ToVfxAddressRequired;

  /// No description provided for @bw2TokenAppearWhenIndexed.
  ///
  /// In en, this message translates to:
  /// **'The token will appear in your list once indexed (typically a few seconds).'**
  String get bw2TokenAppearWhenIndexed;

  /// No description provided for @bw2TokenCreated.
  ///
  /// In en, this message translates to:
  /// **'Token Created'**
  String get bw2TokenCreated;

  /// No description provided for @bw2TokenDeployed.
  ///
  /// In en, this message translates to:
  /// **'Token Deployed!'**
  String get bw2TokenDeployed;

  /// No description provided for @bw2TokenDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Token Description (Optional)'**
  String get bw2TokenDescriptionOptional;

  /// No description provided for @bw2TokenImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Token Image (Optional)'**
  String get bw2TokenImageOptional;

  /// No description provided for @bw2TokenNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Token Name (Optional)'**
  String get bw2TokenNameOptional;

  /// No description provided for @bw2TokenPaused.
  ///
  /// In en, this message translates to:
  /// **'Transactions on this token are currently paused.'**
  String get bw2TokenPaused;

  /// No description provided for @bw2TokenTickerOptional.
  ///
  /// In en, this message translates to:
  /// **'Token Ticker (Optional)'**
  String get bw2TokenTickerOptional;

  /// No description provided for @bw2TransactionBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'Transaction broadcasted!'**
  String get bw2TransactionBroadcasted;

  /// No description provided for @bw2TransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction failed: {error}'**
  String bw2TransactionFailed(String error);

  /// No description provided for @bw2TransactionHashColon.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash:'**
  String get bw2TransactionHashColon;

  /// No description provided for @bw2TransactionsColon.
  ///
  /// In en, this message translates to:
  /// **'Transactions:'**
  String get bw2TransactionsColon;

  /// No description provided for @bw2TransferComplete.
  ///
  /// In en, this message translates to:
  /// **'Transfer Complete!'**
  String get bw2TransferComplete;

  /// No description provided for @bw2TransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get bw2TransferFailed;

  /// No description provided for @bw2TransferFailedError.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed: {error}'**
  String bw2TransferFailedError(String error);

  /// No description provided for @bw2TransferOwnershipConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership of this vBTC token to {address}?\n\nThis cannot be undone.'**
  String bw2TransferOwnershipConfirmBody(String address);

  /// No description provided for @bw2TxVerifiedFeeBody.
  ///
  /// In en, this message translates to:
  /// **'Transaction verified. There will be a fee of {fee} VFX. Would you like to proceed?'**
  String bw2TxVerifiedFeeBody(String fee);

  /// No description provided for @bw2TypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get bw2TypeLabel;

  /// No description provided for @bw2UtxosLabel.
  ///
  /// In en, this message translates to:
  /// **'UTXOs:'**
  String get bw2UtxosLabel;

  /// No description provided for @bw2ValidatorsGeneratingKeys.
  ///
  /// In en, this message translates to:
  /// **'Validators are generating threshold signing keys. This typically takes 30-90 seconds.'**
  String get bw2ValidatorsGeneratingKeys;

  /// No description provided for @bw2ValidatorsSigningBtc.
  ///
  /// In en, this message translates to:
  /// **'Validators are signing the Bitcoin transaction...'**
  String get bw2ValidatorsSigningBtc;

  /// No description provided for @bw2ValidatorsThreshold.
  ///
  /// In en, this message translates to:
  /// **'Validators: {count} (threshold: {threshold})'**
  String bw2ValidatorsThreshold(String count, String threshold);

  /// No description provided for @bw2VaultBalanceRequired.
  ///
  /// In en, this message translates to:
  /// **'A balance on your Vault account is required to broadcast this transaction'**
  String get bw2VaultBalanceRequired;

  /// No description provided for @bw2VaultCannotActionTransferFirst.
  ///
  /// In en, this message translates to:
  /// **'Vault accounts cannot perform this action. Please transfer ownership to your standard VFX account first'**
  String get bw2VaultCannotActionTransferFirst;

  /// No description provided for @bw2VbtcAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC'**
  String bw2VbtcAmount(String amount);

  /// No description provided for @bw2VbtcBalanceUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'Once the BTC transaction is confirmed on-chain, your vBTC balance will update automatically.'**
  String get bw2VbtcBalanceUpdateHint;

  /// No description provided for @bw2VbtcContractCreatedHash.
  ///
  /// In en, this message translates to:
  /// **'vBTC contract created. Hash: {hash}'**
  String bw2VbtcContractCreatedHash(String hash);

  /// No description provided for @bw2VbtcContractCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC contract created successfully!'**
  String get bw2VbtcContractCreatedSuccess;

  /// No description provided for @bw2VbtcInfoBody.
  ///
  /// In en, this message translates to:
  /// **'This wallet provides a specific smart contract that enables tokenizing actual Bitcoin! This will allow you to lock any denomination of Bitcoin you choose into a smart contract with or without media / documents.\n\nOnce minted, you will then hold a Verified Bitcoin Token that you may send to any other person at any time in whole or in part without moving it across the BTC network and without paying any BTC fees. Only you or the holder of a vBTC token may unlock the underlying BTC from the smart contract. You may also add additional BTC to your token at anytime without creating an additional one should you choose.\n\nAny and all vBTC tokens may also be stored in your registered Reserve (Protected) Account feature enabling full on-chain recovery and call-back options providing incredibly secure self-custodial vaulting.'**
  String get bw2VbtcInfoBody;

  /// No description provided for @bw2VbtcInfoWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to true on-chain utility for your BTC!'**
  String get bw2VbtcInfoWelcome;

  /// No description provided for @bw2VbtcTokenCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC token created successfully!'**
  String get bw2VbtcTokenCreatedSuccess;

  /// No description provided for @bw2VbtcTransferBroadcastedSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC transfer broadcasted successfully'**
  String get bw2VbtcTransferBroadcastedSuccess;

  /// No description provided for @bw2VfxAccountBalanceRequired.
  ///
  /// In en, this message translates to:
  /// **'A VFX account with a balance is required to proceed.'**
  String get bw2VfxAccountBalanceRequired;

  /// No description provided for @bw2VfxAccountBalanceRequiredShort.
  ///
  /// In en, this message translates to:
  /// **'A VFX account with a balance is required.'**
  String get bw2VfxAccountBalanceRequiredShort;

  /// No description provided for @bw2VfxAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'A VFX account is required to proceed.'**
  String get bw2VfxAccountRequired;

  /// No description provided for @bw2VfxBalanceRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'A VFX address with a balance is required to proceed.'**
  String get bw2VfxBalanceRequiredBody;

  /// No description provided for @bw2VfxBalanceRequiredBroadcast.
  ///
  /// In en, this message translates to:
  /// **'A balance on your VFX account is required to broadcast this transaction'**
  String get bw2VfxBalanceRequiredBroadcast;

  /// No description provided for @bw2VfxBalanceRequiredSetupBody.
  ///
  /// In en, this message translates to:
  /// **'A VFX address with a balance is required to proceed. Would you like to set this up now?'**
  String get bw2VfxBalanceRequiredSetupBody;

  /// No description provided for @bw2VfxControllerNotFound.
  ///
  /// In en, this message translates to:
  /// **'The VFX account that controls this BTC domain was not found. [{address}]'**
  String bw2VfxControllerNotFound(String address);

  /// No description provided for @bw2VfxFundsReceived.
  ///
  /// In en, this message translates to:
  /// **'VFX Funds Received!'**
  String get bw2VfxFundsReceived;

  /// No description provided for @bw2VfxTransactionLabel.
  ///
  /// In en, this message translates to:
  /// **'VFX Transaction:'**
  String get bw2VfxTransactionLabel;

  /// No description provided for @bw2WaitingBlockConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for block confirmation...'**
  String get bw2WaitingBlockConfirmation;

  /// No description provided for @bw2WaitingBtcToVbtc.
  ///
  /// In en, this message translates to:
  /// **'Waiting for BTC to vBTC transaction to reflect on-chain.'**
  String get bw2WaitingBtcToVbtc;

  /// No description provided for @bw2WaitingBtcTransfer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for BTC transfer to reflect on-chain.'**
  String get bw2WaitingBtcTransfer;

  /// No description provided for @bw2WaitingForBlockBody.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the withdrawal request to be confirmed in a block...'**
  String get bw2WaitingForBlockBody;

  /// No description provided for @bw2WaitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Confirmation'**
  String get bw2WaitingForConfirmation;

  /// No description provided for @bw2WaitingTokenization.
  ///
  /// In en, this message translates to:
  /// **'MPC ceremony and contract creation in progress.'**
  String get bw2WaitingTokenization;

  /// No description provided for @bw2WaitingVfxTransfer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for VFX Transfer to reflect on-chain.'**
  String get bw2WaitingVfxTransfer;

  /// No description provided for @bw2WhatIsVbtc.
  ///
  /// In en, this message translates to:
  /// **'What is vBTC?'**
  String get bw2WhatIsVbtc;

  /// No description provided for @bw2WithdrawalAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Amount'**
  String get bw2WithdrawalAmount;

  /// No description provided for @bw2WithdrawalComplete.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Complete'**
  String get bw2WithdrawalComplete;

  /// No description provided for @bw2WithdrawalCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal completed successfully!'**
  String get bw2WithdrawalCompletedSuccess;

  /// No description provided for @bw2WithdrawalError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during withdrawal.'**
  String get bw2WithdrawalError;

  /// No description provided for @bw2WithdrawalFailed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Failed'**
  String get bw2WithdrawalFailed;

  /// No description provided for @bw2WithdrawalHistory.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal History:'**
  String get bw2WithdrawalHistory;

  /// No description provided for @bw2WithdrawalRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount} BTC to {address}\nFee rate: {feeRate} sats/byte\n\nProceed?'**
  String bw2WithdrawalRequestBody(String amount, String address, String feeRate);

  /// No description provided for @bw2WithdrawalRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request failed'**
  String get bw2WithdrawalRequestFailed;

  /// No description provided for @bw2WithdrawalRequestFailedError.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request failed: {error}'**
  String bw2WithdrawalRequestFailedError(String error);

  /// No description provided for @bw2WithdrawalTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Timed out waiting for withdrawal request to be confirmed. You can retry later.'**
  String get bw2WithdrawalTimedOut;

  /// No description provided for @bw2WithdrawalToLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC → {address}'**
  String bw2WithdrawalToLine(String amount, String address);

  /// No description provided for @prvActivateWallet.
  ///
  /// In en, this message translates to:
  /// **'Activate Privacy Wallet'**
  String get prvActivateWallet;

  /// No description provided for @prvActivating.
  ///
  /// In en, this message translates to:
  /// **'Activating...'**
  String get prvActivating;

  /// No description provided for @prvActivationDescription.
  ///
  /// In en, this message translates to:
  /// **'Activate your privacy wallet to shield VFX using zero-knowledge proofs. Shielded funds are hidden from the public ledger and can be transferred privately.'**
  String get prvActivationDescription;

  /// No description provided for @prvAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get prvAddressCopied;

  /// No description provided for @prvAmountVbtcLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (vBTC)'**
  String get prvAmountVbtcLabel;

  /// No description provided for @prvAmountVfxLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (VFX)'**
  String get prvAmountVfxLabel;

  /// No description provided for @prvBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get prvBack;

  /// No description provided for @prvBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Block {block}'**
  String prvBlockLabel(String block);

  /// No description provided for @prvBridgeAboutTo.
  ///
  /// In en, this message translates to:
  /// **'You\'re about to bridge'**
  String get prvBridgeAboutTo;

  /// No description provided for @prvBridgeAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get prvBridgeAmountRequired;

  /// No description provided for @prvBridgeAmountToBridge.
  ///
  /// In en, this message translates to:
  /// **'Amount to bridge'**
  String get prvBridgeAmountToBridge;

  /// No description provided for @prvBridgeAmountToDest.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC → {dest}'**
  String prvBridgeAmountToDest(String amount, String dest);

  /// No description provided for @prvBridgeAtDest.
  ///
  /// In en, this message translates to:
  /// **'at {dest}'**
  String prvBridgeAtDest(String dest);

  /// No description provided for @prvBridgeAvailableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount} vBTC'**
  String prvBridgeAvailableAmount(String amount);

  /// No description provided for @prvBridgeBaseAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Base address is required'**
  String get prvBridgeBaseAddressRequired;

  /// No description provided for @prvBridgeBaseEvmAddress.
  ///
  /// In en, this message translates to:
  /// **'Base (EVM) Address'**
  String get prvBridgeBaseEvmAddress;

  /// No description provided for @prvBridgeBlockHeight.
  ///
  /// In en, this message translates to:
  /// **'Block height: {height}'**
  String prvBridgeBlockHeight(String height);

  /// No description provided for @prvBridgeBulletExit.
  ///
  /// In en, this message translates to:
  /// **'Exit back to vBTC on VFX or directly to BTC (whoever holds the vBTC.b initiates the exit; the network will detect it and credit you back automatically)'**
  String get prvBridgeBulletExit;

  /// No description provided for @prvBridgeBulletTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer to another Base address'**
  String get prvBridgeBulletTransfer;

  /// No description provided for @prvBridgeBulletYield.
  ///
  /// In en, this message translates to:
  /// **'Earn yield via Base DeFi'**
  String get prvBridgeBulletYield;

  /// No description provided for @prvBridgeCantLoadInfo.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load bridge info.'**
  String get prvBridgeCantLoadInfo;

  /// No description provided for @prvBridgeCantReach.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the bridge service. Check your connection and try again.'**
  String get prvBridgeCantReach;

  /// No description provided for @prvBridgeCantReadBalance.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your vBTC balance: {error}'**
  String prvBridgeCantReadBalance(String error);

  /// No description provided for @prvBridgeCheckingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Checking your accounts…'**
  String get prvBridgeCheckingAccounts;

  /// No description provided for @prvBridgeCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridge complete'**
  String get prvBridgeCompleteTitle;

  /// No description provided for @prvBridgeConfirmAndBridge.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Bridge'**
  String get prvBridgeConfirmAndBridge;

  /// No description provided for @prvBridgeContractLabel.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get prvBridgeContractLabel;

  /// No description provided for @prvBridgeCouldNotComplete.
  ///
  /// In en, this message translates to:
  /// **'The bridge could not complete.'**
  String get prvBridgeCouldNotComplete;

  /// No description provided for @prvBridgeCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get prvBridgeCurrentBalance;

  /// No description provided for @prvBridgeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String prvBridgeDaysAgo(int days);

  /// No description provided for @prvBridgeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridge details'**
  String get prvBridgeDetailsTitle;

  /// No description provided for @prvBridgeEnterPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get prvBridgeEnterPositive;

  /// No description provided for @prvBridgeEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time: 2–5 minutes once submitted.'**
  String get prvBridgeEstimatedTime;

  /// No description provided for @prvBridgeEthAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} ETH'**
  String prvBridgeEthAmount(String amount);

  /// No description provided for @prvBridgeEthForGas.
  ///
  /// In en, this message translates to:
  /// **'ETH for gas'**
  String get prvBridgeEthForGas;

  /// No description provided for @prvBridgeExceedsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Exceeds available ({amount} vBTC)'**
  String prvBridgeExceedsAvailable(String amount);

  /// No description provided for @prvBridgeFailedBodyFallback.
  ///
  /// In en, this message translates to:
  /// **'Open Bridge History for details.'**
  String get prvBridgeFailedBodyFallback;

  /// No description provided for @prvBridgeFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Bridge failed.'**
  String get prvBridgeFailedFallback;

  /// No description provided for @prvBridgeFailedHelp.
  ///
  /// In en, this message translates to:
  /// **'Your vBTC may still be locked on VFX. Check Bridge History for details, or contact support if this persists.'**
  String get prvBridgeFailedHelp;

  /// No description provided for @prvBridgeFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridge failed'**
  String get prvBridgeFailedTitle;

  /// No description provided for @prvBridgeFailedToStart.
  ///
  /// In en, this message translates to:
  /// **'Failed to start bridge. Please try again.'**
  String get prvBridgeFailedToStart;

  /// No description provided for @prvBridgeFromVfx.
  ///
  /// In en, this message translates to:
  /// **'from VFX'**
  String get prvBridgeFromVfx;

  /// No description provided for @prvBridgeGasLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low balance — gas costs vary. Top up the address above if the mint fails.'**
  String get prvBridgeGasLowBalance;

  /// No description provided for @prvBridgeGasTitle.
  ///
  /// In en, this message translates to:
  /// **'Gas (paid on Base)'**
  String get prvBridgeGasTitle;

  /// No description provided for @prvBridgeGasZeroEth.
  ///
  /// In en, this message translates to:
  /// **'This address pays the gas fee for the mint transaction on Base. Send a small amount of Base ETH (≈ 0.001 ETH) to the address above before bridging. You can fund it from any exchange or Base wallet that supports withdrawing to Base mainnet. Balance updates automatically every 10s — tap Refresh for an immediate check.'**
  String get prvBridgeGasZeroEth;

  /// No description provided for @prvBridgeHideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get prvBridgeHideDetails;

  /// No description provided for @prvBridgeHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load bridge history. Check your connection and try again.'**
  String get prvBridgeHistoryLoadError;

  /// No description provided for @prvBridgeHistoryLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading bridge history…'**
  String get prvBridgeHistoryLoading;

  /// No description provided for @prvBridgeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridge History'**
  String get prvBridgeHistoryTitle;

  /// No description provided for @prvBridgeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String prvBridgeHoursAgo(int hours);

  /// No description provided for @prvBridgeInvalidBaseAddress.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid 0x Base address (40 hex chars)'**
  String get prvBridgeInvalidBaseAddress;

  /// No description provided for @prvBridgeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get prvBridgeJustNow;

  /// No description provided for @prvBridgeLoadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Loading bridge status…'**
  String get prvBridgeLoadingStatus;

  /// No description provided for @prvBridgeLockId.
  ///
  /// In en, this message translates to:
  /// **'Lock ID: {id}'**
  String prvBridgeLockId(String id);

  /// No description provided for @prvBridgeMintedBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC.b minted on Base.'**
  String prvBridgeMintedBody(String amount);

  /// No description provided for @prvBridgeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String prvBridgeMinutesAgo(int minutes);

  /// No description provided for @prvBridgeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months}mo ago'**
  String prvBridgeMonthsAgo(int months);

  /// No description provided for @prvBridgeNetworkInfo.
  ///
  /// In en, this message translates to:
  /// **'Network info'**
  String get prvBridgeNetworkInfo;

  /// No description provided for @prvBridgeNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get prvBridgeNetworkLabel;

  /// No description provided for @prvBridgeNoOperations.
  ///
  /// In en, this message translates to:
  /// **'No bridge operations yet.'**
  String get prvBridgeNoOperations;

  /// No description provided for @prvBridgeNothingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Nothing available to bridge yet.\n\nYour wallet may show a balance, but the chain doesn\'t see any confirmed vBTC for this contract yet. The most common cause is a BTC deposit that hasn\'t received enough Bitcoin confirmations. Bridge reservations from an earlier attempt could also be holding the balance.\n\nWait a few minutes and try again, or check Bridge History below for any in-flight operations.'**
  String get prvBridgeNothingAvailable;

  /// No description provided for @prvBridgeOneWayDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Bridging is one-way from this app. Once vBTC.b is on Base, use your DeFi provider or another Base (EVM) wallet to manage, transfer, or exit.'**
  String get prvBridgeOneWayDisclaimer;

  /// No description provided for @prvBridgeOneWayReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder: this is one-way from this app. You\'ll use your DeFi provider or another Base (EVM) wallet for any further actions on vBTC.b.'**
  String get prvBridgeOneWayReminder;

  /// No description provided for @prvBridgePasteDestination.
  ///
  /// In en, this message translates to:
  /// **'Paste the destination address from your DeFi provider or Base wallet.'**
  String get prvBridgePasteDestination;

  /// No description provided for @prvBridgeReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting… the bridge service didn\'t respond to recent status checks. We\'ll keep retrying.'**
  String get prvBridgeReconnecting;

  /// No description provided for @prvBridgeRetryFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Retry failed. See history detail for status.'**
  String get prvBridgeRetryFailedToast;

  /// No description provided for @prvBridgeRetrySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Retry submitted. Watching for status updates.'**
  String get prvBridgeRetrySubmitted;

  /// No description provided for @prvBridgeReviewBridge.
  ///
  /// In en, this message translates to:
  /// **'Review Bridge'**
  String get prvBridgeReviewBridge;

  /// No description provided for @prvBridgeSafeToClose.
  ///
  /// In en, this message translates to:
  /// **'Safe to close this dialog — your bridge will continue in the background. Track progress in Bridge History.'**
  String get prvBridgeSafeToClose;

  /// No description provided for @prvBridgeShowDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get prvBridgeShowDetails;

  /// No description provided for @prvBridgeSigsProgress.
  ///
  /// In en, this message translates to:
  /// **'{collected} / {required} signatures collected'**
  String prvBridgeSigsProgress(int collected, int required);

  /// No description provided for @prvBridgeStageCollectingSigs.
  ///
  /// In en, this message translates to:
  /// **'Collecting validator signatures…'**
  String get prvBridgeStageCollectingSigs;

  /// No description provided for @prvBridgeStageConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed on VFX'**
  String get prvBridgeStageConfirmed;

  /// No description provided for @prvBridgeStageLockSubmitted.
  ///
  /// In en, this message translates to:
  /// **'VFX lock submitted'**
  String get prvBridgeStageLockSubmitted;

  /// No description provided for @prvBridgeStageMinted.
  ///
  /// In en, this message translates to:
  /// **'Minted on Base'**
  String get prvBridgeStageMinted;

  /// No description provided for @prvBridgeStageSigsCollected.
  ///
  /// In en, this message translates to:
  /// **'Validator signatures collected'**
  String get prvBridgeStageSigsCollected;

  /// No description provided for @prvBridgeStageSubmittingMint.
  ///
  /// In en, this message translates to:
  /// **'Submitting mint on Base'**
  String get prvBridgeStageSubmittingMint;

  /// No description provided for @prvBridgeStalled.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than expected. Validator signing can occasionally lag — we\'ll keep watching. You can safely close this dialog; Bridge History will surface the final result.'**
  String get prvBridgeStalled;

  /// No description provided for @prvBridgeStateLost.
  ///
  /// In en, this message translates to:
  /// **'Bridge state lost. Close and try again.'**
  String get prvBridgeStateLost;

  /// No description provided for @prvBridgeStepLock.
  ///
  /// In en, this message translates to:
  /// **'Lock your {amount} vBTC on VFX'**
  String prvBridgeStepLock(String amount);

  /// No description provided for @prvBridgeStepMint.
  ///
  /// In en, this message translates to:
  /// **'Submit a mintWithProof transaction on Base (paid from your derived Base address)'**
  String get prvBridgeStepMint;

  /// No description provided for @prvBridgeStepWaitSignatures.
  ///
  /// In en, this message translates to:
  /// **'Wait for validator signatures'**
  String get prvBridgeStepWaitSignatures;

  /// No description provided for @prvBridgeSuccessAmount.
  ///
  /// In en, this message translates to:
  /// **'You now have {amount} vBTC.b on Base'**
  String prvBridgeSuccessAmount(String amount);

  /// No description provided for @prvBridgeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridged to Base'**
  String get prvBridgeSuccessTitle;

  /// No description provided for @prvBridgeThisWill.
  ///
  /// In en, this message translates to:
  /// **'This will:'**
  String get prvBridgeThisWill;

  /// No description provided for @prvBridgeToBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Bridge to Base'**
  String get prvBridgeToBaseTitle;

  /// No description provided for @prvBridgeToDestOnBase.
  ///
  /// In en, this message translates to:
  /// **'to {dest} on Base'**
  String prvBridgeToDestOnBase(String dest);

  /// No description provided for @prvBridgeTxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tx'**
  String get prvBridgeTxLabel;

  /// No description provided for @prvBridgeUnavailableCli.
  ///
  /// In en, this message translates to:
  /// **'Bridging is currently unavailable. The CLI is not configured to talk to Base.'**
  String get prvBridgeUnavailableCli;

  /// No description provided for @prvBridgeUnavailableNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Bridge unavailable — your Base address couldn\'t be derived. This usually means the wallet is locked. Unlock your wallet and try again.'**
  String get prvBridgeUnavailableNoAddress;

  /// No description provided for @prvBridgeUseDefiTo.
  ///
  /// In en, this message translates to:
  /// **'Use your DeFi provider or another Base (EVM) wallet to:'**
  String get prvBridgeUseDefiTo;

  /// No description provided for @prvBridgeVbtcbAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC.b'**
  String prvBridgeVbtcbAmount(String amount);

  /// No description provided for @prvBridgeVbtcbBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'vBTC.b balance'**
  String get prvBridgeVbtcbBalanceLabel;

  /// No description provided for @prvBridgeViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get prvBridgeViewDetails;

  /// No description provided for @prvBridgeViewOnBasescan.
  ///
  /// In en, this message translates to:
  /// **'View on Basescan'**
  String get prvBridgeViewOnBasescan;

  /// No description provided for @prvBridgeWhatsNext.
  ///
  /// In en, this message translates to:
  /// **'What\'s next?'**
  String get prvBridgeWhatsNext;

  /// No description provided for @prvBridgeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get prvBridgeYesterday;

  /// No description provided for @prvBridgeYourBaseAddress.
  ///
  /// In en, this message translates to:
  /// **'Your Base address'**
  String get prvBridgeYourBaseAddress;

  /// No description provided for @prvBridgeYourGasAddress.
  ///
  /// In en, this message translates to:
  /// **'Your gas address'**
  String get prvBridgeYourGasAddress;

  /// No description provided for @prvBridging.
  ///
  /// In en, this message translates to:
  /// **'Bridging…'**
  String get prvBridging;

  /// No description provided for @prvCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking privacy layer status...'**
  String get prvCheckingStatus;

  /// No description provided for @prvChooseVbtcContract.
  ///
  /// In en, this message translates to:
  /// **'Choose which vBTC contract to resync.'**
  String get prvChooseVbtcContract;

  /// No description provided for @prvConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get prvConfirmPasswordLabel;

  /// No description provided for @prvConfirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get prvConfirmPasswordTitle;

  /// No description provided for @prvConsolidateAction.
  ///
  /// In en, this message translates to:
  /// **'Consolidate'**
  String get prvConsolidateAction;

  /// No description provided for @prvConsolidateMinNotes.
  ///
  /// In en, this message translates to:
  /// **'At least 2 unspent notes are required to consolidate.'**
  String get prvConsolidateMinNotes;

  /// No description provided for @prvConsolidateNotesBody.
  ///
  /// In en, this message translates to:
  /// **'Merge your 2 smallest notes into a single note. This reduces dust and improves privacy.'**
  String get prvConsolidateNotesBody;

  /// No description provided for @prvConsolidateNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Consolidate Notes'**
  String get prvConsolidateNotesTitle;

  /// No description provided for @prvConsolidateVbtcNotesBody.
  ///
  /// In en, this message translates to:
  /// **'Merge your 2 smallest vBTC notes into a single note. This reduces dust and improves privacy.'**
  String get prvConsolidateVbtcNotesBody;

  /// No description provided for @prvConsolidateVbtcNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Consolidate vBTC Notes'**
  String get prvConsolidateVbtcNotesTitle;

  /// No description provided for @prvConsolidationBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Consolidation broadcast successfully'**
  String get prvConsolidationBroadcastSuccess;

  /// No description provided for @prvConsolidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Consolidation failed: {error}'**
  String prvConsolidationFailed(String error);

  /// No description provided for @prvContractName.
  ///
  /// In en, this message translates to:
  /// **'Contract: {name}'**
  String prvContractName(String name);

  /// No description provided for @prvCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get prvCopyAddress;

  /// No description provided for @prvCreatePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Create a password to secure your shielded wallet\'s spending key. You\'ll need this password to unshield, transfer, or consolidate funds.'**
  String get prvCreatePasswordBody;

  /// No description provided for @prvCreatePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Privacy Password'**
  String get prvCreatePasswordTitle;

  /// No description provided for @prvCurrentNotes.
  ///
  /// In en, this message translates to:
  /// **'Current notes: {count}'**
  String prvCurrentNotes(int count);

  /// No description provided for @prvEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get prvEnterValidAmount;

  /// No description provided for @prvEnterValidVfxAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid VFX address'**
  String get prvEnterValidVfxAddress;

  /// No description provided for @prvEnterValidZfxAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid zfx_ address'**
  String get prvEnterValidZfxAddress;

  /// No description provided for @prvEnterVfxAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter VFX address'**
  String get prvEnterVfxAddressHint;

  /// No description provided for @prvEnterViewingKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter the viewing key'**
  String get prvEnterViewingKey;

  /// No description provided for @prvErrorActivatingWallet.
  ///
  /// In en, this message translates to:
  /// **'Error activating privacy wallet: {error}'**
  String prvErrorActivatingWallet(String error);

  /// No description provided for @prvExportViewingKey.
  ///
  /// In en, this message translates to:
  /// **'Export Viewing Key'**
  String get prvExportViewingKey;

  /// No description provided for @prvExportViewingKeyBody.
  ///
  /// In en, this message translates to:
  /// **'Copy this key to import a view-only wallet on another device. This key can see balances but cannot spend.'**
  String get prvExportViewingKeyBody;

  /// No description provided for @prvFailedExportViewingKey.
  ///
  /// In en, this message translates to:
  /// **'Failed to export viewing key'**
  String get prvFailedExportViewingKey;

  /// No description provided for @prvFailedGenerateShieldedAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate shielded address'**
  String get prvFailedGenerateShieldedAddress;

  /// No description provided for @prvFailedImportViewingKey.
  ///
  /// In en, this message translates to:
  /// **'Failed to import viewing key'**
  String get prvFailedImportViewingKey;

  /// No description provided for @prvFeeDeductedFromShielded.
  ///
  /// In en, this message translates to:
  /// **'Fee: {fee} (deducted from shielded balance)'**
  String prvFeeDeductedFromShielded(String fee);

  /// No description provided for @prvFeeDeductedFromShieldedVfx.
  ///
  /// In en, this message translates to:
  /// **'Fee: {fee} (deducted from shielded VFX balance)'**
  String prvFeeDeductedFromShieldedVfx(String fee);

  /// No description provided for @prvFeeDeductedShieldedShort.
  ///
  /// In en, this message translates to:
  /// **'{fee} fee deducted from shielded balance.'**
  String prvFeeDeductedShieldedShort(String fee);

  /// No description provided for @prvFeeDeductedShieldedVfxLong.
  ///
  /// In en, this message translates to:
  /// **'A fee of {fee} will be deducted from your shielded VFX balance.'**
  String prvFeeDeductedShieldedVfxLong(String fee);

  /// No description provided for @prvFromAddress.
  ///
  /// In en, this message translates to:
  /// **'From: {address}'**
  String prvFromAddress(String address);

  /// No description provided for @prvImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get prvImportAction;

  /// No description provided for @prvImportViewingKey.
  ///
  /// In en, this message translates to:
  /// **'Import Viewing Key'**
  String get prvImportViewingKey;

  /// No description provided for @prvImportViewingKeyBody.
  ///
  /// In en, this message translates to:
  /// **'Import a viewing key to create a view-only wallet. You can see balances but cannot spend.'**
  String get prvImportViewingKeyBody;

  /// No description provided for @prvInsufficientVfxFee.
  ///
  /// In en, this message translates to:
  /// **'Insufficient shielded VFX to cover the privacy transaction fee.'**
  String get prvInsufficientVfxFee;

  /// No description provided for @prvLayerStartingUp.
  ///
  /// In en, this message translates to:
  /// **'Privacy Layer Starting Up'**
  String get prvLayerStartingUp;

  /// No description provided for @prvMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get prvMax;

  /// No description provided for @prvMinHint.
  ///
  /// In en, this message translates to:
  /// **'Min: {amount}'**
  String prvMinHint(String amount);

  /// No description provided for @prvMinShieldAmountVbtc.
  ///
  /// In en, this message translates to:
  /// **'Minimum shield amount is {amount} vBTC'**
  String prvMinShieldAmountVbtc(String amount);

  /// No description provided for @prvMinShieldAmountVfx.
  ///
  /// In en, this message translates to:
  /// **'Minimum shield amount is {amount} VFX'**
  String prvMinShieldAmountVfx(String amount);

  /// No description provided for @prvNoAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found'**
  String get prvNoAccountsFound;

  /// No description provided for @prvNoShieldedAddress.
  ///
  /// In en, this message translates to:
  /// **'No shielded address found'**
  String get prvNoShieldedAddress;

  /// No description provided for @prvNoVbtcTokens.
  ///
  /// In en, this message translates to:
  /// **'No vBTC tokens found'**
  String get prvNoVbtcTokens;

  /// No description provided for @prvNoWalletSelected.
  ///
  /// In en, this message translates to:
  /// **'No wallet selected'**
  String get prvNoWalletSelected;

  /// No description provided for @prvNoteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} note} other{{count} notes}}'**
  String prvNoteCount(int count);

  /// No description provided for @prvPasswordConfirmationFailed.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation failed'**
  String get prvPasswordConfirmationFailed;

  /// No description provided for @prvPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get prvPasswordLabel;

  /// No description provided for @prvPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Privacy wallet password required. Please unlock first.'**
  String get prvPasswordRequired;

  /// No description provided for @prvPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get prvPasswordsDoNotMatch;

  /// No description provided for @prvPasteBase64Hint.
  ///
  /// In en, this message translates to:
  /// **'Paste Base64 key here'**
  String get prvPasteBase64Hint;

  /// No description provided for @prvPlonkInitializing.
  ///
  /// In en, this message translates to:
  /// **'The PLONK proof system is initializing. This may take a moment\nwhile cryptographic parameters are loaded.'**
  String get prvPlonkInitializing;

  /// No description provided for @prvPrismLayerTitle.
  ///
  /// In en, this message translates to:
  /// **'PRISM Privacy Layer'**
  String get prvPrismLayerTitle;

  /// No description provided for @prvPrivateTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Private Transfer'**
  String get prvPrivateTransferTitle;

  /// No description provided for @prvPrivateTransferVbtcBody.
  ///
  /// In en, this message translates to:
  /// **'Transfer shielded vBTC to another zfx_ address. Fully private.'**
  String get prvPrivateTransferVbtcBody;

  /// No description provided for @prvPrivateTransferVbtcTitle.
  ///
  /// In en, this message translates to:
  /// **'Private Transfer vBTC'**
  String get prvPrivateTransferVbtcTitle;

  /// No description provided for @prvPrivateTransferVfxBody.
  ///
  /// In en, this message translates to:
  /// **'Transfer shielded VFX to another zfx_ address. Fully private.'**
  String get prvPrivateTransferVfxBody;

  /// No description provided for @prvRecipientInvalidZfx.
  ///
  /// In en, this message translates to:
  /// **'Recipient must be a valid zfx_ address'**
  String get prvRecipientInvalidZfx;

  /// No description provided for @prvRecipientZfxLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient (zfx_ address)'**
  String get prvRecipientZfxLabel;

  /// No description provided for @prvRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get prvRefresh;

  /// No description provided for @prvResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get prvResetAction;

  /// No description provided for @prvResetPrivacyWallet.
  ///
  /// In en, this message translates to:
  /// **'Reset Privacy Wallet'**
  String get prvResetPrivacyWallet;

  /// No description provided for @prvResetWalletBody.
  ///
  /// In en, this message translates to:
  /// **'This will clear your local privacy wallet state and return to the activation screen. Your shielded funds on the network are not affected — you can re-activate with the same account to recover them.\n\nContinue?'**
  String get prvResetWalletBody;

  /// No description provided for @prvResyncAction.
  ///
  /// In en, this message translates to:
  /// **'Resync'**
  String get prvResyncAction;

  /// No description provided for @prvResyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Resync complete'**
  String get prvResyncComplete;

  /// No description provided for @prvResyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Resync failed'**
  String get prvResyncFailed;

  /// No description provided for @prvResyncShieldedWalletBody.
  ///
  /// In en, this message translates to:
  /// **'This will wipe all cached notes and balances, then rescan from the beginning. This may take a while.\n\nContinue?'**
  String get prvResyncShieldedWalletBody;

  /// No description provided for @prvResyncShieldedWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Resync Shielded Wallet'**
  String get prvResyncShieldedWalletTitle;

  /// No description provided for @prvResyncStarted.
  ///
  /// In en, this message translates to:
  /// **'Resync started...'**
  String get prvResyncStarted;

  /// No description provided for @prvResyncVbtcBody.
  ///
  /// In en, this message translates to:
  /// **'This will wipe cached notes and balances for \"{name}\" and rescan from the beginning. This may take a while.\n\nContinue?'**
  String prvResyncVbtcBody(String name);

  /// No description provided for @prvResyncVbtcWallet.
  ///
  /// In en, this message translates to:
  /// **'Resync vBTC Wallet'**
  String get prvResyncVbtcWallet;

  /// No description provided for @prvResyncWallet.
  ///
  /// In en, this message translates to:
  /// **'Resync Wallet'**
  String get prvResyncWallet;

  /// No description provided for @prvRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get prvRetry;

  /// No description provided for @prvScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'PRISM Privacy'**
  String get prvScreenTitle;

  /// No description provided for @prvSelectFromAccounts.
  ///
  /// In en, this message translates to:
  /// **'Select from my accounts'**
  String get prvSelectFromAccounts;

  /// No description provided for @prvSelectVbtcContract.
  ///
  /// In en, this message translates to:
  /// **'Select vBTC Contract'**
  String get prvSelectVbtcContract;

  /// No description provided for @prvSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get prvSettingsTooltip;

  /// No description provided for @prvShieldAction.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get prvShieldAction;

  /// No description provided for @prvShieldBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shield transaction broadcast successfully'**
  String get prvShieldBroadcastSuccess;

  /// No description provided for @prvShieldFailed.
  ///
  /// In en, this message translates to:
  /// **'Shield failed: {error}'**
  String prvShieldFailed(String error);

  /// No description provided for @prvShieldVbtcBody.
  ///
  /// In en, this message translates to:
  /// **'Move vBTC from your transparent wallet into the shielded pool.'**
  String get prvShieldVbtcBody;

  /// No description provided for @prvShieldVbtcTitle.
  ///
  /// In en, this message translates to:
  /// **'Shield vBTC'**
  String get prvShieldVbtcTitle;

  /// No description provided for @prvShieldVfxBody.
  ///
  /// In en, this message translates to:
  /// **'Move VFX from your transparent wallet into the shielded pool.'**
  String get prvShieldVfxBody;

  /// No description provided for @prvShieldVfxTitle.
  ///
  /// In en, this message translates to:
  /// **'Shield VFX'**
  String get prvShieldVfxTitle;

  /// No description provided for @prvShieldedAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Shielded Address'**
  String get prvShieldedAddressLabel;

  /// No description provided for @prvShieldedBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Shielded Balance'**
  String get prvShieldedBalanceLabel;

  /// No description provided for @prvShieldedVbtcHeading.
  ///
  /// In en, this message translates to:
  /// **'Shielded vBTC'**
  String get prvShieldedVbtcHeading;

  /// No description provided for @prvShieldedVfxRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'vBTC privacy operations require a small fee paid from your shielded VFX balance.\n\nYou currently have {balance} shielded VFX.\nPlease shield at least {fee} first.'**
  String prvShieldedVfxRequiredBody(String balance, String fee);

  /// No description provided for @prvShieldedVfxRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Shielded VFX Required'**
  String get prvShieldedVfxRequiredTitle;

  /// No description provided for @prvToAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'To Address (transparent)'**
  String get prvToAddressLabel;

  /// No description provided for @prvTransferAction.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get prvTransferAction;

  /// No description provided for @prvTransferBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Private transfer broadcast successfully'**
  String get prvTransferBroadcastSuccess;

  /// No description provided for @prvTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Private transfer failed: {error}'**
  String prvTransferFailed(String error);

  /// No description provided for @prvTransparentFeeAutoCalc.
  ///
  /// In en, this message translates to:
  /// **'Transparent network fee will be auto-calculated.'**
  String get prvTransparentFeeAutoCalc;

  /// No description provided for @prvTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get prvTryAgain;

  /// No description provided for @prvUnlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get prvUnlockAction;

  /// No description provided for @prvUnlockBannerText.
  ///
  /// In en, this message translates to:
  /// **'Enter your privacy password to unlock spending operations.'**
  String get prvUnlockBannerText;

  /// No description provided for @prvUnlockWalletBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your privacy wallet password to enable spending.'**
  String get prvUnlockWalletBody;

  /// No description provided for @prvUnlockWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Privacy Wallet'**
  String get prvUnlockWalletTitle;

  /// No description provided for @prvUnshieldAction.
  ///
  /// In en, this message translates to:
  /// **'Unshield'**
  String get prvUnshieldAction;

  /// No description provided for @prvUnshieldBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Unshield transaction broadcast successfully'**
  String get prvUnshieldBroadcastSuccess;

  /// No description provided for @prvUnshieldFailed.
  ///
  /// In en, this message translates to:
  /// **'Unshield failed: {error}'**
  String prvUnshieldFailed(String error);

  /// No description provided for @prvUnshieldVbtcBody.
  ///
  /// In en, this message translates to:
  /// **'Move vBTC from the shielded pool back to a transparent address.'**
  String get prvUnshieldVbtcBody;

  /// No description provided for @prvUnshieldVbtcTitle.
  ///
  /// In en, this message translates to:
  /// **'Unshield vBTC'**
  String get prvUnshieldVbtcTitle;

  /// No description provided for @prvUnshieldVfxBody.
  ///
  /// In en, this message translates to:
  /// **'Move VFX from the shielded pool back to a transparent address.'**
  String get prvUnshieldVfxBody;

  /// No description provided for @prvUnshieldVfxTitle.
  ///
  /// In en, this message translates to:
  /// **'Unshield VFX'**
  String get prvUnshieldVfxTitle;

  /// No description provided for @prvVbtcAmountSuffix.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC'**
  String prvVbtcAmountSuffix(String amount);

  /// No description provided for @prvVbtcConsolidationBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC consolidation broadcast successfully'**
  String get prvVbtcConsolidationBroadcastSuccess;

  /// No description provided for @prvVbtcConsolidationFailed.
  ///
  /// In en, this message translates to:
  /// **'vBTC consolidation failed: {error}'**
  String prvVbtcConsolidationFailed(String error);

  /// No description provided for @prvVbtcResyncComplete.
  ///
  /// In en, this message translates to:
  /// **'vBTC resync complete'**
  String get prvVbtcResyncComplete;

  /// No description provided for @prvVbtcResyncFailed.
  ///
  /// In en, this message translates to:
  /// **'vBTC resync failed'**
  String get prvVbtcResyncFailed;

  /// No description provided for @prvVbtcResyncStarted.
  ///
  /// In en, this message translates to:
  /// **'vBTC resync started...'**
  String get prvVbtcResyncStarted;

  /// No description provided for @prvVbtcShieldBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC shield transaction broadcast successfully'**
  String get prvVbtcShieldBroadcastSuccess;

  /// No description provided for @prvVbtcShieldFailed.
  ///
  /// In en, this message translates to:
  /// **'vBTC shield failed: {error}'**
  String prvVbtcShieldFailed(String error);

  /// No description provided for @prvVbtcTransferBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC private transfer broadcast successfully'**
  String get prvVbtcTransferBroadcastSuccess;

  /// No description provided for @prvVbtcTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'vBTC private transfer failed: {error}'**
  String prvVbtcTransferFailed(String error);

  /// No description provided for @prvVbtcUnshieldBroadcastSuccess.
  ///
  /// In en, this message translates to:
  /// **'vBTC unshield transaction broadcast successfully'**
  String get prvVbtcUnshieldBroadcastSuccess;

  /// No description provided for @prvVbtcUnshieldFailed.
  ///
  /// In en, this message translates to:
  /// **'vBTC unshield failed: {error}'**
  String prvVbtcUnshieldFailed(String error);

  /// No description provided for @prvVfxAmountSuffix.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX'**
  String prvVfxAmountSuffix(String amount);

  /// No description provided for @prvViewOnly.
  ///
  /// In en, this message translates to:
  /// **'VIEW ONLY'**
  String get prvViewOnly;

  /// No description provided for @prvViewingKeyBase64Label.
  ///
  /// In en, this message translates to:
  /// **'Viewing Key (Base64)'**
  String get prvViewingKeyBase64Label;

  /// No description provided for @prvViewingKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Viewing key copied to clipboard'**
  String get prvViewingKeyCopied;

  /// No description provided for @prvViewingKeyImported.
  ///
  /// In en, this message translates to:
  /// **'Viewing key imported successfully'**
  String get prvViewingKeyImported;

  /// No description provided for @prvViewingKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewing Key'**
  String get prvViewingKeyTitle;

  /// No description provided for @prvWalletActivated.
  ///
  /// In en, this message translates to:
  /// **'Privacy wallet activated: {address}'**
  String prvWalletActivated(String address);

  /// No description provided for @prvWalletReset.
  ///
  /// In en, this message translates to:
  /// **'Privacy wallet reset'**
  String get prvWalletReset;

  /// No description provided for @prvWalletUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Privacy wallet unlocked'**
  String get prvWalletUnlocked;

  /// No description provided for @prvZfxAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'zfx_ Address'**
  String get prvZfxAddressLabel;

  /// No description provided for @svcActionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get svcActionUpdate;

  /// No description provided for @svcActivateVaultBeforeProceeding.
  ///
  /// In en, this message translates to:
  /// **'You must activate your Vault Account before proceeding.'**
  String get svcActivateVaultBeforeProceeding;

  /// No description provided for @svcAddressOrDomainRequired.
  ///
  /// In en, this message translates to:
  /// **'Address or VFX domain required'**
  String get svcAddressOrDomainRequired;

  /// No description provided for @svcAdnrDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this VFX Domain?\n{costLine}\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.'**
  String svcAdnrDeleteConfirmBody(String costLine);

  /// No description provided for @svcAdnrDeleteNoCost.
  ///
  /// In en, this message translates to:
  /// **'There is no cost to delete a VFX Domain (aside from the TX fee).'**
  String get svcAdnrDeleteNoCost;

  /// No description provided for @svcAdnrDeleteWithCost.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} RBX to delete an RBX Domain.'**
  String svcAdnrDeleteWithCost(String cost);

  /// No description provided for @svcAdnrFundNeededBody.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have the required funds to buy the domain in this account.'**
  String get svcAdnrFundNeededBody;

  /// No description provided for @svcAdnrSufficientBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'You have an account with a sufficient balance.\n\nWould you like to send 6 VFX from:\n{fromAddress}\n[Balance: {balance} VFX]?'**
  String svcAdnrSufficientBalanceBody(String fromAddress, String balance);

  /// No description provided for @svcAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'The amount has to be a positive value'**
  String get svcAmountPositive;

  /// No description provided for @svcAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount required'**
  String get svcAmountRequired;

  /// No description provided for @svcAssetsRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Assets Request failed.'**
  String get svcAssetsRequestFailed;

  /// No description provided for @svcBalanceRowFromTo.
  ///
  /// In en, this message translates to:
  /// **'From: {from}\nTo: {to}'**
  String svcBalanceRowFromTo(String from, String to);

  /// No description provided for @svcBeaconSignatureError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t produce beacon upload signature'**
  String get svcBeaconSignatureError;

  /// No description provided for @svcBeaconUploadRequestError.
  ///
  /// In en, this message translates to:
  /// **'Could not create beacon upload request.'**
  String get svcBeaconUploadRequestError;

  /// No description provided for @svcBtcAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'BTC Address required'**
  String get svcBtcAddressRequired;

  /// No description provided for @svcBtcSentToAddress.
  ///
  /// In en, this message translates to:
  /// **'{amount} BTC has been sent to {address}.'**
  String svcBtcSentToAddress(String amount, String address);

  /// No description provided for @svcCliRestartRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'A restart of the CLI is required. Restart Now?'**
  String get svcCliRestartRequiredBody;

  /// No description provided for @svcCliUpdateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A CLI update is available. Download and install now?'**
  String get svcCliUpdateAvailableBody;

  /// No description provided for @svcCliUpdateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'CLI Update Available'**
  String get svcCliUpdateAvailableTitle;

  /// No description provided for @svcCliUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'CLI Updated'**
  String get svcCliUpdatedTitle;

  /// No description provided for @svcComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get svcComplete;

  /// No description provided for @svcCouldNotParseEncryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not parse encrypted message'**
  String get svcCouldNotParseEncryptedMessage;

  /// No description provided for @svcCsvHeadersInvalid.
  ///
  /// In en, this message translates to:
  /// **'The CSV headers are not in the correct format, please check the example file'**
  String get svcCsvHeadersInvalid;

  /// No description provided for @svcDecryptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to decrypt message. Invalid key or corrupted data.'**
  String get svcDecryptFailed;

  /// No description provided for @svcFailedParseFee.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse fee'**
  String get svcFailedParseFee;

  /// No description provided for @svcFailedParseHash.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse hash'**
  String get svcFailedParseHash;

  /// No description provided for @svcFailedRetrieveFee.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve fee'**
  String get svcFailedRetrieveFee;

  /// No description provided for @svcFailedRetrieveNonce.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve nonce'**
  String get svcFailedRetrieveNonce;

  /// No description provided for @svcFailedRetrieveTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve timestamp'**
  String get svcFailedRetrieveTimestamp;

  /// No description provided for @svcGuiUpdateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A GUI update is available. Download now?'**
  String get svcGuiUpdateAvailableBody;

  /// No description provided for @svcGuiUpdateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'GUI Update Available'**
  String get svcGuiUpdateAvailableTitle;

  /// No description provided for @svcGuiUpdateLaunchBody.
  ///
  /// In en, this message translates to:
  /// **'The VFX GUI download will be launched in your browser. Once launched, the CLI will be shutdown and your wallet will be closed to ensure a safe update.'**
  String get svcGuiUpdateLaunchBody;

  /// No description provided for @svcGuiUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'GUI Update'**
  String get svcGuiUpdateTitle;

  /// No description provided for @svcImBackedUp.
  ///
  /// In en, this message translates to:
  /// **'I\'m Backed Up'**
  String get svcImBackedUp;

  /// No description provided for @svcImportSnapshotBody.
  ///
  /// In en, this message translates to:
  /// **'You are only at {blockHeight} block height locally. The network has a snapshot at {snapshotHeight} block height that will help you sync more quickly. \n\nWould you like to import it now?'**
  String svcImportSnapshotBody(String blockHeight, String snapshotHeight);

  /// No description provided for @svcImportSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Snapshot?'**
  String get svcImportSnapshotTitle;

  /// No description provided for @svcInsufficientBalanceToSend.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance to send'**
  String get svcInsufficientBalanceToSend;

  /// No description provided for @svcInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON'**
  String get svcInvalidJson;

  /// No description provided for @svcLocatorsRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Locators request failed.'**
  String get svcLocatorsRequestFailed;

  /// No description provided for @svcMainMenuSyncTooltip.
  ///
  /// In en, this message translates to:
  /// **'Last Sync: {lastSync}\nNext Sync: {nextSync}'**
  String svcMainMenuSyncTooltip(String lastSync, String nextSync);

  /// No description provided for @svcMessageDecryptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message decrypted successfully!'**
  String get svcMessageDecryptedSuccess;

  /// No description provided for @svcMinTxAmountBtc.
  ///
  /// In en, this message translates to:
  /// **'The minimum transaction amount is {amount} BTC'**
  String svcMinTxAmountBtc(String amount);

  /// No description provided for @svcMintingProgress.
  ///
  /// In en, this message translates to:
  /// **'Minting {current}/{total}...'**
  String svcMintingProgress(String current, String total);

  /// No description provided for @svcNavPrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get svcNavPrivacyLabel;

  /// No description provided for @svcNftNotEnoughVfxAction.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX to do this action'**
  String get svcNftNotEnoughVfxAction;

  /// No description provided for @svcNftNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'NFT not loaded'**
  String get svcNftNotLoaded;

  /// No description provided for @svcNftNotOwner.
  ///
  /// In en, this message translates to:
  /// **'You are not the owner of this NFT.'**
  String get svcNftNotOwner;

  /// No description provided for @svcNftNotOwnerOrMinter.
  ///
  /// In en, this message translates to:
  /// **'You are not the owner or minter of this NFT.'**
  String get svcNftNotOwnerOrMinter;

  /// No description provided for @svcNoAccountSelectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'No account selected.'**
  String get svcNoAccountSelectedPeriod;

  /// No description provided for @svcNoBtcAccount.
  ///
  /// In en, this message translates to:
  /// **'No BTC Account'**
  String get svcNoBtcAccount;

  /// No description provided for @svcNoEncryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'No encrypted message found'**
  String get svcNoEncryptedMessage;

  /// No description provided for @svcNotEnoughBalanceAccount.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance in account.'**
  String get svcNotEnoughBalanceAccount;

  /// No description provided for @svcNotEnoughBalanceBtcAccount.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance in BTC account'**
  String get svcNotEnoughBalanceBtcAccount;

  /// No description provided for @svcNotValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Not a valid amount'**
  String get svcNotValidAmount;

  /// No description provided for @svcNotifBtcDomainCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain created for {name}.btc'**
  String svcNotifBtcDomainCreatedBody(String name);

  /// No description provided for @svcNotifBtcDomainCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Name Created'**
  String get svcNotifBtcDomainCreatedTitle;

  /// No description provided for @svcNotifBtcDomainDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain deleted for {name}'**
  String svcNotifBtcDomainDeletedBody(String name);

  /// No description provided for @svcNotifBtcDomainDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Name Deleted'**
  String get svcNotifBtcDomainDeletedTitle;

  /// No description provided for @svcNotifBtcDomainTransferredTitle.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Name Transferred'**
  String get svcNotifBtcDomainTransferredTitle;

  /// No description provided for @svcNotifDecShopTxBody.
  ///
  /// In en, this message translates to:
  /// **'DecShop TX Complete'**
  String get svcNotifDecShopTxBody;

  /// No description provided for @svcNotifDecShopTxTitle.
  ///
  /// In en, this message translates to:
  /// **'DecShop TX'**
  String get svcNotifDecShopTxTitle;

  /// No description provided for @svcNotifDomainCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Domain Name Created'**
  String get svcNotifDomainCreatedTitle;

  /// No description provided for @svcNotifDomainDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Domain Name Deleted'**
  String get svcNotifDomainDeletedTitle;

  /// No description provided for @svcNotifDomainTransferredTitle.
  ///
  /// In en, this message translates to:
  /// **'Domain Name Transferred'**
  String get svcNotifDomainTransferredTitle;

  /// No description provided for @svcNotifFundsReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX from {fromAddress}'**
  String svcNotifFundsReceivedBody(String amount, String fromAddress);

  /// No description provided for @svcNotifFundsReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Funds Received'**
  String get svcNotifFundsReceivedTitle;

  /// No description provided for @svcNotifFundsSentBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX to {toAddress}'**
  String svcNotifFundsSentBody(String amount, String toAddress);

  /// No description provided for @svcNotifNftBurnedTitle.
  ///
  /// In en, this message translates to:
  /// **'NFT Burned'**
  String get svcNotifNftBurnedTitle;

  /// No description provided for @svcNotifNftEvolvedBody.
  ///
  /// In en, this message translates to:
  /// **'NFT evolved to state {state}.'**
  String svcNotifNftEvolvedBody(String state);

  /// No description provided for @svcNotifNftEvolvedTitle.
  ///
  /// In en, this message translates to:
  /// **'NFT Evolved'**
  String get svcNotifNftEvolvedTitle;

  /// No description provided for @svcNotifNftMintedTitle.
  ///
  /// In en, this message translates to:
  /// **'NFT Minted'**
  String get svcNotifNftMintedTitle;

  /// No description provided for @svcNotifNftReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'NFT from {fromAddress}'**
  String svcNotifNftReceivedBody(String fromAddress);

  /// No description provided for @svcNotifNftReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'NFT Received'**
  String get svcNotifNftReceivedTitle;

  /// No description provided for @svcNotifNftSentBody.
  ///
  /// In en, this message translates to:
  /// **'NFT to {toAddress}'**
  String svcNotifNftSentBody(String toAddress);

  /// No description provided for @svcNotifNftSentTitle.
  ///
  /// In en, this message translates to:
  /// **'NFT Sent'**
  String get svcNotifNftSentTitle;

  /// No description provided for @svcNotifPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get svcNotifPaused;

  /// No description provided for @svcNotifResumed.
  ///
  /// In en, this message translates to:
  /// **'Resumed'**
  String get svcNotifResumed;

  /// No description provided for @svcNotifSaleCompletedManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Completed (Manual)'**
  String get svcNotifSaleCompletedManualTitle;

  /// No description provided for @svcNotifSaleCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Completed'**
  String get svcNotifSaleCompletedTitle;

  /// No description provided for @svcNotifSaleStartedManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Started (Manual)'**
  String get svcNotifSaleStartedManualTitle;

  /// No description provided for @svcNotifSaleStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Started'**
  String get svcNotifSaleStartedTitle;

  /// No description provided for @svcNotifTokenBanAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Ban Address'**
  String get svcNotifTokenBanAddressTitle;

  /// No description provided for @svcNotifTokenBurnTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Burn'**
  String get svcNotifTokenBurnTitle;

  /// No description provided for @svcNotifTokenChangeOwnershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Change Ownership'**
  String get svcNotifTokenChangeOwnershipTitle;

  /// No description provided for @svcNotifTokenDeployedTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Deployed'**
  String get svcNotifTokenDeployedTitle;

  /// No description provided for @svcNotifTokenPauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Pause'**
  String get svcNotifTokenPauseTitle;

  /// No description provided for @svcNotifTokenTopicCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Topic Created'**
  String get svcNotifTokenTopicCreatedTitle;

  /// No description provided for @svcNotifTokenTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Transfer'**
  String get svcNotifTokenTransferTitle;

  /// No description provided for @svcNotifTokenVoteCastTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Vote Cast'**
  String get svcNotifTokenVoteCastTitle;

  /// No description provided for @svcNotifTokensMintedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tokens Minted'**
  String get svcNotifTokensMintedTitle;

  /// No description provided for @svcNotifTopicCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'Topic {name} Created.'**
  String svcNotifTopicCreatedBody(String name);

  /// No description provided for @svcNotifTopicCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic Created'**
  String get svcNotifTopicCreatedTitle;

  /// No description provided for @svcNotifVbtcTokenizationMintTitle.
  ///
  /// In en, this message translates to:
  /// **'vBTC Tokenization Mint'**
  String get svcNotifVbtcTokenizationMintTitle;

  /// No description provided for @svcNotifVfxDomainCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain created for {name}.vfx'**
  String svcNotifVfxDomainCreatedBody(String name);

  /// No description provided for @svcNotifVfxDomainDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain deleted for {name}'**
  String svcNotifVfxDomainDeletedBody(String name);

  /// No description provided for @svcNotifVfxDomainTransferBody.
  ///
  /// In en, this message translates to:
  /// **'VFX Domain transfer for {name}'**
  String svcNotifVfxDomainTransferBody(String name);

  /// No description provided for @svcNotifVoteCastedBody.
  ///
  /// In en, this message translates to:
  /// **'Vote casted on {topic}'**
  String svcNotifVoteCastedBody(String topic);

  /// No description provided for @svcNotifVoteCastedTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote Casted'**
  String get svcNotifVoteCastedTitle;

  /// No description provided for @svcPrivateKeyNotAvailableUnlock.
  ///
  /// In en, this message translates to:
  /// **'Private key not available. Please ensure wallet is unlocked.'**
  String get svcPrivateKeyNotAvailableUnlock;

  /// No description provided for @svcPrivateKeyNotFoundRecipient.
  ///
  /// In en, this message translates to:
  /// **'Private key not found for recipient address'**
  String get svcPrivateKeyNotFoundRecipient;

  /// No description provided for @svcProblemDownloadingSkipping.
  ///
  /// In en, this message translates to:
  /// **'Problem downloading {url}. Skipping.'**
  String svcProblemDownloadingSkipping(String url);

  /// No description provided for @svcSendingConfirmBtcFee.
  ///
  /// In en, this message translates to:
  /// **'Sending:\n{amount} BTC\n\nTo:\n{toAddress}\n\nFrom:\n{fromAddress}\n\nFee:\n{fee} BTC'**
  String svcSendingConfirmBtcFee(String amount, String toAddress, String fromAddress, String fee);

  /// No description provided for @svcSendingConfirmBtcFeeRate.
  ///
  /// In en, this message translates to:
  /// **'Sending:\n{amount} BTC\n\nTo:\n{toAddress}\n\nFrom:\n{fromAddress}\n\nFeeRate:\n{feeRate} SATS'**
  String svcSendingConfirmBtcFeeRate(String amount, String toAddress, String fromAddress, String feeRate);

  /// No description provided for @svcSignatureGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Signature generation failed.'**
  String get svcSignatureGenerationFailed;

  /// No description provided for @svcSignatureNotValid.
  ///
  /// In en, this message translates to:
  /// **'Signature not valid'**
  String get svcSignatureNotValid;

  /// No description provided for @svcSnapshotBackupWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Be sure your private keys are backed up as this process will wipe your database folder.\n\nIf they are NOT backed up, click cancel now, back them up, and then restart your wallet to be prompted with this again.'**
  String get svcSnapshotBackupWarningBody;

  /// No description provided for @svcSnapshotDetermineStateError.
  ///
  /// In en, this message translates to:
  /// **'Could not determine latest snapshot state'**
  String get svcSnapshotDetermineStateError;

  /// No description provided for @svcSnapshotImportFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Snapshot import failed.'**
  String get svcSnapshotImportFailedBody;

  /// No description provided for @svcSnapshotImportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get svcSnapshotImportFailedTitle;

  /// No description provided for @svcSnapshotRestartTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please restart and try again.'**
  String get svcSnapshotRestartTryAgain;

  /// No description provided for @svcTimelockDuration.
  ///
  /// In en, this message translates to:
  /// **'Timelock Duration'**
  String get svcTimelockDuration;

  /// No description provided for @svcTimelockHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours (24 Minimum)'**
  String get svcTimelockHoursLabel;

  /// No description provided for @svcTokenAutoMintInitiated.
  ///
  /// In en, this message translates to:
  /// **'Token Auto Mint initiated. ({scId}: {amount})'**
  String svcTokenAutoMintInitiated(String scId, String amount);

  /// No description provided for @svcTransactionNotValid.
  ///
  /// In en, this message translates to:
  /// **'Transaction not valid'**
  String get svcTransactionNotValid;

  /// No description provided for @svcUnimplemented.
  ///
  /// In en, this message translates to:
  /// **'Unimplemented'**
  String get svcUnimplemented;

  /// No description provided for @svcValidTxConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This transaction is valid and is ready to send.\nAre you sure you want to proceed?\n\nTo: {toAddress}\n\nAmount: {amount} VFX'**
  String svcValidTxConfirmBody(String toAddress, String amount);

  /// No description provided for @svcValidTxFeeSuffix.
  ///
  /// In en, this message translates to:
  /// **'\nTX Fee: {fee} VFX\nTotal: {total} VFX'**
  String svcValidTxFeeSuffix(String fee, String total);

  /// No description provided for @svcVaultAutoActivationInitiated.
  ///
  /// In en, this message translates to:
  /// **'Vault Account Auto Activation process initiated'**
  String get svcVaultAutoActivationInitiated;

  /// No description provided for @svcVfxSentToAddress.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX sent to {address}'**
  String svcVfxSentToAddress(String amount, String address);

  /// No description provided for @svcVfxSentToAddressDashboard.
  ///
  /// In en, this message translates to:
  /// **'{amount} VFX has been sent to {address}. See dashboard for TX ID.'**
  String svcVfxSentToAddressDashboard(String amount, String address);

  /// No description provided for @r3aActivatingSoon.
  ///
  /// In en, this message translates to:
  /// **'Activating soon...'**
  String get r3aActivatingSoon;

  /// No description provided for @r3aAdditionalOwners.
  ///
  /// In en, this message translates to:
  /// **'Additional Owners'**
  String get r3aAdditionalOwners;

  /// No description provided for @r3aAssetIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Asset is required'**
  String get r3aAssetIsRequired;

  /// No description provided for @r3aAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get r3aAssets;

  /// No description provided for @r3aAutomatedAppControlled.
  ///
  /// In en, this message translates to:
  /// **'Automated/Application Controlled'**
  String get r3aAutomatedAppControlled;

  /// No description provided for @r3aBlockHeightMustBeGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Block height must be greater than {currentBh}.'**
  String r3aBlockHeightMustBeGreaterThan(String currentBh);

  /// No description provided for @r3aBtcTokenization.
  ///
  /// In en, this message translates to:
  /// **'BTC Tokenization'**
  String get r3aBtcTokenization;

  /// No description provided for @r3aChooseAFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a File'**
  String get r3aChooseAFile;

  /// No description provided for @r3aClearNftWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear NFT Collection Wizard?'**
  String get r3aClearNftWizardTitle;

  /// No description provided for @r3aCloseNftWizardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the NFT collection Wizard?'**
  String get r3aCloseNftWizardConfirm;

  /// No description provided for @r3aCloseScCreatorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the smart contract creator?'**
  String get r3aCloseScCreatorConfirm;

  /// No description provided for @r3aCompileMintScConfirm.
  ///
  /// In en, this message translates to:
  /// **'Compile & Mint Smart Contract?'**
  String get r3aCompileMintScConfirm;

  /// No description provided for @r3aConfirmMintBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed minting {amount} Smart Contract(s)?\n\nOnce compiled you will not be able to make any changes\nand the smart contract will be deployed to the chain.'**
  String r3aConfirmMintBody(String amount);

  /// No description provided for @r3aConsumable.
  ///
  /// In en, this message translates to:
  /// **'Consumable'**
  String get r3aConsumable;

  /// No description provided for @r3aCreateInstance.
  ///
  /// In en, this message translates to:
  /// **'Create Instance'**
  String get r3aCreateInstance;

  /// No description provided for @r3aCreateNewInstance.
  ///
  /// In en, this message translates to:
  /// **'Create New Instance'**
  String get r3aCreateNewInstance;

  /// No description provided for @r3aCreateNewPhase.
  ///
  /// In en, this message translates to:
  /// **'Create New Phase'**
  String get r3aCreateNewPhase;

  /// No description provided for @r3aCreateRarity.
  ///
  /// In en, this message translates to:
  /// **'Create Rarity'**
  String get r3aCreateRarity;

  /// No description provided for @r3aCreatorRetainedOwnership.
  ///
  /// In en, this message translates to:
  /// **'Creator Retained Ownership'**
  String get r3aCreatorRetainedOwnership;

  /// No description provided for @r3aDateMustBeInFuture.
  ///
  /// In en, this message translates to:
  /// **'Date must be in the future.'**
  String get r3aDateMustBeInFuture;

  /// No description provided for @r3aDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get r3aDateTime;

  /// No description provided for @r3aDeleteInstanceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this instance?'**
  String get r3aDeleteInstanceConfirm;

  /// No description provided for @r3aDeleteInstanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Instance?'**
  String get r3aDeleteInstanceTitle;

  /// No description provided for @r3aDeleteStage.
  ///
  /// In en, this message translates to:
  /// **'Delete Stage'**
  String get r3aDeleteStage;

  /// No description provided for @r3aDeleteThisStageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this stage?'**
  String get r3aDeleteThisStageConfirm;

  /// No description provided for @r3aDescriptionIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get r3aDescriptionIsRequired;

  /// No description provided for @r3aEditRarity.
  ///
  /// In en, this message translates to:
  /// **'Edit Rarity'**
  String get r3aEditRarity;

  /// No description provided for @r3aEvolutionTime.
  ///
  /// In en, this message translates to:
  /// **'Evolution Time ({tz})'**
  String r3aEvolutionTime(String tz);

  /// No description provided for @r3aEvolutionType.
  ///
  /// In en, this message translates to:
  /// **'Evolution Type'**
  String get r3aEvolutionType;

  /// No description provided for @r3aEvolveStageNumber.
  ///
  /// In en, this message translates to:
  /// **'Evolve Stage {number}'**
  String r3aEvolveStageNumber(String number);

  /// No description provided for @r3aEvolvingMode.
  ///
  /// In en, this message translates to:
  /// **'Evolving Mode'**
  String get r3aEvolvingMode;

  /// No description provided for @r3aFeatureDescBtcTokenization.
  ///
  /// In en, this message translates to:
  /// **'Tokenize BTC within a smart contract'**
  String get r3aFeatureDescBtcTokenization;

  /// No description provided for @r3aFeatureDescEvolution.
  ///
  /// In en, this message translates to:
  /// **'Allow the smart contract to evolve based on time or network variables'**
  String get r3aFeatureDescEvolution;

  /// No description provided for @r3aFeatureDescFractional.
  ///
  /// In en, this message translates to:
  /// **'Share ownership between multiple wallets and support voting'**
  String get r3aFeatureDescFractional;

  /// No description provided for @r3aFeatureDescMultiAsset.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple assets to be compiled into the smart contract'**
  String get r3aFeatureDescMultiAsset;

  /// No description provided for @r3aFeatureDescPair.
  ///
  /// In en, this message translates to:
  /// **'Pair/Wrap this smart contract with an existing NFT on or off this network'**
  String get r3aFeatureDescPair;

  /// No description provided for @r3aFeatureDescRoyalty.
  ///
  /// In en, this message translates to:
  /// **'Include a royalty that is enforced on-chain upon any trade'**
  String get r3aFeatureDescRoyalty;

  /// No description provided for @r3aFeatureDescSoulBound.
  ///
  /// In en, this message translates to:
  /// **'Create a non-transferrable smart contract bound to a perminent address'**
  String get r3aFeatureDescSoulBound;

  /// No description provided for @r3aFeatureDescTokenization.
  ///
  /// In en, this message translates to:
  /// **'Pair this smart contract with a physical/digital good'**
  String get r3aFeatureDescTokenization;

  /// No description provided for @r3aFeatureNameEvolving.
  ///
  /// In en, this message translates to:
  /// **'Evolving'**
  String get r3aFeatureNameEvolving;

  /// No description provided for @r3aInvalidHexColor.
  ///
  /// In en, this message translates to:
  /// **'Invalid hex color'**
  String get r3aInvalidHexColor;

  /// No description provided for @r3aInvalidSmartContract.
  ///
  /// In en, this message translates to:
  /// **'Invalid Smart Contract'**
  String get r3aInvalidSmartContract;

  /// No description provided for @r3aInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get r3aInvalidValue;

  /// No description provided for @r3aIssuerMinterControlled.
  ///
  /// In en, this message translates to:
  /// **'Issuer/Minter Controlled'**
  String get r3aIssuerMinterControlled;

  /// No description provided for @r3aLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get r3aLabel;

  /// No description provided for @r3aMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get r3aMint;

  /// No description provided for @r3aMintPhysicalRwa.
  ///
  /// In en, this message translates to:
  /// **'Mint a physical or Real World Asset'**
  String get r3aMintPhysicalRwa;

  /// No description provided for @r3aMinterAddressColon.
  ///
  /// In en, this message translates to:
  /// **'Minter Address:'**
  String get r3aMinterAddressColon;

  /// No description provided for @r3aMinterNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Minter name is required'**
  String get r3aMinterNameIsRequired;

  /// No description provided for @r3aMultiAsset.
  ///
  /// In en, this message translates to:
  /// **'Multi Asset'**
  String get r3aMultiAsset;

  /// No description provided for @r3aMusicRelease.
  ///
  /// In en, this message translates to:
  /// **'Music Release'**
  String get r3aMusicRelease;

  /// No description provided for @r3aNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get r3aNameIsRequired;

  /// No description provided for @r3aNewInstance.
  ///
  /// In en, this message translates to:
  /// **'New Instance'**
  String get r3aNewInstance;

  /// No description provided for @r3aNftAddress.
  ///
  /// In en, this message translates to:
  /// **'NFT Address'**
  String get r3aNftAddress;

  /// No description provided for @r3aNftCollectionWizard.
  ///
  /// In en, this message translates to:
  /// **'NFT Collection Wizard'**
  String get r3aNftCollectionWizard;

  /// No description provided for @r3aNotEnoughVfxToMint.
  ///
  /// In en, this message translates to:
  /// **'Not enough VFX balance to mint a smart contract.'**
  String get r3aNotEnoughVfxToMint;

  /// No description provided for @r3aNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented'**
  String get r3aNotImplemented;

  /// No description provided for @r3aOnlineEvent.
  ///
  /// In en, this message translates to:
  /// **'Online Event'**
  String get r3aOnlineEvent;

  /// No description provided for @r3aPhysicalEvent.
  ///
  /// In en, this message translates to:
  /// **'Physical Event'**
  String get r3aPhysicalEvent;

  /// No description provided for @r3aPrimaryAssetIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Primary Asset is required'**
  String get r3aPrimaryAssetIsRequired;

  /// No description provided for @r3aPrimaryAssetOverride.
  ///
  /// In en, this message translates to:
  /// **'Primary Asset Override'**
  String get r3aPrimaryAssetOverride;

  /// No description provided for @r3aRareness.
  ///
  /// In en, this message translates to:
  /// **'Rareness'**
  String get r3aRareness;

  /// No description provided for @r3aReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get r3aReason;

  /// No description provided for @r3aRemoveEverythingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove everything?'**
  String get r3aRemoveEverythingConfirm;

  /// No description provided for @r3aRequiredForBlockHeightEvolution.
  ///
  /// In en, this message translates to:
  /// **'Required for Block Height evolution.'**
  String get r3aRequiredForBlockHeightEvolution;

  /// No description provided for @r3aRequiredForDateTimeEvolution.
  ///
  /// In en, this message translates to:
  /// **'Required for Date/Time evolution.'**
  String get r3aRequiredForDateTimeEvolution;

  /// No description provided for @r3aSaveAndClose.
  ///
  /// In en, this message translates to:
  /// **'Save and Close'**
  String get r3aSaveAndClose;

  /// No description provided for @r3aSaveClose.
  ///
  /// In en, this message translates to:
  /// **'Save & Close'**
  String get r3aSaveClose;

  /// No description provided for @r3aSelfDestructive.
  ///
  /// In en, this message translates to:
  /// **'Self Destructive'**
  String get r3aSelfDestructive;

  /// No description provided for @r3aStatsOverride.
  ///
  /// In en, this message translates to:
  /// **'Stats Override'**
  String get r3aStatsOverride;

  /// No description provided for @r3aThumbnailOverride.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail Override'**
  String get r3aThumbnailOverride;

  /// No description provided for @r3aTicketing.
  ///
  /// In en, this message translates to:
  /// **'Ticketing'**
  String get r3aTicketing;

  /// No description provided for @r3aTimeMustBeInFuture.
  ///
  /// In en, this message translates to:
  /// **'Time must be in the future.'**
  String get r3aTimeMustBeInFuture;

  /// No description provided for @r3aToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get r3aToken;

  /// No description provided for @r3aTokenizationPhysicalDigital.
  ///
  /// In en, this message translates to:
  /// **'Tokenization of Physical/Digital Good'**
  String get r3aTokenizationPhysicalDigital;

  /// No description provided for @r3aValueIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Value is required'**
  String get r3aValueIsRequired;

  /// No description provided for @r3aViewCompiledSmartContract.
  ///
  /// In en, this message translates to:
  /// **'View Compiled Smart Contract'**
  String get r3aViewCompiledSmartContract;

  /// No description provided for @r3aWillBeMintedBy.
  ///
  /// In en, this message translates to:
  /// **'This will be minted by {name}'**
  String r3aWillBeMintedBy(String name);

  /// No description provided for @r3aWrap.
  ///
  /// In en, this message translates to:
  /// **'Wrap'**
  String get r3aWrap;

  /// No description provided for @r3bActionCreation.
  ///
  /// In en, this message translates to:
  /// **'creation'**
  String get r3bActionCreation;

  /// No description provided for @r3bActionEditing.
  ///
  /// In en, this message translates to:
  /// **'editing'**
  String get r3bActionEditing;

  /// No description provided for @r3bActionPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get r3bActionPublish;

  /// No description provided for @r3bActive.
  ///
  /// In en, this message translates to:
  /// **'Active:'**
  String get r3bActive;

  /// No description provided for @r3bAddBeaconDescription.
  ///
  /// In en, this message translates to:
  /// **'Add an existing beacon to foreign nodes to use that relay instead of default ones on the VFX network. Configure your wallet to use a remote beacon for media transferring rather than using the default VFX network beacons. You will need to know the IP address of the remote beacon. If that beacon is using the non-default port, provide that as well. The beacon name is a friendly name visible only to you.'**
  String get r3bAddBeaconDescription;

  /// No description provided for @r3bAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address Required.'**
  String get r3bAddressRequired;

  /// No description provided for @r3bAlreadyOwnerNft.
  ///
  /// In en, this message translates to:
  /// **'You are already the owner of this NFT.'**
  String get r3bAlreadyOwnerNft;

  /// No description provided for @r3bAmountValue.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String r3bAmountValue(String amount);

  /// No description provided for @r3bApproveSaleStart.
  ///
  /// In en, this message translates to:
  /// **'Please approve the Sale Start TX for your shop purchase.'**
  String get r3bApproveSaleStart;

  /// No description provided for @r3bAssetCache.
  ///
  /// In en, this message translates to:
  /// **'Asset Cache'**
  String get r3bAssetCache;

  /// No description provided for @r3bAuctionEnds.
  ///
  /// In en, this message translates to:
  /// **'Auction Ends'**
  String get r3bAuctionEnds;

  /// No description provided for @r3bAutoDeleteAssets.
  ///
  /// In en, this message translates to:
  /// **'Auto Delete Assets'**
  String get r3bAutoDeleteAssets;

  /// No description provided for @r3bBaselineAsset.
  ///
  /// In en, this message translates to:
  /// **'Baseline Asset'**
  String get r3bBaselineAsset;

  /// No description provided for @r3bBeaconUploadSigFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t produce beacon upload signature'**
  String get r3bBeaconUploadSigFailed;

  /// No description provided for @r3bBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Bid Amount'**
  String get r3bBidAmount;

  /// No description provided for @r3bBidNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: Bid not found.'**
  String get r3bBidNotFound;

  /// No description provided for @r3bBuyNowTag.
  ///
  /// In en, this message translates to:
  /// **'[Buy Now]'**
  String get r3bBuyNowTag;

  /// No description provided for @r3bBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer: {address}'**
  String r3bBuyerLabel(String address);

  /// No description provided for @r3bChain.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get r3bChain;

  /// No description provided for @r3bCloseCollectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the collection {action} screen?'**
  String r3bCloseCollectionConfirm(String action);

  /// No description provided for @r3bCloseShopConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the shop {action} screen?'**
  String r3bCloseShopConfirm(String action);

  /// No description provided for @r3bCloseStoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the store {action} screen?'**
  String r3bCloseStoreConfirm(String action);

  /// No description provided for @r3bCollectionCreatedToast.
  ///
  /// In en, this message translates to:
  /// **'Collection Created'**
  String get r3bCollectionCreatedToast;

  /// No description provided for @r3bCollectionUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Collection Updated!'**
  String get r3bCollectionUpdatedToast;

  /// No description provided for @r3bCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get r3bCollections;

  /// No description provided for @r3bCouldNotCreateThread.
  ///
  /// In en, this message translates to:
  /// **'Could not create or get thread'**
  String get r3bCouldNotCreateThread;

  /// No description provided for @r3bCouldNotLogin.
  ///
  /// In en, this message translates to:
  /// **'Could not login'**
  String get r3bCouldNotLogin;

  /// No description provided for @r3bCouldNotVerifyTx.
  ///
  /// In en, this message translates to:
  /// **'Could not verify transaction.'**
  String get r3bCouldNotVerifyTx;

  /// No description provided for @r3bCreateAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'Create Auction House'**
  String get r3bCreateAuctionHouse;

  /// No description provided for @r3bCreateCollectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Now you can create collections and then add listings to them.'**
  String get r3bCreateCollectionsHint;

  /// No description provided for @r3bCreateListingsHint.
  ///
  /// In en, this message translates to:
  /// **'Now you can create listings for the NFTs you own.'**
  String get r3bCreateListingsHint;

  /// No description provided for @r3bCreateNewCollection.
  ///
  /// In en, this message translates to:
  /// **'Create New Collection'**
  String get r3bCreateNewCollection;

  /// No description provided for @r3bCurrentBidPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Bid Price:'**
  String get r3bCurrentBidPrice;

  /// No description provided for @r3bCurrentBids.
  ///
  /// In en, this message translates to:
  /// **'Current Bids'**
  String get r3bCurrentBids;

  /// No description provided for @r3bDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get r3bDay;

  /// No description provided for @r3bDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get r3bDays;

  /// No description provided for @r3bDeleteListingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing?'**
  String get r3bDeleteListingConfirm;

  /// No description provided for @r3bDeleteShopConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this shop?'**
  String get r3bDeleteShopConfirm;

  /// No description provided for @r3bDeleteShopConfirmPublished.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this shop? There is a cost of {cost} VFX to delete this from the network.'**
  String r3bDeleteShopConfirmPublished(String cost);

  /// No description provided for @r3bEditAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'Edit Auction House'**
  String get r3bEditAuctionHouse;

  /// No description provided for @r3bEnableOneOption.
  ///
  /// In en, this message translates to:
  /// **'Enable at least one of the options (Gallery, Buy Now, or Auction)'**
  String get r3bEnableOneOption;

  /// No description provided for @r3bEndDateAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after the start date'**
  String get r3bEndDateAfterStart;

  /// No description provided for @r3bEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in'**
  String get r3bEndsIn;

  /// No description provided for @r3bErrorGeneratingScData.
  ///
  /// In en, this message translates to:
  /// **'Error generating smart contract data'**
  String get r3bErrorGeneratingScData;

  /// No description provided for @r3bFailedParseFee.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse fee'**
  String get r3bFailedParseFee;

  /// No description provided for @r3bFailedParseHash.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse hash'**
  String get r3bFailedParseHash;

  /// No description provided for @r3bFailedRetrieveNonce.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve nonce'**
  String get r3bFailedRetrieveNonce;

  /// No description provided for @r3bFailedRetrieveTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve timestamp'**
  String get r3bFailedRetrieveTimestamp;

  /// No description provided for @r3bIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get r3bIdentifier;

  /// No description provided for @r3bImportAndPublish.
  ///
  /// In en, this message translates to:
  /// **'Import & Publish'**
  String get r3bImportAndPublish;

  /// No description provided for @r3bImportShopBroadcastBody.
  ///
  /// In en, this message translates to:
  /// **'Once the transaction relects on chain, your shop will appear here.'**
  String get r3bImportShopBroadcastBody;

  /// No description provided for @r3bImportShopConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to import this shop? A {cost} VFX fee will be charged to publish this change to the network.\n\nThis is a destructive action and will not carry over your collections and listings.'**
  String r3bImportShopConfirmBody(String cost);

  /// No description provided for @r3bIncorrectLoginDetails.
  ///
  /// In en, this message translates to:
  /// **'Incorrect login details for {address}.'**
  String r3bIncorrectLoginDetails(String address);

  /// No description provided for @r3bIncrementAmount.
  ///
  /// In en, this message translates to:
  /// **'Increment Amount:'**
  String get r3bIncrementAmount;

  /// No description provided for @r3bInfinite.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get r3bInfinite;

  /// No description provided for @r3bLabelCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String r3bLabelCopied(String label);

  /// No description provided for @r3bLoggedInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get r3bLoggedInSuccess;

  /// No description provided for @r3bMintedBy.
  ///
  /// In en, this message translates to:
  /// **'Minted By'**
  String get r3bMintedBy;

  /// No description provided for @r3bMinterAddress.
  ///
  /// In en, this message translates to:
  /// **'Minter Address'**
  String get r3bMinterAddress;

  /// No description provided for @r3bMyShopSuffix.
  ///
  /// In en, this message translates to:
  /// **' [My Shop]'**
  String get r3bMyShopSuffix;

  /// No description provided for @r3bNftFeatures.
  ///
  /// In en, this message translates to:
  /// **'NFT Features:'**
  String get r3bNftFeatures;

  /// No description provided for @r3bNftMustBeSet.
  ///
  /// In en, this message translates to:
  /// **'The NFT must be set'**
  String get r3bNftMustBeSet;

  /// No description provided for @r3bNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address.'**
  String get r3bNoAddress;

  /// No description provided for @r3bNoAuctionHouses.
  ///
  /// In en, this message translates to:
  /// **'No Auction Houses'**
  String get r3bNoAuctionHouses;

  /// No description provided for @r3bNoBids.
  ///
  /// In en, this message translates to:
  /// **'No bids.'**
  String get r3bNoBids;

  /// No description provided for @r3bNoCollections.
  ///
  /// In en, this message translates to:
  /// **'No Collections'**
  String get r3bNoCollections;

  /// No description provided for @r3bNoListings.
  ///
  /// In en, this message translates to:
  /// **'No Listings'**
  String get r3bNoListings;

  /// No description provided for @r3bNoPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'No private key.'**
  String get r3bNoPrivateKey;

  /// No description provided for @r3bNoPublicKey.
  ///
  /// In en, this message translates to:
  /// **'No public key.'**
  String get r3bNoPublicKey;

  /// No description provided for @r3bNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Not Authorized'**
  String get r3bNotAuthorized;

  /// No description provided for @r3bNotOwnerLoginAs.
  ///
  /// In en, this message translates to:
  /// **'You are not the owner of this shop. Please login as {address}'**
  String r3bNotOwnerLoginAs(String address);

  /// No description provided for @r3bOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get r3bOffline;

  /// No description provided for @r3bOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get r3bOnline;

  /// No description provided for @r3bOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get r3bOr;

  /// No description provided for @r3bOwnedBy.
  ///
  /// In en, this message translates to:
  /// **'Owned by'**
  String get r3bOwnedBy;

  /// No description provided for @r3bPrivateTag.
  ///
  /// In en, this message translates to:
  /// **'[Private]'**
  String get r3bPrivateTag;

  /// No description provided for @r3bPublishShopBody.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to publish your shop to the network (plus the transaction fee).'**
  String r3bPublishShopBody(String cost);

  /// No description provided for @r3bReadyToImport.
  ///
  /// In en, this message translates to:
  /// **'Ready to Import'**
  String get r3bReadyToImport;

  /// No description provided for @r3bReserveGteFloor.
  ///
  /// In en, this message translates to:
  /// **'The reserve price must be greater or equal to the floor price.'**
  String get r3bReserveGteFloor;

  /// No description provided for @r3bReserveMet.
  ///
  /// In en, this message translates to:
  /// **'Reserve Met:'**
  String get r3bReserveMet;

  /// No description provided for @r3bSaleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sale has Completed'**
  String get r3bSaleCompleted;

  /// No description provided for @r3bSalePending.
  ///
  /// In en, this message translates to:
  /// **'Sale is Pending'**
  String get r3bSalePending;

  /// No description provided for @r3bSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get r3bSaveChanges;

  /// No description provided for @r3bSetupAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'Setup Auction House'**
  String get r3bSetupAuctionHouse;

  /// No description provided for @r3bSetupAuctionHousePrompt.
  ///
  /// In en, this message translates to:
  /// **'First, setup your auction house / gallery.\nThen you\'ll be able to create collections and add listings to them.'**
  String get r3bSetupAuctionHousePrompt;

  /// No description provided for @r3bShareListing.
  ///
  /// In en, this message translates to:
  /// **'Share Listing'**
  String get r3bShareListing;

  /// No description provided for @r3bShareUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Share url copied to clipboard'**
  String get r3bShareUrlCopied;

  /// No description provided for @r3bShopDeleteBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Shop Delete transaction broadcasted to the network'**
  String get r3bShopDeleteBroadcast;

  /// No description provided for @r3bShopIsOffline.
  ///
  /// In en, this message translates to:
  /// **'Shop is offline.'**
  String get r3bShopIsOffline;

  /// No description provided for @r3bShopNotFound.
  ///
  /// In en, this message translates to:
  /// **'Shop Not Found'**
  String get r3bShopNotFound;

  /// No description provided for @r3bShopPublishBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Shop Publish transaction broadcasted to the network'**
  String get r3bShopPublishBroadcast;

  /// No description provided for @r3bShopUpdateBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Shop Update transaction broadcasted to the network'**
  String get r3bShopUpdateBroadcast;

  /// No description provided for @r3bShopUrlImportPrompt.
  ///
  /// In en, this message translates to:
  /// **'What is the shop URL you\'d like to import?'**
  String get r3bShopUrlImportPrompt;

  /// No description provided for @r3bShopUrlNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Shop URL is not available.'**
  String get r3bShopUrlNotAvailable;

  /// No description provided for @r3bSignInToAuthorize.
  ///
  /// In en, this message translates to:
  /// **'To authorize this transaction, you must sign in as'**
  String get r3bSignInToAuthorize;

  /// No description provided for @r3bSignatureNotValidPrimary.
  ///
  /// In en, this message translates to:
  /// **'Signature not valid (primary)'**
  String get r3bSignatureNotValidPrimary;

  /// No description provided for @r3bSmartContractId.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract ID: {id}'**
  String r3bSmartContractId(String id);

  /// No description provided for @r3bStartBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'The start date must be before the end date.'**
  String get r3bStartBeforeEnd;

  /// No description provided for @r3bSubscribeUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'In order for the web wallet to provide notifications about bids/purchases for you to sign the transactions, an email address is required.'**
  String get r3bSubscribeUpdatesBody;

  /// No description provided for @r3bThisIsPermanent.
  ///
  /// In en, this message translates to:
  /// **'This is permanent'**
  String get r3bThisIsPermanent;

  /// No description provided for @r3bThisIsYourShop.
  ///
  /// In en, this message translates to:
  /// **'This is your own shop.'**
  String get r3bThisIsYourShop;

  /// No description provided for @r3bTransactionSent.
  ///
  /// In en, this message translates to:
  /// **'Transaction Sent.'**
  String get r3bTransactionSent;

  /// No description provided for @r3bUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Unpublished'**
  String get r3bUnpublished;

  /// No description provided for @r3bUpdateShopBody.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to update your shop on the network (plus the transaction fee).'**
  String r3bUpdateShopBody(String cost);

  /// No description provided for @r3bUpdateShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Shop?'**
  String get r3bUpdateShopTitle;

  /// No description provided for @r3bWalletNotSyncedBody.
  ///
  /// In en, this message translates to:
  /// **'Since your wallet is not synced there may be some issues viewing the data in this shop. Continue anyway?'**
  String get r3bWalletNotSyncedBody;

  /// No description provided for @r3bWillNotBeNotified.
  ///
  /// In en, this message translates to:
  /// **'You will not be notified. You can update this setting on the dashboard if you change your mind.'**
  String get r3bWillNotBeNotified;

  /// No description provided for @r3bYouAreShopOwner.
  ///
  /// In en, this message translates to:
  /// **'You are the owner of this shop.'**
  String get r3bYouAreShopOwner;

  /// No description provided for @r3cCallbackFromDetails.
  ///
  /// In en, this message translates to:
  /// **'{text} [{amount} VFX from {address}]'**
  String r3cCallbackFromDetails(String text, String amount, String address);

  /// No description provided for @r3cNoTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Found'**
  String get r3cNoTransactionsFound;

  /// No description provided for @r3cNoTransactionsFoundFiltered.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Found\n[with current filters]'**
  String get r3cNoTransactionsFoundFiltered;

  /// No description provided for @r3cPriceHistoryBtc.
  ///
  /// In en, this message translates to:
  /// **'BTC Price History'**
  String get r3cPriceHistoryBtc;

  /// No description provided for @r3cPriceHistoryVfx.
  ///
  /// In en, this message translates to:
  /// **'VFX Price History'**
  String get r3cPriceHistoryVfx;

  /// No description provided for @r3cStatusCalledBack.
  ///
  /// In en, this message translates to:
  /// **'Called Back'**
  String get r3cStatusCalledBack;

  /// No description provided for @r3cStatusFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get r3cStatusFail;

  /// No description provided for @r3cStatusRecovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get r3cStatusRecovered;

  /// No description provided for @r3cTypeAdnr.
  ///
  /// In en, this message translates to:
  /// **'ADNR'**
  String get r3cTypeAdnr;

  /// No description provided for @r3cTypeAdnrCreate.
  ///
  /// In en, this message translates to:
  /// **'ADNR Create'**
  String get r3cTypeAdnrCreate;

  /// No description provided for @r3cTypeAdnrDelete.
  ///
  /// In en, this message translates to:
  /// **'ADNR Delete'**
  String get r3cTypeAdnrDelete;

  /// No description provided for @r3cTypeAdnrTransfer.
  ///
  /// In en, this message translates to:
  /// **'ADNR Transfer'**
  String get r3cTypeAdnrTransfer;

  /// No description provided for @r3cTypeAuctionHouseCreate.
  ///
  /// In en, this message translates to:
  /// **'P2P Auction House (Create)'**
  String get r3cTypeAuctionHouseCreate;

  /// No description provided for @r3cTypeAuctionHouseDelete.
  ///
  /// In en, this message translates to:
  /// **'P2P Auction House (Delete)'**
  String get r3cTypeAuctionHouseDelete;

  /// No description provided for @r3cTypeAuctionHouseUpdate.
  ///
  /// In en, this message translates to:
  /// **'P2P Auction House (Update)'**
  String get r3cTypeAuctionHouseUpdate;

  /// No description provided for @r3cTypeBtcAdnrCreate.
  ///
  /// In en, this message translates to:
  /// **'BTC ADNR Create'**
  String get r3cTypeBtcAdnrCreate;

  /// No description provided for @r3cTypeBtcAdnrDelete.
  ///
  /// In en, this message translates to:
  /// **'BTC ADNR Delete'**
  String get r3cTypeBtcAdnrDelete;

  /// No description provided for @r3cTypeBtcAdnrTransfer.
  ///
  /// In en, this message translates to:
  /// **'BTC ADNR Transfer'**
  String get r3cTypeBtcAdnrTransfer;

  /// No description provided for @r3cTypeDstRegistration.
  ///
  /// In en, this message translates to:
  /// **'DST Registration'**
  String get r3cTypeDstRegistration;

  /// No description provided for @r3cTypeFungibleBanAddress.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Ban Address'**
  String get r3cTypeFungibleBanAddress;

  /// No description provided for @r3cTypeFungibleBurn.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Burn'**
  String get r3cTypeFungibleBurn;

  /// No description provided for @r3cTypeFungibleDeploy.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Deploy'**
  String get r3cTypeFungibleDeploy;

  /// No description provided for @r3cTypeFungibleMint.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Mint'**
  String get r3cTypeFungibleMint;

  /// No description provided for @r3cTypeFungibleOwnershipChange.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Ownership Change'**
  String get r3cTypeFungibleOwnershipChange;

  /// No description provided for @r3cTypeFungiblePause.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Pause'**
  String get r3cTypeFungiblePause;

  /// No description provided for @r3cTypeFungibleResume.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Resume'**
  String get r3cTypeFungibleResume;

  /// No description provided for @r3cTypeFungibleTopicCreated.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Topic Created'**
  String get r3cTypeFungibleTopicCreated;

  /// No description provided for @r3cTypeFungibleTransfer.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Transfer'**
  String get r3cTypeFungibleTransfer;

  /// No description provided for @r3cTypeFungibleTx.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token TX'**
  String get r3cTypeFungibleTx;

  /// No description provided for @r3cTypeFungibleVoteCast.
  ///
  /// In en, this message translates to:
  /// **'Fungible Token Vote Cast'**
  String get r3cTypeFungibleVoteCast;

  /// No description provided for @r3cTypeNftBurn.
  ///
  /// In en, this message translates to:
  /// **'NFT Burn'**
  String get r3cTypeNftBurn;

  /// No description provided for @r3cTypeNftEvolution.
  ///
  /// In en, this message translates to:
  /// **'NFT Evolution'**
  String get r3cTypeNftEvolution;

  /// No description provided for @r3cTypeNftMint.
  ///
  /// In en, this message translates to:
  /// **'NFT Mint'**
  String get r3cTypeNftMint;

  /// No description provided for @r3cTypeNftMintTokenized.
  ///
  /// In en, this message translates to:
  /// **'NFT Mint (Tokenized)'**
  String get r3cTypeNftMintTokenized;

  /// No description provided for @r3cTypeNftSale.
  ///
  /// In en, this message translates to:
  /// **'NFT Sale'**
  String get r3cTypeNftSale;

  /// No description provided for @r3cTypeNftSaleComplete.
  ///
  /// In en, this message translates to:
  /// **'NFT Sale Complete'**
  String get r3cTypeNftSaleComplete;

  /// No description provided for @r3cTypeNftSaleCompleteManual.
  ///
  /// In en, this message translates to:
  /// **'NFT Sale Complete (Manual)'**
  String get r3cTypeNftSaleCompleteManual;

  /// No description provided for @r3cTypeNftSaleCompleteParen.
  ///
  /// In en, this message translates to:
  /// **'NFT Sale (Complete)'**
  String get r3cTypeNftSaleCompleteParen;

  /// No description provided for @r3cTypeNftSaleStart.
  ///
  /// In en, this message translates to:
  /// **'NFT Sale Start'**
  String get r3cTypeNftSaleStart;

  /// No description provided for @r3cTypeNftSaleStartManual.
  ///
  /// In en, this message translates to:
  /// **'NFT Sale Start (Manual)'**
  String get r3cTypeNftSaleStartManual;

  /// No description provided for @r3cTypeNftTransfer.
  ///
  /// In en, this message translates to:
  /// **'NFT Transfer'**
  String get r3cTypeNftTransfer;

  /// No description provided for @r3cTypeNftTx.
  ///
  /// In en, this message translates to:
  /// **'NFT Tx'**
  String get r3cTypeNftTx;

  /// No description provided for @r3cTypeNode.
  ///
  /// In en, this message translates to:
  /// **'Node'**
  String get r3cTypeNode;

  /// No description provided for @r3cTypeSmartContractBurn.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract Burn'**
  String get r3cTypeSmartContractBurn;

  /// No description provided for @r3cTypeSmartContractMint.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract Mint'**
  String get r3cTypeSmartContractMint;

  /// No description provided for @r3cTypeSmartContractTx.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract TX'**
  String get r3cTypeSmartContractTx;

  /// No description provided for @r3cTypeTokenizationBurn.
  ///
  /// In en, this message translates to:
  /// **'Tokenization Burn'**
  String get r3cTypeTokenizationBurn;

  /// No description provided for @r3cTypeTokenizationMint.
  ///
  /// In en, this message translates to:
  /// **'Tokenization Mint'**
  String get r3cTypeTokenizationMint;

  /// No description provided for @r3cTypeTokenizationTx.
  ///
  /// In en, this message translates to:
  /// **'Tokenization TX'**
  String get r3cTypeTokenizationTx;

  /// No description provided for @r3cTypeTokenizationWithdrawalComplete.
  ///
  /// In en, this message translates to:
  /// **'Tokenization Withdrawal Complete'**
  String get r3cTypeTokenizationWithdrawalComplete;

  /// No description provided for @r3cTypeTokenizationWithdrawalRequest.
  ///
  /// In en, this message translates to:
  /// **'Tokenization Withdrawal Request'**
  String get r3cTypeTokenizationWithdrawalRequest;

  /// No description provided for @r3cTypeTopicCreate.
  ///
  /// In en, this message translates to:
  /// **'Topic Create'**
  String get r3cTypeTopicCreate;

  /// No description provided for @r3cTypeTopicVote.
  ///
  /// In en, this message translates to:
  /// **'Topic Vote'**
  String get r3cTypeTopicVote;

  /// No description provided for @r3cTypeTx.
  ///
  /// In en, this message translates to:
  /// **'Tx'**
  String get r3cTypeTx;

  /// No description provided for @r3cTypeValidatorHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'Validator Heartbeat'**
  String get r3cTypeValidatorHeartbeat;

  /// No description provided for @r3cTypeValidatorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Validator Registration'**
  String get r3cTypeValidatorRegistration;

  /// No description provided for @r3cTypeVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get r3cTypeVault;

  /// No description provided for @r3cTypeVaultCallback.
  ///
  /// In en, this message translates to:
  /// **'Vault (Callback)'**
  String get r3cTypeVaultCallback;

  /// No description provided for @r3cTypeVaultRecover.
  ///
  /// In en, this message translates to:
  /// **'Vault (Recover)'**
  String get r3cTypeVaultRecover;

  /// No description provided for @r3cTypeVaultRegister.
  ///
  /// In en, this message translates to:
  /// **'Vault (Register)'**
  String get r3cTypeVaultRegister;

  /// No description provided for @r3cTypeVbtcBridgeLock.
  ///
  /// In en, this message translates to:
  /// **'vBTC Bridge Lock'**
  String get r3cTypeVbtcBridgeLock;

  /// No description provided for @r3cTypeVbtcBridgeUnlock.
  ///
  /// In en, this message translates to:
  /// **'vBTC Bridge Unlock'**
  String get r3cTypeVbtcBridgeUnlock;

  /// No description provided for @r3cTypeVbtcBulkTransfer.
  ///
  /// In en, this message translates to:
  /// **'vBTC Bulk Transfer'**
  String get r3cTypeVbtcBulkTransfer;

  /// No description provided for @r3cTypeVbtcBurn.
  ///
  /// In en, this message translates to:
  /// **'vBTC Burn'**
  String get r3cTypeVbtcBurn;

  /// No description provided for @r3cTypeVbtcContractCreate.
  ///
  /// In en, this message translates to:
  /// **'vBTC Contract Create'**
  String get r3cTypeVbtcContractCreate;

  /// No description provided for @r3cTypeVbtcContractMint.
  ///
  /// In en, this message translates to:
  /// **'vBTC Contract Mint'**
  String get r3cTypeVbtcContractMint;

  /// No description provided for @r3cTypeVbtcMint.
  ///
  /// In en, this message translates to:
  /// **'vBTC Mint'**
  String get r3cTypeVbtcMint;

  /// No description provided for @r3cTypeVbtcPrivateTransfer.
  ///
  /// In en, this message translates to:
  /// **'vBTC Private Transfer'**
  String get r3cTypeVbtcPrivateTransfer;

  /// No description provided for @r3cTypeVbtcShield.
  ///
  /// In en, this message translates to:
  /// **'vBTC Shield'**
  String get r3cTypeVbtcShield;

  /// No description provided for @r3cTypeVbtcTokenOwnershipTransfer.
  ///
  /// In en, this message translates to:
  /// **'vBTC Token Ownership Transfer'**
  String get r3cTypeVbtcTokenOwnershipTransfer;

  /// No description provided for @r3cTypeVbtcTransfer.
  ///
  /// In en, this message translates to:
  /// **'vBTC Transfer'**
  String get r3cTypeVbtcTransfer;

  /// No description provided for @r3cTypeVbtcTransferCoin.
  ///
  /// In en, this message translates to:
  /// **'vBTC Transfer Coin'**
  String get r3cTypeVbtcTransferCoin;

  /// No description provided for @r3cTypeVbtcTx.
  ///
  /// In en, this message translates to:
  /// **'vBTC TX'**
  String get r3cTypeVbtcTx;

  /// No description provided for @r3cTypeVbtcUnshield.
  ///
  /// In en, this message translates to:
  /// **'vBTC Unshield'**
  String get r3cTypeVbtcUnshield;

  /// No description provided for @r3cTypeVbtcValidatorExit.
  ///
  /// In en, this message translates to:
  /// **'vBTC Validator Exit'**
  String get r3cTypeVbtcValidatorExit;

  /// No description provided for @r3cTypeVbtcValidatorHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'vBTC Validator Heartbeat'**
  String get r3cTypeVbtcValidatorHeartbeat;

  /// No description provided for @r3cTypeVbtcValidatorRegister.
  ///
  /// In en, this message translates to:
  /// **'vBTC Validator Register'**
  String get r3cTypeVbtcValidatorRegister;

  /// No description provided for @r3cTypeVbtcWithdrawalArb.
  ///
  /// In en, this message translates to:
  /// **'vBTC Withdrawal (Arb)'**
  String get r3cTypeVbtcWithdrawalArb;

  /// No description provided for @r3cTypeVbtcWithdrawalCancel.
  ///
  /// In en, this message translates to:
  /// **'vBTC Withdrawal Cancel'**
  String get r3cTypeVbtcWithdrawalCancel;

  /// No description provided for @r3cTypeVbtcWithdrawalComplete.
  ///
  /// In en, this message translates to:
  /// **'vBTC Withdrawal Complete'**
  String get r3cTypeVbtcWithdrawalComplete;

  /// No description provided for @r3cTypeVbtcWithdrawalOwner.
  ///
  /// In en, this message translates to:
  /// **'vBTC Withdrawal (Owner)'**
  String get r3cTypeVbtcWithdrawalOwner;

  /// No description provided for @r3cTypeVbtcWithdrawalRequest.
  ///
  /// In en, this message translates to:
  /// **'vBTC Withdrawal Request'**
  String get r3cTypeVbtcWithdrawalRequest;

  /// No description provided for @r3cTypeVbtcWithdrawalVote.
  ///
  /// In en, this message translates to:
  /// **'vBTC Withdrawal Vote'**
  String get r3cTypeVbtcWithdrawalVote;

  /// No description provided for @r3cTypeVfxPrivateTransfer.
  ///
  /// In en, this message translates to:
  /// **'VFX Private Transfer'**
  String get r3cTypeVfxPrivateTransfer;

  /// No description provided for @r3cTypeVfxShield.
  ///
  /// In en, this message translates to:
  /// **'VFX Shield'**
  String get r3cTypeVfxShield;

  /// No description provided for @r3cTypeVfxUnshield.
  ///
  /// In en, this message translates to:
  /// **'VFX Unshield'**
  String get r3cTypeVfxUnshield;

  /// No description provided for @r3dActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get r3dActivate;

  /// No description provided for @r3dActivateVaultBody.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to activate your Vault Account which is burned.\n\nContinue?'**
  String r3dActivateVaultBody(String cost);

  /// No description provided for @r3dActivateVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate Vault Account?'**
  String get r3dActivateVaultTitle;

  /// No description provided for @r3dActivationTxBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'Activation transaction broadcasted'**
  String get r3dActivationTxBroadcasted;

  /// No description provided for @r3dActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get r3dActivity;

  /// No description provided for @r3dAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address Required.'**
  String get r3dAddressRequired;

  /// No description provided for @r3dAttemptingSaleCompleteTx.
  ///
  /// In en, this message translates to:
  /// **'Attempting to send sale complete TX.'**
  String get r3dAttemptingSaleCompleteTx;

  /// No description provided for @r3dAuctionAlreadyStarted.
  ///
  /// In en, this message translates to:
  /// **'The auction has already started.'**
  String get r3dAuctionAlreadyStarted;

  /// No description provided for @r3dAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get r3dAwaitingPayment;

  /// No description provided for @r3dBackupAddress.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get r3dBackupAddress;

  /// No description provided for @r3dBackupPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key:'**
  String get r3dBackupPrivateKey;

  /// No description provided for @r3dBackupRecoveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Recovery Address:'**
  String get r3dBackupRecoveryAddress;

  /// No description provided for @r3dBackupRecoveryPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Recovery Private Key:'**
  String get r3dBackupRecoveryPrivateKey;

  /// No description provided for @r3dBackupRestoreCode.
  ///
  /// In en, this message translates to:
  /// **'Restore Code:'**
  String get r3dBackupRestoreCode;

  /// No description provided for @r3dBeingClaimed.
  ///
  /// In en, this message translates to:
  /// **'Being Claimed'**
  String get r3dBeingClaimed;

  /// No description provided for @r3dBtcExplorer.
  ///
  /// In en, this message translates to:
  /// **'BTC Explorer'**
  String get r3dBtcExplorer;

  /// No description provided for @r3dBuyNowPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy Now: {price} VFX'**
  String r3dBuyNowPriceLabel(String price);

  /// No description provided for @r3dCantDeleteAuctionStarted.
  ///
  /// In en, this message translates to:
  /// **'You can\'t delete this listing because the auction has already started.'**
  String get r3dCantDeleteAuctionStarted;

  /// No description provided for @r3dChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get r3dChat;

  /// No description provided for @r3dChooseNft.
  ///
  /// In en, this message translates to:
  /// **'Choose NFT'**
  String get r3dChooseNft;

  /// No description provided for @r3dClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get r3dClaimed;

  /// No description provided for @r3dCliRestartBody.
  ///
  /// In en, this message translates to:
  /// **'A CLI restart is required for this change to take effect. Would you like to restart now?'**
  String get r3dCliRestartBody;

  /// No description provided for @r3dCloseCollectionCreationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the collection creation screen?'**
  String get r3dCloseCollectionCreationConfirm;

  /// No description provided for @r3dCloseCollectionEditingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the collection editing screen?'**
  String get r3dCloseCollectionEditingConfirm;

  /// No description provided for @r3dCloseListingCreationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the listing creation screen?'**
  String get r3dCloseListingCreationConfirm;

  /// No description provided for @r3dCloseListingEditingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the listing editing screen?'**
  String get r3dCloseListingEditingConfirm;

  /// No description provided for @r3dCloseShopCreationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the shop creation screen?'**
  String get r3dCloseShopCreationConfirm;

  /// No description provided for @r3dCloseShopEditingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the shop editing screen?'**
  String get r3dCloseShopEditingConfirm;

  /// No description provided for @r3dCloseStoreCreationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the store creation screen?'**
  String get r3dCloseStoreCreationConfirm;

  /// No description provided for @r3dCloseStoreEditingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the store editing screen?'**
  String get r3dCloseStoreEditingConfirm;

  /// No description provided for @r3dCollectionLiveHelp.
  ///
  /// In en, this message translates to:
  /// **'When this is enabled, this collection will be visible to other users when they connect to your shop'**
  String get r3dCollectionLiveHelp;

  /// No description provided for @r3dConfirmDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing?'**
  String get r3dConfirmDeleteListing;

  /// No description provided for @r3dConfirmDeletePublishedShop.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this shop from the network? There is a cost of {cost} VFX plus TX fee to perform this operation.'**
  String r3dConfirmDeletePublishedShop(String cost);

  /// No description provided for @r3dConfirmDeleteUnpublishedShop.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your unpublished shop?'**
  String get r3dConfirmDeleteUnpublishedShop;

  /// No description provided for @r3dConfirmDetails.
  ///
  /// In en, this message translates to:
  /// **'Confirm Details'**
  String get r3dConfirmDetails;

  /// No description provided for @r3dConfirmDiscardListing.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard the listing?'**
  String get r3dConfirmDiscardListing;

  /// No description provided for @r3dCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get r3dCopyLink;

  /// No description provided for @r3dCraftTime.
  ///
  /// In en, this message translates to:
  /// **'Craft Time'**
  String get r3dCraftTime;

  /// No description provided for @r3dCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get r3dCreate;

  /// No description provided for @r3dCreateAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'Create Auction House'**
  String get r3dCreateAuctionHouse;

  /// No description provided for @r3dCreateCollectionsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Now you can create collections and then add listings to them.'**
  String get r3dCreateCollectionsPrompt;

  /// No description provided for @r3dCreateFirstListing.
  ///
  /// In en, this message translates to:
  /// **'Create First Listing'**
  String get r3dCreateFirstListing;

  /// No description provided for @r3dCreateLink.
  ///
  /// In en, this message translates to:
  /// **'Create Link'**
  String get r3dCreateLink;

  /// No description provided for @r3dCreateListingsForNfts.
  ///
  /// In en, this message translates to:
  /// **'Now you can create listings for the NFTs you own.'**
  String get r3dCreateListingsForNfts;

  /// No description provided for @r3dCreateNewCollection.
  ///
  /// In en, this message translates to:
  /// **'Create New Collection'**
  String get r3dCreateNewCollection;

  /// No description provided for @r3dCreatePaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Link'**
  String get r3dCreatePaymentLink;

  /// No description provided for @r3dCreatingNewCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'You are creating a new collection in your auction house.\nAfter creating the new collection you will be able to create listings.'**
  String get r3dCreatingNewCollectionBody;

  /// No description provided for @r3dDeleteTxBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'Delete TX broadcasted.'**
  String get r3dDeleteTxBroadcasted;

  /// No description provided for @r3dEditAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'Edit Auction House'**
  String get r3dEditAuctionHouse;

  /// No description provided for @r3dEnableAtLeastOneOption.
  ///
  /// In en, this message translates to:
  /// **'Enable at least one of the options (Gallery, Buy Now, or Auction)'**
  String get r3dEnableAtLeastOneOption;

  /// No description provided for @r3dEndDateAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get r3dEndDateAfterStartDate;

  /// No description provided for @r3dEstimatedFee.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fee'**
  String get r3dEstimatedFee;

  /// No description provided for @r3dFailedCreatePaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to create payment link. Please try again.'**
  String get r3dFailedCreatePaymentLink;

  /// No description provided for @r3dFailedParseFee.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse fee'**
  String get r3dFailedParseFee;

  /// No description provided for @r3dFailedParseHash.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse hash'**
  String get r3dFailedParseHash;

  /// No description provided for @r3dFailedRetrieveNonce.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve nonce'**
  String get r3dFailedRetrieveNonce;

  /// No description provided for @r3dFailedRetrieveTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve timestamp'**
  String get r3dFailedRetrieveTimestamp;

  /// No description provided for @r3dFailedSendVfxEscrow.
  ///
  /// In en, this message translates to:
  /// **'Failed to send VFX to escrow. Please try again.'**
  String get r3dFailedSendVfxEscrow;

  /// No description provided for @r3dFloorPriceGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'The floor price must be greater than zero.'**
  String get r3dFloorPriceGreaterThanZero;

  /// No description provided for @r3dFloorPriceValue.
  ///
  /// In en, this message translates to:
  /// **'Floor: {price} VFX'**
  String r3dFloorPriceValue(String price);

  /// No description provided for @r3dGalleryListing.
  ///
  /// In en, this message translates to:
  /// **'Gallery Listing'**
  String get r3dGalleryListing;

  /// No description provided for @r3dHdAccountRestored.
  ///
  /// In en, this message translates to:
  /// **'HD Account restored. Keys will now be generated deterministically based on phrase.'**
  String get r3dHdAccountRestored;

  /// No description provided for @r3dHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get r3dHidden;

  /// No description provided for @r3dHideCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to hide this collection? It won\'t be visible to other users when they connect to your shop.'**
  String get r3dHideCollectionBody;

  /// No description provided for @r3dHideCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide Collection?'**
  String get r3dHideCollectionTitle;

  /// No description provided for @r3dInputRecoverPhrase.
  ///
  /// In en, this message translates to:
  /// **'Input Recover Phrase'**
  String get r3dInputRecoverPhrase;

  /// No description provided for @r3dInsufficientBalancePublish.
  ///
  /// In en, this message translates to:
  /// **'This wallet doesn\'t have the minimmun balance send a publish tx'**
  String get r3dInsufficientBalancePublish;

  /// No description provided for @r3dInsufficientBalanceUpdate.
  ///
  /// In en, this message translates to:
  /// **'This wallet doesn\'t have the minimmun balance send an update tx'**
  String get r3dInsufficientBalanceUpdate;

  /// No description provided for @r3dLabelHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get r3dLabelHash;

  /// No description provided for @r3dLinkCopiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get r3dLinkCopiedClipboard;

  /// No description provided for @r3dLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get r3dLive;

  /// No description provided for @r3dLocalChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Local changes saved!'**
  String get r3dLocalChangesSaved;

  /// No description provided for @r3dMakeCollectionLiveBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to make this collection live? This collection will be visible to other users when they connect to your shop.'**
  String get r3dMakeCollectionLiveBody;

  /// No description provided for @r3dMakeCollectionLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Collection Live?'**
  String get r3dMakeCollectionLiveTitle;

  /// No description provided for @r3dMakeLive.
  ///
  /// In en, this message translates to:
  /// **'Make Live'**
  String get r3dMakeLive;

  /// No description provided for @r3dMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get r3dMessage;

  /// No description provided for @r3dNftMustBeSet.
  ///
  /// In en, this message translates to:
  /// **'The NFT must be set'**
  String get r3dNftMustBeSet;

  /// No description provided for @r3dNftTransferStarted.
  ///
  /// In en, this message translates to:
  /// **'Success: NFT Transfer has been started.'**
  String get r3dNftTransferStarted;

  /// No description provided for @r3dNotOneOfYourAddresses.
  ///
  /// In en, this message translates to:
  /// **'This is not one of your addresses'**
  String get r3dNotOneOfYourAddresses;

  /// No description provided for @r3dNumberOfTxs.
  ///
  /// In en, this message translates to:
  /// **'# of Txs'**
  String get r3dNumberOfTxs;

  /// No description provided for @r3dOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get r3dOr;

  /// No description provided for @r3dPaymentCaptured.
  ///
  /// In en, this message translates to:
  /// **'Payment Captured'**
  String get r3dPaymentCaptured;

  /// No description provided for @r3dPaymentFromVfxWallet.
  ///
  /// In en, this message translates to:
  /// **'Payment from VFX Wallet'**
  String get r3dPaymentFromVfxWallet;

  /// No description provided for @r3dPaymentLinkCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment link created successfully!'**
  String get r3dPaymentLinkCreatedSuccess;

  /// No description provided for @r3dPaymentLinkReady.
  ///
  /// In en, this message translates to:
  /// **'Payment Link Ready!'**
  String get r3dPaymentLinkReady;

  /// No description provided for @r3dPaymentNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Payment not available in this environment'**
  String get r3dPaymentNotAvailable;

  /// No description provided for @r3dPaymentProcessed.
  ///
  /// In en, this message translates to:
  /// **'Payment Processed'**
  String get r3dPaymentProcessed;

  /// No description provided for @r3dPendingDeposit.
  ///
  /// In en, this message translates to:
  /// **'Pending Deposit'**
  String get r3dPendingDeposit;

  /// No description provided for @r3dPriceGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than zero'**
  String get r3dPriceGreaterThanZero;

  /// No description provided for @r3dPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get r3dPublish;

  /// No description provided for @r3dPublishChanges.
  ///
  /// In en, this message translates to:
  /// **'Publish Changes'**
  String get r3dPublishChanges;

  /// No description provided for @r3dPublishIpChange.
  ///
  /// In en, this message translates to:
  /// **'Publish IP Change'**
  String get r3dPublishIpChange;

  /// No description provided for @r3dPublishShopCostBody.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to publish your shop to the network (plus the transaction fee).'**
  String r3dPublishShopCostBody(String cost);

  /// No description provided for @r3dPublishTransactionSent.
  ///
  /// In en, this message translates to:
  /// **'Publish Transaction Sent!'**
  String get r3dPublishTransactionSent;

  /// No description provided for @r3dPublishUpdateCostBody.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to publish your shop changes to the network (plus the transaction fee).'**
  String r3dPublishUpdateCostBody(String cost);

  /// No description provided for @r3dPublishUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'Your local changes were saved successfully. Would you like to publish this to the network?'**
  String get r3dPublishUpdatesBody;

  /// No description provided for @r3dPublishUpdatesBodyWithCost.
  ///
  /// In en, this message translates to:
  /// **'Your local changes were saved successfully. Would you like to publish this to the network?\n\n1 VFX is required since you have already published within the past 24 hours.'**
  String get r3dPublishUpdatesBodyWithCost;

  /// No description provided for @r3dReadyToClaim.
  ///
  /// In en, this message translates to:
  /// **'Ready to Claim'**
  String get r3dReadyToClaim;

  /// No description provided for @r3dRecipientWillReceive.
  ///
  /// In en, this message translates to:
  /// **'The recipient will receive {amount} VFX when they claim the link.'**
  String r3dRecipientWillReceive(String amount);

  /// No description provided for @r3dRecoveryInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recovery In Progress'**
  String get r3dRecoveryInProgress;

  /// No description provided for @r3dRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get r3dRefreshStatus;

  /// No description provided for @r3dRefreshingStatus.
  ///
  /// In en, this message translates to:
  /// **'Refreshing status...'**
  String get r3dRefreshingStatus;

  /// No description provided for @r3dReservePriceGteFloor.
  ///
  /// In en, this message translates to:
  /// **'The reserve price must be greater or equal to the floor price.'**
  String get r3dReservePriceGteFloor;

  /// No description provided for @r3dReservePriceValue.
  ///
  /// In en, this message translates to:
  /// **'Reserve: {price} VFX'**
  String r3dReservePriceValue(String price);

  /// No description provided for @r3dRestoreHdAccount.
  ///
  /// In en, this message translates to:
  /// **'Restore HD Account'**
  String get r3dRestoreHdAccount;

  /// No description provided for @r3dSaleCompleteTxFailed.
  ///
  /// In en, this message translates to:
  /// **'Sale Complete TX Failed'**
  String get r3dSaleCompleteTxFailed;

  /// No description provided for @r3dSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get r3dSaveChanges;

  /// No description provided for @r3dSecondsValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String r3dSecondsValue(String seconds);

  /// No description provided for @r3dSendingVfx.
  ///
  /// In en, this message translates to:
  /// **'Sending VFX'**
  String get r3dSendingVfx;

  /// No description provided for @r3dSendingVfxEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Sending VFX...'**
  String get r3dSendingVfxEllipsis;

  /// No description provided for @r3dSetOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to set this store offline?'**
  String get r3dSetOfflineBody;

  /// No description provided for @r3dSetOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Offline?'**
  String get r3dSetOfflineTitle;

  /// No description provided for @r3dSetOnlineBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to set this store online?'**
  String get r3dSetOnlineBody;

  /// No description provided for @r3dSetOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Online?'**
  String get r3dSetOnlineTitle;

  /// No description provided for @r3dSetupAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'Setup Auction House'**
  String get r3dSetupAuctionHouse;

  /// No description provided for @r3dSetupAuctionHousePrompt.
  ///
  /// In en, this message translates to:
  /// **'First, setup your auction house / gallery.\nThen you\'ll be able to create collections and add listings to them.'**
  String get r3dSetupAuctionHousePrompt;

  /// No description provided for @r3dShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get r3dShareLink;

  /// No description provided for @r3dShareLinkInstructions.
  ///
  /// In en, this message translates to:
  /// **'Share this link with the recipient.\nThey can claim the VFX without needing a wallet.'**
  String get r3dShareLinkInstructions;

  /// No description provided for @r3dShopDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shop Deleted'**
  String get r3dShopDeleted;

  /// No description provided for @r3dShopImported.
  ///
  /// In en, this message translates to:
  /// **'Shop Imported'**
  String get r3dShopImported;

  /// No description provided for @r3dShopOffline.
  ///
  /// In en, this message translates to:
  /// **'Shop Offline'**
  String get r3dShopOffline;

  /// No description provided for @r3dShopOnline.
  ///
  /// In en, this message translates to:
  /// **'Shop Online'**
  String get r3dShopOnline;

  /// No description provided for @r3dShopUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Shop URL copied to clipboard'**
  String get r3dShopUrlCopied;

  /// No description provided for @r3dShopUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL: {url}'**
  String r3dShopUrlLabel(String url);

  /// No description provided for @r3dSignatureGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Signature generation failed.'**
  String get r3dSignatureGenerationFailed;

  /// No description provided for @r3dSignatureNotValid.
  ///
  /// In en, this message translates to:
  /// **'Signature not valid'**
  String get r3dSignatureNotValid;

  /// No description provided for @r3dSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get r3dSize;

  /// No description provided for @r3dStartDateBeforeEndDate.
  ///
  /// In en, this message translates to:
  /// **'The start date must be before the end date.'**
  String get r3dStartDateBeforeEndDate;

  /// No description provided for @r3dStatusInitialized.
  ///
  /// In en, this message translates to:
  /// **'Initialized'**
  String get r3dStatusInitialized;

  /// No description provided for @r3dStatusQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted'**
  String get r3dStatusQuoted;

  /// No description provided for @r3dTimeoutDepositConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Timeout waiting for deposit confirmation. The link was created but may need manual verification.'**
  String get r3dTimeoutDepositConfirmation;

  /// No description provided for @r3dTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get r3dTotalAmount;

  /// No description provided for @r3dTotalReward.
  ///
  /// In en, this message translates to:
  /// **'Total Reward'**
  String get r3dTotalReward;

  /// No description provided for @r3dTransactionNotValid.
  ///
  /// In en, this message translates to:
  /// **'Transaction not valid'**
  String get r3dTransactionNotValid;

  /// No description provided for @r3dTransactionSettled.
  ///
  /// In en, this message translates to:
  /// **'Transaction Settled'**
  String get r3dTransactionSettled;

  /// No description provided for @r3dTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get r3dTryAgain;

  /// No description provided for @r3dValidatedBy.
  ///
  /// In en, this message translates to:
  /// **'Validated By'**
  String get r3dValidatedBy;

  /// No description provided for @r3dVaultAccountsIntroPost.
  ///
  /// In en, this message translates to:
  /// **'] is a Cold Storage and On-Chain Escrow Feature to keep your VFX Funds and your Digital Assets Safe.\n\n'**
  String get r3dVaultAccountsIntroPost;

  /// No description provided for @r3dVaultAccountsIntroPre.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts ['**
  String get r3dVaultAccountsIntroPre;

  /// No description provided for @r3dVaultActivationNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Activating this feature requires a 5 VFX deposit, 4 of which will be burned upon activation.'**
  String get r3dVaultActivationNote;

  /// No description provided for @r3dVaultFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'This feature is separate from your VFX instant settlement address and enables both recovery and call-back on-chain escrow features that allows you to be able to recover funds and assets back to your Vault Account in the event of theft, misplacement, or from a recipient that requires trustless escrow within 24 hours of occurrence or within a user pre-set defined time.\n\n'**
  String get r3dVaultFeatureDescription;

  /// No description provided for @r3dVaultFeaturesOnChain.
  ///
  /// In en, this message translates to:
  /// **'These features are all on-chain and all peers are aware of their current state.\n'**
  String get r3dVaultFeaturesOnChain;

  /// No description provided for @r3dVaultNoFungibleTokens.
  ///
  /// In en, this message translates to:
  /// **'Your Vault Account has no Fungible Tokens.'**
  String get r3dVaultNoFungibleTokens;

  /// No description provided for @r3dVaultNoVbtcTokens.
  ///
  /// In en, this message translates to:
  /// **'Your Vault Account has no vBTC Tokens.'**
  String get r3dVaultNoVbtcTokens;

  /// No description provided for @r3dVaultNotActivatedWarning.
  ///
  /// In en, this message translates to:
  /// **'Your vault account is not activated yet. To protect funds and assets securely, please activate first.'**
  String get r3dVaultNotActivatedWarning;

  /// No description provided for @r3dVfxExplorer.
  ///
  /// In en, this message translates to:
  /// **'VFX Explorer'**
  String get r3dVfxExplorer;

  /// No description provided for @r3dVfxForUsd.
  ///
  /// In en, this message translates to:
  /// **'{vfx} VFX for \${usd} USD'**
  String r3dVfxForUsd(String vfx, String usd);

  /// No description provided for @r3dViewTxs.
  ///
  /// In en, this message translates to:
  /// **'View Txs'**
  String get r3dViewTxs;

  /// No description provided for @r3dWaitingDepositConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for deposit confirmation...\nThis may take up to 20 seconds.'**
  String get r3dWaitingDepositConfirmation;

  /// No description provided for @r3dWaitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Confirmation'**
  String get r3dWaitingForConfirmation;

  /// No description provided for @r3eAccountRequiredExplanation.
  ///
  /// In en, this message translates to:
  /// **'An account is required to continue.\nPlease create your account now with your email address and a password.'**
  String get r3eAccountRequiredExplanation;

  /// No description provided for @r3eAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get r3eAgree;

  /// No description provided for @r3eAgreeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the disclaimer.'**
  String get r3eAgreeDisclaimer;

  /// No description provided for @r3eBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Block: {block}'**
  String r3eBlockLabel(String block);

  /// No description provided for @r3eBtcDomainBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'BTC Domain Transaction has been broadcasted. See log for hash.'**
  String get r3eBtcDomainBroadcasted;

  /// No description provided for @r3eBtcDomainValidBody.
  ///
  /// In en, this message translates to:
  /// **'The BTC Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: {domain}\nAmount: {amount} VFX\nFee: {fee} VFX\nTotal: {total} VFX'**
  String r3eBtcDomainValidBody(String domain, String amount, String fee, String total);

  /// No description provided for @r3eBtcExplorer.
  ///
  /// In en, this message translates to:
  /// **'BTC Explorer'**
  String get r3eBtcExplorer;

  /// No description provided for @r3eButterflyDescDesktop.
  ///
  /// In en, this message translates to:
  /// **'Butterfly makes sending payments simple. Save, Spend, and Pay Anyone, Anywhere, Anytime. Instantly. No Borders, No Restrictions, No Limits, and No Accounts Needed… Be Free!\n\nAuto-login with this account?'**
  String get r3eButterflyDescDesktop;

  /// No description provided for @r3eButterflyDescMobile.
  ///
  /// In en, this message translates to:
  /// **'Butterfly makes sending payments simple. Save, Spend, and Pay Anyone, Anywhere, Anytime. Instantly.\n\nAuto-login with this account?'**
  String get r3eButterflyDescMobile;

  /// No description provided for @r3eCannotLockWhileValidating.
  ///
  /// In en, this message translates to:
  /// **'You can not lock your wallet while validating.'**
  String get r3eCannotLockWhileValidating;

  /// No description provided for @r3eCantFindPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find private key'**
  String get r3eCantFindPrivateKey;

  /// No description provided for @r3eCantFindPublicKey.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find public key'**
  String get r3eCantFindPublicKey;

  /// No description provided for @r3eCloseWallet.
  ///
  /// In en, this message translates to:
  /// **'Close Wallet'**
  String get r3eCloseWallet;

  /// No description provided for @r3eCoinPrices.
  ///
  /// In en, this message translates to:
  /// **'Coin Prices'**
  String get r3eCoinPrices;

  /// No description provided for @r3eCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get r3eCollapse;

  /// No description provided for @r3eConfirmEncryptionPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your encryption password.'**
  String get r3eConfirmEncryptionPassword;

  /// No description provided for @r3eCopySignature.
  ///
  /// In en, this message translates to:
  /// **'Copy Signature'**
  String get r3eCopySignature;

  /// No description provided for @r3eCostToDelete.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} VFX to delete a BTC Domain.'**
  String r3eCostToDelete(String cost);

  /// No description provided for @r3eCouldNotGenerateSignature.
  ///
  /// In en, this message translates to:
  /// **'Could not generate signature'**
  String get r3eCouldNotGenerateSignature;

  /// No description provided for @r3eCouldNotImportMedia.
  ///
  /// In en, this message translates to:
  /// **'Could not import media'**
  String get r3eCouldNotImportMedia;

  /// No description provided for @r3eCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get r3eCreateAccount;

  /// No description provided for @r3eCreateBtcDomainDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a BTC Domain as an alias to your account\'s address for receiving funds.'**
  String get r3eCreateBtcDomainDesc;

  /// No description provided for @r3eDebugData.
  ///
  /// In en, this message translates to:
  /// **'Debug Data'**
  String get r3eDebugData;

  /// No description provided for @r3eDebugDataCopied.
  ///
  /// In en, this message translates to:
  /// **'Debug data copied to clipboard'**
  String get r3eDebugDataCopied;

  /// No description provided for @r3eDecryptAccountPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the password for this account to decrypt its private keys.'**
  String get r3eDecryptAccountPasswordBody;

  /// No description provided for @r3eDeleteBtcDomainBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this BTC Domain?\n{costLine}\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.'**
  String r3eDeleteBtcDomainBody(String costLine);

  /// No description provided for @r3eDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get r3eDisclaimer;

  /// No description provided for @r3eDoNotCloseWallet.
  ///
  /// In en, this message translates to:
  /// **'Please do not close your wallet.'**
  String get r3eDoNotCloseWallet;

  /// No description provided for @r3eDoesNotOwnBody.
  ///
  /// In en, this message translates to:
  /// **'{address}\ndoes NOT own\n{scId}'**
  String r3eDoesNotOwnBody(String address, String scId);

  /// No description provided for @r3eEmailPasswordSeedInfo.
  ///
  /// In en, this message translates to:
  /// **'Your email and password is used to seed your private key which is processed in this browser and will never be transmitted across the internet.'**
  String get r3eEmailPasswordSeedInfo;

  /// No description provided for @r3eEncryptAccountKeys.
  ///
  /// In en, this message translates to:
  /// **'Encrypt Account Keys'**
  String get r3eEncryptAccountKeys;

  /// No description provided for @r3eEncryptAccountPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a password to encrypt this account\'s private keys.'**
  String get r3eEncryptAccountPasswordBody;

  /// No description provided for @r3eEncryptWallet.
  ///
  /// In en, this message translates to:
  /// **'Encrypt Wallet'**
  String get r3eEncryptWallet;

  /// No description provided for @r3eEncryptWalletBody.
  ///
  /// In en, this message translates to:
  /// **'This function will encrypt ALL private keys in this wallet. Please ensure you have ALL private keys in this wallet backed up before proceeding.\n\nThis is an irreversible action and the password that you create will be the only way to gain access to this wallet once you complete this encryption.\n\nIt is also recommended to backup your password in addition to your private keys.'**
  String get r3eEncryptWalletBody;

  /// No description provided for @r3eEnterPasswordBackup.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to backup your keys.'**
  String get r3eEnterPasswordBackup;

  /// No description provided for @r3eExportNftMedia.
  ///
  /// In en, this message translates to:
  /// **'Export NFT Media'**
  String get r3eExportNftMedia;

  /// No description provided for @r3eFailedDecryptKeys.
  ///
  /// In en, this message translates to:
  /// **'Failed to decrypt account keys. Check your password.'**
  String get r3eFailedDecryptKeys;

  /// No description provided for @r3eFailedDeleteDb.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete {path} — folder still exists after delete'**
  String r3eFailedDeleteDb(String path);

  /// No description provided for @r3eFailedDownloadFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to download {filename} after {attempts} attempts'**
  String r3eFailedDownloadFile(String filename, String attempts);

  /// No description provided for @r3eFaucetIntro.
  ///
  /// In en, this message translates to:
  /// **'The community has allocated some VFX to lower the barrier to entry for trying out this feature. In order to prevent abuse, a phone number is required for an SMS authorization. Only a hash of your phone number will be stored.'**
  String get r3eFaucetIntro;

  /// No description provided for @r3eFaucetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success! Funds are on their way. TX Hash: {result}'**
  String r3eFaucetSuccess(String result);

  /// No description provided for @r3eFilesOnDiskMismatch.
  ///
  /// In en, this message translates to:
  /// **'Only {count} of {total} files on disk after download'**
  String r3eFilesOnDiskMismatch(String count, String total);

  /// No description provided for @r3eGetBtc.
  ///
  /// In en, this message translates to:
  /// **'Get BTC'**
  String get r3eGetBtc;

  /// No description provided for @r3eImportMedia.
  ///
  /// In en, this message translates to:
  /// **'Import Media'**
  String get r3eImportMedia;

  /// No description provided for @r3eImportSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Import Snapshot'**
  String get r3eImportSnapshot;

  /// No description provided for @r3eIncorrectDecryptionPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect decryption password.'**
  String get r3eIncorrectDecryptionPassword;

  /// No description provided for @r3eIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get r3eIncorrectPassword;

  /// No description provided for @r3eInvalidHexColor.
  ///
  /// In en, this message translates to:
  /// **'Invalid hex color'**
  String get r3eInvalidHexColor;

  /// No description provided for @r3eInvalidOwnershipSig.
  ///
  /// In en, this message translates to:
  /// **'Invalid ownership verification signature'**
  String get r3eInvalidOwnershipSig;

  /// No description provided for @r3eJustTakeMeThere.
  ///
  /// In en, this message translates to:
  /// **'Just Take Me There'**
  String get r3eJustTakeMeThere;

  /// No description provided for @r3eLaunchButterfly.
  ///
  /// In en, this message translates to:
  /// **'Launch Butterfly'**
  String get r3eLaunchButterfly;

  /// No description provided for @r3eLocalHeightAhead.
  ///
  /// In en, this message translates to:
  /// **'Your local blockheight is further along than the snapshot.'**
  String get r3eLocalHeightAhead;

  /// No description provided for @r3eLockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock Now'**
  String get r3eLockNow;

  /// No description provided for @r3eLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get r3eLogin;

  /// No description provided for @r3eLoginWithThisAccount.
  ///
  /// In en, this message translates to:
  /// **'Login with this Account'**
  String get r3eLoginWithThisAccount;

  /// No description provided for @r3eMaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Amount: {amount} VFX'**
  String r3eMaxAmount(String amount);

  /// No description provided for @r3eMediaBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Media backed up successfully.'**
  String get r3eMediaBackedUp;

  /// No description provided for @r3eMediaImported.
  ///
  /// In en, this message translates to:
  /// **'Media Imported Successfully'**
  String get r3eMediaImported;

  /// No description provided for @r3eMustAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms before proceeding.'**
  String get r3eMustAgreeTerms;

  /// No description provided for @r3eNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get r3eNewPassword;

  /// No description provided for @r3eNoAccountSelected.
  ///
  /// In en, this message translates to:
  /// **'No Account Selected'**
  String get r3eNoAccountSelected;

  /// No description provided for @r3eNoBtcTransactions.
  ///
  /// In en, this message translates to:
  /// **'No BTC Transactions Found'**
  String get r3eNoBtcTransactions;

  /// No description provided for @r3eNoCostToDelete.
  ///
  /// In en, this message translates to:
  /// **'There is no cost to delete and BTC Domain (aside from the TX fee).'**
  String get r3eNoCostToDelete;

  /// No description provided for @r3eNoKeysToEncrypt.
  ///
  /// In en, this message translates to:
  /// **'No keys to encrypt.'**
  String get r3eNoKeysToEncrypt;

  /// No description provided for @r3eNoNotValidating.
  ///
  /// In en, this message translates to:
  /// **'NO you are NOT Validating'**
  String get r3eNoNotValidating;

  /// No description provided for @r3eNoVfxTransactions.
  ///
  /// In en, this message translates to:
  /// **'No VFX Transactions Found'**
  String get r3eNoVfxTransactions;

  /// No description provided for @r3eNotValidatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Validating ❌'**
  String get r3eNotValidatingTitle;

  /// No description provided for @r3eOpenDbFolder.
  ///
  /// In en, this message translates to:
  /// **'Open DB Folder'**
  String get r3eOpenDbFolder;

  /// No description provided for @r3eOpenExplorer.
  ///
  /// In en, this message translates to:
  /// **'Open Explorer'**
  String get r3eOpenExplorer;

  /// No description provided for @r3eOpenLog.
  ///
  /// In en, this message translates to:
  /// **'Open Log'**
  String get r3eOpenLog;

  /// No description provided for @r3eOwnershipNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Ownership NOT Verified'**
  String get r3eOwnershipNotVerified;

  /// No description provided for @r3eOwnershipVerificationSignature.
  ///
  /// In en, this message translates to:
  /// **'Ownership Verification Signature'**
  String get r3eOwnershipVerificationSignature;

  /// No description provided for @r3eOwnsBody.
  ///
  /// In en, this message translates to:
  /// **'{address}\nOWNS\n{scId}'**
  String r3eOwnsBody(String address, String scId);

  /// No description provided for @r3ePasswordConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation failed'**
  String get r3ePasswordConfirmFailed;

  /// No description provided for @r3ePasswordEncryptKeys.
  ///
  /// In en, this message translates to:
  /// **'This password will be used to encrypt your keys.'**
  String get r3ePasswordEncryptKeys;

  /// No description provided for @r3ePasswordsDoNotMatchRetry.
  ///
  /// In en, this message translates to:
  /// **'Your passwords do not match. Please try again.'**
  String get r3ePasswordsDoNotMatchRetry;

  /// No description provided for @r3ePasteSignature.
  ///
  /// In en, this message translates to:
  /// **'Paste in the signature provided by the owner to validate its ownership.'**
  String get r3ePasteSignature;

  /// No description provided for @r3ePhoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number is required'**
  String get r3ePhoneNumberRequired;

  /// No description provided for @r3ePrintAddresses.
  ///
  /// In en, this message translates to:
  /// **'Print Addresses'**
  String get r3ePrintAddresses;

  /// No description provided for @r3ePrintValidators.
  ///
  /// In en, this message translates to:
  /// **'Print Validators'**
  String get r3ePrintValidators;

  /// No description provided for @r3eProblemLocalHeight.
  ///
  /// In en, this message translates to:
  /// **'Problem fetching local block height. Please try again.'**
  String get r3eProblemLocalHeight;

  /// No description provided for @r3eProblemSnapshotHeight.
  ///
  /// In en, this message translates to:
  /// **'Problem fetching snapshot block height. Please try again.'**
  String get r3eProblemSnapshotHeight;

  /// No description provided for @r3eProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}'**
  String r3eProgressLabel(String percent);

  /// No description provided for @r3eReadLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get r3eReadLess;

  /// No description provided for @r3eReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get r3eReadMore;

  /// No description provided for @r3eRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get r3eRecentTransactions;

  /// No description provided for @r3eRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Your Reserve (Protected) Account is being recovered to your recovery address.\n\nTransaction Hash: {hash}\n\nAll non-settled transactions for funds and assets will be transferred as well as your current available balance. \n\nIt is recommended you import your recovery private key into a new machine. NFT media will not be transferred over so please export them by clicking the button below and import them to your new environment.'**
  String r3eRecoveryBody(String hash);

  /// No description provided for @r3eRecoveryStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery process has started'**
  String get r3eRecoveryStartedTitle;

  /// No description provided for @r3eRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get r3eRestart;

  /// No description provided for @r3eRestartCliConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the CLI?'**
  String get r3eRestartCliConfirm;

  /// No description provided for @r3eSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {data}'**
  String r3eSavedTo(String data);

  /// No description provided for @r3eSendOwnershipSignature.
  ///
  /// In en, this message translates to:
  /// **'Send this ownership validation signature to prove you are the owner.'**
  String get r3eSendOwnershipSignature;

  /// No description provided for @r3eSensitiveOperationPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue with this sensitive operation.'**
  String get r3eSensitiveOperationPassword;

  /// No description provided for @r3eSessionTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'Your session will be locked due to inactivity. Do you want to stay logged in?\n\nThis dialog will auto-lock in 15 seconds.'**
  String get r3eSessionTimeoutBody;

  /// No description provided for @r3eSessionTimeoutWarning.
  ///
  /// In en, this message translates to:
  /// **'Session Timeout Warning'**
  String get r3eSessionTimeoutWarning;

  /// No description provided for @r3eSetPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get r3eSetPassword;

  /// No description provided for @r3eShowDebugData.
  ///
  /// In en, this message translates to:
  /// **'Show Debug Data'**
  String get r3eShowDebugData;

  /// No description provided for @r3eSignatureCopied.
  ///
  /// In en, this message translates to:
  /// **'Signature Verification copied to clipboard.'**
  String get r3eSignatureCopied;

  /// No description provided for @r3eSnapshotNoUrls.
  ///
  /// In en, this message translates to:
  /// **'Snapshot has no download URLs'**
  String get r3eSnapshotNoUrls;

  /// No description provided for @r3eStatusLog.
  ///
  /// In en, this message translates to:
  /// **'Status Log'**
  String get r3eStatusLog;

  /// No description provided for @r3eStayLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay Logged In'**
  String get r3eStayLoggedIn;

  /// No description provided for @r3eSyncingState.
  ///
  /// In en, this message translates to:
  /// **'Syncing state treis due to improper shutdown'**
  String get r3eSyncingState;

  /// No description provided for @r3eUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String r3eUnexpectedError(String error);

  /// No description provided for @r3eUnlockWallet.
  ///
  /// In en, this message translates to:
  /// **'Unlock Wallet'**
  String get r3eUnlockWallet;

  /// No description provided for @r3eValidatingCheckProblem.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred checking your validating status. Please restart your wallet and try again.'**
  String get r3eValidatingCheckProblem;

  /// No description provided for @r3eValidatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Validating ✅'**
  String get r3eValidatingTitle;

  /// No description provided for @r3eValidatorCheck.
  ///
  /// In en, this message translates to:
  /// **'Validator Check'**
  String get r3eValidatorCheck;

  /// No description provided for @r3eValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Value is required'**
  String get r3eValueRequired;

  /// No description provided for @r3eVerifyNftOwnership.
  ///
  /// In en, this message translates to:
  /// **'Verify NFT Ownership'**
  String get r3eVerifyNftOwnership;

  /// No description provided for @r3eVfxAddress.
  ///
  /// In en, this message translates to:
  /// **'VFX Address: {address}'**
  String r3eVfxAddress(String address);

  /// No description provided for @r3eVfxDomainValidBody.
  ///
  /// In en, this message translates to:
  /// **'The VFX Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: {domain}\nAmount: {amount} VFX\nFee: {fee} VFX\nTotal: {total} VFX'**
  String r3eVfxDomainValidBody(String domain, String amount, String fee, String total);

  /// No description provided for @r3eVfxExplorer.
  ///
  /// In en, this message translates to:
  /// **'VFX Explorer'**
  String get r3eVfxExplorer;

  /// No description provided for @r3eViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get r3eViewAll;

  /// No description provided for @r3eViewChart.
  ///
  /// In en, this message translates to:
  /// **'View Chart'**
  String get r3eViewChart;

  /// No description provided for @r3eWalletEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is now encrypted.'**
  String get r3eWalletEncrypted;

  /// No description provided for @r3eWalletLocked.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is now locked.'**
  String get r3eWalletLocked;

  /// No description provided for @r3eWalletUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Wallet has been unlocked.'**
  String get r3eWalletUnlocked;

  /// No description provided for @r3eWalletUnlocked10Min.
  ///
  /// In en, this message translates to:
  /// **'Wallet has been unlocked for 10 minutes.'**
  String get r3eWalletUnlocked10Min;

  /// No description provided for @r3eWebWalletEncryptionBody.
  ///
  /// In en, this message translates to:
  /// **'The web wallet now uses encryption to protect your keys. In order to add an additional account you must fully sign out of the wallet and login again. Please make sure all your existing login details / keys are backed up before proceeding.'**
  String get r3eWebWalletEncryptionBody;

  /// No description provided for @r3eWebWalletEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Web Wallet Now Uses Encryption'**
  String get r3eWebWalletEncryptionTitle;

  /// No description provided for @r3eWhichVfxManageDomain.
  ///
  /// In en, this message translates to:
  /// **'What VFX address will manage this BTC domain?'**
  String get r3eWhichVfxManageDomain;

  /// No description provided for @r3eYesValidating.
  ///
  /// In en, this message translates to:
  /// **'YES you are Validating!'**
  String get r3eYesValidating;

  /// No description provided for @r3fAProblemOccurred.
  ///
  /// In en, this message translates to:
  /// **'A Problem Occurred'**
  String get r3fAProblemOccurred;

  /// No description provided for @r3fAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address {address} copied to clipboard'**
  String r3fAddressCopied(String address);

  /// No description provided for @r3fAnErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'And error occurred'**
  String get r3fAnErrorOccurred;

  /// No description provided for @r3fAutoActivateBody.
  ///
  /// In en, this message translates to:
  /// **'Would you like to activate the account automatically once the funding is complete?'**
  String get r3fAutoActivateBody;

  /// No description provided for @r3fBridgeHistoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bridge history is unavailable.'**
  String get r3fBridgeHistoryUnavailable;

  /// No description provided for @r3fBridgeStatusAwaitingSignatures.
  ///
  /// In en, this message translates to:
  /// **'Awaiting signatures'**
  String get r3fBridgeStatusAwaitingSignatures;

  /// No description provided for @r3fBridgeStatusExiting.
  ///
  /// In en, this message translates to:
  /// **'Exiting'**
  String get r3fBridgeStatusExiting;

  /// No description provided for @r3fBridgeStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get r3fBridgeStatusExpired;

  /// No description provided for @r3fBridgeStatusLocking.
  ///
  /// In en, this message translates to:
  /// **'Locking'**
  String get r3fBridgeStatusLocking;

  /// No description provided for @r3fBridgeStatusMinted.
  ///
  /// In en, this message translates to:
  /// **'Minted'**
  String get r3fBridgeStatusMinted;

  /// No description provided for @r3fBridgeStatusMinting.
  ///
  /// In en, this message translates to:
  /// **'Minting'**
  String get r3fBridgeStatusMinting;

  /// No description provided for @r3fBridgeStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get r3fBridgeStatusReturned;

  /// No description provided for @r3fBridgeStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get r3fBridgeStatusUnknown;

  /// No description provided for @r3fBridgeUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the bridge service.'**
  String get r3fBridgeUnreachable;

  /// No description provided for @r3fBulkConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send a total of {amount} vBTC to {address}'**
  String r3fBulkConfirmBody(String amount, String address);

  /// No description provided for @r3fBulkMinTwoTokens.
  ///
  /// In en, this message translates to:
  /// **'At least two tokens are required to do a bulk vBTC transaction'**
  String get r3fBulkMinTwoTokens;

  /// No description provided for @r3fBulkSentToast.
  ///
  /// In en, this message translates to:
  /// **'{amount} vBTC has been sent to {address}.'**
  String r3fBulkSentToast(String amount, String address);

  /// No description provided for @r3fCliRestartRequired.
  ///
  /// In en, this message translates to:
  /// **'CLI restart required for changes to take effect.'**
  String get r3fCliRestartRequired;

  /// No description provided for @r3fConfirmingBalance.
  ///
  /// In en, this message translates to:
  /// **'Confirming Balance...'**
  String get r3fConfirmingBalance;

  /// No description provided for @r3fCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'\'{value}\' Copied to clipboard'**
  String r3fCopiedToClipboard(String value);

  /// No description provided for @r3fErrorColon.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String r3fErrorColon(String msg);

  /// No description provided for @r3fErrorHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get r3fErrorHasOccurred;

  /// No description provided for @r3fFailedCancelWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel withdrawal.'**
  String get r3fFailedCancelWithdrawal;

  /// No description provided for @r3fFailedCeremonyStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to get ceremony status.'**
  String get r3fFailedCeremonyStatus;

  /// No description provided for @r3fFailedCompleteWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete withdrawal.'**
  String get r3fFailedCompleteWithdrawal;

  /// No description provided for @r3fFailedCreateContract.
  ///
  /// In en, this message translates to:
  /// **'Failed to create contract.'**
  String get r3fFailedCreateContract;

  /// No description provided for @r3fFailedInitiateCeremony.
  ///
  /// In en, this message translates to:
  /// **'Failed to initiate ceremony.'**
  String get r3fFailedInitiateCeremony;

  /// No description provided for @r3fFailedParseFee.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse fee'**
  String get r3fFailedParseFee;

  /// No description provided for @r3fFailedParseHash.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse hash'**
  String get r3fFailedParseHash;

  /// No description provided for @r3fFailedRequestWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Failed to request withdrawal.'**
  String get r3fFailedRequestWithdrawal;

  /// No description provided for @r3fFailedRetrieveNonce.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve nonce'**
  String get r3fFailedRetrieveNonce;

  /// No description provided for @r3fFailedRetrieveTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve timestamp'**
  String get r3fFailedRetrieveTimestamp;

  /// No description provided for @r3fFailedTransferOwnership.
  ///
  /// In en, this message translates to:
  /// **'Failed to transfer ownership.'**
  String get r3fFailedTransferOwnership;

  /// No description provided for @r3fFailedTransferVbtc.
  ///
  /// In en, this message translates to:
  /// **'Failed to transfer vBTC.'**
  String get r3fFailedTransferVbtc;

  /// No description provided for @r3fFeePresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get r3fFeePresetCustom;

  /// No description provided for @r3fFeePresetEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get r3fFeePresetEconomy;

  /// No description provided for @r3fFeePresetFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get r3fFeePresetFastest;

  /// No description provided for @r3fFeePresetHalfHour.
  ///
  /// In en, this message translates to:
  /// **'Half Hour'**
  String get r3fFeePresetHalfHour;

  /// No description provided for @r3fFeePresetHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get r3fFeePresetHour;

  /// No description provided for @r3fFeePresetMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get r3fFeePresetMinimum;

  /// No description provided for @r3fFundConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send 5 VFX from {address}?'**
  String r3fFundConfirmBody(String address);

  /// No description provided for @r3fFundSentToast.
  ///
  /// In en, this message translates to:
  /// **'5 VFX sent to {address}'**
  String r3fFundSentToast(String address);

  /// No description provided for @r3fInputAmountsPerToken.
  ///
  /// In en, this message translates to:
  /// **'Input Amounts for each token:'**
  String get r3fInputAmountsPerToken;

  /// No description provided for @r3fInsufficientVfxBalance.
  ///
  /// In en, this message translates to:
  /// **'Selected VFX account doesn\'t have enough balance'**
  String get r3fInsufficientVfxBalance;

  /// No description provided for @r3fMaxAmountIs.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount is {amount} vBTC'**
  String r3fMaxAmountIs(String amount);

  /// No description provided for @r3fMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'(MAX: {amount} vBTC)'**
  String r3fMaxLabel(String amount);

  /// No description provided for @r3fMyBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'My Balance: {balance} vBTC{usd}'**
  String r3fMyBalanceLabel(String balance, String usd);

  /// No description provided for @r3fNftNotTransferred.
  ///
  /// In en, this message translates to:
  /// **'NFT assets have not been transferred to the VFX Web Account.'**
  String get r3fNftNotTransferred;

  /// No description provided for @r3fNoAdditionalMedia.
  ///
  /// In en, this message translates to:
  /// **'This token does not contain any additional media.'**
  String get r3fNoAdditionalMedia;

  /// No description provided for @r3fNoBtcTransactions.
  ///
  /// In en, this message translates to:
  /// **'No BTC Transactions'**
  String get r3fNoBtcTransactions;

  /// No description provided for @r3fNoRequestHash.
  ///
  /// In en, this message translates to:
  /// **'No request hash returned from withdrawal request.'**
  String get r3fNoRequestHash;

  /// No description provided for @r3fNotGenerated.
  ///
  /// In en, this message translates to:
  /// **'Not Generated'**
  String get r3fNotGenerated;

  /// No description provided for @r3fOnboardFaucetDetails.
  ///
  /// In en, this message translates to:
  /// **'The community has provided a faucet to withdraw a minimal amount of VFX from in order to try out this feature. A phone number is required for verification purposes and to reduce the chance of abuse. Please note that only a hash of the phone number is stored with the faucet. Alternatively, you are welcome to purchase VFX via an exchange on on-ramp if you like.'**
  String get r3fOnboardFaucetDetails;

  /// No description provided for @r3fOnboardTokenizeDetails.
  ///
  /// In en, this message translates to:
  /// **'Time to tokenize a vBTC token. The following fields are all optional!'**
  String get r3fOnboardTokenizeDetails;

  /// No description provided for @r3fOnboardTransferBtcDetails.
  ///
  /// In en, this message translates to:
  /// **'Looks like this account doesn\'t have any BTC. Please transfer BTC to this account to continue.'**
  String get r3fOnboardTransferBtcDetails;

  /// No description provided for @r3fOnboardTransferToVbtcDetails.
  ///
  /// In en, this message translates to:
  /// **'Now you are ready to transfer BTC to your vBTC token. Select the amount and Fee Rate below'**
  String get r3fOnboardTransferToVbtcDetails;

  /// No description provided for @r3fPrivateKeyImportedSync.
  ///
  /// In en, this message translates to:
  /// **'Private Key Imported! Please wait until {time} for the balance to sync.'**
  String r3fPrivateKeyImportedSync(String time);

  /// No description provided for @r3fProblemRecoverySigScript.
  ///
  /// In en, this message translates to:
  /// **'Problem generating RecoverySigScript'**
  String get r3fProblemRecoverySigScript;

  /// No description provided for @r3fQrScannerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner not available on this platform'**
  String get r3fQrScannerUnavailable;

  /// No description provided for @r3fRecoverBody.
  ///
  /// In en, this message translates to:
  /// **'This is a destructive function that will callback all pending transactions and assets and move everything to this recovery address:\n\n{address}'**
  String r3fRecoverBody(String address);

  /// No description provided for @r3fRestartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get r3fRestartNow;

  /// No description provided for @r3fRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Importing an existing Vault Account will replace the current one tied to your login. To revert you can logout and login again.\n\nContinue?'**
  String get r3fRestoreBody;

  /// No description provided for @r3fRestoreCodePrompt.
  ///
  /// In en, this message translates to:
  /// **'Paste in your RESTORE CODE to import your existing Vault Account.'**
  String get r3fRestoreCodePrompt;

  /// No description provided for @r3fRevealPrivateKeyBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reveal your private key?'**
  String get r3fRevealPrivateKeyBody;

  /// No description provided for @r3fSelectTokensToTransfer.
  ///
  /// In en, this message translates to:
  /// **'Select the tokens you\'d like to transfer from:'**
  String get r3fSelectTokensToTransfer;

  /// No description provided for @r3fTokenMedia.
  ///
  /// In en, this message translates to:
  /// **'Token Media'**
  String get r3fTokenMedia;

  /// No description provided for @r3fTokenTotalBalanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Token Total Balance: {balance} vBTC{usd}'**
  String r3fTokenTotalBalanceTooltip(String balance, String usd);

  /// No description provided for @r3fTransactionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction completed: {txHash}'**
  String r3fTransactionCompleted(String txHash);

  /// No description provided for @r3fTxTypeMultiSig.
  ///
  /// In en, this message translates to:
  /// **'Multi-signature'**
  String get r3fTxTypeMultiSig;

  /// No description provided for @r3fTxTypeReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get r3fTxTypeReplace;

  /// No description provided for @r3fTxTypeSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Same Account TX'**
  String get r3fTxTypeSameAccount;

  /// No description provided for @r3fWaitingTokenization.
  ///
  /// In en, this message translates to:
  /// **'Waiting for vBTC Tokenization to compile.'**
  String get r3fWaitingTokenization;

  /// No description provided for @r3gAccountUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Account unlocked.'**
  String get r3gAccountUnlocked;

  /// No description provided for @r3gAccountUnlocked10Min.
  ///
  /// In en, this message translates to:
  /// **'Account unlocked for 10 minutes.'**
  String get r3gAccountUnlocked10Min;

  /// No description provided for @r3gActiveColon.
  ///
  /// In en, this message translates to:
  /// **'Active:'**
  String get r3gActiveColon;

  /// No description provided for @r3gAdditionalAssetsColon.
  ///
  /// In en, this message translates to:
  /// **'Additional Assets:'**
  String get r3gAdditionalAssetsColon;

  /// No description provided for @r3gAddressCopiedDot.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard.'**
  String get r3gAddressCopiedDot;

  /// No description provided for @r3gAdnrCreateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The {currency} Domain transaction is valid.\nAre you sure you want to proceed?\n\nDomain: {domain}\nAmount: {amount} VFX\nFee: {fee} VFX\nTotal: {total} VFX'**
  String r3gAdnrCreateConfirmBody(String currency, String domain, String amount, String fee, String total);

  /// No description provided for @r3gAdnrDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this VFX Domain?\n{costLine}\n\nOnce deleted, this ADNR will no longer be able to receive any transactions.'**
  String r3gAdnrDeleteBody(String costLine);

  /// No description provided for @r3gAdnrDeleteNoCost.
  ///
  /// In en, this message translates to:
  /// **'There is no cost to delete and VFX Domain (aside from the TX fee).'**
  String get r3gAdnrDeleteNoCost;

  /// No description provided for @r3gAdnrDeleteWithCost.
  ///
  /// In en, this message translates to:
  /// **'There is a cost of {cost} RBX to delete an RBX Domain.'**
  String r3gAdnrDeleteWithCost(String cost);

  /// No description provided for @r3gAssetListedInAuctionHouse.
  ///
  /// In en, this message translates to:
  /// **'This {assetType} is listed in your auction house. Please remove the listing before transferring.'**
  String r3gAssetListedInAuctionHouse(String assetType);

  /// No description provided for @r3gAssetTransferSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'{assetType} Transfer sent successfully to {address}!'**
  String r3gAssetTransferSentSuccess(String assetType, String address);

  /// No description provided for @r3gAuctionBegins.
  ///
  /// In en, this message translates to:
  /// **'Begins: {date} {time}'**
  String r3gAuctionBegins(String date, String time);

  /// No description provided for @r3gAuctionEnds.
  ///
  /// In en, this message translates to:
  /// **'Auction Ends'**
  String get r3gAuctionEnds;

  /// No description provided for @r3gAuctionHasEnded.
  ///
  /// In en, this message translates to:
  /// **'Auction Has Ended'**
  String get r3gAuctionHasEnded;

  /// No description provided for @r3gAuctionStarts.
  ///
  /// In en, this message translates to:
  /// **'Auction Starts'**
  String get r3gAuctionStarts;

  /// No description provided for @r3gAuctionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Auction Upcoming'**
  String get r3gAuctionUpcoming;

  /// No description provided for @r3gBackupUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Backup URL required'**
  String get r3gBackupUrlRequired;

  /// No description provided for @r3gBackupUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup URL {optional}'**
  String r3gBackupUrlTitle(String optional);

  /// No description provided for @r3gBaselineAsset.
  ///
  /// In en, this message translates to:
  /// **'Baseline Asset'**
  String get r3gBaselineAsset;

  /// No description provided for @r3gBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Bid Amount'**
  String get r3gBidAmount;

  /// No description provided for @r3gBidGreaterThanHighest.
  ///
  /// In en, this message translates to:
  /// **'Your bid must be greater than the current highest bid ({price} VFX)'**
  String r3gBidGreaterThanHighest(String price);

  /// No description provided for @r3gBidResent.
  ///
  /// In en, this message translates to:
  /// **'Bid Resent!'**
  String get r3gBidResent;

  /// No description provided for @r3gBidSent.
  ///
  /// In en, this message translates to:
  /// **'Bid sent. Please check the Bid History to see if it\'s been accepted or rejected.'**
  String get r3gBidSent;

  /// No description provided for @r3gBurnSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Burn transaction sent successfully!'**
  String get r3gBurnSentSuccess;

  /// No description provided for @r3gBuyNowSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Buy Now transaction sent successfully. Please wait for confirmation.'**
  String get r3gBuyNowSentSuccess;

  /// No description provided for @r3gChain.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get r3gChain;

  /// No description provided for @r3gCollectionError.
  ///
  /// In en, this message translates to:
  /// **'Collection Error'**
  String get r3gCollectionError;

  /// No description provided for @r3gConfirmBurnName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to burn {name}'**
  String r3gConfirmBurnName(String name);

  /// No description provided for @r3gConfirmBuyNowBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to buy now for {price} VFX?'**
  String r3gConfirmBuyNowBody(String price);

  /// No description provided for @r3gConfirmDevolveOneStage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to devolve this NFT one stage?'**
  String get r3gConfirmDevolveOneStage;

  /// No description provided for @r3gConfirmEvolveOneStage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to evolve this NFT one stage?'**
  String get r3gConfirmEvolveOneStage;

  /// No description provided for @r3gConfirmEvolveToStage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to evolve to stage {index}?'**
  String r3gConfirmEvolveToStage(String index);

  /// No description provided for @r3gConfirmPlaceBidBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to place a bid of {amount} VFX{maxSuffix}?'**
  String r3gConfirmPlaceBidBody(String amount, String maxSuffix);

  /// No description provided for @r3gConfirmSellNftBody.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you want to sell the NFT to \"{address}\" for {amount} VFX.'**
  String r3gConfirmSellNftBody(String address, String amount);

  /// No description provided for @r3gConfirmSendAssetBody.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you want to send the {assetType} to \"{address}\".{warning}'**
  String r3gConfirmSendAssetBody(String assetType, String address, String warning);

  /// No description provided for @r3gConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get r3gConnect;

  /// No description provided for @r3gConnectToAuctionHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to Auction House?'**
  String get r3gConnectToAuctionHouseTitle;

  /// No description provided for @r3gConnectToShopBody.
  ///
  /// In en, this message translates to:
  /// **'Would you like to connect to {name} ({url})?'**
  String r3gConnectToShopBody(String name, String url);

  /// No description provided for @r3gConnectedFetchingData.
  ///
  /// In en, this message translates to:
  /// **'Connected to {url}. Fetching data...'**
  String r3gConnectedFetchingData(String url);

  /// No description provided for @r3gConnectingToShop.
  ///
  /// In en, this message translates to:
  /// **'Connecting to shop...'**
  String get r3gConnectingToShop;

  /// No description provided for @r3gCopyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy Message'**
  String get r3gCopyMessage;

  /// No description provided for @r3gCouldNotConnectOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to shop because it\'s offline.'**
  String get r3gCouldNotConnectOffline;

  /// No description provided for @r3gCouldNotFindShop.
  ///
  /// In en, this message translates to:
  /// **'Could not find auction house with url of {url}'**
  String r3gCouldNotFindShop(String url);

  /// No description provided for @r3gCurrentBidPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Bid Price:'**
  String get r3gCurrentBidPrice;

  /// No description provided for @r3gCurrentBids.
  ///
  /// In en, this message translates to:
  /// **'Current Bids'**
  String get r3gCurrentBids;

  /// No description provided for @r3gCurrentStage.
  ///
  /// In en, this message translates to:
  /// **'Current Stage: {name}'**
  String r3gCurrentStage(String name);

  /// No description provided for @r3gDevolve.
  ///
  /// In en, this message translates to:
  /// **'Devolve'**
  String get r3gDevolve;

  /// No description provided for @r3gEncryptionPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Encryption Password Required to continue validating.'**
  String get r3gEncryptionPasswordRequired;

  /// No description provided for @r3gEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in'**
  String get r3gEndsIn;

  /// No description provided for @r3gEvolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get r3gEvolution;

  /// No description provided for @r3gEvolveBlockHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Evolve Block Height: {blockHeight}\n{description}'**
  String r3gEvolveBlockHeightLabel(String blockHeight, String description);

  /// No description provided for @r3gEvolveDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Evolve Date: {date} {time} {tz} \n{description}'**
  String r3gEvolveDateLabel(String date, String time, String tz, String description);

  /// No description provided for @r3gEvolveSyncBody.
  ///
  /// In en, this message translates to:
  /// **'This screen will reflect the change once the block is crafted and block height has synced with this transaction.'**
  String get r3gEvolveSyncBody;

  /// No description provided for @r3gFeeRateEstimateCustom.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate: {fee} SATS /byte [{feeBtc} BTC /byte]\nFee Estimate: {feeEstimate} SATS [~{feeEstimateBtc} BTC]'**
  String r3gFeeRateEstimateCustom(String fee, String feeBtc, String feeEstimate, String feeEstimateBtc);

  /// No description provided for @r3gFeeRateEstimatePreset.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate: {fee} SATS /byte [{feeBtc} BTC /byte]\nFee Estimate: ~{feeEstimate} SATS [~{feeEstimateBtc} BTC]    '**
  String r3gFeeRateEstimatePreset(String fee, String feeBtc, String feeEstimate, String feeEstimateBtc);

  /// No description provided for @r3gGettingCollections.
  ///
  /// In en, this message translates to:
  /// **'Getting collections and listings...'**
  String get r3gGettingCollections;

  /// No description provided for @r3gIncorrectDecryptionPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect decryption password.'**
  String get r3gIncorrectDecryptionPassword;

  /// No description provided for @r3gIncrementAmount.
  ///
  /// In en, this message translates to:
  /// **'Increment Amount:'**
  String get r3gIncrementAmount;

  /// No description provided for @r3gLabelCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String r3gLabelCopiedToClipboard(String label);

  /// No description provided for @r3gManageEvolution.
  ///
  /// In en, this message translates to:
  /// **'Manage Evolution'**
  String get r3gManageEvolution;

  /// No description provided for @r3gManagingName.
  ///
  /// In en, this message translates to:
  /// **'Managing {name}'**
  String r3gManagingName(String name);

  /// No description provided for @r3gMaxBidSuffix.
  ///
  /// In en, this message translates to:
  /// **' with a max bid of {max} VFX'**
  String r3gMaxBidSuffix(String max);

  /// No description provided for @r3gMediaFilesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Media files not found on this machine.'**
  String get r3gMediaFilesNotFound;

  /// No description provided for @r3gMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard.'**
  String get r3gMessageCopied;

  /// No description provided for @r3gMinIncrementAmount.
  ///
  /// In en, this message translates to:
  /// **'The minimum increment amount is {increment} VFX. A bid grater than {minBid} VFX is required.'**
  String r3gMinIncrementAmount(String increment, String minBid);

  /// No description provided for @r3gMinted.
  ///
  /// In en, this message translates to:
  /// **'Minted'**
  String get r3gMinted;

  /// No description provided for @r3gMintedBy.
  ///
  /// In en, this message translates to:
  /// **'Minted By'**
  String get r3gMintedBy;

  /// No description provided for @r3gMintedByName.
  ///
  /// In en, this message translates to:
  /// **'Minted By: {name}'**
  String r3gMintedByName(String name);

  /// No description provided for @r3gMinting.
  ///
  /// In en, this message translates to:
  /// **'Minting...'**
  String get r3gMinting;

  /// No description provided for @r3gMustBeGreaterThanBid.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than {minBid} VFX'**
  String r3gMustBeGreaterThanBid(String minBid);

  /// No description provided for @r3gNextOwner.
  ///
  /// In en, this message translates to:
  /// **'Next Owner'**
  String get r3gNextOwner;

  /// No description provided for @r3gNftAssetsNotTransferred.
  ///
  /// In en, this message translates to:
  /// **'NFT assets have not been transferred to the VFX Web Wallet.'**
  String get r3gNftAssetsNotTransferred;

  /// No description provided for @r3gNftFeaturesColon.
  ///
  /// In en, this message translates to:
  /// **'NFT Features:'**
  String get r3gNftFeaturesColon;

  /// No description provided for @r3gNftListedBeforeBurning.
  ///
  /// In en, this message translates to:
  /// **'This NFT is listed in your auction house. Please remove the listing before burning.'**
  String get r3gNftListedBeforeBurning;

  /// No description provided for @r3gNoBids.
  ///
  /// In en, this message translates to:
  /// **'No bids.'**
  String get r3gNoBids;

  /// No description provided for @r3gNoFeatures.
  ///
  /// In en, this message translates to:
  /// **'No features'**
  String get r3gNoFeatures;

  /// No description provided for @r3gNoMintedNfts.
  ///
  /// In en, this message translates to:
  /// **'No minted NFTs with management capabilities.'**
  String get r3gNoMintedNfts;

  /// No description provided for @r3gNoNftsFound.
  ///
  /// In en, this message translates to:
  /// **'No NFTs found.'**
  String get r3gNoNftsFound;

  /// No description provided for @r3gNoRecoveryWarning.
  ///
  /// In en, this message translates to:
  /// **'\n\nIf this address is not correct, there will be no way to recover the ownership of the {assetType}.'**
  String r3gNoRecoveryWarning(String assetType);

  /// No description provided for @r3gNotEnoughBalanceDot.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance.'**
  String get r3gNotEnoughBalanceDot;

  /// No description provided for @r3gNotEnoughBalanceValidating.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance since you are validating.'**
  String get r3gNotEnoughBalanceValidating;

  /// No description provided for @r3gOptionalParenthetical.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get r3gOptionalParenthetical;

  /// No description provided for @r3gPasteZipfileUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste in a public URL to a hosted zipfile containing the assets.'**
  String get r3gPasteZipfileUrl;

  /// No description provided for @r3gPropertiesColon.
  ///
  /// In en, this message translates to:
  /// **'Properties:'**
  String get r3gPropertiesColon;

  /// No description provided for @r3gPropertySingular.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get r3gPropertySingular;

  /// No description provided for @r3gPurchasedBy.
  ///
  /// In en, this message translates to:
  /// **'Purchased by: '**
  String get r3gPurchasedBy;

  /// No description provided for @r3gPurchasedFor.
  ///
  /// In en, this message translates to:
  /// **'for '**
  String get r3gPurchasedFor;

  /// No description provided for @r3gRemoveShopBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {url} from your saved shops?'**
  String r3gRemoveShopBody(String url);

  /// No description provided for @r3gRemoveShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove shop?'**
  String get r3gRemoveShopTitle;

  /// No description provided for @r3gResendMessage.
  ///
  /// In en, this message translates to:
  /// **'Resend Message'**
  String get r3gResendMessage;

  /// No description provided for @r3gReserveMet.
  ///
  /// In en, this message translates to:
  /// **'Reserve Met:'**
  String get r3gReserveMet;

  /// No description provided for @r3gSellNftPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much are you selling this NFT for?'**
  String get r3gSellNftPrompt;

  /// No description provided for @r3gShopCurrentlyOffline.
  ///
  /// In en, this message translates to:
  /// **'This shop is currently offline.'**
  String get r3gShopCurrentlyOffline;

  /// No description provided for @r3gShopError.
  ///
  /// In en, this message translates to:
  /// **'Shop Error'**
  String get r3gShopError;

  /// No description provided for @r3gShopIsOffline.
  ///
  /// In en, this message translates to:
  /// **'Shop is offline.'**
  String get r3gShopIsOffline;

  /// No description provided for @r3gShopOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: This shop is currently offline so the information may not be up to date.'**
  String get r3gShopOfflineWarning;

  /// No description provided for @r3gSmartContractIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract Identifier copied to clipboard'**
  String get r3gSmartContractIdCopied;

  /// No description provided for @r3gStartSale.
  ///
  /// In en, this message translates to:
  /// **'Start Sale'**
  String get r3gStartSale;

  /// No description provided for @r3gStepAmountAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'Input the percentage amount to be paid to the VFX address defined in the next field.'**
  String get r3gStepAmountAddressDesc;

  /// No description provided for @r3gStepAmountAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount & Address'**
  String get r3gStepAmountAddressTitle;

  /// No description provided for @r3gStepEvolutionModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Decide whether you want the evolution to be controlled by the issuer or by the owner of the NFT.'**
  String get r3gStepEvolutionModeDesc;

  /// No description provided for @r3gStepEvolutionModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolution Mode'**
  String get r3gStepEvolutionModeTitle;

  /// No description provided for @r3gStepEvolutionStagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Create multiple evolution stages based on the variables provided previously. Give each stage a name, description and optionally override the asset.'**
  String get r3gStepEvolutionStagesDesc;

  /// No description provided for @r3gStepEvolutionStagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolution Stages'**
  String get r3gStepEvolutionStagesTitle;

  /// No description provided for @r3gStepEvolutionTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure whether you want the NFT to evolve automatically by date/time, block height, or only manually.'**
  String get r3gStepEvolutionTypeDesc;

  /// No description provided for @r3gStepEvolutionTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolution Type'**
  String get r3gStepEvolutionTypeTitle;

  /// No description provided for @r3gStepMetadataDesc.
  ///
  /// In en, this message translates to:
  /// **'Start by providing the name, minter, and description of the smart contract.'**
  String get r3gStepMetadataDesc;

  /// No description provided for @r3gStepMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get r3gStepMetadataTitle;

  /// No description provided for @r3gStepMintDesc.
  ///
  /// In en, this message translates to:
  /// **'Click the compile button to generate the Trilliam code that represents the smart contract then click mint to deploy it to the chain.'**
  String get r3gStepMintDesc;

  /// No description provided for @r3gStepMintTitle.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get r3gStepMintTitle;

  /// No description provided for @r3gStepPrimaryAssetDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the primary asset for the smart contract. This can be an image, audio file, video, or any digital file.'**
  String get r3gStepPrimaryAssetDesc;

  /// No description provided for @r3gStepRoyaltyFeeDesc.
  ///
  /// In en, this message translates to:
  /// **'The fee is calculated from the sale proceeds and settled on transaction finality. For flat fees, the NFT can\'t be sold for less than the enforced royalty.'**
  String get r3gStepRoyaltyFeeDesc;

  /// No description provided for @r3gStepRoyaltyFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Royalty Fee'**
  String get r3gStepRoyaltyFeeTitle;

  /// No description provided for @r3gStepRoyaltyTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose either a flat fee or percentage based royalty enforced by the on the chain upon any trade.'**
  String get r3gStepRoyaltyTypeDesc;

  /// No description provided for @r3gTplBaselineDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a baseline smart contract with an asset and metadata and mint it to the chain'**
  String get r3gTplBaselineDesc;

  /// No description provided for @r3gTplBaselineName.
  ///
  /// In en, this message translates to:
  /// **'Baseline Smart Contract'**
  String get r3gTplBaselineName;

  /// No description provided for @r3gTplEvolvingDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate a smart contract that can evolve based on time or on-chain variables'**
  String get r3gTplEvolvingDesc;

  /// No description provided for @r3gTplEvolvingName.
  ///
  /// In en, this message translates to:
  /// **'Evolving Smart Contract'**
  String get r3gTplEvolvingName;

  /// No description provided for @r3gTplRoyaltyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a smart contract that includes a royalty that is enforced on-chain upon any trade'**
  String get r3gTplRoyaltyDesc;

  /// No description provided for @r3gTplRoyaltyName.
  ///
  /// In en, this message translates to:
  /// **'Royalty Smart Contract'**
  String get r3gTplRoyaltyName;

  /// No description provided for @r3gTransferAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer {assetType}'**
  String r3gTransferAssetTitle(String assetType);

  /// No description provided for @r3gTransferInProgress.
  ///
  /// In en, this message translates to:
  /// **'Transfer in Progress'**
  String get r3gTransferInProgress;

  /// No description provided for @r3gTransferInProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Please ensure to keep your wallet open until this {assetType} transfer transaction appears in your transaction list.\n\nTo monitor the asset transfer progress, open your \'sclog.txt\' in your databases folder.'**
  String r3gTransferInProgressBody(String assetType);

  /// No description provided for @r3gUnlockAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlock Account'**
  String get r3gUnlockAccount;

  /// No description provided for @r3gUrlOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'URL {optional}'**
  String r3gUrlOptionalLabel(String optional);

  /// No description provided for @r3gValueCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{value} copied to clipboard'**
  String r3gValueCopiedToClipboard(String value);

  /// No description provided for @r3gVaultCannotBurnNfts.
  ///
  /// In en, this message translates to:
  /// **'Vault Accounts cannot burn NFTs'**
  String get r3gVaultCannotBurnNfts;

  /// No description provided for @r3hAccountIsValidating.
  ///
  /// In en, this message translates to:
  /// **'This account is validating'**
  String get r3hAccountIsValidating;

  /// No description provided for @r3hActiveValidators.
  ///
  /// In en, this message translates to:
  /// **'Active Validators: {count}'**
  String r3hActiveValidators(String count);

  /// No description provided for @r3hAdditionalLinksOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Link(s) (Optional)'**
  String get r3hAdditionalLinksOptional;

  /// No description provided for @r3hAddressInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Address.'**
  String get r3hAddressInvalid;

  /// No description provided for @r3hAddressOrDomainRequired.
  ///
  /// In en, this message translates to:
  /// **'Address or VFX domain required'**
  String get r3hAddressOrDomainRequired;

  /// No description provided for @r3hAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address required'**
  String get r3hAddressRequired;

  /// No description provided for @r3hAddressToBan.
  ///
  /// In en, this message translates to:
  /// **'Address to Ban'**
  String get r3hAddressToBan;

  /// No description provided for @r3hAdjVoteInDetails.
  ///
  /// In en, this message translates to:
  /// **'Adj Vote In Details'**
  String get r3hAdjVoteInDetails;

  /// No description provided for @r3hAdjVoteInTooLong.
  ///
  /// In en, this message translates to:
  /// **'The \'Vote Adjudicator In\' submission is too long. Please reduce the content.'**
  String get r3hAdjVoteInTooLong;

  /// No description provided for @r3hAllowVotingLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow Voting:'**
  String get r3hAllowVotingLabel;

  /// No description provided for @r3hAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available: {balance} VFX'**
  String r3hAvailableBalance(String balance);

  /// No description provided for @r3hBalanceRequired.
  ///
  /// In en, this message translates to:
  /// **'A balance is required'**
  String get r3hBalanceRequired;

  /// No description provided for @r3hBandwidthHint.
  ///
  /// In en, this message translates to:
  /// **'0 for unlimited'**
  String get r3hBandwidthHint;

  /// No description provided for @r3hBandwidthTb.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth (in TB)'**
  String get r3hBandwidthTb;

  /// No description provided for @r3hCannotHideValidating.
  ///
  /// In en, this message translates to:
  /// **'You can\'t hide an account that is validating'**
  String get r3hCannotHideValidating;

  /// No description provided for @r3hCompileMintBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed?\nOnce compiled you will not be able to make any changes\nand the smart contract/token will be deployed to the chain.'**
  String get r3hCompileMintBody;

  /// No description provided for @r3hConfirmVoteNoBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to vote NO on this topic?'**
  String get r3hConfirmVoteNoBody;

  /// No description provided for @r3hConfirmVoteNoTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote [NO]'**
  String get r3hConfirmVoteNoTitle;

  /// No description provided for @r3hConfirmVoteYesBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to vote YES on this topic?'**
  String get r3hConfirmVoteYesBody;

  /// No description provided for @r3hConfirmVoteYesTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote [YES]'**
  String get r3hConfirmVoteYesTitle;

  /// No description provided for @r3hCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String r3hCopiedToClipboard(String label);

  /// No description provided for @r3hCpu.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get r3hCpu;

  /// No description provided for @r3hCpuCores.
  ///
  /// In en, this message translates to:
  /// **'CPU Cores'**
  String get r3hCpuCores;

  /// No description provided for @r3hCpuHint.
  ///
  /// In en, this message translates to:
  /// **'ie. Intel'**
  String get r3hCpuHint;

  /// No description provided for @r3hCpuThreads.
  ///
  /// In en, this message translates to:
  /// **'CPU Threads'**
  String get r3hCpuThreads;

  /// No description provided for @r3hDecimalPlacesLabel.
  ///
  /// In en, this message translates to:
  /// **'Decimal Places:'**
  String get r3hDecimalPlacesLabel;

  /// No description provided for @r3hDescRequired.
  ///
  /// In en, this message translates to:
  /// **'The description is required'**
  String get r3hDescRequired;

  /// No description provided for @r3hDescTooLong.
  ///
  /// In en, this message translates to:
  /// **'The description exceeds the maximum character length'**
  String get r3hDescTooLong;

  /// No description provided for @r3hDescTooManyWords.
  ///
  /// In en, this message translates to:
  /// **'The description exceeds the maximum word count'**
  String get r3hDescTooManyWords;

  /// No description provided for @r3hDescriptionColon.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get r3hDescriptionColon;

  /// No description provided for @r3hDescriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional):'**
  String get r3hDescriptionOptionalLabel;

  /// No description provided for @r3hDnrAlphaNumeric.
  ///
  /// In en, this message translates to:
  /// **'A DNR may only contain letters and numbers.'**
  String get r3hDnrAlphaNumeric;

  /// No description provided for @r3hEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email.'**
  String get r3hEmailInvalid;

  /// No description provided for @r3hEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required.'**
  String get r3hEmailRequired;

  /// No description provided for @r3hErrorBanning.
  ///
  /// In en, this message translates to:
  /// **'Error banning address'**
  String get r3hErrorBanning;

  /// No description provided for @r3hErrorBurning.
  ///
  /// In en, this message translates to:
  /// **'Error burning token'**
  String get r3hErrorBurning;

  /// No description provided for @r3hErrorChangingOwnership.
  ///
  /// In en, this message translates to:
  /// **'Error changing ownership'**
  String get r3hErrorChangingOwnership;

  /// No description provided for @r3hErrorCreatingTopic.
  ///
  /// In en, this message translates to:
  /// **'Error creating topic'**
  String get r3hErrorCreatingTopic;

  /// No description provided for @r3hErrorMinting.
  ///
  /// In en, this message translates to:
  /// **'Error minting token'**
  String get r3hErrorMinting;

  /// No description provided for @r3hErrorPausing.
  ///
  /// In en, this message translates to:
  /// **'Error pausing/unpausing token'**
  String get r3hErrorPausing;

  /// No description provided for @r3hErrorTransferring.
  ///
  /// In en, this message translates to:
  /// **'Error transferring token'**
  String get r3hErrorTransferring;

  /// No description provided for @r3hFieldInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid {label}.'**
  String r3hFieldInvalid(String label);

  /// No description provided for @r3hFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required.'**
  String r3hFieldRequired(String label);

  /// No description provided for @r3hGithubLinkOptional.
  ///
  /// In en, this message translates to:
  /// **'Github Link (Optional)'**
  String get r3hGithubLinkOptional;

  /// No description provided for @r3hHdSize.
  ///
  /// In en, this message translates to:
  /// **'HD Size'**
  String get r3hHdSize;

  /// No description provided for @r3hHdSizeSpecifier.
  ///
  /// In en, this message translates to:
  /// **'HD Size Specifier'**
  String get r3hHdSizeSpecifier;

  /// No description provided for @r3hHours24Minimum.
  ///
  /// In en, this message translates to:
  /// **'Hours (24 Minimum)'**
  String get r3hHours24Minimum;

  /// No description provided for @r3hInsufficientBalanceForTopic.
  ///
  /// In en, this message translates to:
  /// **'Balance will not be sufficent to validate due to the cost of creating a topic (1 VFX + fee)'**
  String get r3hInsufficientBalanceForTopic;

  /// No description provided for @r3hInternetSpeedDown.
  ///
  /// In en, this message translates to:
  /// **'Internet Speed Down (in Gbps)'**
  String get r3hInternetSpeedDown;

  /// No description provided for @r3hInternetSpeedUp.
  ///
  /// In en, this message translates to:
  /// **'Internet Speed Up (in Gbps)'**
  String get r3hInternetSpeedUp;

  /// No description provided for @r3hInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get r3hInvalid;

  /// No description provided for @r3hIsBurnableLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Burnable:'**
  String get r3hIsBurnableLabel;

  /// No description provided for @r3hLabelMinTokenRequirement.
  ///
  /// In en, this message translates to:
  /// **'Minimum Token Requirement'**
  String get r3hLabelMinTokenRequirement;

  /// No description provided for @r3hLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout of the VFX Web Wallet?'**
  String get r3hLogoutConfirmBody;

  /// No description provided for @r3hMachineOs.
  ///
  /// In en, this message translates to:
  /// **'Machine OS'**
  String get r3hMachineOs;

  /// No description provided for @r3hMachineProvider.
  ///
  /// In en, this message translates to:
  /// **'Machine Provider'**
  String get r3hMachineProvider;

  /// No description provided for @r3hMachineType.
  ///
  /// In en, this message translates to:
  /// **'Machine Type'**
  String get r3hMachineType;

  /// No description provided for @r3hMachineTypeHint.
  ///
  /// In en, this message translates to:
  /// **'ie. Server, Desktop, Laptop, etc.'**
  String get r3hMachineTypeHint;

  /// No description provided for @r3hManageToken.
  ///
  /// In en, this message translates to:
  /// **'Manage Token'**
  String get r3hManageToken;

  /// No description provided for @r3hMaxPercent.
  ///
  /// In en, this message translates to:
  /// **'Can not be more than 100%'**
  String get r3hMaxPercent;

  /// No description provided for @r3hMinPercent.
  ///
  /// In en, this message translates to:
  /// **'Must be more than 0%'**
  String get r3hMinPercent;

  /// No description provided for @r3hMintBroadcastedBody.
  ///
  /// In en, this message translates to:
  /// **'Token Smart Contract mint transaction has been broadcasted.\n\nThe Fungible Token screen will reflect the change once the block is crafted and block height has synced with this transaction.'**
  String get r3hMintBroadcastedBody;

  /// No description provided for @r3hMintedByBody.
  ///
  /// In en, this message translates to:
  /// **'This will be minted by {address}'**
  String r3hMintedByBody(String address);

  /// No description provided for @r3hMustBeValidatorToCreateTopic.
  ///
  /// In en, this message translates to:
  /// **'Your active account must be a validator to create a topic.'**
  String get r3hMustBeValidatorToCreateTopic;

  /// No description provided for @r3hMustSelectAccountToVote.
  ///
  /// In en, this message translates to:
  /// **'Must have an account selected to vote.'**
  String get r3hMustSelectAccountToVote;

  /// No description provided for @r3hNameRequired.
  ///
  /// In en, this message translates to:
  /// **'The name is required'**
  String get r3hNameRequired;

  /// No description provided for @r3hNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The name exceeds the maximum character length'**
  String get r3hNameTooLong;

  /// No description provided for @r3hNewOwnerAddress.
  ///
  /// In en, this message translates to:
  /// **'New Owner\'s Address'**
  String get r3hNewOwnerAddress;

  /// No description provided for @r3hNoActiveTopics.
  ///
  /// In en, this message translates to:
  /// **'No Active Topics'**
  String get r3hNoActiveTopics;

  /// No description provided for @r3hNoCreatedTopics.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any topics.'**
  String get r3hNoCreatedTopics;

  /// No description provided for @r3hNoInactiveTopics.
  ///
  /// In en, this message translates to:
  /// **'No Inactive Topics'**
  String get r3hNoInactiveTopics;

  /// No description provided for @r3hNoTokensInAccounts.
  ///
  /// In en, this message translates to:
  /// **'No tokens in any of your accounts.'**
  String get r3hNoTokensInAccounts;

  /// No description provided for @r3hNoUpper.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get r3hNoUpper;

  /// No description provided for @r3hNoVotingTopics.
  ///
  /// In en, this message translates to:
  /// **'No Voting Topics'**
  String get r3hNoVotingTopics;

  /// No description provided for @r3hNodeNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Node name already taken.'**
  String get r3hNodeNameTaken;

  /// No description provided for @r3hNotAuthorizedAddress.
  ///
  /// In en, this message translates to:
  /// **'Not authorized (incorrect address).'**
  String get r3hNotAuthorizedAddress;

  /// No description provided for @r3hNotAuthorizedToken.
  ///
  /// In en, this message translates to:
  /// **'Not authorized (token invalid).'**
  String get r3hNotAuthorizedToken;

  /// No description provided for @r3hNotVotedAnyTopics.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t voted on any topics.'**
  String get r3hNotVotedAnyTopics;

  /// No description provided for @r3hOneActiveTopicPerAddress.
  ///
  /// In en, this message translates to:
  /// **'Only one active topic per address is allowed.'**
  String get r3hOneActiveTopicPerAddress;

  /// No description provided for @r3hOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get r3hOptional;

  /// No description provided for @r3hPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required.'**
  String get r3hPasswordRequired;

  /// No description provided for @r3hPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password not strong enough.'**
  String get r3hPasswordWeak;

  /// No description provided for @r3hPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get r3hPause;

  /// No description provided for @r3hPauseTokenTransactions.
  ///
  /// In en, this message translates to:
  /// **'Pause Token Transactions'**
  String get r3hPauseTokenTransactions;

  /// No description provided for @r3hPauseTokenTxConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to pause token transactions? This will prevent transfers and burning of this token until resumed.'**
  String get r3hPauseTokenTxConfirmBody;

  /// No description provided for @r3hPauseTransactions.
  ///
  /// In en, this message translates to:
  /// **'Pause Transactions'**
  String get r3hPauseTransactions;

  /// No description provided for @r3hPauseTxConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to pause all transactions with this token?'**
  String get r3hPauseTxConfirmBody;

  /// No description provided for @r3hPauseTxs.
  ///
  /// In en, this message translates to:
  /// **'Pause TXs'**
  String get r3hPauseTxs;

  /// No description provided for @r3hPendingPause.
  ///
  /// In en, this message translates to:
  /// **'Pending Pause'**
  String get r3hPendingPause;

  /// No description provided for @r3hPendingResume.
  ///
  /// In en, this message translates to:
  /// **'Pending Resume'**
  String get r3hPendingResume;

  /// No description provided for @r3hPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Phone Number.'**
  String get r3hPhoneInvalid;

  /// No description provided for @r3hPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number required.'**
  String get r3hPhoneRequired;

  /// No description provided for @r3hProblemOccurred.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred.'**
  String get r3hProblemOccurred;

  /// No description provided for @r3hRamGb.
  ///
  /// In en, this message translates to:
  /// **'RAM (in GB)'**
  String get r3hRamGb;

  /// No description provided for @r3hReasonToBecomeAdj.
  ///
  /// In en, this message translates to:
  /// **'Reason To Become Adjudicator'**
  String get r3hReasonToBecomeAdj;

  /// No description provided for @r3hReplaceTokenIcon.
  ///
  /// In en, this message translates to:
  /// **'Replace Token Icon'**
  String get r3hReplaceTokenIcon;

  /// No description provided for @r3hRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get r3hRequired;

  /// No description provided for @r3hResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get r3hResume;

  /// No description provided for @r3hResumeTokenTransactions.
  ///
  /// In en, this message translates to:
  /// **'Resume Token Transactions'**
  String get r3hResumeTokenTransactions;

  /// No description provided for @r3hResumeTokenTxConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to resume token transactions?'**
  String get r3hResumeTokenTxConfirmBody;

  /// No description provided for @r3hResumeTransactions.
  ///
  /// In en, this message translates to:
  /// **'Resume Transactions'**
  String get r3hResumeTransactions;

  /// No description provided for @r3hResumeTxConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want resume transactions with this token?'**
  String get r3hResumeTxConfirmBody;

  /// No description provided for @r3hResumeTxs.
  ///
  /// In en, this message translates to:
  /// **'Resume TXs'**
  String get r3hResumeTxs;

  /// No description provided for @r3hSeparateWithCommas.
  ///
  /// In en, this message translates to:
  /// **'Separate multiple with commas'**
  String get r3hSeparateWithCommas;

  /// No description provided for @r3hTechnicalBackground.
  ///
  /// In en, this message translates to:
  /// **'Technical Background'**
  String get r3hTechnicalBackground;

  /// No description provided for @r3hTokenAccounts.
  ///
  /// In en, this message translates to:
  /// **'Token Accounts'**
  String get r3hTokenAccounts;

  /// No description provided for @r3hTokenHasFixedSupply.
  ///
  /// In en, this message translates to:
  /// **'Token Has Fixed Supply:'**
  String get r3hTokenHasFixedSupply;

  /// No description provided for @r3hTokenIconUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Token Icon URL:'**
  String get r3hTokenIconUrlLabel;

  /// No description provided for @r3hTokenNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Token Name:'**
  String get r3hTokenNameFieldLabel;

  /// No description provided for @r3hTokenNameHelper.
  ///
  /// In en, this message translates to:
  /// **'The name of this new token.'**
  String get r3hTokenNameHelper;

  /// No description provided for @r3hTokenOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Token Owner: '**
  String get r3hTokenOwnerLabel;

  /// No description provided for @r3hTokenPauseBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'Token pause transaction broadcasted'**
  String get r3hTokenPauseBroadcasted;

  /// No description provided for @r3hTokenResumeBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'Token resume transaction broadcasted'**
  String get r3hTokenResumeBroadcasted;

  /// No description provided for @r3hTokenTickerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Token Ticker:'**
  String get r3hTokenTickerFieldLabel;

  /// No description provided for @r3hTokenTickerHelper.
  ///
  /// In en, this message translates to:
  /// **'The ticker for this new token.'**
  String get r3hTokenTickerHelper;

  /// No description provided for @r3hTotalSupplyLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Supply:'**
  String get r3hTotalSupplyLabel;

  /// No description provided for @r3hUploadTokenIcon.
  ///
  /// In en, this message translates to:
  /// **'Upload Token Icon'**
  String get r3hUploadTokenIcon;

  /// No description provided for @r3hUseZeroForInfinite.
  ///
  /// In en, this message translates to:
  /// **'Use 0 for Infinite (allows minting)'**
  String get r3hUseZeroForInfinite;

  /// No description provided for @r3hUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username not valid.'**
  String get r3hUsernameInvalid;

  /// No description provided for @r3hUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username required.'**
  String get r3hUsernameRequired;

  /// No description provided for @r3hVaultActionNotAllowedBody.
  ///
  /// In en, this message translates to:
  /// **'Vault Account owned tokens can not perform this action. Please change the ownership to a standard VFX account to continue.'**
  String get r3hVaultActionNotAllowedBody;

  /// No description provided for @r3hVaultKeypairNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not locate vault keypair for address {address}.'**
  String r3hVaultKeypairNotFound(String address);

  /// No description provided for @r3hVfxAddressToNominate.
  ///
  /// In en, this message translates to:
  /// **'VFX Address to Nominate'**
  String get r3hVfxAddressToNominate;

  /// No description provided for @r3hVoteNoUpper.
  ///
  /// In en, this message translates to:
  /// **'Vote NO'**
  String get r3hVoteNoUpper;

  /// No description provided for @r3hVoteYesUpper.
  ///
  /// In en, this message translates to:
  /// **'Vote YES'**
  String get r3hVoteYesUpper;

  /// No description provided for @r3hVotedAllTopics.
  ///
  /// In en, this message translates to:
  /// **'You have voted on all topics.'**
  String get r3hVotedAllTopics;

  /// No description provided for @r3hVotingEndedOn.
  ///
  /// In en, this message translates to:
  /// **'Voting Ended on {date}.'**
  String r3hVotingEndedOn(String date);

  /// No description provided for @r3hVotingEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Voting ends {date}.'**
  String r3hVotingEndsOn(String date);

  /// No description provided for @r3hWalletSyncWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait until your wallet is synced with the network'**
  String get r3hWalletSyncWait;

  /// No description provided for @r3hWalletSynced.
  ///
  /// In en, this message translates to:
  /// **'Wallet Synced'**
  String get r3hWalletSynced;

  /// No description provided for @r3hYesUpper.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get r3hYesUpper;

  /// No description provided for @r3hYouVotedOnBlock.
  ///
  /// In en, this message translates to:
  /// **'You voted {vote} on block {block}'**
  String r3hYouVotedOnBlock(String vote, String block);

  /// No description provided for @r3hYouVotedPending.
  ///
  /// In en, this message translates to:
  /// **'You voted {vote}. Transaction is pending.'**
  String r3hYouVotedPending(String vote);

  /// No description provided for @r3aAccountUnlockTime.
  ///
  /// In en, this message translates to:
  /// **'Account Unlock Time'**
  String get r3aAccountUnlockTime;

  /// No description provided for @r3aAddRarity.
  ///
  /// In en, this message translates to:
  /// **'Add Rarity'**
  String get r3aAddRarity;

  /// No description provided for @r3aAdditionalAsset.
  ///
  /// In en, this message translates to:
  /// **'Additional Asset'**
  String get r3aAdditionalAsset;

  /// No description provided for @r3aAdditionalAssets.
  ///
  /// In en, this message translates to:
  /// **'Additional Assets'**
  String get r3aAdditionalAssets;

  /// No description provided for @r3aAllowedAssetExtensionTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed Asset Extension Types'**
  String get r3aAllowedAssetExtensionTypes;

  /// No description provided for @r3aAutoDownloadNftAsset.
  ///
  /// In en, this message translates to:
  /// **'Auto Download NFT Asset'**
  String get r3aAutoDownloadNftAsset;

  /// No description provided for @r3aBackupUrlBody.
  ///
  /// In en, this message translates to:
  /// **'Paste in a public URL to a hosted zipfile containing the assets.'**
  String get r3aBackupUrlBody;

  /// No description provided for @r3aBlockHeightVariable.
  ///
  /// In en, this message translates to:
  /// **'Block Height Variable'**
  String get r3aBlockHeightVariable;

  /// No description provided for @r3aBurnNft.
  ///
  /// In en, this message translates to:
  /// **'Burn NFT'**
  String get r3aBurnNft;

  /// No description provided for @r3aChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get r3aChooseFile;

  /// No description provided for @r3aCompile.
  ///
  /// In en, this message translates to:
  /// **'Compile'**
  String get r3aCompile;

  /// No description provided for @r3aCompileMintBodySimple.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed?\nOnce compiled you will not be able to make any changes\nand the smart contract will be deployed to the chain.'**
  String get r3aCompileMintBodySimple;

  /// No description provided for @r3aCompilingMinting.
  ///
  /// In en, this message translates to:
  /// **'Compiling & Minting'**
  String get r3aCompilingMinting;

  /// No description provided for @r3aCompilingMintingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Compiling & Minting…'**
  String get r3aCompilingMintingEllipsis;

  /// No description provided for @r3aConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get r3aConfiguration;

  /// No description provided for @r3aCreateBlueprint.
  ///
  /// In en, this message translates to:
  /// **'Create Blueprint'**
  String get r3aCreateBlueprint;

  /// No description provided for @r3aCreateCollectionBlueprint.
  ///
  /// In en, this message translates to:
  /// **'Create Collection Blueprint'**
  String get r3aCreateCollectionBlueprint;

  /// No description provided for @r3aCreateFirstInstance.
  ///
  /// In en, this message translates to:
  /// **'Create First Instance'**
  String get r3aCreateFirstInstance;

  /// No description provided for @r3aDateTimeVariable.
  ///
  /// In en, this message translates to:
  /// **'Date/Time Variable'**
  String get r3aDateTimeVariable;

  /// No description provided for @r3aDeleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get r3aDeleteDraft;

  /// No description provided for @r3aDeleteDraftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wan\'t to delete this smart contract draft?'**
  String get r3aDeleteDraftConfirm;

  /// No description provided for @r3aDeleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get r3aDeleteQuestion;

  /// No description provided for @r3aDeleteThisConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get r3aDeleteThisConfirm;

  /// No description provided for @r3aDraftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft Delete'**
  String get r3aDraftDeleted;

  /// No description provided for @r3aDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved!'**
  String get r3aDraftSaved;

  /// No description provided for @r3aDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get r3aDuplicate;

  /// No description provided for @r3aEditInstance.
  ///
  /// In en, this message translates to:
  /// **'Edit Instance'**
  String get r3aEditInstance;

  /// No description provided for @r3aEvolutionMode.
  ///
  /// In en, this message translates to:
  /// **'Evolution Mode'**
  String get r3aEvolutionMode;

  /// No description provided for @r3aEvolvePhase.
  ///
  /// In en, this message translates to:
  /// **'Evolve Phase'**
  String get r3aEvolvePhase;

  /// No description provided for @r3aEvolvePhases.
  ///
  /// In en, this message translates to:
  /// **'Evolve Phases'**
  String get r3aEvolvePhases;

  /// No description provided for @r3aEvolveStagesInPast.
  ///
  /// In en, this message translates to:
  /// **'Evolve stage(s) in the past'**
  String get r3aEvolveStagesInPast;

  /// No description provided for @r3aEvolveStagesInPastBody.
  ///
  /// In en, this message translates to:
  /// **'One or more of your evolve stages will have already evolved at the time of minting.\n\nAre your sure you want to proceed?'**
  String get r3aEvolveStagesInPastBody;

  /// No description provided for @r3aFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get r3aFeatures;

  /// No description provided for @r3aHelpBodyAllowedExt.
  ///
  /// In en, this message translates to:
  /// **'This will remove extension types to the already defined list and will allow any NFT assets with these known extension types to be downloaded \nEx: pdf,doc,xls \n\nDefault value: (leave blank)'**
  String get r3aHelpBodyAllowedExt;

  /// No description provided for @r3aHelpBodyApiCallUrl.
  ///
  /// In en, this message translates to:
  /// **'This URL is used to send incoming transactions to an outside URL. This is something used for like incoming deposits or other notification. services. \n\nDefault value: null'**
  String get r3aHelpBodyApiCallUrl;

  /// No description provided for @r3aHelpBodyApiPort.
  ///
  /// In en, this message translates to:
  /// **'This is the port to call the API. This may be changed to whatever you want. \n\nDefault value: 7292'**
  String get r3aHelpBodyApiPort;

  /// No description provided for @r3aHelpBodyAutoDownload.
  ///
  /// In en, this message translates to:
  /// **'This will control whether or not an NFT\'s asset is automatically downloaded \n\nDefault value: true'**
  String get r3aHelpBodyAutoDownload;

  /// No description provided for @r3aHelpBodyBaseline.
  ///
  /// In en, this message translates to:
  /// **'Fill out the baseline info required by all smart contracts. Choose a name, the minter\'s name (optional), and the account you want to use. Then, give your smart contract/NFT a detailed description.'**
  String get r3aHelpBodyBaseline;

  /// No description provided for @r3aHelpBodyBurn.
  ///
  /// In en, this message translates to:
  /// **'Burn (destroy) this NFT permanently.'**
  String get r3aHelpBodyBurn;

  /// No description provided for @r3aHelpBodyCompile.
  ///
  /// In en, this message translates to:
  /// **'Compile the Trilliam code based on the parameters you\'ve configured and then mint when ready.'**
  String get r3aHelpBodyCompile;

  /// No description provided for @r3aHelpBodyConfiguration.
  ///
  /// In en, this message translates to:
  /// **'This values will modify the config.txt file located in the CLIs database, for this changes to take effect the CLI needs to be restarted'**
  String get r3aHelpBodyConfiguration;

  /// No description provided for @r3aHelpBodyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete your smart contract'**
  String get r3aHelpBodyDelete;

  /// No description provided for @r3aHelpBodyDescription.
  ///
  /// In en, this message translates to:
  /// **'Provide a text-based description of your smart contract/NFT. This field is required and will be publicly visible.'**
  String get r3aHelpBodyDescription;

  /// No description provided for @r3aHelpBodyEvolveAsset.
  ///
  /// In en, this message translates to:
  /// **'Overide the asset when the smart contract evolves to this stage. This field is optional.'**
  String get r3aHelpBodyEvolveAsset;

  /// No description provided for @r3aHelpBodyEvolveBlockHeight.
  ///
  /// In en, this message translates to:
  /// **'The smart contract will evolve when the VFX chain reaches this block height.'**
  String get r3aHelpBodyEvolveBlockHeight;

  /// No description provided for @r3aHelpBodyEvolveDatetime.
  ///
  /// In en, this message translates to:
  /// **'The date and time the smart contract will evolve (UTC).'**
  String get r3aHelpBodyEvolveDatetime;

  /// No description provided for @r3aHelpBodyEvolveMode.
  ///
  /// In en, this message translates to:
  /// **'You decide how the evolution will be controlled.\n\nIssuer/Minter Controlled: The minter will be able to evolve/devolve the smart contract at any point.\n\nAutomated/Application Controlled: Automatically evolves based on time/date, on-chain variables, and/or application induced variables.'**
  String get r3aHelpBodyEvolveMode;

  /// No description provided for @r3aHelpBodyEvolveStageDescription.
  ///
  /// In en, this message translates to:
  /// **'Provide a description for this evolution stage.'**
  String get r3aHelpBodyEvolveStageDescription;

  /// No description provided for @r3aHelpBodyEvolveStageName.
  ///
  /// In en, this message translates to:
  /// **'Provide a name for this evolution stage.'**
  String get r3aHelpBodyEvolveStageName;

  /// No description provided for @r3aHelpBodyEvolveType.
  ///
  /// In en, this message translates to:
  /// **'Choose the variable type that can dynamically affect the evolution state.\n\nDate/Time: The smart contract will automatically evolve at a certain point of time.\n\nBlock Height: The smart contract will evolve when the chain reaches a particular block height.\n\nManual Only: The smart contract will not evolve unless manually told to by the issuer or user/application (depending on which mode is selected).'**
  String get r3aHelpBodyEvolveType;

  /// No description provided for @r3aHelpBodyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Add a feature to your smart contract such as royalties or evolving functionality.'**
  String get r3aHelpBodyFeatures;

  /// No description provided for @r3aHelpBodyIgnoreIncoming.
  ///
  /// In en, this message translates to:
  /// **'This will control whether or not incoming NFTs are processed or just added as a TX record \n\nDefault value: false'**
  String get r3aHelpBodyIgnoreIncoming;

  /// No description provided for @r3aHelpBodyManageProperties.
  ///
  /// In en, this message translates to:
  /// **'Create label & value pairs.\nFor example:\n\nLabel: Color\nValue: Blue'**
  String get r3aHelpBodyManageProperties;

  /// No description provided for @r3aHelpBodyMint.
  ///
  /// In en, this message translates to:
  /// **'Mint and deploy the smart contract to the chain.'**
  String get r3aHelpBodyMint;

  /// No description provided for @r3aHelpBodyMintQuantity.
  ///
  /// In en, this message translates to:
  /// **'The number of Smart Contracts / NFTs you want to mint from this template.'**
  String get r3aHelpBodyMintQuantity;

  /// No description provided for @r3aHelpBodyMinterName.
  ///
  /// In en, this message translates to:
  /// **'This field is optional but will be displayed publicly if set. This can be your name/persona, or just leave it blank.'**
  String get r3aHelpBodyMinterName;

  /// No description provided for @r3aHelpBodyMinting.
  ///
  /// In en, this message translates to:
  /// **'This action occurs after you have successfully compiled and minted but requires the transaction to be authenticated by the network which takes approximately 30 seconds for finality as well as your wallet to be synced with the block that includes this transaction.'**
  String get r3aHelpBodyMinting;

  /// No description provided for @r3aHelpBodyMotherAddress.
  ///
  /// In en, this message translates to:
  /// **'The IP address of the HOST wallet. \n\n Default value: (leave blank)'**
  String get r3aHelpBodyMotherAddress;

  /// No description provided for @r3aHelpBodyMotherPassword.
  ///
  /// In en, this message translates to:
  /// **'The password set in your HOST wallet when configuring MOTHER.\n\n Default value: (leave blank)'**
  String get r3aHelpBodyMotherPassword;

  /// No description provided for @r3aHelpBodyNftTimeout.
  ///
  /// In en, this message translates to:
  /// **'This will control the timeout for processing an incoming NFT \n\nDefault value: 15'**
  String get r3aHelpBodyNftTimeout;

  /// No description provided for @r3aHelpBodyOwnerAddress.
  ///
  /// In en, this message translates to:
  /// **'This should be the account address that will be used to compile and mint the smart contract.'**
  String get r3aHelpBodyOwnerAddress;

  /// No description provided for @r3aHelpBodyPasswordClearTime.
  ///
  /// In en, this message translates to:
  /// **'This will control the clear time for an ecrypted wallets password \n\nDefault value: 10'**
  String get r3aHelpBodyPasswordClearTime;

  /// No description provided for @r3aHelpBodyPrimaryAsset.
  ///
  /// In en, this message translates to:
  /// **'This is the primary file asset contained in the smart contract/NFT. It can be an image, audio, video or any file.'**
  String get r3aHelpBodyPrimaryAsset;

  /// No description provided for @r3aHelpBodyProperties.
  ///
  /// In en, this message translates to:
  /// **'Define and assign values to assets in your smart contract. This can be a rare trait as an example.'**
  String get r3aHelpBodyProperties;

  /// No description provided for @r3aHelpBodyPropertyTypes.
  ///
  /// In en, this message translates to:
  /// **'Define the kind of value that your property will have \nThis types are: \n- Text: alphanumeric value \n- Number: numerical value \n- Color: Hexadecimal value of a color of your choice'**
  String get r3aHelpBodyPropertyTypes;

  /// No description provided for @r3aHelpBodyRejectExt.
  ///
  /// In en, this message translates to:
  /// **'This will add extension types to the already defined list and will reject any NFT assets with these known extension types \nEx: exe,zip,pdf... (ensure there are no spaces between types) \n\nDefault value: (leave blank)\n\nIf left blank, this is the default:\n{exts}'**
  String r3aHelpBodyRejectExt(String exts);

  /// No description provided for @r3aHelpBodyRoyaltyAddress.
  ///
  /// In en, this message translates to:
  /// **'Provide the VFX public address that the royalty will be paid to upon transaction finality.'**
  String get r3aHelpBodyRoyaltyAddress;

  /// No description provided for @r3aHelpBodyRoyaltyFlat.
  ///
  /// In en, this message translates to:
  /// **'Type in the amount of VFX that will be paid to the address provided and is enforced on-chain upon any trade. This fee is remitted to the royalty holder upon transaction finality.'**
  String get r3aHelpBodyRoyaltyFlat;

  /// No description provided for @r3aHelpBodyRoyaltyPercent.
  ///
  /// In en, this message translates to:
  /// **'Type in the percent that will be paid to the address provided and is enforced on-chain upon any trade. This fee is remitted to the royalty holder upon transaction finality.'**
  String get r3aHelpBodyRoyaltyPercent;

  /// No description provided for @r3aHelpBodySaveAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Save your smart contract as a draft locally to come back and work on it later.'**
  String get r3aHelpBodySaveAsDraft;

  /// No description provided for @r3aHelpBodyScName.
  ///
  /// In en, this message translates to:
  /// **'Name your smart contract. This field is required and is publicly visible.'**
  String get r3aHelpBodyScName;

  /// No description provided for @r3aHelpBodySetEvolution.
  ///
  /// In en, this message translates to:
  /// **'With an NFT that has more than 2 phases the user can go directly from one stage to another with the “Set Evolution” button instead of evolving and devolving stage by stage'**
  String get r3aHelpBodySetEvolution;

  /// No description provided for @r3aHelpBodySmartContract.
  ///
  /// In en, this message translates to:
  /// **'Configure the parameters of your smart contract then compile and mint it.'**
  String get r3aHelpBodySmartContract;

  /// No description provided for @r3aHelpBodyTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer this NFT to another account.'**
  String get r3aHelpBodyTransfer;

  /// No description provided for @r3aHelpBodyWalletUnlockTime.
  ///
  /// In en, this message translates to:
  /// **'This is the amount of time once a password has been entered the wallet will remain unlocked and not need password again \n\nDefault value: 15'**
  String get r3aHelpBodyWalletUnlockTime;

  /// No description provided for @r3aIgnoreIncomingNfts.
  ///
  /// In en, this message translates to:
  /// **'Ignore Incoming NFTs'**
  String get r3aIgnoreIncomingNfts;

  /// No description provided for @r3aMaxMintAtOnce.
  ///
  /// In en, this message translates to:
  /// **'The maxium number you can mint at one time is {max}.'**
  String r3aMaxMintAtOnce(String max);

  /// No description provided for @r3aMintBroadcastedBody.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract mint transaction has been broadcasted.\n\nThe NFTs screen will reflect the change once the block is crafted and block height has synced with this transaction.'**
  String get r3aMintBroadcastedBody;

  /// No description provided for @r3aMintTxSent.
  ///
  /// In en, this message translates to:
  /// **'Mint transaction sent successfully. Please wait until the the smart contract is minted on-chain.'**
  String get r3aMintTxSent;

  /// No description provided for @r3aMinterCreatorName.
  ///
  /// In en, this message translates to:
  /// **'Minter/Creator Name'**
  String get r3aMinterCreatorName;

  /// No description provided for @r3aMinterName.
  ///
  /// In en, this message translates to:
  /// **'Minter Name'**
  String get r3aMinterName;

  /// No description provided for @r3aMinting.
  ///
  /// In en, this message translates to:
  /// **'Minting'**
  String get r3aMinting;

  /// No description provided for @r3aMintingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Minting…'**
  String get r3aMintingEllipsis;

  /// No description provided for @r3aMotherAddress.
  ///
  /// In en, this message translates to:
  /// **'Mother Address'**
  String get r3aMotherAddress;

  /// No description provided for @r3aMotherPassword.
  ///
  /// In en, this message translates to:
  /// **'Mother Password'**
  String get r3aMotherPassword;

  /// No description provided for @r3aNftSaleTransferStarted.
  ///
  /// In en, this message translates to:
  /// **'Success: NFT Sale Transfer has been started.'**
  String get r3aNftSaleTransferStarted;

  /// No description provided for @r3aNftTimeout.
  ///
  /// In en, this message translates to:
  /// **'Nft Timeout'**
  String get r3aNftTimeout;

  /// No description provided for @r3aNftTransferStarted.
  ///
  /// In en, this message translates to:
  /// **'Success: NFT Transfer has been started.'**
  String get r3aNftTransferStarted;

  /// No description provided for @r3aPasswordClearTime.
  ///
  /// In en, this message translates to:
  /// **'Password Clear Time'**
  String get r3aPasswordClearTime;

  /// No description provided for @r3aPayeeAddress.
  ///
  /// In en, this message translates to:
  /// **'Payee Address'**
  String get r3aPayeeAddress;

  /// No description provided for @r3aProblemCompilingSc.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred compiling this smart contract.'**
  String get r3aProblemCompilingSc;

  /// No description provided for @r3aProblemMintingSc.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred minting this smart contract.'**
  String get r3aProblemMintingSc;

  /// No description provided for @r3aProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get r3aProperty;

  /// No description provided for @r3aPropertyTypes.
  ///
  /// In en, this message translates to:
  /// **'Property Types'**
  String get r3aPropertyTypes;

  /// No description provided for @r3aRarities.
  ///
  /// In en, this message translates to:
  /// **'Rarities'**
  String get r3aRarities;

  /// No description provided for @r3aRejectAssetExtensionTypes.
  ///
  /// In en, this message translates to:
  /// **'Reject Asset Extension Types'**
  String get r3aRejectAssetExtensionTypes;

  /// No description provided for @r3aRoyaltyFlatFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'Royalty Flat Fee Amount'**
  String get r3aRoyaltyFlatFeeAmount;

  /// No description provided for @r3aRoyaltyPercentageFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'Royalty Percentage Fee Amount'**
  String get r3aRoyaltyPercentageFeeAmount;

  /// No description provided for @r3aRoyaltyTo.
  ///
  /// In en, this message translates to:
  /// **'Royalty to'**
  String get r3aRoyaltyTo;

  /// No description provided for @r3aSaleCompleteTxSent.
  ///
  /// In en, this message translates to:
  /// **'Sale Complete TX Sent'**
  String get r3aSaleCompleteTxSent;

  /// No description provided for @r3aSaveAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get r3aSaveAsDraft;

  /// No description provided for @r3aScMintedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract minted successfully.'**
  String get r3aScMintedSuccessfully;

  /// No description provided for @r3aSetEvolution.
  ///
  /// In en, this message translates to:
  /// **'Set Evolution'**
  String get r3aSetEvolution;

  /// No description provided for @r3aSmartContract.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract'**
  String get r3aSmartContract;

  /// No description provided for @r3aSmartContractName.
  ///
  /// In en, this message translates to:
  /// **'Smart Contract Name'**
  String get r3aSmartContractName;

  /// No description provided for @r3aStat.
  ///
  /// In en, this message translates to:
  /// **'Stat'**
  String get r3aStat;

  /// No description provided for @r3aStatType.
  ///
  /// In en, this message translates to:
  /// **'Stat Type'**
  String get r3aStatType;

  /// No description provided for @r3aTransferNft.
  ///
  /// In en, this message translates to:
  /// **'Transfer NFT'**
  String get r3aTransferNft;

  /// No description provided for @r3aUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get r3aUntitled;

  /// No description provided for @r3aValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get r3aValue;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
