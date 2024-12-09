import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../di/notifiers/finance_notifier.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  late DateTime selectedMonth;
  late int firstDayOfMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    firstDayOfMonth = Provider.of<FinanceNotifier>(context, listen: false).firstDayOfMonth;
  }

  List<DateTime> _getPreviousMonths(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
          (index) => DateTime(now.year, now.month - index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = _getPreviousMonths(12);

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<DateTime>(
          value: selectedMonth,
          icon: const Icon(Icons.arrow_drop_down),
          items: months.map((month) {
            final formattedMonth = DateFormat.yMMMM('pl_PL').format(month);
            return DropdownMenuItem<DateTime>(
              value: month,
              child: Text(formattedMonth),
            );
          }).toList(),
          onChanged: (newMonth) {
            if (newMonth != null) {
              setState(() {
                selectedMonth = newMonth;
              });
            }
          },
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesWithSpentAmountsLoaded) {
            final incomeCategories = state.incomeCategories;
            final expenseCategories = state.expenseCategories;

            final dateRange = getMonthRange(selectedMonth, firstDayOfMonth);

            return SingleChildScrollView(
              child: Column(
                children: [
                  if (incomeCategories.isNotEmpty)
                    _buildChartSection(
                      AppLocalizations.of(context)!.incomes,
                      incomeCategories,
                      context,
                      dateRange,
                    ),
                  if (expenseCategories.isNotEmpty)
                    _buildChartSection(
                      AppLocalizations.of(context)!.expenses,
                      expenseCategories,
                      context,
                      dateRange,
                    ),
                ],
              ),
            );
          } else if (state is CategoryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(
              child: Text(
                '${AppLocalizations.of(context)!.noChartsToDisplay}.',
              ),
            );
          }
        },
      ),
    );
  }

  DateTimeRange getMonthRange(DateTime selectedMonth, int firstDayOfMonth) {
    final start = DateTime(selectedMonth.year, selectedMonth.month, firstDayOfMonth);
    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    final end = DateTime(nextMonth.year, nextMonth.month, firstDayOfMonth - 1, 23, 59, 59);

    return DateTimeRange(start: start, end: end);
  }

  Widget _buildChartSection(String title, List<Category> categories, BuildContext context,
      DateTimeRange dateRange) {
    final filteredCategories = categories.where((category) {
      return category.transactions.any((transaction) {
        final transactionDate = transaction.date;
        return transactionDate.isAfter(dateRange.start) &&
            transactionDate.isBefore(dateRange.end);
      });
    }).toList();

    for (var category in filteredCategories) {
      category.spentAmount = category.transactions.fold<double>(
        0.0,
            (sum, transaction) {
          final transactionDate = transaction.date;
          if (transactionDate.isAfter(dateRange.start) &&
              transactionDate.isBefore(dateRange.end)) {
            return sum + transaction.amount;
          }
          return sum;
        },
      );
    }

    final totalBudget = filteredCategories.fold<double>(
      0.0,
          (sum, category) => sum + (category.budgetLimit ?? 0.0),
    );

    final totalSpent = filteredCategories.fold<double>(
      0.0,
          (sum, category) => sum + (category.spentAmount ?? 0.0),
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
        _buildBudgetPieChart(filteredCategories, totalBudget),
        _buildLegend(filteredCategories, isBudget: true),
        const SizedBox(height: 16),
        _buildChartTitle(AppLocalizations.of(context)!.budgetUsage),
        _buildUsagePieChart(filteredCategories),
        _buildLegend(filteredCategories, isBudget: false),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${AppLocalizations.of(context)!.total} $title: ${totalSpent.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)} '
                '(${(totalSpent / (totalBudget == 0 ? 1 : totalBudget) * 100).toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 16),
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
  Widget _buildBudgetPieChart(List categories, double totalBudget) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((category) {
            final budgetShare = (category.budgetLimit ?? 0) / (totalBudget == 0 ? 1 : totalBudget) * 100;

            return PieChartSectionData(
              value: category.budgetLimit ?? 0,
              title: '',
              color: Colors.primaries[categories.indexOf(category) % Colors.primaries.length],
              radius: 100,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildUsagePieChart(List categories) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((category) {
            final spent = category.spentAmount ?? 0;
            final budget = category.budgetLimit ?? spent;
            final usagePercentage = (spent / (budget == 0 ? 1 : budget)) * 100;

            return PieChartSectionData(
              value: usagePercentage,
              title: '',
              color: Colors.primaries[categories.indexOf(category) % Colors.primaries.length],
              radius: 100,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildLegend(List categories, {required bool isBudget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((category) {
          final color = Colors.primaries[categories.indexOf(category) %
              Colors.primaries.length];
          final value = isBudget
              ? '${(category.budgetLimit ?? 0).toStringAsFixed(2)}'
              : '${((category.spentAmount ?? 0) / (category.budgetLimit ?? 1) *
              100).toStringAsFixed(1)}%';

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
                '${category.name}: $value',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
