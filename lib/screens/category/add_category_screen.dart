import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../di/notifiers/currency_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../utils/enums/currency.dart';
import '../../widgets/icon_picker_dialog.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double? _budgetLimit;
  bool _isIncome = false;
  IconData? _selectedIcon;
  Currency? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency =
        Provider.of<CurrencyNotifier>(context, listen: false).currency;
  }

  void _selectIcon() async {
    final selectedIcon = await showDialog<IconData>(
      context: context,
      builder: (context) => IconPickerDialog(),
    );
    if (selectedIcon != null) {
      setState(() {
        _selectedIcon = selectedIcon;
      });
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newCategory = Category(
        name: _name,
        description: _description,
        icon: _selectedIcon?.codePoint,
        isIncome: _isIncome,
        budgetLimit: _budgetLimit,
        currency: _selectedCurrency!,
      );
      context.read<CategoryBloc>().add(AddCategory(newCategory));

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.addCategory),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: _buildFormContent(context),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration:
              InputDecoration(labelText: AppLocalizations.of(context)!.name),
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
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.description),
          onSaved: (value) {
            _description = value!;
          },
        ),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.budgetLimit,
            suffixText: _selectedCurrency?.sign,
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
              child:
                  Text(currency.localizedName(AppLocalizations.of(context)!)),
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
        const SizedBox(
          height: 10,
        ),
        InkWell(
            onTap: _selectIcon,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseIcon,
                  style: TextStyle(fontSize: 16),
                ),
                _selectedIcon != null
                    ? Icon(_selectedIcon)
                    : Icon(Icons.category),
              ],
            )),
        const SizedBox(
          height: 10,
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
          onPressed: _selectedCurrency != null ? _saveCategory : null,
          child: Text(AppLocalizations.of(context)!.saveCategory),
        ),
      ],
    );
  }
}
