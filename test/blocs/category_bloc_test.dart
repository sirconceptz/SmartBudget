import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_budget/blocs/category/category_bloc.dart';
import 'package:smart_budget/blocs/category/category_event.dart';
import 'package:smart_budget/blocs/category/category_state.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/utils/enums/currency.dart';

import 'transaction_bloc_test.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

@GenerateMocks([CategoryRepository])
void main() {
  late CategoryBloc categoryBloc;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    categoryBloc = CategoryBloc(
      mockCategoryRepository,
      MockCurrencyConversionBloc(),
      MockCurrencyNotifier(),
    );
  });

  tearDown(() {
    categoryBloc.close();
  });

  test('initial state is CategoriesLoading', () {
    expect(categoryBloc.state, CategoriesLoading());
  });

  blocTest<CategoryBloc, CategoryState>(
    'emits CategoriesWithSpentAmountsLoaded when LoadCategoriesWithSpentAmounts is added',
    build: () {
      when(mockCategoryRepository.getCategoriesWithTransactions())
          .thenAnswer((_) async => [
        Category(
          id: 1,
          name: 'Food',
          description: 'Food',
          icon: Icons.fastfood.codePoint,
          isIncome: false,
          spentAmount: 100.0,
          currency: Currency.usd
        ),
      ]);
      return categoryBloc;
    },
    act: (bloc) => bloc.add(LoadCategoriesWithSpentAmounts(
      DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      ),
    )),
    expect: () => [
      CategoriesLoading(),
      isA<CategoriesWithSpentAmountsLoaded>(),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'emits CategoryError when repository throws',
    build: () {
      when(mockCategoryRepository.getCategoriesWithTransactions())
          .thenThrow(Exception('Database error'));
      return categoryBloc;
    },
    act: (bloc) => bloc.add(LoadCategoriesWithSpentAmounts(
      DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      ),
    )),
    expect: () => [
      CategoriesLoading(),
      isA<CategoryError>(),
    ],
  );
}
