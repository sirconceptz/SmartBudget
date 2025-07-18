import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Budget'**
  String get appTitle;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose Currency'**
  String get chooseCurrency;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categories;

  /// No description provided for @backup_file_title.
  ///
  /// In en, this message translates to:
  /// **'Backup File'**
  String get backup_file_title;

  /// No description provided for @backup_file_text.
  ///
  /// In en, this message translates to:
  /// **'Here is my Smart Budget backup file.'**
  String get backup_file_text;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Budget limit'**
  String get budgetLimit;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @giveCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Give category name'**
  String get giveCategoryName;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteCategoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get deleteCategoryConfirmation;

  /// No description provided for @deleteTransactionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @noChartsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No charts to display'**
  String get noChartsToDisplay;

  /// No description provided for @budgetDistribution.
  ///
  /// In en, this message translates to:
  /// **'Budget Distribution'**
  String get budgetDistribution;

  /// No description provided for @budgetUsage.
  ///
  /// In en, this message translates to:
  /// **'Budget Usage'**
  String get budgetUsage;

  /// No description provided for @unbudgetedCategoriesNotice.
  ///
  /// In en, this message translates to:
  /// **'Some categories have no budget set'**
  String get unbudgetedCategoriesNotice;

  /// No description provided for @incomes.
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get incomes;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @chooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get chooseIcon;

  /// No description provided for @saveCategory.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get saveCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get chooseTime;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get saveTransaction;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @giveCorrectAmount.
  ///
  /// In en, this message translates to:
  /// **'Give correct amount'**
  String get giveCorrectAmount;

  /// No description provided for @errorWhileLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error while loading categories'**
  String get errorWhileLoadingCategories;

  /// No description provided for @errorWhileLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error while loading transactions'**
  String get errorWhileLoadingTransactions;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Expenses related to food and dining'**
  String get categoryFoodDescription;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryEntertainmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Costs for leisure and fun activities'**
  String get categoryEntertainmentDescription;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categorySalaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your monthly or periodic income'**
  String get categorySalaryDescription;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryTravelDescription.
  ///
  /// In en, this message translates to:
  /// **'Expenses for trips and vacations'**
  String get categoryTravelDescription;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Health-related expenses and services'**
  String get categoryHealthDescription;

  /// No description provided for @financeSection.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get financeSection;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get appSection;

  /// No description provided for @firstDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'First day of the month'**
  String get firstDayOfMonth;

  /// No description provided for @currency_usd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currency_usd;

  /// No description provided for @currency_eur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currency_eur;

  /// No description provided for @currency_pln.
  ///
  /// In en, this message translates to:
  /// **'Polish Zloty'**
  String get currency_pln;

  /// No description provided for @currency_jpy.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currency_jpy;

  /// No description provided for @currency_gbp.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currency_gbp;

  /// No description provided for @currency_aud.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currency_aud;

  /// No description provided for @currency_cad.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get currency_cad;

  /// No description provided for @currency_chf.
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get currency_chf;

  /// No description provided for @currency_cny.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get currency_cny;

  /// No description provided for @currency_hkd.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get currency_hkd;

  /// No description provided for @currency_nzd.
  ///
  /// In en, this message translates to:
  /// **'New Zealand Dollar'**
  String get currency_nzd;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @backupSection.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSection;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @exportBackupStatement.
  ///
  /// In en, this message translates to:
  /// **'Backup exported to file.'**
  String get exportBackupStatement;

  /// No description provided for @importBackupStatement.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully.'**
  String get importBackupStatement;

  /// No description provided for @exportBackupError.
  ///
  /// In en, this message translates to:
  /// **'Problem with exporting backup.'**
  String get exportBackupError;

  /// No description provided for @importBackupError.
  ///
  /// In en, this message translates to:
  /// **'Problem with importing backup.'**
  String get importBackupError;

  /// No description provided for @sendApplicationLog.
  ///
  /// In en, this message translates to:
  /// **'Send application logs'**
  String get sendApplicationLog;

  /// No description provided for @filterTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter transactions'**
  String get filterTransactionsTitle;

  /// No description provided for @amountFrom.
  ///
  /// In en, this message translates to:
  /// **'Amount from'**
  String get amountFrom;

  /// No description provided for @amountTo.
  ///
  /// In en, this message translates to:
  /// **'Amount to'**
  String get amountTo;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'Date from'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'Date to'**
  String get dateTo;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @currencyUpdateDateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading currency rates update date...'**
  String get currencyUpdateDateLoading;

  /// No description provided for @currencyUpdateDateError.
  ///
  /// In en, this message translates to:
  /// **'Error while fetching currency rates update date'**
  String get currencyUpdateDateError;

  /// No description provided for @currencyUpdateDateValue.
  ///
  /// In en, this message translates to:
  /// **'Currency rates update date: {date}'**
  String currencyUpdateDateValue(Object date);

  /// No description provided for @currencyUpdateDateNone.
  ///
  /// In en, this message translates to:
  /// **'No saved currency rates update date'**
  String get currencyUpdateDateNone;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No saved transactions'**
  String get noTransactions;

  /// No description provided for @repeatInterval.
  ///
  /// In en, this message translates to:
  /// **'Repeat Interval'**
  String get repeatInterval;

  /// No description provided for @pleaseAddCategoriesFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add categories first'**
  String get pleaseAddCategoriesFirst;

  /// No description provided for @pleaseWaitLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Please wait, loading categories...'**
  String get pleaseWaitLoadingCategories;

  /// No description provided for @noDataToSend.
  ///
  /// In en, this message translates to:
  /// **'No data to send'**
  String get noDataToSend;

  /// No description provided for @monthlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReportTitle;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @incomeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Income Distribution'**
  String get incomeDistribution;

  /// No description provided for @expenseDistribution.
  ///
  /// In en, this message translates to:
  /// **'Expense Distribution'**
  String get expenseDistribution;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @spentAmount.
  ///
  /// In en, this message translates to:
  /// **'Spent Amount'**
  String get spentAmount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'it', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
