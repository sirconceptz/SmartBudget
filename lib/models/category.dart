import 'package:smart_budget/models/transaction_entity.dart';

import '../utils/enums/currency.dart';

class Category {
  final int? id;
  final String name;
  final String description;
  final int? icon;
  double? budgetLimit;
  double? convertedBudgetLimit;
  double? spentAmount;
  double? convertedSpentAmount;
  final bool isIncome;
  final Currency currency;
  List<TransactionEntity> transactions;

  Category({
    this.id,
    required this.name,
    required this.description,
    this.icon,
    this.budgetLimit,
    this.spentAmount,
    this.convertedBudgetLimit,
    this.convertedSpentAmount,
    required this.isIncome,
    required this.currency,
    this.transactions = const [],
  });

  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? icon,
    double? budgetLimit,
    double? convertedBudgetLimit,
    double? spentAmount,
    double? convertedSpentAmount,
    Currency? currency,
    bool? isIncome,
  }) {
    return Category(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        budgetLimit: budgetLimit ?? this.budgetLimit,
        spentAmount: spentAmount ?? this.spentAmount,
        convertedSpentAmount: convertedSpentAmount ?? this.convertedSpentAmount,
        convertedBudgetLimit: convertedBudgetLimit ?? this.convertedBudgetLimit,
        isIncome: isIncome ?? this.isIncome,
        currency: currency ?? this.currency);
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        isIncome: json['is_income'] == 1,
        spentAmount: json['spent_amount'],
        budgetLimit: json['budget_limit'],
        currency: CurrencyExtension.fromString(json['currency']));
  }

  static Category convertMoney(Category category, double rateToUserCurrency) {
    return Category(
      id: category.id,
      name: category.name,
      description: category.description,
      icon: category.icon,
      spentAmount: category.spentAmount != null
          ? category.spentAmount! / rateToUserCurrency
          : null,
      isIncome: category.isIncome,
      budgetLimit: category.budgetLimit,
      convertedBudgetLimit: category.budgetLimit != null
          ? category.budgetLimit! / rateToUserCurrency
          : null,
      currency: category.currency,
    );
  }
}
