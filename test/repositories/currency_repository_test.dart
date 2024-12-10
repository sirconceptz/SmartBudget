import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_budget/data/db/database_helper.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';

import '../data/repositories/transaction_repository_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late CategoryRepository categoryRepository;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    categoryRepository = CategoryRepository(mockDatabaseHelper);
  });

  test('getCategoriesWithTransactions returns list of categories', () async {
    when(mockDatabaseHelper.query('categories')).thenAnswer((_) async => [
      {'id': 1, 'name': 'Food', 'icon': 123, 'is_income': 0}
    ]);
    final categories = await categoryRepository.getCategoriesWithTransactions();
    expect(categories.length, 1);
    expect(categories.first.name, 'Food');
  });

  test('throws exception when database query fails', () async {
    when(mockDatabaseHelper.query('categories'))
        .thenThrow(Exception('Database error'));
    expect(
      categoryRepository.getCategoriesWithTransactions(),
      throwsException,
    );
  });
}
