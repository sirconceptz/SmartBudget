// category_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_type/transaction_type_bloc.dart';
import '../blocs/transaction_type/transaction_type_event.dart';
import '../blocs/transaction_type/transaction_type_state.dart';
import '../models/transaction_type_model.dart';

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a drawer or a button in AppBar to navigate back to MainScreen if needed
      appBar: AppBar(title: Text('Kategorie')),
      body: BlocBuilder<TransactionTypeBloc, TransactionTypeState>(
        builder: (context, state) {
          if (state is TransactionTypesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TransactionTypesLoaded) {
            final categories = state.transactionTypes;

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
                        context.read<TransactionTypeBloc>().add(DeleteTransactionType(category.id!));
                        return true;
                      }
                    }
                    return false;
                  },
                  child: ListTile(
                    title: Text(category.name),
                    subtitle: Text(category.description ?? ''),
                    trailing: Icon(Icons.category),
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
        onPressed: () async {
          await goToAddCategory(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> goToAddCategory(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/addCategory');

    if (result == true) {
      // No need to dispatch LoadTransactionTypes; Bloc handles state updates
    }
  }

  Future<void> goToEditCategory(BuildContext context, TransactionType category) async {
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
