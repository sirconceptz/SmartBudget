import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';

import '../../blocs/currency_conversion/currency_conversion_bloc.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../models/category.dart';
import '../../models/monthly_spent.dart';
import '../currency_conversion/currency_conversion_state.dart';
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
    LoadCategoriesWithSpentAmounts event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoriesLoading());

      // 1. Pobierz kategorie wraz z transakcjami
      final categories =
          await categoryRepository.getCategoriesWithTransactions();
      // W tym momencie każda kategoria ma: category.transactions (lista TransactionEntity)

      // 2. Grupujemy transakcje w obrębie każdej kategorii po (year-month) i sumujemy
      for (final cat in categories) {
        // Zbuduj mapę: "YYYY-MM" -> suma
        final Map<String, double> monthMap = {};

        for (final tx in cat.transactions) {
          // (Opcjonalnie) filtruj transakcje w event.dateRange
          // Jeśli NIE chcesz filtru, usuń warunek poniżej
          final start = event.dateRange.start.millisecondsSinceEpoch;
          final end = event.dateRange.end.millisecondsSinceEpoch;
          final txMs = tx.date.millisecondsSinceEpoch;
          if (txMs < start || txMs > end) {
            // pomijamy transakcje poza zakresem, jeśli chcesz
            continue;
          }

          // wyliczamy klucz miesiąca "YYYY-MM"
          final key = _formatYearMonth(tx.date);

          // dodajemy do sumy
          final currentSum = monthMap[key] ?? 0.0;
          monthMap[key] = currentSum + tx.amount;
        }

        // zmapuj na listę MonthlySpent
        final monthlySpentList = monthMap.entries.map((entry) {
          return MonthlySpent(
            monthKey: entry.key,
            spentAmount: entry.value,
          );
        }).toList();

        // wpisz do kategorii
        cat.monthlySpent = monthlySpentList;
      }

      // 3. Konwersja walut
      final currentState = currencyConversionBloc.state;
      if (currentState is! CurrencyRatesLoaded) {
        throw Exception("Currency rates not loaded");
      }
      final rates = currentState.rates;
      final userCurrency = currencyNotifier.currency;

      final ratesMap = {
        for (var rate in rates) rate.code.toUpperCase(): rate.rate
      };
      const defaultRate = 1.0;

      // przeliczamy każdą kategorię
      final convertedCategories = categories.map((cat) {
        final baseToUserRate =
            (ratesMap[cat.currency.value.toUpperCase()] ?? defaultRate) /
                (ratesMap[userCurrency.value.toUpperCase()] ?? defaultRate);

        // Category.convertMoney powinno przeliczać monthlySpent
        // z cat.monthlySpent[i].spentAmount
        return Category.convertMoney(cat, baseToUserRate);
      }).toList();

      // 4. Podziel na income / expense
      final incomeCategories =
          convertedCategories.where((c) => c.isIncome).toList();
      final expenseCategories =
          convertedCategories.where((c) => !c.isIncome).toList();

      // 5. Wylicz sumy -> sumujemy we wszystkich miesiącach
      final totalIncomes = incomeCategories.fold<double>(0, (sum, cat) {
        double catSum =
            cat.monthlySpent.fold(0.0, (acc, ms) => acc + ms.spentAmount);
        return sum + catSum;
      });

      final totalExpenses = expenseCategories.fold<double>(0, (sum, cat) {
        double catSum =
            cat.monthlySpent.fold(0.0, (acc, ms) => acc + ms.spentAmount);
        return sum + catSum;
      });

      final budgetIncomes = incomeCategories.fold<double>(
        0,
        (sum, cat) => sum + (cat.budgetLimit ?? 0),
      );
      final budgetExpenses = expenseCategories.fold<double>(
        0,
        (sum, cat) => sum + (cat.budgetLimit ?? 0),
      );

      emit(
        CategoriesForMonthLoaded(
          incomeCategories: incomeCategories,
          expenseCategories: expenseCategories,
          allCategories: convertedCategories,
          totalIncomes: totalIncomes,
          totalExpenses: totalExpenses,
          budgetIncomes: budgetIncomes,
          budgetExpenses: budgetExpenses,
        ),
      );
    } catch (e) {
      emit(CategoryError('Failed to load categories with spent amounts: $e'));
    }
  }

  String _formatYearMonth(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.createOrReplaceCategory(event.category);
      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
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
        start: DateTime.now().subtract(const Duration(days: 30)),
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
        start: DateTime.now().subtract(const Duration(days: 30)),
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
      for (final categoryData in predefinedCategories) {
        final category = Category(
          id: categoryData['id'] as int,
          name: categoryData['name'] as String,
          icon: categoryData['icon'] as int,
          description: categoryData['description'] as String,
          isIncome: categoryData['is_income'] == 1,
          currency: currencyNotifier.currency,
        );
        await categoryRepository.createOrReplaceCategory(category);
      }

      final dateRange = DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      );
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to update localized categories'));
    }
  }
}
