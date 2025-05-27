import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../models/recurring_transaction.dart';
import '../../models/transaction.dart';
import '../../utils/enums/currency.dart';
import '../../utils/enums/repeat_interval.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type = AppLocalizations.of(context)!.expense;
  double? _amount;
  Category? _selectedCategory;
  String? _description;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Currency? _selectedCurrency;
  bool isRecurringTransaction = false;
  RepeatInterval? _repeatInterval;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _type = AppLocalizations.of(context)!.expense;
      });
    });

    _selectedCurrency =
        Provider.of<CurrencyNotifier>(context, listen: false).currency;
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transactionDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newTransaction = Transaction(
        isExpense: _type == AppLocalizations.of(context)!.income ? 1 : 2,
        originalAmount: _amount!,
        convertedAmount: _amount!,
        category: _selectedCategory!,
        date: transactionDateTime,
        description: _description,
        originalCurrency: _selectedCurrency!,
      );

      context.read<TransactionBloc>().add(AddTransaction(newTransaction));

      if (isRecurringTransaction) {
        final recurringTransaction = RecurringTransaction(
          isExpense:
              _type == AppLocalizations.of(context)!.income ? false : true,
          amount: _amount!,
          categoryId: _selectedCategory!.id!,
          startDate: transactionDateTime,
          description: _description,
          currency: _selectedCurrency!,
          repeatInterval: _repeatInterval!.name,
        );

        context
            .read<TransactionBloc>()
            .add(AddRecurringTransaction(recurringTransaction));
      }

      Navigator.pop(context, true);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addTransaction),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  enableFeedback: true,
                  value: _type,
                  items: [
                    AppLocalizations.of(context)!.income,
                    AppLocalizations.of(context)!.expense
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                      _selectedCategory = null;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Typ transakcji'),
                ),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is CategoriesWithSpentAmountsLoaded) {
                      final categories = state.allCategories
                          .where((category) =>
                              (_type == AppLocalizations.of(context)!.income
                                  ? category.isIncome
                                  : !category.isIncome))
                          .toList();

                      return DropdownButtonFormField<Category>(
                        enableFeedback: true,
                        value: _selectedCategory,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.category,
                        ),
                        validator: (value) => value == null
                            ? AppLocalizations.of(context)!.chooseCategory
                            : null,
                      );
                    } else {
                      return Text(AppLocalizations.of(context)!
                          .errorWhileLoadingCategories);
                    }
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.amount,
                    suffixText: currentCurrency.name,
                  ),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return AppLocalizations.of(context)!.giveCorrectAmount;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _amount = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                  ),
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                DropdownButtonFormField<Currency>(
                  value: _selectedCurrency,
                  items: Currency.values.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(
                        currency.localizedName(
                          AppLocalizations.of(context)!,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.currency,
                  ),
                ),
                CheckboxListTile(
                    value: isRecurringTransaction,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          isRecurringTransaction = newValue;
                        });
                      }
                    }),
                if (isRecurringTransaction) ...[
                  DropdownButtonFormField<RepeatInterval>(
                    value: _repeatInterval,
                    items: RepeatInterval.values.map((interval) {
                      return DropdownMenuItem(
                        value: interval,
                        child: Text(interval.localizedName(context)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _repeatInterval = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.repeatInterval,
                    ),
                  )
                ],
                const SizedBox(height: 20),
                Table(
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text('${AppLocalizations.of(context)!.date}: ',
                            style: TextStyle(fontSize: 16)),
                        Text(
                          DateFormat.yMd("pl_PL").format(_selectedDate),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _pickDate,
                          child: Text(AppLocalizations.of(context)!.chooseDate),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('${AppLocalizations.of(context)!.time}: ',
                            style: TextStyle(fontSize: 16)),
                        Text(_selectedTime.format(context),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: _pickTime,
                          child: Text(AppLocalizations.of(context)!.chooseTime),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _selectedCurrency != null ? _saveTransaction : null,
                  child: Text(AppLocalizations.of(context)!.saveTransaction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
