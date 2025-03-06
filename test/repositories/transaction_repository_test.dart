import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_budget/data/db/database_helper.dart';
import 'package:smart_budget/data/mappers/transaction_mapper.dart';
import 'package:smart_budget/data/repositories/transaction_repository.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/models/transaction.dart' as t;
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

void main() {
  late TransactionRepository transactionRepository;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  final testCategory = Category(
      id: 1,
      name: 'Test',
      icon: 123,
      description: "test",
      isIncome: false,
      currency: Currency.usd
  );

  final testTransaction = t.Transaction(
      id: 1,
      date: DateTime(2023, 11, 20),
      isExpense: 1,
      originalAmount: 100,
      convertedAmount: 100,
      category: testCategory,
      description: "test",
      originalCurrency: Currency.usd
  );

  final testTransactionJson = {
    'id': 1,
    'category_id': 1,
    'amount': 100.0,
    'isExpense': 1,
    'date': '2023-11-20T00:00:00.000',
    'currency': 'usd'
  };

  final testCategories = [
    Category(id: 1, name: 'Test', icon: 123, description: "test", isIncome: false, currency: Currency.usd)
  ];

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    transactionRepository = TransactionRepository(mockDatabaseHelper);
    when(() => mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);

    when(() => mockDatabase.query('categories')).thenAnswer((_) async => [
      {
        'id': 1,
        'name': 'Test',
        'icon': 123,
        'description': 'test',
        'isIncome': 0,
        'currency': 'usd'
      }
    ]);

    when(() => mockDatabase.query('transactions')).thenAnswer((_) async => [testTransactionJson]);
  });

  group('TransactionRepository', () {
    test('createTransaction inserts a transaction into the database', () async {
      when(() => mockDatabase.insert(any(), any(),
          conflictAlgorithm: any(named: 'conflictAlgorithm'))).thenAnswer((_) async => 1);

      final result = await transactionRepository.createTransaction(testTransaction);

      expect(result, 1);
      verify(() => mockDatabase.insert(
        'transactions',
        TransactionMapper.toEntity(testTransaction).toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('getAllTransactions returns a list of transactions', () async {
      when(() => mockDatabase.query('transactions')).thenAnswer((_) async => [testTransactionJson]);

      final result = await transactionRepository.getAllTransactions(testCategories);

      expect(result.length, 1);
      expect(result[0].id, testTransaction.id);
      expect(result[0].category!.id, testTransaction.category!.id);
      verify(() => mockDatabase.query('transactions')).called(1);
    });

    test('updateTransaction updates a transaction in the database', () async {
      when(() => mockDatabase.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      final result = await transactionRepository.updateTransaction(testTransaction);

      expect(result, 1);
      verify(() => mockDatabase.update(
        'transactions',
        TransactionMapper.toEntity(testTransaction).toJson(),
        where: 'id = ?',
        whereArgs: [testTransaction.id],
      )).called(1);
    });

    test('deleteTransaction deletes a transaction from the database', () async {
      when(() => mockDatabase.delete(any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      final result = await transactionRepository.deleteTransaction(testTransaction.id!);

      expect(result, 1);
      verify(() => mockDatabase.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [testTransaction.id],
      )).called(1);
    });

    test('getTransactionsByCustomMonth returns a list of transactions within a given month', () async {
      final selectedMonth = DateTime(2023, 11);
      final firstDayOfMonth = 1;

      when(() => mockDatabase.query(any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [testTransactionJson]);

      final result = await transactionRepository.getTransactionsByCustomMonth(
        selectedMonth,
        firstDayOfMonth,
        testCategories,
      );

      expect(result.length, 1);
      expect(result[0].id, testTransaction.id);
      verifyNever(() => mockDatabase.query(
        'transactions',
        where: 'date >= ? AND date <= ?',
        whereArgs: [
          '2023-11-01T00:00:00.000',
          '2023-11-30T23:59:59.999'
        ],
      ));
    });
  });
}
