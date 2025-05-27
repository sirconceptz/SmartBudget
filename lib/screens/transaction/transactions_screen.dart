import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/utils/enums/currency.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../utils/toast.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _filterName;
  double? _filterAmountMin;
  double? _filterAmountMax;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  int? _filterCategoryId;

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _openFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _filterName = null;
                _filterAmountMin = null;
                _filterAmountMax = null;
                _filterDateFrom = null;
                _filterDateTo = null;
                _filterCategoryId = null;
              });
              context.read<TransactionBloc>().add(LoadTransactions());
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsLoaded) {
            final transactions = state.transactions;

            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.noTransactions,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            }

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
                    enableFeedback: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: transaction.category?.icon != null
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
                      style: const TextStyle(fontSize: 10),
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
                            fontSize: 12,
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
                              fontSize: 8,
                            ),
                          ),
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
              Toast.show(context,
                  AppLocalizations.of(context)!.pleaseAddCategoriesFirst);
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

  Future<void> _openFilterDialog(BuildContext ctx) async {
    final catState = ctx.read<CategoryBloc>().state;
    List<Category> allCats = [];
    if (catState is CategoriesWithSpentAmountsLoaded) {
      allCats = catState.allCategories;
    }

    String? tmpName = _filterName;
    double? tmpAmountMin = _filterAmountMin;
    double? tmpAmountMax = _filterAmountMax;
    DateTime? tmpDateFrom = _filterDateFrom;
    DateTime? tmpDateTo = _filterDateTo;
    int? tmpCategoryId = _filterCategoryId;

    await showDialog(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.filterTransactionsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.name,
                  ),
                  controller: TextEditingController(text: tmpName ?? ""),
                  onChanged: (value) {
                    tmpName = value.isEmpty ? null : value;
                  },
                ),
                if (allCats.isNotEmpty)
                  DropdownButtonFormField<int?>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx)!.category,
                    ),
                    value: tmpCategoryId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('-- Brak --'),
                      ),
                      ...allCats.map((cat) => DropdownMenuItem<int?>(
                            value: cat.id,
                            child: Text(cat.name),
                          ))
                    ],
                    onChanged: (value) {
                      tmpCategoryId = value;
                    },
                  ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx)!.amountFrom),
                  controller: TextEditingController(
                    text: tmpAmountMin?.toString() ?? "",
                  ),
                  onChanged: (value) {
                    tmpAmountMin =
                        (value.isEmpty) ? null : double.tryParse(value);
                  },
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx)!.amountTo),
                  controller: TextEditingController(
                    text: tmpAmountMax?.toString() ?? "",
                  ),
                  onChanged: (value) {
                    tmpAmountMax =
                        (value.isEmpty) ? null : double.tryParse(value);
                  },
                ),
                Row(
                  children: [
                    Text(tmpDateFrom != null
                        ? DateFormat.yMd('pl_PL').format(tmpDateFrom!)
                        : AppLocalizations.of(ctx)!.dateFrom),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogCtx,
                          initialDate: tmpDateFrom ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateIfMounted(() {
                            tmpDateFrom = picked;
                          }, dialogCtx);
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(tmpDateTo != null
                        ? DateFormat.yMd('pl_PL').format(tmpDateTo!)
                        : AppLocalizations.of(ctx)!.dateTo),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogCtx,
                          initialDate: tmpDateTo ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateIfMounted(() {
                            tmpDateTo = picked;
                          }, dialogCtx);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
              },
              child: Text(AppLocalizations.of(ctx)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterName = tmpName;
                  _filterCategoryId = tmpCategoryId;
                  _filterAmountMin = tmpAmountMin;
                  _filterAmountMax = tmpAmountMax;
                  _filterDateFrom = tmpDateFrom;
                  _filterDateTo = tmpDateTo;
                });

                Navigator.of(dialogCtx).pop();

                context.read<TransactionBloc>().add(
                      FilterTransactions(
                        name: _filterName,
                        categoryId: _filterCategoryId,
                        amountMin: _filterAmountMin,
                        amountMax: _filterAmountMax,
                        dateFrom: _filterDateFrom,
                        dateTo: _filterDateTo,
                      ),
                    );
              },
              child: Text(AppLocalizations.of(ctx)!.search),
            ),
          ],
        );
      },
    );
  }

  void setStateIfMounted(VoidCallback fn, BuildContext dialogContext) {
    if (mounted && dialogContext == context) {
      setState(fn);
    } else {
      fn();
    }
  }
}
