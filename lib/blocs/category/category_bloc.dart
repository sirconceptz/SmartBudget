import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';

import '../../models/category.dart';
import '../../models/currency_rate.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../blocs/currency_conversion/currency_conversion_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;
  final CurrencyConversionBloc currencyConversionBloc;
  final CurrencyNotifier currencyNotifier;

  CategoryBloc(
      this.categoryRepository,
      this.currencyConversionBloc,
      this.currencyNotifier,
      ) : super(CategoriesLoading()) {
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadCategoriesWithSpentAmounts>(_onLoadCategoriesWithSpentAmounts);
    on<UpdateLocalizedCategories>(_onUpdateLocalizedCategories);
  }

  Future<void> _onLoadCategoriesWithSpentAmounts(
      LoadCategoriesWithSpentAmounts event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoriesLoading());

      final categoryEntities = await categoryRepository.getCategoriesWithTransactions();

      final rates = await currencyConversionBloc.repository.fetchCurrencyRates();
      final userCurrency = currencyNotifier.currency;

      final convertedCategories = categoryEntities.map((entity) {
        final baseToUserRate = rates.firstWhere(
              (rate) => rate.code.toUpperCase() == entity.currency.value.toUpperCase(),
          orElse: () => CurrencyRate(name: 'USD', code: 'USD', rate: 1.0),
        ).rate /
            rates.firstWhere(
                  (rate) => rate.code.toUpperCase() == userCurrency.value.toUpperCase(),
              orElse: () => CurrencyRate(name: 'USD', code: 'USD', rate: 1.0),
            ).rate;

        return Category.convertMoney(entity, baseToUserRate);
      }).toList();

      final incomeCategories = convertedCategories.where((c) => c.isIncome).toList();
      final expenseCategories = convertedCategories.where((c) => !c.isIncome).toList();

      emit(CategoriesWithSpentAmountsLoaded(
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
        allCategories: incomeCategories + expenseCategories,
      ));
    } catch (e) {
      emit(CategoryError('Failed to load categories with spent amounts'));
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.createOrReplaceCategory(event.category);
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to add category'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.updateCategory(event.category);
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.deleteCategory(event.id);
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to delete category'));
    }
  }

  Future<void> _onUpdateLocalizedCategories(
      UpdateLocalizedCategories event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoriesLoading());

      final predefinedCategories = [
        {
          'id': 1,
          'name': event.localizations.categoryFood,
          'icon': Icons.fastfood.codePoint,
          'description': event.localizations.categoryFoodDescription,
          'is_income': 0,
        },
        {
          'id': 2,
          'name': event.localizations.categoryEntertainment,
          'icon': Icons.movie.codePoint,
          'description': event.localizations.categoryEntertainmentDescription,
          'is_income': 0,
        },
        {
          'id': 3,
          'name': event.localizations.categorySalary,
          'icon': Icons.attach_money.codePoint,
          'description': event.localizations.categorySalaryDescription,
          'is_income': 1,
        },
        {
          'id': 4,
          'name': event.localizations.categoryHealth,
          'icon': Icons.health_and_safety.codePoint,
          'description': event.localizations.categoryHealthDescription,
          'is_income': 0,
        },
        {
          'id': 5,
          'name': event.localizations.categoryTravel,
          'icon': Icons.flight.codePoint,
          'description': event.localizations.categoryTravelDescription,
          'is_income': 0,
        },
      ];
      List<Category> categoryList = [];
      for (final categoryData in predefinedCategories) {
        final category = Category(
          id: categoryData['id'] as int,
          name: categoryData['name'] as String,
          icon: categoryData['icon'] as int,
          description: categoryData['description'] as String,
          isIncome: categoryData['is_income'] == 1,
          currency: currencyNotifier.currency
        );
        categoryList.add(category);
      }
      await categoryRepository.initCoreCategories(categoryList);
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      );
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to update localized categories'));
    }
  }
}
