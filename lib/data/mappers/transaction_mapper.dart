import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../models/transaction_entity.dart';

class TransactionMapper {
  static Transaction mapFromEntity(
    TransactionEntity entity,
    double rateToUserCurrency,
      Category category
  ) {
    return Transaction(
      id: entity.id,
      type: entity.type,
      originalAmount: entity.amount,
      convertedAmount: entity.amount * rateToUserCurrency,
      category: category,
      date: entity.date,
      description: entity.description,
      originalCurrency: entity.currency,
    );
  }

  static TransactionEntity toEntity(Transaction transaction) {
    return TransactionEntity(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.originalAmount,
      date: transaction.date,
      description: transaction.description,
      currency: transaction.originalCurrency,
      categoryId: transaction.category.id
    );
  }
}
