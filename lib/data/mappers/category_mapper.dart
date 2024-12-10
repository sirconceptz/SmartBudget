import '../../models/category.dart';
import '../../models/category_entity.dart';

class CategoryMapper {
  static Category mapFromEntity(
      CategoryEntity entity, double rateToUserCurrency) {
    return Category(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      description: entity.description,
      spentAmount: entity.spentAmount != null
          ? entity.spentAmount! * rateToUserCurrency
          : null,
      isIncome: entity.isIncome,
      budgetLimit: entity.budgetLimit,
      convertedBudgetLimit: entity.spentAmount != null
          ? entity.spentAmount! * rateToUserCurrency
          : null,
      currency: entity.currency,
    );
  }

  static CategoryEntity toEntity(Category category) {
    return CategoryEntity(
        id: category.id,
        name: category.name,
        description: category.description,
        icon: category.icon,
        spentAmount: category.spentAmount,
        isIncome: category.isIncome,
        budgetLimit: category.budgetLimit,
        currency: category.currency);
  }
}
