import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/utils/enums/currency.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_budget/data/db/database_helper.dart';

void main() {
  sqfliteFfiInit();

  late CategoryRepository categoryRepository;
  late DatabaseHelper databaseHelper;

  setUp(() async {
    databaseHelper = DatabaseHelper(databaseFactory: databaseFactoryFfi);
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    await databaseFactoryFfi.deleteDatabase('$dbPath/budget_manager.db');

    categoryRepository = CategoryRepository(databaseHelper);
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
  });

  test('update and delete Category', () async {
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

    await categoryRepository.updateCategory(cat.copyWith(budgetLimit: 200.0));
    categories = await categoryRepository.getAllCategories();
    expect(categories.first.budgetLimit, 200.0);

    await categoryRepository.deleteCategory(categories.first.id!);
    categories = await categoryRepository.getAllCategories();
    expect(categories.isEmpty, true);
  });
}
