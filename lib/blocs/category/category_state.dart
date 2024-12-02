import '../../models/category.dart';

abstract class CategoryState {}

class CategoriesLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;

  CategoriesLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}

class CategoriesWithSpentAmountsLoaded extends CategoryState {
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;

  CategoriesWithSpentAmountsLoaded({
    required this.incomeCategories,
    required this.expenseCategories,
  });
}
