import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../di/notifiers/currency_notifier.dart';
import '../models/category.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({required this.category});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double? _budgetLimit;
  late String? _description;
  late int? _icon;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _name = widget.category.name;
    _description = widget.category.description;
    _icon = widget.category.icon;
    _isIncome = widget.category.isIncome;
    _budgetLimit = widget.category.budgetLimit;
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedCategory = Category(
          id: widget.category.id,
          name: _name,
          description: _description,
          icon: _icon,
          isIncome: _isIncome,
          budgetLimit: _budgetLimit);

      context.read<CategoryBloc>().add(UpdateCategory(updatedCategory));

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final currentCurrency = currencyNotifier.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editCategory),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.giveCategoryName;
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
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
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.budgetLimit,
                  suffixText: currentCurrency.name,
                ),
                onSaved: (value) {
                  _budgetLimit = double.tryParse(value!);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.expenses),
                  Switch(
                    value: _isIncome,
                    onChanged: (value) {
                      setState(() {
                        _isIncome = value;
                      });
                    },
                  ),
                  Text(AppLocalizations.of(context)!.incomes),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text(AppLocalizations.of(context)!.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
