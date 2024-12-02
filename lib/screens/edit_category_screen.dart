// edit_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_type/transaction_type_bloc.dart';
import '../blocs/transaction_type/transaction_type_event.dart';
import '../models/transaction_type_model.dart';

class EditCategoryScreen extends StatefulWidget {
  final TransactionType category;

  EditCategoryScreen({required this.category});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _description;
  late String? _icon;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _name = widget.category.name;
    _description = widget.category.description;
    _icon = widget.category.icon;
    _isIncome = widget.category.isIncome;
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedCategory = TransactionType(
        id: widget.category.id,
        name: _name,
        description: _description,
        icon: _icon,
        isIncome: _isIncome,
      );

      context.read<TransactionTypeBloc>().add(UpdateTransactionType(updatedCategory));

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edytuj kategorię'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nazwa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj nazwę kategorii';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Opis'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              // Add an icon picker if desired
              SwitchListTile(
                title: Text('Przychód'),
                value: _isIncome,
                onChanged: (value) {
                  setState(() {
                    _isIncome = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text('Zapisz zmiany'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
