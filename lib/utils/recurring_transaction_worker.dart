import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../blocs/currency_conversion/currency_conversion_bloc.dart';
import '../data/db/database_helper.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/recurring_transactions_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../di/di.dart';
import '../models/currency_rate.dart';
import '../models/transaction.dart';
import 'my_logger.dart';

class RecurringTransactionWorker {
  static void initialize() {
    Workmanager().initialize(_callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask(
      "checkRecurringTransactions",
      "processRecurringTransactions",
      frequency: const Duration(hours: 24),
    );
  }

  static void _callbackDispatcher() {
    final db = DatabaseHelper();
    final recurringTransactionsRepository = RecurringTransactionRepository(db);
    final transactionsRepository = TransactionRepository(db);
    final categoryRepository = CategoryRepository(db);
    final currencyConversionBloc = getIt<CurrencyConversionBloc>();

    Workmanager().executeTask((task, inputData) async {
      final now = DateTime.now();
      final transactions =
          await recurringTransactionsRepository.getAllRecurringTransactions();

      final lastUpdated = await _getLastUpdatedTimestamp();
      final currentTime = DateTime.now();

      List<CurrencyRate> rates = [];
      if (lastUpdated != null &&
          currentTime.difference(lastUpdated).inHours < 24) {
        final prefs = await SharedPreferences.getInstance();
        final ratesJson = prefs.getString('cached_currency_rates');
        if (ratesJson != null) {
          rates = (jsonDecode(ratesJson) as List)
              .map((json) => CurrencyRate.fromJson(json))
              .toList();
        }
      } else {
        try {
          final ratesResponse =
              await currencyConversionBloc.repository.fetchCurrencyRates();
          await _cacheCurrencyRates(ratesResponse);
          await _setLastUpdatedTimestamp(currentTime);
          rates = ratesResponse;
        } catch (error) {
          MyLogger.write(
              "Failed to fetch updated currency rates", error.toString());
          return Future.value(true);
        }
      }

      final ratesMap = {
        for (var rate in rates) rate.code.toUpperCase(): rate.rate
      };
      const defaultRate = 1.0;
      final prefs = await SharedPreferences.getInstance();
      final userCurrency = prefs.getString('user_currency') ?? 'USD';

      for (var transaction in transactions) {
        bool shouldAddTransaction = false;
        if (transaction.repeatInterval == 'daily' &&
            now.difference(transaction.startDate).inDays >= 1) {
          shouldAddTransaction = true;
        } else if (transaction.repeatInterval == 'weekly' &&
            now.difference(transaction.startDate).inDays >= 7) {
          shouldAddTransaction = true;
        } else if (transaction.repeatInterval == 'monthly' &&
            now.month != transaction.startDate.month) {
          shouldAddTransaction = true;
        }

        if (shouldAddTransaction) {
          final category =
              await categoryRepository.getCategory(transaction.categoryId);

          final baseToUsdRate =
              ratesMap[transaction.currency.name.toUpperCase()] ?? defaultRate;
          final usdToUserCurrencyRate =
              ratesMap[userCurrency.toUpperCase()] ?? defaultRate;
          final conversionRate = usdToUserCurrencyRate / baseToUsdRate;
          final convertedAmount = transaction.amount * conversionRate;

          await transactionsRepository.createTransaction(Transaction(
            isExpense: transaction.isExpense ? 1 : 0,
            originalAmount: transaction.amount,
            convertedAmount: convertedAmount,
            date: DateTime.now(),
            originalCurrency: transaction.currency,
            category: category,
          ));

          if (transaction.repeatCount != null) {
            final repeatCount = transaction.repeatCount! - 1;
            if (repeatCount <= 0) {
              await recurringTransactionsRepository
                  .deleteRecurringTransaction(transaction.id!);
            } else {
              await recurringTransactionsRepository.updateRecurringTransaction(
                  transaction.copyWith(repeatCount: repeatCount));
            }
          }
        }
      }
      return Future.value(true);
    });
  }

  static Future<DateTime?> _getLastUpdatedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_updated_timestamp');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  static Future<void> _setLastUpdatedTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'last_updated_timestamp', timestamp.millisecondsSinceEpoch);
  }

  static Future<void> _cacheCurrencyRates(List<CurrencyRate> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = jsonEncode(rates.map((rate) => rate.toJson()).toList());
    await prefs.setString('cached_currency_rates', ratesJson);
  }
}
