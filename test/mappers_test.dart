import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/data/mappers/transaction_mapper.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/models/transaction_entity.dart';
import 'package:smart_budget/utils/enums/currency.dart';

void main() {
  test('TransactionMapper correctly maps entity to model', () {
    final entity = TransactionEntity(
      id: 1,
      amount: 100.0,
      categoryId: 2,
      currency: Currency.usd,
      date: DateTime.now(),
      description: 'Test transaction',
      type: 1,
    );

    final category = Category(
      id: 2,
      name: 'Test Category',
      isIncome: false,
    );

    final conversionRate = 1.2;

    final model = TransactionMapper.mapFromEntity(entity, conversionRate, category);

    expect(model.id, 1);
    expect(model.convertedAmount, 120.0);
    expect(model.category, category);
    expect(model.originalCurrency, Currency.usd);
    expect(model.description, 'Test transaction');
  });
}
