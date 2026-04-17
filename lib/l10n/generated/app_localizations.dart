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
