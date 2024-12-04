import '../utils/enums/currency.dart';

class Transaction {
  final int? id;
  final int type;
  final double originalAmount;
  final double convertedAmount;
  final int? categoryId;
  final DateTime date;
  final String? description;
  final Currency originalCurrency;
  final int? categoryIcon;

  Transaction({
    this.id,
    required this.type,
    required this.originalAmount,
    required this.convertedAmount,
    this.categoryId,
    required this.date,
    this.description,
    required this.originalCurrency,
    this.categoryIcon,
  });

  Transaction copyWith({
    int? id,
    int? type,
    double? originalAmount,
    double? convertedAmount,
    int? categoryId,
    DateTime? date,
    String? description,
    Currency? originalCurrency,
    int? categoryIcon,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      originalAmount: originalAmount ?? this.originalAmount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
