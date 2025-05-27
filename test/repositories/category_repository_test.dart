import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/data/db/database_helper.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late CategoryRepository categoryRepository;
  late DatabaseHelper databaseHelper;

  setUp(() async {
    databaseHelper = DatabaseHelper(databaseFactory: databaseFactoryFfi, inMemory: true);

    categoryRepository = CategoryRepository(databaseHelper);
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  test('createOrReplaceCategory and getAllCategories', () async {
    final category = Category(
      id: null,
      name: 'Test Category',
      icon: 123,
      description: 'Test Desc',
      isIncome: false,
      currency: Currency.usd,
    );

    await categoryRepository.createOrReplaceCategory(category);

    final categories = await categoryRepository.getAllCategories();
    expect(categories.length, 1);
    expect(categories[0].name, 'Test Category');
    expect(categories[0].currency, Currency.usd);
  });

  test('updateCategory updates the category', () async {
    final category = Category(
      id: null,
      name: 'Test Category',
      icon: 123,
      description: 'Test Desc',
      isIncome: false,
      currency: Currency.usd,
    );

    await categoryRepository.createOrReplaceCategory(category);
    var categories = await categoryRepository.getAllCategories();
    final cat = categories.first;

    final updatedCategory = cat.copyWith(description: 'Updated', budgetLimit: 500.0);
    final updateResult = await categoryRepository.updateCategory(updatedCategory);
    expect(updateResult, 1);

    categories = await categoryRepository.getAllCategories();
    expect(categories.first.description, 'Updated');
    expect(categories.first.budgetLimit, 500.0);
  });

  test('deleteCategory removes the category', () async {
    final category = Category(
      id: null,
      name: 'Test Category',
      icon: 123,
      description: 'Test Desc',
      isIncome: false,
      currency: Currency.usd,
    );

    await categoryRepository.createOrReplaceCategory(category);
    var categories = await categoryRepository.getAllCategories();
    final catId = categories.first.id!;

    final deleteResult = await categoryRepository.deleteCategory(catId);
    expect(deleteResult, 1);

    categories = await categoryRepository.getAllCategories();
    expect(categories.isEmpty, true);
  });

  test('getCategoriesWithTransactions returns categories with transactions', () async {
    final db = await databaseHelper.database;

    // Insert category directly
    final catId = await db.insert('categories', {
      'name': 'Test Category',
      'icon': 123,
      'description': 'Test Desc',
      'budget_limit': 1000.0,
      'currency': 'usd',
      'is_income': 0,
    });

    // Insert transaction linked to the category
    await db.insert('transactions', {
      'amount': 100.0,
      'isExpense': 1,
      'category_id': catId,
      'currency': 'usd',
      'description': 'Test Transaction',
      'date': DateTime.now().toIso8601String(),
    });

    final categories = await categoryRepository.getCategoriesWithTransactions();
    expect(categories.length, 1);
    expect(categories.first.transactions.length, 1);
    expect(categories.first.transactions.first.amount, 100.0);
  });
}
