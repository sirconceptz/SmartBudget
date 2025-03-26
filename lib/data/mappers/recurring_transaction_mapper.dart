import '../../models/recurring_transaction.dart';

class RecurringTransactionMapper {
  static Map<String, dynamic> toEntity(RecurringTransaction transaction) {
    return {
      'id': transaction.id,
      'isExpense': transaction.isExpense ? 1 : 0,
      'amount': transaction.amount,
      'category_id': transaction.categoryId,
      'currency': transaction.currency,
      'start_date': transaction.startDate.toIso8601String(),
      'repeat_interval': transaction.repeatInterval,
      'repeat_count': transaction.repeatCount,
      'description': transaction.description,
    };
  }

  static RecurringTransaction fromEntity(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      isExpense: json['isExpense'] == 1,
      amount: json['amount'],
      categoryId: json['category_id'],
      currency: json['currency'],
      startDate: DateTime.parse(json['start_date']),
      repeatInterval: json['repeat_interval'],
      repeatCount: json['repeat_count'],
      description: json['description'],
    );
  }
}
