import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/utils/enums/currency.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categories)),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CategoriesWithSpentAmountsLoaded) {
            final categories = state.allCategories;

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isIncome = category.isIncome;
                final mainColor = isIncome
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error;
                final iconBg = mainColor.withOpacity(0.08);
                final iconColor = mainColor;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                    elevation: 4,
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () async {
                        await goToEditCategory(context, category);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Kolorowy akcent/ikona
                            CircleAvatar(
                              backgroundColor: iconBg,
                              radius: 26,
                              child: category.icon != null
                                  ? Icon(
                                      IconData(
                                        category.icon!,
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: iconColor,
                                      size: 28,
                                    )
                                  : Icon(Icons.category,
                                      color: iconColor, size: 28),
                            ),
                            const SizedBox(width: 14),
                            // Nazwa i opis
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (category.description.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2, bottom: 6),
                                      child: Text(
                                        category.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      if (category.budgetLimit != null)
                                        Text(
                                          "${AppLocalizations.of(context)!.budgetLimit}: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      if (category.budgetLimit != null)
                                        Text(
                                          category.currency.formatAmount(
                                                  category.budgetLimit) ??
                                              "0.00",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: mainColor,
                                          ),
                                        ),
                                      if (category.budgetLimit !=
                                              category.convertedBudgetLimit &&
                                          category.budgetLimit != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Text(
                                            "(≈${currentCurrency.formatAmount(category.convertedBudgetLimit) ?? ""})",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Strzałka
                            Icon(Icons.chevron_right,
                                color: Colors.grey[400], size: 28),
                          ],
                        ),
                      ),
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
