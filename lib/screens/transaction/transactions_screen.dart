import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/models/transaction.dart';
import 'package:smart_budget/utils/enums/currency.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../utils/toast.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

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
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: transaction.category!.icon != null
                          ? Icon(
                              IconData(
                                transaction.category!.icon!,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: transaction.isExpense == 1
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            )
                          : Icon(
                              Icons.category,
                              color: transaction.isExpense == 1
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                    ),
                    title: Text(
                      transaction.description ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMMd('pl_PL')
                          .add_jm()
                          .format(transaction.date),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentCurrency
                                  .formatAmount(transaction.convertedAmount) ??
                              "",
                          style: TextStyle(
                            color: transaction.isExpense == 1
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (transaction.originalAmount !=
                            transaction.convertedAmount)
                          Text(
                            "(${transaction.originalCurrency.formatAmount(transaction.originalAmount)})",
                            style: TextStyle(
                              color: transaction.isExpense == 1
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () async {
                            await goToEditTransaction(context, transaction);
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                  AppLocalizations.of(context)!.errorWhileLoadingTransactions),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () async {
          final catState = context.read<CategoryBloc>().state;

          if (catState is CategoriesWithSpentAmountsLoaded) {
            if (catState.allCategories.isEmpty) {
              Toast.show(context, 'Proszę najpierw dodać kategorie');
            } else {
              await Navigator.pushNamed(context, '/addTransaction');
            }
          } else if (catState is CategoryError) {
            Toast.show(context, 'Wystąpił błąd przy ładowaniu kategorii.');
          } else {
            Toast.show(
                context, 'Proszę zaczekać, trwa wczytywanie kategorii...');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> goToEditTransaction(
      BuildContext context, Transaction transaction) async {
    await Navigator.pushNamed(
      context,
      '/editTransaction',
      arguments: transaction,
    );
  }
}
