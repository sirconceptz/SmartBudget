import '../utils/enums/currency.dart';
import 'monthly_spent.dart';
import 'transaction_entity.dart';

class Category {
  final int? id;
  final String name;
  final String description;
  final int? icon;
  double? budgetLimit;
  double? convertedBudgetLimit;
  final bool isIncome;
  final Currency currency;
  List<TransactionEntity> transactions;
  List<MonthlySpent> monthlySpent;

  Category({
    this.id,
    required this.name,
    required this.description,
    this.icon,
    this.budgetLimit,
    this.convertedBudgetLimit,
    required this.isIncome,
    required this.currency,
    this.transactions = const [],
    this.monthlySpent = const [],
  });

  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? icon,
    double? budgetLimit,
    double? convertedBudgetLimit,
    bool? isIncome,
    Currency? currency,
    List<TransactionEntity>? transactions,
    List<MonthlySpent>? monthlySpent,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      convertedBudgetLimit: convertedBudgetLimit ?? this.convertedBudgetLimit,
      isIncome: isIncome ?? this.isIncome,
      currency: currency ?? this.currency,
      transactions: transactions ?? this.transactions,
      monthlySpent: monthlySpent ?? this.monthlySpent,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    List<MonthlySpent> monthlySpentList = [];
    if (json['monthlySpent'] != null) {
      final dynamicList = json['monthlySpent'] as List<dynamic>;
      monthlySpentList = dynamicList
          .map((item) => MonthlySpent.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isIncome: json['is_income'] == 1,
      budgetLimit: (json['budget_limit'] ?? json['budgetLimit'])?.toDouble(),
      convertedBudgetLimit:
      (json['convertedBudgetLimit'] ?? 0).toDouble(), // albo null
      currency: CurrencyExtension.fromString(json['currency']),
      monthlySpent: monthlySpentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'budget_limit': budgetLimit,
      'convertedBudgetLimit': convertedBudgetLimit,
      'is_income': isIncome ? 1 : 0,
      'currency': currency.value,
      'monthlySpent': monthlySpent.map((ms) => ms.toJson()).toList(),
    };
  }

  static Category convertMoney(Category category, double rateToUserCurrency) {
    if (rateToUserCurrency == 1.0) {
      return category;
    }

    final updatedMonthlySpent = category.monthlySpent.map((ms) {
      final newAmount = ms.spentAmount * rateToUserCurrency;
      return ms.copyWith(spentAmount: newAmount);
    }).toList();

    final newConvertedBudgetLimit = category.budgetLimit != null
        ? category.budgetLimit! * rateToUserCurrency
        : null;

    return category.copyWith(
      monthlySpent: updatedMonthlySpent,
      convertedBudgetLimit: newConvertedBudgetLimit,
    );
  }
}
