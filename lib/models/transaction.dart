import '../utils/enums/currency.dart';

class Transaction {
  final int? id;
  final int type;
  final double amount;
  final int? categoryId;
  final DateTime date;
  final String? description;
  final Currency currency;

  Transaction(
      {this.id,
      required this.type,
      required this.amount,
      this.categoryId,
      required this.date,
      this.description,
      required this.currency});

  Transaction copyWith(
      {int? id,
      int? type,
      double? amount,
      int? categoryId,
      DateTime? date,
      String? description,
      Currency? currency}) {
    return Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        description: description ?? this.description,
        currency: currency ?? this.currency);
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json['id'],
        type: json['type'],
        amount: json['amount'].toDouble(),
        categoryId: json['category_id'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        currency: CurrencyExtension.fromString(json['currency']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'description': description,
      'currency': currency.value
    };
  }
}
