import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../di/notifiers/currency_notifier.dart';
import '../models/category.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

    return Scaffold(
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CategoriesLoaded) {
            final categories = state.categories;

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: category.isIncome
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: category.icon != null
                          ? Icon(
                              IconData(category.icon!,
                                  fontFamily: 'MaterialIcons'),
                              color:
                                  category.isIncome ? Colors.green : Colors.red,
                            )
                          : Icon(Icons.category,
                              color: category.isIncome
                                  ? Colors.green
                                  : Colors.red),
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.description ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          category.budgetLimit != null
                              ? category.budgetLimit!.toStringAsFixed(2) +
                                  currentCurrency.sign
                              : "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        )
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () async {
                        await goToEditCategory(context, category);
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                  AppLocalizations.of(context)!.errorWhileLoadingCategories),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories_fab',
        onPressed: () async {
          await goToAddCategory(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> goToAddCategory(BuildContext context) async {
    await Navigator.pushNamed(context, '/addCategory');
  }

  Future<void> goToEditCategory(BuildContext context, Category category) async {
    await Navigator.pushNamed(
      context,
      '/editCategory',
      arguments: category,
    );
  }
}
