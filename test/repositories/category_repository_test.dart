import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_budget/data/mappers/category_mapper.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:sqflite/sqflite.dart';

import '../screens/settings_screen_test.mocks.dart';
import 'transaction_repository_test.dart';

void main() {
  late CategoryRepository categoryRepository;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    categoryRepository = CategoryRepository(mockDatabaseHelper);
    when(() => mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('CategoryRepository', () {
    final testCategory = Category(
        id: 1,
        name: 'Test',
        icon: 123,
        description: "test",
        isIncome: false,
        currency: Currency.usd
    );
    final testCategoryJson = {
      'id': 1,
      'name': 'Test',
      'icon': 123,
      'description': "test",
      'isIncome': 0,
      'currency': 'usd'
    };

    final testTransactionJson = {
      'id': 1,
      'categoryId': 1,
      'isExpense': 1,
      'amount': 100.0,
      'date': '2023-11-20T00:00:00.000',
      'currency': 'usd'
    };

    test('getAllCategories returns a list of categories', () async {
      when(() => mockDatabase.query(any(), orderBy: any(named: 'orderBy')))
          .thenAnswer((_) async => [testCategoryJson]);

      final result = await categoryRepository.getAllCategories();

      expect(result.length, 1);
      expect(result[0].id, testCategory.id);
      expect(result[0].name, testCategory.name);
      verify(() => mockDatabase.query('categories', orderBy: 'name')).called(1);
    });

    test('updateCategory updates a category in the database', () async {
      when(() => mockDatabase.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      final result = await categoryRepository.updateCategory(testCategory);

      expect(result, 1);
      verify(() => mockDatabase.update(
        'categories',
        CategoryMapper.toEntity(testCategory).toJson(),
        where: 'id = ?',
        whereArgs: [testCategory.id],
      )).called(1);
    });

    test('deleteCategory deletes a category from the database', () async {
      when(() => mockDatabase.delete(any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      final result = await categoryRepository.deleteCategory(testCategory.id!);

      expect(result, 1);
      verify(() => mockDatabase.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [testCategory.id],
      )).called(1);
    });

    test('createOrReplaceCategory inserts a category into the database', () async {
      when(() => mockDatabase.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      await categoryRepository.createOrReplaceCategory(testCategory);

      verify(() => mockDatabase.insert(
        'categories',
        CategoryMapper.toEntity(testCategory).toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('getCategoriesWithTransactions returns a list of categories with their transactions', () async {
      when(() => mockDatabase.query('categories')).thenAnswer((_) async => [testCategoryJson]);
      when(() => mockDatabase.query('transactions', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [testTransactionJson]);

      final result = await categoryRepository.getCategoriesWithTransactions();

      expect(result.length, 1);
      expect(result[0].id, testCategory.id);
      expect(result[0].transactions.length, 1);
      verify(() => mockDatabase.query('categories')).called(1);
      verify(() => mockDatabase.query(
        'transactions',
        where: 'category_id = ?',
        whereArgs: [testCategoryJson['id']],
      )).called(1);
    });
  });
}