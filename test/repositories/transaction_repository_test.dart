import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/data/db/database_helper.dart';
import 'package:smart_budget/data/repositories/transaction_repository.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/models/transaction.dart' as t;
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late TransactionRepository transactionRepository;

  final testCategory = Category(
    id: 1,
    name: 'Test',
    icon: 123,
    description: "test",
    isIncome: false,
    currency: Currency.usd,
  );

  final testTransaction = t.Transaction(
    id: 1,
    date: DateTime(2023, 11, 20),
    isExpense: 1,
    originalAmount: 100,
    convertedAmount: 100,
    category: testCategory,
    description: "test",
    originalCurrency: Currency.usd,
  );

  final testCategories = [testCategory];

  setUp(() async {
    sqfliteFfiInit();

    databaseHelper = DatabaseHelper(databaseFactory: databaseFactoryFfi, inMemory: true);

    transactionRepository = TransactionRepository(databaseHelper);

    await databaseHelper.database.then((db) async {
      await db.insert('categories', {
        'id': testCategory.id,
        'name': testCategory.name,
        'icon': testCategory.icon,
        'description': testCategory.description,
        'is_income': testCategory.isIncome ? 1 : 0,
        'currency': testCategory.currency.name,
      });
    });
  });

  tearDown(() async {
    final db = await databaseHelper.database;
    await db.close();
  });

  group('TransactionRepository with real DB', () {
    test('createTransaction inserts a transaction into the database', () async {
      final id = await transactionRepository.createTransaction(testTransaction);
      expect(id, isNonZero);

      final all = await transactionRepository.getAllTransactions(testCategories);
      expect(all.length, 1);
      expect(all.first.id, id);
      expect(all.first.category!.name, testCategory.name);
    });

    test('getAllTransactions returns all transactions', () async {
      await transactionRepository.createTransaction(testTransaction);

      final transactions = await transactionRepository.getAllTransactions(testCategories);

      expect(transactions, isNotEmpty);
      expect(transactions.first.id, isNotNull);
      expect(transactions.first.category!.id, testCategory.id);
    });

    test('updateTransaction updates an existing transaction', () async {
      final id = await transactionRepository.createTransaction(testTransaction);

      final updatedTransaction = t.Transaction(
        id: id,
        date: DateTime(2023, 11, 21),
        isExpense: 0,
        originalAmount: 200,
        convertedAmount: 200,
        category: testCategory,
        description: "updated",
        originalCurrency: Currency.usd,
      );

      final updatedCount = await transactionRepository.updateTransaction(updatedTransaction);
      expect(updatedCount, 1);

      final transactions = await transactionRepository.getAllTransactions(testCategories);
      final updated = transactions.firstWhere((t) => t.id == id);

      expect(updated.description, 'updated');
      expect(updated.originalAmount, 200);
      expect(updated.isExpense, 0);
    });

    test('deleteTransaction deletes a transaction by id', () async {
      final id = await transactionRepository.createTransaction(testTransaction);

      final deletedCount = await transactionRepository.deleteTransaction(id);
      expect(deletedCount, 1);

      final transactions = await transactionRepository.getAllTransactions(testCategories);
      expect(transactions.where((t) => t.id == id), isEmpty);
    });

    test('getTransactionsByCustomMonth returns correct transactions', () async {
      await transactionRepository.createTransaction(testTransaction);

      final selectedMonth = DateTime(2023, 11);
      final firstDayOfMonth = 1;

      final results = await transactionRepository.getTransactionsByCustomMonth(
        selectedMonth,
        firstDayOfMonth,
        testCategories,
      );

      expect(results, isNotEmpty);
      expect(results.first.id, isNotNull);
      expect(results.first.date.month, 11);
    });
  });
}
