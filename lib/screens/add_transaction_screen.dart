import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_block/transaction_bloc.dart';
import '../blocs/transaction_block/transaction_event.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Wydatek';
  double? _amount;
  String? _description;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _saveTransaction() {
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
        type: _type == 'Przychód' ? 1 : 2, // 1 dla przychodu, 2 dla wydatku
        amount: _amount!,
        date: transactionDateTime,
        description: _description,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj transakcję'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
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
                  });
                },
                decoration: InputDecoration(labelText: 'Typ transakcji'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Kwota'),
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
                onPressed: _saveTransaction,
                child: Text('Zapisz transakcję'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
