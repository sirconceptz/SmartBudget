import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../models/category.dart';
import '../widgets/confirm_dialog.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                return Dismissible(
                  key: ValueKey(category.id),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await goToEditCategory(context, category);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: AppLocalizations.of(context)!.deleteCategory,
                          content: AppLocalizations.of(context)!
                              .deleteCategoryConfirmation,
                          cancelText: AppLocalizations.of(context)!.cancel,
                          confirmText: AppLocalizations.of(context)!.delete,
                          onConfirm: () {
                            context
                                .read<CategoryBloc>()
                                .add(DeleteCategory(category.id!));
                          },
                        ),
                      );
                      return confirm == true;
                    }
                    return false;
                  },
                  child: Card(
                    color: category.isIncome ? Colors.green : Colors.red,
                    child: ListTile(
                      leading: category.icon != null
                          ? Icon(IconData(category.icon!,
                              fontFamily: 'MaterialIcons'))
                          : Icon(Icons.category),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        category.description ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Error loading categories'));
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
