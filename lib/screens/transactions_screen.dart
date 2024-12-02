import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_block/transaction_bloc.dart';
import '../blocs/transaction_block/transaction_event.dart';
import '../blocs/transaction_block/transaction_state.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TransactionsLoaded) {
            final transactions = state.transactions;

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Dismissible(
                  key: ValueKey(transaction.id),
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
                      await goToEditTransaction(context, transaction);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Usuń transakcję'),
                            content: Text('Czy na pewno chcesz usunąć tę transakcję?'),
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
                        context.read<TransactionBloc>().add(DeleteTransaction(transaction.id!));
                        return true;
                      }
                    }
                    return false;
                  },
                  child: ListTile(
                    title: Text(transaction.description ?? 'No description'),
                    subtitle: Text(DateFormat.yMMMMd('pl_PL').add_jm().format(transaction.date)),
                    trailing: Text(transaction.amount.toStringAsFixed(2)),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Error loading transactions'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await goToAddTransaction(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> goToAddTransaction(BuildContext context) async {
    await Navigator.pushNamed(context, '/addTransaction');
  }

  Future<void> goToEditTransaction(BuildContext context, Transaction transaction) async {
    await Navigator.pushNamed(
      context,
      '/editTransaction',
      arguments: transaction,
    );
  }
}
