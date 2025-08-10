import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'package:smart_budget/di/notifiers/finance_notifier.dart';

import '../../blocs/currency_conversion/currency_conversion_bloc.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../models/category.dart';
import '../../models/monthly_spent.dart';
import '../../utils/available_icons.dart';
import '../../utils/custom_date_time_range.dart';
import '../currency_conversion/currency_conversion_state.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;
  final CurrencyConversionBloc currencyConversionBloc;
  final CurrencyNotifier currencyNotifier;
  final FinanceNotifier financeNotifier;
  VoidCallback? _currencyChangeListener;

  CategoryBloc(
    this.categoryRepository,
    this.currencyConversionBloc,
    this.currencyNotifier,
    this.financeNotifier,
  ) : super(CategoriesLoading()) {
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadCategoriesWithSpentAmounts>(_onLoadCategoriesWithSpentAmounts);
    on<UpdateLocalizedCategories>(_onUpdateLocalizedCategories);

    _currencyChangeListener = () {
      add(LoadCategoriesWithSpentAmounts(null));
    };
    currencyNotifier.addListener(_currencyChangeListener!);
  }

  int retryCount = 0;

  Future<void> _onLoadCategoriesWithSpentAmounts(
    LoadCategoriesWithSpentAmounts event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoriesLoading());

      final categories =
          await categoryRepository.getCategoriesWithTransactions();

      final firstDayOfMonth = financeNotifier.firstDayOfMonth;

      final currentState = currencyConversionBloc.state;

      if (currentState is! CurrencyRatesLoaded) {
        if (retryCount >= 3) {
          emit(CategoryError('Currency rates not loaded after retries'));
          return;
        }
        retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        add(event);
        return;
      }
      final rates = currentState.rates;

      final ratesMap = {
        for (var rate in rates) rate.code.toUpperCase(): rate.rate
      };
      const defaultRate = 1.0;

      final userCurrency = currencyNotifier.currency;
      final userCurCode = userCurrency.value.toUpperCase();
      final userCurToUsdRate = ratesMap[userCurCode] ?? defaultRate;

      for (final cat in categories) {
        final Map<String, double> monthMap = {};

        for (final tx in cat.transactions) {
          final key = _computeCustomMonthKey(tx.date, firstDayOfMonth);

          final txCurrencyCode = tx.currency.value.toUpperCase();
          final txCurToUsdRate = ratesMap[txCurrencyCode] ?? defaultRate;

          final finalAmount = tx.amount *
              ((userCurToUsdRate == 0.0)
                  ? 1.0
                  : (txCurToUsdRate / userCurToUsdRate));

          final currentSum = monthMap[key] ?? 0.0;
          monthMap[key] = currentSum + finalAmount;
        }

        cat.monthlySpent = monthMap.entries.map((entry) {
          return MonthlySpent(
            monthKey: entry.key,
            spentAmount: entry.value, // w userCurrency
          );
        }).toList();
      }

      final convertedCategories = categories.map((cat) {
        final baseToUserRate =
            (ratesMap[cat.currency.value.toUpperCase()] ?? defaultRate) /
                (ratesMap[userCurrency.value.toUpperCase()] ?? defaultRate);

        return _convertBudgetOnly(cat, baseToUserRate);
      }).toList();

      final incomeCategories =
          convertedCategories.where((c) => c.isIncome).toList();
      final expenseCategories =
          convertedCategories.where((c) => !c.isIncome).toList();

      final totalIncomes = incomeCategories.fold<double>(0, (sum, cat) {
        final catSum =
            cat.monthlySpent.fold(0.0, (acc, ms) => acc + ms.spentAmount);
        return sum + catSum;
      });

      final totalExpenses = expenseCategories.fold<double>(0, (sum, cat) {
        final catSum =
            cat.monthlySpent.fold(0.0, (acc, ms) => acc + ms.spentAmount);
        return sum + catSum;
      });

      final budgetIncomes = incomeCategories.fold<double>(
          0, (sum, cat) => sum + (cat.budgetLimit ?? 0));
      final budgetExpenses = expenseCategories.fold<double>(
          0, (sum, cat) => sum + (cat.budgetLimit ?? 0));

      emit(CategoriesForMonthLoaded(
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
        allCategories: convertedCategories,
        totalIncomes: totalIncomes,
        totalExpenses: totalExpenses,
        budgetIncomes: budgetIncomes,
        budgetExpenses: budgetExpenses,
      ));
    } catch (e) {
      emit(CategoryError('Failed to load categories with spent amounts: $e'));
    }
  }

  Category _convertBudgetOnly(Category cat, double rateToUserCurrency) {
    final newBudgetLimit =
        cat.budgetLimit != null ? cat.budgetLimit! / rateToUserCurrency : null;

    return cat.copyWith(
      convertedBudgetLimit: newBudgetLimit,
    );
  }

  String _computeCustomMonthKey(DateTime date, int firstDayOfMonth) {
    final txYear = date.year;
    final txMonth = date.month;
    final txDay = date.day;

    if (txDay < firstDayOfMonth) {
      final prevMonth = txMonth - 1;
      if (prevMonth < 1) {
        return CustomDateTimeRange.formatYearMonth(txYear - 1, 12);
      } else {
        return CustomDateTimeRange.formatYearMonth(txYear, prevMonth);
      }
    } else {
      return CustomDateTimeRange.formatYearMonth(txYear, txMonth);
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      final firstDayOfMonth = financeNotifier.firstDayOfMonth;

      await categoryRepository.createOrReplaceCategory(event.category);
      final dateRange = CustomDateTimeRange.getExactOneMonthRange(
          selectedFirstDay: firstDayOfMonth, minDate: DateTime.now());
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to add category'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      final firstDayOfMonth = financeNotifier.firstDayOfMonth;
      await categoryRepository.updateCategory(event.category);
      final dateRange = CustomDateTimeRange.getExactOneMonthRange(
          selectedFirstDay: firstDayOfMonth, minDate: DateTime.now());
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      final firstDayOfMonth = financeNotifier.firstDayOfMonth;

      await categoryRepository.deleteCategory(event.id);
      final dateRange = CustomDateTimeRange.getExactOneMonthRange(
          selectedFirstDay: firstDayOfMonth, minDate: DateTime.now());
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
          'icon': availableIcons.indexOf(Icons.fastfood),
          'description': event.localizations.categoryFoodDescription,
          'is_income': 0,
        },
        {
          'id': 2,
          'name': event.localizations.categoryEntertainment,
          'icon': availableIcons.indexOf(Icons.movie),
          'description': event.localizations.categoryEntertainmentDescription,
          'is_income': 0,
        },
        {
          'id': 3,
          'name': event.localizations.categorySalary,
          'icon': availableIcons.indexOf(Icons.attach_money),
          'description': event.localizations.categorySalaryDescription,
          'is_income': 1,
        },
        {
          'id': 4,
          'name': event.localizations.categoryHealth,
          'icon': availableIcons.indexOf(Icons.health_and_safety),
          'description': event.localizations.categoryHealthDescription,
          'is_income': 0,
        },
        {
          'id': 5,
          'name': event.localizations.categoryTravel,
          'icon': availableIcons.indexOf(Icons.flight),
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
      final firstDayOfMonth = financeNotifier.firstDayOfMonth;

      final dateRange = CustomDateTimeRange.getExactOneMonthRange(
          selectedFirstDay: firstDayOfMonth, minDate: DateTime.now());
      add(LoadCategoriesWithSpentAmounts(dateRange));
    } catch (e) {
      emit(CategoryError('Failed to update localized categories'));
    }
  }
}
