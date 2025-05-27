import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/recurring_transactions_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/currency_conversion/currency_conversion_bloc.dart';
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

  getIt.registerFactory<TransactionRepository>(
    () => TransactionRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepository(getIt<DatabaseHelper>()),
  );

  final sharedPrefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepository(sharedPreferences: sharedPrefs),
  );

  getIt.registerSingleton<CurrencyNotifier>(CurrencyNotifier());

  getIt.registerSingleton<CurrencyConversionBloc>(
    CurrencyConversionBloc(getIt<CurrencyRepository>()),
  );

  getIt.registerLazySingleton<FinanceNotifier>(() => FinanceNotifier());

  getIt.registerSingleton<CategoryBloc>(
    CategoryBloc(
      getIt<CategoryRepository>(),
      getIt<CurrencyConversionBloc>(),
      getIt<CurrencyNotifier>(),
      getIt<FinanceNotifier>(),
    ),
  );
}
