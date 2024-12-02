import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../di/notifiers/currency_notifier.dart';
import '../models/category.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _description;
  String? _icon;
  double? _budgetLimit;
  bool _isIncome = false;

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newCategory = Category(
          name: _name,
          description: _description,
          icon: _icon,
          isIncome: _isIncome,
          budgetLimit: _budgetLimit);

      context.read<CategoryBloc>().add(AddCategory(newCategory));

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj kategorię'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
                decoration: InputDecoration(labelText: 'Opis'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Limit budżetu',
                  suffixText: currentCurrency.name,
                ),
                onSaved: (value) {
                  _budgetLimit = double.tryParse(value!);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wydatki'),
                  Switch(
                    value: _isIncome,
                    onChanged: (value) {
                      setState(() {
                        _isIncome = value;
                      });
                    },
                  ),
                  Text('Przychody'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text('Zapisz kategorię'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
