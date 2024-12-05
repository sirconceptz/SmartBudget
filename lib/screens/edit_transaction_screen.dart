import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../utils/enums/currency.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
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
    _type = widget.transaction.type == 1
        ? AppLocalizations.of(context)!.income
        : AppLocalizations.of(context)!.expense;
    _amount = widget.transaction.originalAmount;
    _description = widget.transaction.description;
    _selectedDate = widget.transaction.date;
    _selectedTime = TimeOfDay(
      hour: widget.transaction.date.hour,
      minute: widget.transaction.date.minute,
    );
    _selectedCurrency = widget.transaction.originalCurrency;
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        type: _type == AppLocalizations.of(context)!.income ? 1 : 2,
        originalAmount: _amount,
        convertedAmount: _amount, // Możesz dodać logikę przeliczenia waluty
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

      context.read<TransactionBloc>().add(UpdateTransaction(updatedTransaction));
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
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return CircularProgressIndicator();
                  } else if (state is CategoriesLoaded) {
                    final categories = state.categories
                        .where((category) =>
                    (_type == AppLocalizations.of(context)!.income
                        ? category.isIncome
                        : !category.isIncome))
                        .toList();

                    return DropdownButtonFormField<Category>(
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
                          labelText: AppLocalizations.of(context)!.category),
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
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                items: Currency.values.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency.localizedName(AppLocalizations.of(context)!)),
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
                              .split(' ')[0]),
                      Text(
                          '${AppLocalizations.of(context)!.time}: ${_selectedTime.format(context)}'),
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
            ],
          ),
        ),
      ),
    );
  }
}
