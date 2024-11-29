import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Expense'; // Default type
  double? _amount;
  String? _description;
  DateTime _selectedDate = DateTime.now();

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('Transaction Saved: $_type, $_amount, $_description, $_selectedDate');

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
              // Transaction Type Dropdown
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
              // Amount Input
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
              // Description Input
              TextFormField(
                decoration: InputDecoration(labelText: 'Opis'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              // Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Data: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Wybierz datę'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Save Button
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
