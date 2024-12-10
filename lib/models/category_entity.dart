import '../utils/enums/currency.dart';

class CategoryEntity {
  final int? id;
  final String name;
  final String description;
  final int? icon;
  double? budgetLimit;
  double? spentAmount;
  final bool isIncome;
  final Currency currency;

  CategoryEntity({
    this.id,
    required this.name,
    required this.description,
    this.icon,
    this.budgetLimit,
    this.spentAmount,
    required this.isIncome,
    required this.currency,
  });

  CategoryEntity copyWith(
      {int? id,
      String? name,
      String? description,
      int? icon,
      double? budgetLimit,
      double? spentAmount,
      bool? isIncome,
      Currency? currency}) {
    return CategoryEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        budgetLimit: budgetLimit ?? this.budgetLimit,
        spentAmount: spentAmount ?? this.spentAmount,
        isIncome: isIncome ?? this.isIncome,
        currency: currency ?? this.currency);
  }

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        isIncome: json['is_income'] == 1,
        spentAmount: json['spent_amount'],
        budgetLimit: json['budget_limit'],
        currency: CurrencyExtension.fromString(json['currency']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_income': isIncome ? 1 : 0,
      'budget_limit': budgetLimit,
      'currency': currency.value
    };
  }
}
