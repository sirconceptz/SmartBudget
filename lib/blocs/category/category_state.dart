import '../../models/category.dart';

abstract class CategoryState {}

class CategoriesLoading extends CategoryState {}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}

class CategoriesWithSpentAmountsLoaded extends CategoryState {
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;
  final List<Category> allCategories;

  CategoriesWithSpentAmountsLoaded({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.allCategories
  });
}
