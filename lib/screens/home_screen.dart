import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesWithSpentAmountsLoaded) {
            final incomeCategories = state.incomeCategories;
            final expenseCategories = state.expenseCategories;

            return SingleChildScrollView(
              child: Column(
                children: [
                  if (incomeCategories.isNotEmpty)
                    _buildChartSection('Przychody', incomeCategories),
                  if (expenseCategories.isNotEmpty)
                    _buildChartSection('Wydatki', expenseCategories),
                ],
              ),
            );
          } else if (state is CategoryError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Brak wykresów do wyświetlenia.'));
          }
        },
      ),
    );
  }

  Widget _buildChartSection(String title, List categories) {
    final totalBudget = categories.fold<double>(
      0.0,
      (sum, category) => sum + (category.budgetLimit ?? 0.0),
    );

    final totalSpent = categories.fold<double>(
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
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sections: categories.map((category) {
                final percentage = (category.spentAmount ?? 0) /
                    (category.budgetLimit ?? 1) *
                    100;

                return PieChartSectionData(
                  value: category.spentAmount ?? 0,
                  title: '${percentage.toStringAsFixed(1)}%',
                  color: category.isEssential ? Colors.red : Colors.blue,
                  radius: 100,
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Text(
          'Całkowite $title: ${totalSpent.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)} '
          '(${(totalSpent / (totalBudget == 0 ? 1 : totalBudget) * 100).toStringAsFixed(1)}%)',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
