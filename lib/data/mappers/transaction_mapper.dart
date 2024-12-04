import '../../models/transaction.dart';
import '../../models/transaction_entity.dart';

class TransactionMapper {
  static Transaction mapFromEntity(
    TransactionEntity entity,
    double rateToUserCurrency,
    int? categoryIcon,
  ) {
    return Transaction(
      id: entity.id,
      type: entity.type,
      originalAmount: entity.amount,
      convertedAmount: entity.amount * rateToUserCurrency,
      categoryId: entity.categoryId,
      date: entity.date,
      description: entity.description,
      originalCurrency: entity.currency,
      categoryIcon: categoryIcon,
    );
  }

  static TransactionEntity toEntity(Transaction transaction) {
    return TransactionEntity(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.originalAmount,
      categoryId: transaction.categoryId,
      date: transaction.date,
      description: transaction.description,
      currency: transaction.originalCurrency,
    );
  }
}
