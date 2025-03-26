import '../utils/enums/currency.dart';

class RecurringTransaction {
  final int? id;
  final bool isExpense;
  final double amount;
  final int categoryId;
  final Currency currency;
  final DateTime startDate;
  final String repeatInterval; // daily, weekly, monthly
  final int? repeatCount;
  final String? description;

  RecurringTransaction({
    this.id,
    required this.isExpense,
    required this.amount,
    required this.categoryId,
    required this.currency,
    required this.startDate,
    required this.repeatInterval,
    this.repeatCount,
    this.description,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      isExpense: json['isExpense'] == 1,
      amount: json['amount'],
      categoryId: json['category_id'],
      currency: CurrencyExtension.fromString(json['currency']),
      startDate: DateTime.parse(json['start_date']),
      repeatInterval: json['repeat_interval'],
      repeatCount: json['repeat_count'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isExpense': isExpense ? 1 : 0,
      'amount': amount,
      'category_id': categoryId,
      'currency': currency.value,
      'start_date': startDate.toIso8601String(),
      'repeat_interval': repeatInterval,
      'repeat_count': repeatCount,
      'description': description,
    };
  }

  RecurringTransaction copyWith({
    int? id,
    bool? isExpense,
    double? amount,
    int? categoryId,
    Currency? currency,
    DateTime? startDate,
    String? repeatInterval,
    int? repeatCount,
    String? description,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      isExpense: isExpense ?? this.isExpense,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      repeatCount: repeatCount ?? this.repeatCount,
      description: description ?? this.description,
    );
  }
}
