import 'package:get_it/get_it.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/currency_conversion/currency_conversion_bloc.dart';
import '../data/db/database_helper.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/currency_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../di/notifiers/currency_notifier.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());

  getIt.registerFactory<TransactionRepository>(
    () => TransactionRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepository(),
  );

  getIt.registerSingleton<CurrencyNotifier>(CurrencyNotifier());

  getIt.registerSingleton<CurrencyConversionBloc>(
    CurrencyConversionBloc(getIt<CurrencyRepository>()),
  );

  getIt.registerSingleton<CategoryBloc>(
    CategoryBloc(
      getIt<CategoryRepository>(),
      getIt<CurrencyConversionBloc>(),
      getIt<CurrencyNotifier>(),
    ),
  );
}
