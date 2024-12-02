import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';

import '../../models/category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(CategoriesLoading()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadCategoriesWithSpentAmounts>(_onLoadCategoriesWithSpentAmounts);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoriesLoading());
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories'));
    }
  }

  Future<void> _onLoadCategoriesWithSpentAmounts(
      LoadCategoriesWithSpentAmounts event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoriesLoading());
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
      ));
    } catch (e) {
      emit(CategoryError('Failed to load categories with spent amounts'));
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.createCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to add category'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.deleteCategory(event.id);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to delete category'));
    }
  }
}
