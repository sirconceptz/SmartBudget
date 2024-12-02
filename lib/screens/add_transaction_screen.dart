import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../di/notifiers/currency_notifier.dart';
import '../models/transaction.dart';
import '../utils/enums/currency.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Wydatek';
  double? _amount;
  int? _selectedCategoryId;
  String? _description;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _saveTransaction(Currency currentCurrency) async {
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
        type: _type == 'Przychód' ? 1 : 2,
        amount: _amount!,
        categoryId: _selectedCategoryId,
        date: transactionDateTime,
        description: _description,
        currency: currentCurrency,
      );

      context.read<TransactionBloc>().add(AddTransaction(newTransaction));

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                enableFeedback: true,
                value: _type,
                items: ['Przychód', 'Wydatek'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    _selectedCategoryId = null;
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
                        .where((category) => (_type == 'Przychód'
                            ? category.isIncome
                            : !category.isIncome))
                        .toList();

                    return DropdownButtonFormField<int>(
                      enableFeedback: true,
                      value: _selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Kategoria'),
                      validator: (value) =>
                          value == null ? 'Wybierz kategorię' : null,
                    );
                  } else {
                    return Text('Błąd ładowania kategorii');
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kwota',
                  suffixText: currentCurrency.name,
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Podaj prawidłową kwotę';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Opis'),
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
                      Text('Data: ${_selectedDate.toLocal()}'.split(' ')[0]),
                      Text('Godzina: ${_selectedTime.format(context)}'),
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed: _pickDate,
                        child: Text('Wybierz datę'),
                      ),
                      TextButton(
                        onPressed: _pickTime,
                        child: Text('Wybierz godzinę'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveTransaction(currentCurrency),
                child: Text('Zapisz transakcję'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
