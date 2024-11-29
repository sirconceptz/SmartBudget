import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_block/transaction_bloc.dart';
import '../data/di.dart';
import '../data/repositories/transaction_repository.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(getIt<TransactionRepository>())..add(LoadTransactions()),
      child: Scaffold(
        appBar: AppBar(title: Text('Budget Manager')),
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
                  return ListTile(
                    title: Text(transaction.description ?? 'No description'),
                    subtitle: Text(transaction.date.toIso8601String()),
                    trailing: Text(transaction.amount.toStringAsFixed(2)),
                  );
                },
              );
            } else {
              return Center(child: Text('Error loading transactions'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add transaction functionality
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
