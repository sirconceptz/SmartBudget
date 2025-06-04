import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../blocs/currency_conversion/currency_conversion_bloc.dart';
import '../data/db/database_helper.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/recurring_transactions_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../models/currency_rate.dart';
import '../models/transaction.dart';

class RecurringTransactionManager {
  Future<void> addMissingRecurringTransactions(
      CurrencyConversionBloc currencyBloc) async {
    final db = DatabaseHelper(databaseFactory: databaseFactory);
    final recurringTransactionsRepository = RecurringTransactionRepository(db);
    final transactionsRepository = TransactionRepository(db);
    final categoryRepository = CategoryRepository(db);
    final prefs = await SharedPreferences.getInstance();

    List<CurrencyRate> rates;
    try {
      rates = await currencyBloc.ensureLatestCurrencyRates();
    } catch (e) {
      return;
    }

    final userCurrency = prefs.getString('user_currency') ?? 'USD';
    final ratesMap = {
      for (var rate in rates) rate.code.toUpperCase(): rate.rate
    };
    final defaultRate = 1.0;
    final usdToUser = ratesMap[userCurrency.toUpperCase()] ?? defaultRate;

    final now = DateTime.now();
    final recurringTransactions =
        await recurringTransactionsRepository.getAllRecurringTransactions();
    final allCategories = await categoryRepository.getAllCategories();
    final allTransactions =
        await transactionsRepository.getAllTransactions(allCategories);

    for (var recurring in recurringTransactions) {
      DateTime nextDate = recurring.startDate;
      int addedCount = 0;

      while (!nextDate.isAfter(now)) {
        final alreadyExists = allTransactions.any((t) =>
            t.category != null &&
            t.category!.id == recurring.categoryId &&
            _isSameDate(t.date, nextDate) &&
            t.originalAmount == recurring.amount &&
            t.originalCurrency == recurring.currency);

        if (!alreadyExists) {
          final category =
              allCategories.firstWhere((c) => c.id == recurring.categoryId);

          final baseToUsd =
              ratesMap[recurring.currency.name.toUpperCase()] ?? defaultRate;
          final conversionRate = usdToUser / baseToUsd;
          final convertedAmount = recurring.amount * conversionRate;

          await transactionsRepository.createTransaction(Transaction(
            isExpense: recurring.isExpense ? 1 : 0,
            originalAmount: recurring.amount,
            convertedAmount: convertedAmount,
            date: nextDate,
            originalCurrency: recurring.currency,
            category: category,
            description: recurring.description,
          ));

          addedCount++;
        }

        switch (recurring.repeatInterval) {
          case 'daily':
            nextDate = nextDate.add(Duration(days: 1));
            break;
          case 'weekly':
            nextDate = nextDate.add(Duration(days: 7));
            break;
          case 'monthly':
            nextDate = _addOneMonth(nextDate);
            break;
          default:
            nextDate = now.add(Duration(days: 1));
        }

        if (recurring.repeatCount != null &&
            addedCount >= recurring.repeatCount!) {
          await recurringTransactionsRepository
              .deleteRecurringTransaction(recurring.id!);
          break;
        }
      }
    }
  }

  DateTime _addOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    int day = date.day;
    int maxDay = DateTime(year, month + 1, 0).day;
    if (day > maxDay) day = maxDay;
    return DateTime(year, month, day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
