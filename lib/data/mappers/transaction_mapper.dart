import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../models/transaction_entity.dart';

class TransactionMapper {
  static Transaction mapFromEntityAndConvert(
    TransactionEntity entity,
    double rateToUserCurrency,
    Category category,
  ) {
    return Transaction(
      id: entity.id,
      isExpense: entity.isExpense,
      originalAmount: entity.amount,
      convertedAmount: entity.amount * rateToUserCurrency,
      category: category,
      date: entity.date,
      description: entity.description,
      originalCurrency: entity.currency,
    );
  }

  static Transaction mapFromEntity(
    TransactionEntity entity,
    List<Category> categories,
  ) {
    print(entity.categoryId);
    final category =
        categories.firstWhere((cat) => cat.id == entity.categoryId);

    return Transaction(
      id: entity.id,
      isExpense: entity.isExpense,
      originalAmount: entity.amount,
      convertedAmount: entity.amount,
      category: category,
      date: entity.date,
      description: entity.description,
      originalCurrency: entity.currency,
    );
  }

  static TransactionEntity toEntity(Transaction transaction) {
    return TransactionEntity(
      id: transaction.id,
      isExpense: transaction.isExpense,
      amount: transaction.originalAmount,
      date: transaction.date,
      description: transaction.description,
      currency: transaction.originalCurrency,
      categoryId: transaction.category!.id,
    );
  }
}
