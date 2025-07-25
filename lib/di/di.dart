import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/recurring_transactions_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/currency_conversion/currency_conversion_bloc.dart';
import '../blocs/currency_conversion/currency_conversion_event.dart';
import '../data/db/database_helper.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/currency_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../di/notifiers/currency_notifier.dart';
import 'notifiers/finance_notifier.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<DatabaseHelper>(
    DatabaseHelper(databaseFactory: databaseFactory, inMemory: false),
  );

  getIt.registerLazySingleton<RecurringTransactionRepository>(
        () => RecurringTransactionRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerFactory<TransactionRepository>(
        () => TransactionRepository(getIt<DatabaseHelper>()),
  );

  final sharedPrefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<CurrencyRepository>(
    CurrencyRepository(sharedPreferences: sharedPrefs),
  );

  getIt.registerSingleton<CurrencyNotifier>(CurrencyNotifier());
  getIt.registerLazySingleton<FinanceNotifier>(() => FinanceNotifier());

  getIt.registerLazySingleton<CategoryRepository>(
        () => CategoryRepository(getIt<DatabaseHelper>()),
  );

  final currencyBloc = CurrencyConversionBloc(getIt<CurrencyRepository>());

  currencyBloc.add(LoadCurrencyRates());

  getIt.registerSingleton<CurrencyConversionBloc>(currencyBloc);

  getIt.registerLazySingleton<CategoryBloc>(() => CategoryBloc(
    getIt<CategoryRepository>(),
    getIt<CurrencyConversionBloc>(),
    getIt<CurrencyNotifier>(),
    getIt<FinanceNotifier>(),
  ));
}
