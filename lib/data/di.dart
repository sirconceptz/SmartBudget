import 'package:get_it/get_it.dart';
import 'db/database_helper.dart';
import 'repositories/transaction_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register DatabaseHelper
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());

  // Register TransactionRepository
  getIt.registerFactory<TransactionRepository>(
          () => TransactionRepository(getIt<DatabaseHelper>()));
}
