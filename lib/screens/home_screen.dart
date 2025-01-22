import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/finance_notifier.dart';
import '../models/category.dart';
import '../models/monthly_spent.dart';
import '../utils/enums/currency.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
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
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CategoryBloc, CategoryState>(
          buildWhen: (previous, current) {
            return true;
          },
          builder: (context, state) {
            if (state is CategoriesForMonthLoaded) {
              _availableMonths = _getAvailableMonthsFromCategories(
                state.incomeCategories,
                state.expenseCategories,
              );

              if (_availableMonths.isNotEmpty &&
                  !_availableMonths.contains(selectedMonth)) {
                selectedMonth = _availableMonths.first;
              }

              return DropdownButton<DateTime>(
                value: _availableMonths.contains(selectedMonth)
                    ? selectedMonth
                    : (_availableMonths.isNotEmpty
                        ? _availableMonths.first
                        : null),
                icon: const Icon(Icons.arrow_drop_down),
                items: _availableMonths.map((monthDate) {
                  final formattedMonth =
                      DateFormat.yMMMM('pl_PL').format(monthDate);
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
            } else {
              return Text(AppLocalizations.of(context)!.incomes);
            }
          },
        ),
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
                      title: AppLocalizations.of(context)!.incomes,
                      categories: incomeCategories,
                      totalSpent: state.totalIncomes,
                      totalBudget: budgetIncomes,
                    ),
                  if (expenseCategories.isNotEmpty)
                    _buildChartSection(
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
    );
  }

  Widget _buildChartSection({
    required String title,
    required List<Category> categories,
    required double totalSpent,
    required double totalBudget,
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

              // Formatowanie wydanej kwoty i budżetu z symbolem waluty
              final spentFormatted =
                  _formatWithCurrency(totalSpentThisMonth, currency);
              final budgetFormatted =
                  _formatWithCurrency(totalBudget, currency);

              final percentage =
                  (totalSpentThisMonth / (totalBudget == 0 ? 1 : totalBudget)) *
                      100;

              return Text(
                '${AppLocalizations.of(context)!.total} $title: '
                '$spentFormatted / $budgetFormatted '
                '(${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
        ),
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
        Provider.of<CurrencyNotifier>(context, listen: false).currency;

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            final catBudget = cat.budgetLimit ?? 0;
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
        Provider.of<CurrencyNotifier>(context, listen: false).currency;

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            final spent =
                _spentInSelectedMonth(cat, selectedMonth, firstDayOfMonth);
            final budget = cat.budgetLimit ?? 0;
            final usagePercentage = (spent / (budget == 0 ? 1 : budget)) * 100;

            final spentFormatted = _formatWithCurrency(spent, currency);

            return PieChartSectionData(
              value: usagePercentage,
              title:
                  '$spentFormatted\n(${usagePercentage.toStringAsFixed(2)}%)',
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

  Widget _buildLegend(List<Category> categories, {required bool isBudget}) {
    return Consumer<CurrencyNotifier>(
      builder: (context, currencyNotifier, child) {
        final currency = currencyNotifier.currency;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              final color = Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length];

              if (isBudget) {
                final budget = cat.budgetLimit ?? 0;
                final formattedBudget = _formatWithCurrency(budget, currency);

                return _buildLegendRow(color, cat.name, formattedBudget);
              } else {
                final spent = _spentInSelectedMonth(
                  cat,
                  selectedMonth,
                  firstDayOfMonth,
                );
                final spentFormatted = _formatWithCurrency(spent, currency);

                final budget = cat.budgetLimit ?? 0;
                final usagePct = (spent / (budget == 0 ? 1 : budget)) * 100;
                final usageText = '${usagePct.toStringAsFixed(1)}%';

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
    return _formatYearMonth(y, m);
  }

  String _formatYearMonth(int year, int month) {
    final yy = year.toString().padLeft(4, '0');
    final mm = month.toString().padLeft(2, '0');
    return '$yy-$mm';
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
