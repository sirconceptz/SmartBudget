import '../utils/enums/currency.dart';
import 'category.dart';

class Transaction {
  final int? id;
  final int isExpense;
  final double originalAmount;
  final double convertedAmount;
  final DateTime date;
  final String? description;
  final Currency originalCurrency;
  final Category? category;

  Transaction({
    this.id,
    required this.isExpense,
    required this.originalAmount,
    required this.convertedAmount,
    required this.date,
    this.description,
    required this.originalCurrency,
    required this.category,
  });

  Transaction copyWith({
    int? id,
    int? isExpense,
    double? originalAmount,
    double? convertedAmount,
    DateTime? date,
    String? description,
    Currency? originalCurrency,
    Category? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      isExpense: isExpense ?? this.isExpense,
      originalAmount: originalAmount ?? this.originalAmount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      date: date ?? this.date,
      description: description ?? this.description,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      category: category ?? this.category,
    );
  }
}
