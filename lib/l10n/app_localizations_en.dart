// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Budget';

  @override
  String get chooseCurrency => 'Choose Currency';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get automatic => 'Automatic';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get categories => 'Category';

  @override
  String get backup_file_title => 'Backup File';

  @override
  String get backup_file_text => 'Here is my Smart Budget backup file.';

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get addCategory => 'Add category';

  @override
  String get budgetLimit => 'Budget limit';

  @override
  String get description => 'Description';

  @override
  String get name => 'Name';

  @override
  String get giveCategoryName => 'Give category name';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get deleteCategoryConfirmation => 'Are you sure you want to delete this category?';

  @override
  String get deleteTransactionConfirmation => 'Are you sure you want to delete this transaction?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get total => 'Total';

  @override
  String get noChartsToDisplay => 'No charts to display';

  @override
  String get budgetDistribution => 'Budget Distribution';

  @override
  String get budgetUsage => 'Budget Usage';

  @override
  String get unbudgetedCategoriesNotice => 'Some categories have no budget set';

  @override
  String get incomes => 'Incomes';

  @override
  String get expenses => 'Expenses';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get chooseIcon => 'Choose icon';

  @override
  String get saveCategory => 'Save category';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get chooseTime => 'Choose time';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get category => 'Category';

  @override
  String get giveCorrectAmount => 'Give correct amount';

  @override
  String get errorWhileLoadingCategories => 'Error while loading categories';

  @override
  String get errorWhileLoadingTransactions => 'Error while loading transactions';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryFoodDescription => 'Expenses related to food and dining';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryEntertainmentDescription => 'Costs for leisure and fun activities';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categorySalaryDescription => 'Your monthly or periodic income';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryTravelDescription => 'Expenses for trips and vacations';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryHealthDescription => 'Health-related expenses and services';

  @override
  String get financeSection => 'Finances';

  @override
  String get appSection => 'Application';

  @override
  String get firstDayOfMonth => 'First day of the month';

  @override
  String get currency_usd => 'US Dollar';

  @override
  String get currency_eur => 'Euro';

  @override
  String get currency_pln => 'Polish Zloty';

  @override
  String get currency_jpy => 'Japanese Yen';

  @override
  String get currency_gbp => 'British Pound';

  @override
  String get currency_aud => 'Australian Dollar';

  @override
  String get currency_cad => 'Canadian Dollar';

  @override
  String get currency_chf => 'Swiss Franc';

  @override
  String get currency_cny => 'Chinese Yuan';

  @override
  String get currency_hkd => 'Hong Kong Dollar';

  @override
  String get currency_nzd => 'New Zealand Dollar';

  @override
  String get currency => 'Currency';

  @override
  String get backupSection => 'Backup';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get exportBackupStatement => 'Backup exported to file.';

  @override
  String get importBackupStatement => 'Backup imported successfully.';

  @override
  String get exportBackupError => 'Problem with exporting backup.';

  @override
  String get importBackupError => 'Problem with importing backup.';

  @override
  String get sendApplicationLog => 'Send application logs';

  @override
  String get filterTransactionsTitle => 'Filter transactions';

  @override
  String get amountFrom => 'Amount from';

  @override
  String get amountTo => 'Amount to';

  @override
  String get dateFrom => 'Date from';

  @override
  String get dateTo => 'Date to';

  @override
  String get search => 'Search';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get currencyUpdateDateLoading => 'Loading currency rates update date...';

  @override
  String get currencyUpdateDateError => 'Error while fetching currency rates update date';

  @override
  String currencyUpdateDateValue(Object date) {
    return 'Currency rates update date: $date';
  }

  @override
  String get currencyUpdateDateNone => 'No saved currency rates update date';

  @override
  String get noTransactions => 'No saved transactions';

  @override
  String get repeatInterval => 'Repeat Interval';

  @override
  String get pleaseAddCategoriesFirst => 'Please add categories first';

  @override
  String get pleaseWaitLoadingCategories => 'Please wait, loading categories...';

  @override
  String get noDataToSend => 'No data to send';

  @override
  String get monthlyReportTitle => 'Monthly Report';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get incomeDistribution => 'Income Distribution';

  @override
  String get expenseDistribution => 'Expense Distribution';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get spentAmount => 'Spent Amount';
}
