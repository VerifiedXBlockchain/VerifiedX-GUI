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
