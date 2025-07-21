import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../utils/enums/currency.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late double _amount;
  late String? _description;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  Category? _selectedCategory;
  late Currency _selectedCurrency;

  @override
  void initState() {
    super.initState();

    _amount = widget.transaction.originalAmount;
    _description = widget.transaction.description;
    _selectedDate = widget.transaction.date;
    _selectedTime = TimeOfDay(
      hour: widget.transaction.date.hour,
      minute: widget.transaction.date.minute,
    );
    _selectedCategory = widget.transaction.category;
    _selectedCurrency = widget.transaction.originalCurrency;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      _type = widget.transaction.isExpense == 1
          ? AppLocalizations.of(context)!.income
          : AppLocalizations.of(context)!.expense;
    });
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        isExpense: _type == AppLocalizations.of(context)!.income ? 1 : 2,
        originalAmount: _amount,
        convertedAmount: _amount,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        description: _description,
        category: _selectedCategory!,
        originalCurrency: _selectedCurrency,
      );

      context
          .read<TransactionBloc>()
          .add(UpdateTransaction(updatedTransaction));
      Navigator.pop(context, true);
    }
  }

  void _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTransaction),
        content:
            Text(AppLocalizations.of(context)!.deleteTransactionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<TransactionBloc>()
                  .add(DeleteTransaction(widget.transaction.id!));
              Navigator.pop(context, true);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
    if (pickedDate != null) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editTransaction),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
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
              SizedBox(height: 16),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return CircularProgressIndicator();
                  } else if (state is CategoriesWithSpentAmountsLoaded) {
                    final categories = state.allCategories
                        .where((category) =>
                            _type == AppLocalizations.of(context)!.income
                                ? category.isIncome
                                : !category.isIncome)
                        .toList();

                    final selectedCategory = categories.firstWhereOrNull(
                      (category) =>
                          category.id == widget.transaction.category!.id,
                    );

                    return DropdownButtonFormField<Category>(
                      value: selectedCategory,
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
              SizedBox(height: 16),
              TextFormField(
                initialValue: _amount.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  suffixText: _selectedCurrency.sign,
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
              SizedBox(height: 16),
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                items: Currency.values.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(
                        currency.localizedName(AppLocalizations.of(context)!)),
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
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                ),
                onSaved: (value) {
                  _description = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${AppLocalizations.of(context)!.date}: ${_selectedDate.toLocal()}'
                              .split(' ')[0], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      Text(
                          '${AppLocalizations.of(context)!.time}: ${_selectedTime.format(context)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed: _pickDate,
                        child: Text(AppLocalizations.of(context)!.chooseDate),
                      ),
                      TextButton(
                        onPressed: _pickTime,
                        child: Text(AppLocalizations.of(context)!.chooseTime),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(AppLocalizations.of(context)!.saveChanges),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _deleteTransaction,
                icon: Icon(Icons.delete),
                label: Text(AppLocalizations.of(context)!.deleteTransaction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
