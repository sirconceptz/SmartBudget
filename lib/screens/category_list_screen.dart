import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../models/category.dart';

class CategoryListScreen extends StatelessWidget {
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
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Usuń kategorię'),
                            content: Text('Czy na pewno chcesz usunąć tę kategorię?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Anuluj'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Usuń'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        context.read<CategoryBloc>().add(DeleteCategory(category.id!));
                        return true;
                      }
                    }
                    return false;
                  },
                  child: Card(
                    color: category.isIncome ? Colors.green : Colors.red,
                    child: ListTile(
                      title: Text(category.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                      subtitle: Text(category.description ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                      trailing: Icon(Icons.category),
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
    final result = await Navigator.pushNamed(
      context,
      '/editCategory',
      arguments: category,
    );

    if (result == true) {
      // No need to dispatch LoadTransactionTypes; Bloc handles state updates
    }
  }
}
