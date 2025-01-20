import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_budget/data/mappers/transaction_mapper.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_budget/data/repositories/transaction_repository.dart';
import 'package:smart_budget/models/transaction.dart' as t;

import 'transaction_repository_test.mocks.dart';

void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;
  late TransactionRepository repository;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    repository = TransactionRepository(mockDatabaseHelper);
  });

  group('TransactionRepository', () {
    test('createTransaction inserts a transaction into the database', () async {
      final transaction = t.Transaction(
        id: null,
        isExpense: 1,
        originalAmount: 100.0,
        convertedAmount: 100.0,
        category: Category(id: 1, name: "Food", description: "", isIncome: false, currency: Currency.usd),
        originalCurrency: Currency.usd,
        date: DateTime.now(),
        description: 'Test transaction',
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.insert('transactions', TransactionMapper.toEntity(transaction).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);

      final result = await repository.createTransaction(transaction);

      expect(result, 1);
      verify(mockDatabase.insert('transactions', TransactionMapper.toEntity(transaction).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
    });

    test('getAllTransactions fetches all transactions from the database',
            () async {
          final transactionJson = {
            'id': 1,
            'type': 1,
            'amount': 100.0,
            'category_id': 2,
            'currency': 'USD',
            'date': DateTime.now().toIso8601String(),
            'description': 'Test transaction',
          };

          when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
          when(mockDatabase.query('transactions'))
              .thenAnswer((_) async => [transactionJson]);

          final result = await repository.getAllTransactions();

          expect(result.length, 1);
          expect(result.first.id, 1);
          expect(result.first.originalAmount, 100.0);
          expect(result.first.description, 'Test transaction');

          verify(mockDatabase.query('transactions')).called(1);
        });

    test('updateTransaction updates a transaction in the database', () async {
      final transaction = t.Transaction(
        id: 1,
        isExpense: 1,
        originalAmount: 150.0,
        convertedAmount: 150.0,
        category: Category(id: 1, name: "Food", description: "", isIncome: false, currency: Currency.usd),
        originalCurrency: Currency.usd,
        date: DateTime.now(),
        description: 'Updated transaction',
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.update('transactions', TransactionMapper.toEntity(transaction).toJson(),
          where: 'id = ?', whereArgs: [transaction.id]))
          .thenAnswer((_) async => 1);

      final result = await repository.updateTransaction(transaction);

      expect(result, 1);
      verify(mockDatabase.update('transactions', TransactionMapper.toEntity(transaction).toJson(),
          where: 'id = ?', whereArgs: [transaction.id])).called(1);
    });

    test('deleteTransaction deletes a transaction from the database',
            () async {
          when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
          when(mockDatabase.delete('transactions', where: 'id = ?', whereArgs: [1]))
              .thenAnswer((_) async => 1);

          final result = await repository.deleteTransaction(1);

          expect(result, 1);
          verify(mockDatabase.delete('transactions', where: 'id = ?', whereArgs: [1]))
              .called(1);
        });
  });
}
