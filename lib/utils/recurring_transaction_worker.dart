import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: false,
        autoStart: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onBackground,
      ),
    );

    await service.startService();
  }

  static Future<void> onStart(ServiceInstance service) async {

    final db = DatabaseHelper();
    final recurringTransactionsRepository = RecurringTransactionRepository(db);
    final transactionsRepository = TransactionRepository(db);
    final categoryRepository = CategoryRepository(db);

    final prefs = await SharedPreferences.getInstance();

    DateTime now = DateTime.now();
    DateTime? lastUpdated = _getLastUpdatedTimestamp(prefs);
    List<CurrencyRate> rates = [];

    if (lastUpdated != null && now.difference(lastUpdated).inHours < 24) {
      final ratesJson = prefs.getString('cached_currency_rates');
      if (ratesJson != null) {
        rates = (jsonDecode(ratesJson) as List)
            .map((json) => CurrencyRate.fromJson(json))
            .toList();
      }
    } else {
      try {
        final currencyConversionBloc = getIt<CurrencyConversionBloc>();
        final ratesResponse = await currencyConversionBloc.repository.fetchCurrencyRates();
        await _cacheCurrencyRates(prefs, ratesResponse);
        _setLastUpdatedTimestamp(prefs, now);
        rates = ratesResponse;
      } catch (error) {
        MyLogger.write("Failed to fetch currency rates", error.toString());
        return;
      }
    }

    final ratesMap = { for (var rate in rates) rate.code.toUpperCase(): rate.rate };
    final userCurrency = prefs.getString('user_currency') ?? 'USD';
    final defaultRate = 1.0;

    final transactions = await recurringTransactionsRepository.getAllRecurringTransactions();

    for (var transaction in transactions) {
      bool shouldAdd = false;
      if (transaction.repeatInterval == 'daily' && now.difference(transaction.startDate).inDays >= 1) {
        shouldAdd = true;
      } else if (transaction.repeatInterval == 'weekly' && now.difference(transaction.startDate).inDays >= 7) {
        shouldAdd = true;
      } else if (transaction.repeatInterval == 'monthly' && now.month != transaction.startDate.month) {
        shouldAdd = true;
      }

      if (shouldAdd) {
        final category = await categoryRepository.getCategory(transaction.categoryId);
        final baseToUsd = ratesMap[transaction.currency.name.toUpperCase()] ?? defaultRate;
        final usdToUser = ratesMap[userCurrency.toUpperCase()] ?? defaultRate;
        final conversionRate = usdToUser / baseToUsd;
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
            await recurringTransactionsRepository.deleteRecurringTransaction(transaction.id!);
          } else {
            await recurringTransactionsRepository.updateRecurringTransaction(
                transaction.copyWith(repeatCount: repeatCount));
          }
        }
      }
    }
  }

  static bool onBackground(ServiceInstance service) {
    // Optional - dla iOS
    return true;
  }

  static DateTime? _getLastUpdatedTimestamp(SharedPreferences prefs) {
    final timestamp = prefs.getInt('last_updated_timestamp');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  static Future<void> _setLastUpdatedTimestamp(SharedPreferences prefs, DateTime timestamp) async {
    await prefs.setInt('last_updated_timestamp', timestamp.millisecondsSinceEpoch);
  }

  static Future<void> _cacheCurrencyRates(SharedPreferences prefs, List<CurrencyRate> rates) async {
    final ratesJson = jsonEncode(rates.map((r) => r.toJson()).toList());
    await prefs.setString('cached_currency_rates', ratesJson);
  }
}
