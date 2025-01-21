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
    required this.allCategories,
  });
}

class CategoriesForMonthLoaded extends CategoriesWithSpentAmountsLoaded {
  final double totalIncomes;
  final double totalExpenses;

  final double budgetIncomes;
  final double budgetExpenses;

  CategoriesForMonthLoaded({
    required super.incomeCategories,
    required super.expenseCategories,
    required super.allCategories,
    required this.totalIncomes,
    required this.totalExpenses,
    required this.budgetIncomes,
    required this.budgetExpenses,
  });
}
