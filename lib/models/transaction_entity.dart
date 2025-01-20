import '../utils/enums/currency.dart';

class TransactionEntity {
  final int? id;
  final int isExpense;
  final double amount;
  final int? categoryId;
  final DateTime date;
  final String? description;
  final Currency currency;

  TransactionEntity({
    this.id,
    required this.isExpense,
    required this.amount,
    this.categoryId,
    required this.date,
    this.description,
    required this.currency,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'],
      isExpense: json['isExpense'],
      amount: json['amount'].toDouble(),
      categoryId: json['category_id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      currency: CurrencyExtension.fromString(json['currency']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isExpense': isExpense,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'description': description,
      'currency': currency.value,
    };
  }
}
