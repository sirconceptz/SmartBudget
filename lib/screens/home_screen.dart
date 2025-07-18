import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/utils/custom_date_time_range.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/finance_notifier.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/monthly_spent.dart';
import '../utils/enums/currency.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime selectedMonth;
  late int firstDayOfMonth;

  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    firstDayOfMonth =
        Provider.of<FinanceNotifier>(context, listen: false).firstDayOfMonth;

    _loadCategoriesForSelectedMonth();
  }

  List<DateTime> _getAvailableMonthsFromCategories(
      List<Category> incomeCategories, List<Category> expenseCategories) {
    final allCats = [...incomeCategories, ...expenseCategories];

    final monthKeys = <String>{};

    for (final cat in allCats) {
      for (final ms in cat.monthlySpent) {
        if (ms.spentAmount > 0) {
          monthKeys.add(ms.monthKey);
        }
      }
    }

    final parsedMonths = monthKeys.map((key) => _parseMonthKey(key)).toList();
    parsedMonths.sort((a, b) => b.compareTo(a));
    return parsedMonths;
  }

  DateTime _parseMonthKey(String monthKey) {
    final parts = monthKey.split('-');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(y, m, 1);
  }

  void _loadCategoriesForSelectedMonth() {
    final dateRange = _getCustomMonthRange(selectedMonth, firstDayOfMonth);
    context.read<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
  }

  DateTimeRange _getCustomMonthRange(DateTime month, int firstDay) {
    final start = DateTime(month.year, month.month, firstDay);
    final nextMonth = DateTime(month.year, month.month + 1, firstDay);
    final end = nextMonth.subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoriesForMonthLoaded) {
          final newAvailableMonths = _getAvailableMonthsFromCategories(
            state.incomeCategories,
            state.expenseCategories,
          );

          if (!listEquals(_availableMonths, newAvailableMonths)) {
            setState(() {
              _availableMonths = newAvailableMonths;
            });
          }

          if (!_availableMonths.contains(selectedMonth) &&
              _availableMonths.isNotEmpty) {
            setState(() {
              selectedMonth = _availableMonths.first;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildMonthDropdown(),
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoriesForMonthLoaded) {
              final incomeCategories = state.incomeCategories;
              final expenseCategories = state.expenseCategories;

              final budgetIncomes = state.budgetIncomes;
              final budgetExpenses = state.budgetExpenses;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (incomeCategories.isNotEmpty)
                      _buildChartSection(
                        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                        title: AppLocalizations.of(context)!.incomes,
                        categories: incomeCategories,
                        totalSpent: state.totalIncomes,
                        totalBudget: budgetIncomes,
                      ),
                    if (expenseCategories.isNotEmpty)
                      _buildChartSection(
                        key:
                            ValueKey(DateTime.now().millisecondsSinceEpoch + 2),
                        title: AppLocalizations.of(context)!.expenses,
                        categories: expenseCategories,
                        totalSpent: state.totalExpenses,
                        totalBudget: budgetExpenses,
                      ),
                    if (incomeCategories.isEmpty && expenseCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.noChartsToDisplay,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else if (state is CategoryError) {
              return Center(child: Text(state.message));
            } else {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.noChartsToDisplay,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    if (_availableMonths.isEmpty) {
      return Text(AppLocalizations.of(context)!.incomes);
    }

    return DropdownButton<DateTime>(
      value: selectedMonth,
      icon: const Icon(Icons.arrow_drop_down),
      items: _availableMonths.map((monthDate) {
        final formattedMonth = DateFormat.yMMMM('pl_PL').format(monthDate);
        return DropdownMenuItem<DateTime>(
          value: monthDate,
          child: Text(formattedMonth),
        );
      }).toList(),
      onChanged: (newMonth) {
        if (newMonth != null) {
          setState(() {
            selectedMonth = newMonth;
          });
          _loadCategoriesForSelectedMonth();
        }
      },
    );
  }

  Widget _buildChartSection({
    required String title,
    required List<Category> categories,
    required double totalSpent,
    required double totalBudget,
    required Key key,
  }) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context)!.noChartsToDisplay,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    final totalSpentThisMonth = categories.fold<double>(
      0.0,
      (sum, cat) =>
          sum + _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth),
    );

    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildChartTitle(AppLocalizations.of(context)!.budgetDistribution),
        _buildBudgetPieChart(categories, totalBudget),
        _buildLegend(categories, isBudget: true),
        const SizedBox(height: 16),
        _buildChartTitle(AppLocalizations.of(context)!.budgetUsage),
        _buildUsagePieChart(categories),
        _buildLegend(categories, isBudget: false),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CurrencyNotifier>(
            builder: (ctx, currencyNotifier, _) {
              final currency = currencyNotifier.currency;

              // Poprawione liczenie totalBudget
              final totalBudget = categories.fold<double>(0.0, (sum, cat) {
                final spent =
                    _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth);
                final budget = cat.convertedBudgetLimit;
                return sum + (budget != null && budget > 0 ? budget : spent);
              });

              final spentFormatted =
                  _formatWithCurrency(totalSpentThisMonth, currency);
              final budgetFormatted =
                  _formatWithCurrency(totalBudget, currency);

              final percentage = totalBudget == 0
                  ? 0.0
                  : (totalSpentThisMonth / totalBudget) * 100.0;

              return Text(
                '${AppLocalizations.of(context)!.total} $title: '
                '$spentFormatted / $budgetFormatted '
                '(${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildChartTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBudgetPieChart(List<Category> categories, double totalBudget) {
    final currency =
        Provider.of<CurrencyNotifier>(context, listen: true).currency;

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            final catBudget = cat.convertedBudgetLimit ?? 0;
            final budgetShare =
                (catBudget / (totalBudget == 0 ? 1 : totalBudget)) * 100;

            final budgetAmountFormatted = _formatWithCurrency(
              catBudget,
              currency,
            );

            return PieChartSectionData(
              value: budgetShare,
              title:
                  '$budgetAmountFormatted\n(${budgetShare.toStringAsFixed(2)}%)',
              color: Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length],
              radius: 60,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildUsagePieChart(List<Category> categories) {
    final currency =
        Provider.of<CurrencyNotifier>(context, listen: true).currency;

    final totalSpent = categories.fold<double>(0.0, (sum, cat) {
      final spent = _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth);
      return sum + spent;
    });

    final pieChartData = PieChartData(
      sections: categories.map((cat) {
        final spent =
            _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth);
        final percentageOfTotal =
            totalSpent == 0 ? 0.0 : (spent / totalSpent) * 100.0;

        final spentFormatted = _formatWithCurrency(spent, currency);

        return PieChartSectionData(
          value: percentageOfTotal.toDouble(),
          title: '$spentFormatted\n(${percentageOfTotal.toStringAsFixed(1)}%)',
          color: Colors
              .primaries[categories.indexOf(cat) % Colors.primaries.length],
          radius: 60,
        );
      }).toList(),
      centerSpaceRadius: 40,
      sectionsSpace: 2,
    );

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        pieChartData,
      ),
    );
  }

  Widget _buildLegend(List<Category> categories, {required bool isBudget}) {
    return Consumer<CurrencyNotifier>(
      builder: (context, currencyNotifier, child) {
        final currency = currencyNotifier.currency;

        final totalSpent = categories.fold<double>(0.0, (sum, cat) {
          final spent =
              _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth);
          return sum + spent;
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              final color = Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length];

              if (isBudget) {
                final budget = cat.convertedBudgetLimit ?? 0.0;
                final formattedBudget = _formatWithCurrency(budget, currency);
                return _buildLegendRow(color, cat.name, formattedBudget);
              } else {
                final spent =
                    _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth);
                final spentFormatted = _formatWithCurrency(spent, currency);

                final percentageOfTotal =
                    totalSpent == 0.0 ? 0.0 : (spent / totalSpent) * 100.0;
                final usageText = '${percentageOfTotal.toStringAsFixed(1)}%';

                final legendValue = '$spentFormatted ($usageText)';

                return _buildLegendRow(color, cat.name, legendValue);
              }
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLegendRow(Color color, String categoryName, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$categoryName: $value',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Future<void> generateMonthlyReport({
    required BuildContext context,
    required DateTime selectedMonth,
    required List<Category> incomeCategories,
    required List<Category> expenseCategories,
    required double totalIncomes,
    required double totalExpenses,
  }) async {}

  double _spentInSelectedMonth(
    Category cat,
    DateTime selectedMonth,
    int firstDayOfMonth,
  ) {
    final monthKey = _computeCustomMonthKey(selectedMonth, firstDayOfMonth);
    final match = cat.monthlySpent.firstWhere(
      (ms) => ms.monthKey == monthKey,
      orElse: () => MonthlySpent(monthKey: monthKey, spentAmount: 0.0),
    );
    return match.spentAmount;
  }

  String _computeCustomMonthKey(DateTime month, int firstDayOfMonth) {
    final y = month.year;
    final m = month.month;
    return CustomDateTimeRange.formatYearMonth(y, m);
  }

  String _formatWithCurrency(double amount, Currency currency) {
    final formatted = amount.toStringAsFixed(2);

    if (currency.isLeftSigned) {
      return '${currency.sign}$formatted';
    } else {
      return '$formatted ${currency.sign}';
    }
  }
}
