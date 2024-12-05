import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';

import '../../models/category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(CategoriesLoading()) {
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
      final allCategories = await categoryRepository.getAllCategories();
      final spentData = await categoryRepository.getSpentAmountForCategories();

      final categories = spentData.map<Category>((data) {
        return Category(
          id: data['category_id'] as int,
          name: data['name'] as String,
          budgetLimit: data['budget_limit'] as double?,
          spentAmount: data['spent_amount'] as double? ?? 0.0,
          isIncome: data['is_income'] == 1,
        );
      }).toList();

      final incomeCategories =
          categories.where((category) => category.isIncome).toList();
      final expenseCategories =
          categories.where((category) => !category.isIncome).toList();

      emit(CategoriesWithSpentAmountsLoaded(
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
        allCategories: allCategories
      ));
    } catch (e) {
      emit(CategoryError('Failed to load categories with spent amounts'));
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.createCategory(event.category);
      add(LoadCategoriesWithSpentAmounts());
    } catch (e) {
      emit(CategoryError('Failed to add category'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.updateCategory(event.category);
      add(LoadCategoriesWithSpentAmounts());
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.deleteCategory(event.id);
      add(LoadCategoriesWithSpentAmounts());
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

      for (final categoryData in predefinedCategories) {
        final category = Category(
          id: categoryData['id'] as int,
          name: categoryData['name'] as String,
          icon: categoryData['icon'] as int,
          description: categoryData['description'] as String,
          isIncome: categoryData['is_income'] == 1,
        );
        await categoryRepository.createOrReplaceCategory(category);
      }

      add(LoadCategoriesWithSpentAmounts());
    } catch (e) {
      emit(CategoryError('Failed to update localized categories'));
    }
  }
}
