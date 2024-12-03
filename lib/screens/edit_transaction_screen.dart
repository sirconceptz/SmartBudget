import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../models/transaction.dart';

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

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type == 1
        ? AppLocalizations.of(context)!.income
        : AppLocalizations.of(context)!.expense;
    _amount = widget.transaction.amount;
    _description = widget.transaction.description;
    _selectedDate = widget.transaction.date;
    _selectedTime = TimeOfDay(
      hour: widget.transaction.date.hour,
      minute: widget.transaction.date.minute,
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTransaction = Transaction(
          id: widget.transaction.id,
          type: _type == 'Przychód' ? 1 : 2,
          amount: _amount,
          date: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
          description: _description,
          currency: widget.transaction.currency);

      context
          .read<TransactionBloc>()
          .add(UpdateTransaction(updatedTransaction));

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
                  });
                },
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.category),
              ),
              TextFormField(
                initialValue: _amount.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.amount),
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
                initialValue: _description,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description),
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
