import 'package:get_it/get_it.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/db/database_helper.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());

  getIt.registerFactory<TransactionRepository>(
          () => TransactionRepository(getIt<DatabaseHelper>()));

  getIt.registerLazySingleton<CategoryRepository>(
        () => CategoryRepository(getIt<DatabaseHelper>()),
  );
}
