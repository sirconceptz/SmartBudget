import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../utils/enums/currency.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double? _budgetLimit;
  late String _description;
  late int? _icon;
  late bool _isIncome;
  late Currency _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _name = widget.category.name;
    _description = widget.category.description;
    _icon = widget.category.icon;
    _isIncome = widget.category.isIncome;
    _budgetLimit = widget.category.budgetLimit;
    _selectedCurrency = widget.category.currency;
  }

  void _saveCategory(Currency currency) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedCategory = Category(
        id: widget.category.id,
        name: _name,
        description: _description,
        icon: _icon,
        isIncome: _isIncome,
        budgetLimit: _budgetLimit,
        currency: _selectedCurrency,
      );

      context.read<CategoryBloc>().add(UpdateCategory(updatedCategory));

      Navigator.pop(context, true);
    }
  }

  void _deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCategory),
        content: Text(AppLocalizations.of(context)!.deleteCategoryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<CategoryBloc>()
                  .add(DeleteCategory(widget.category.id!));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editCategory),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name,
                  border: OutlineInputBorder(),
                ),
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
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _budgetLimit?.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.budgetLimit,
                  border: OutlineInputBorder(),
                  suffixText: _selectedCurrency.sign,
                ),
                onSaved: (value) {
                  _budgetLimit = double.tryParse(value!);
                },
              ),
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
              SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveCategory(_selectedCurrency);
                      },
                      icon: Icon(Icons.save),
                      label: Text(AppLocalizations.of(context)!.saveChanges),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _deleteCategory,
                      icon: Icon(Icons.delete),
                      label: Text(AppLocalizations.of(context)!.deleteCategory),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
