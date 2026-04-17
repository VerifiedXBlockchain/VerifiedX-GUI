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

  /// Toast shown after a successful send transaction, with the sent amount.
  ///
  /// In en, this message translates to:
  /// **'Sent {amount} VFX'**
  String sentAmount(String amount);
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
