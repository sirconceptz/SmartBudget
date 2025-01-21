import '../../models/category.dart';
import '../../models/category_entity.dart';

class CategoryMapper {
  static Category mapFromEntity(CategoryEntity entity) {
    return Category(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      description: entity.description,
      budgetLimit: entity.budgetLimit,
      convertedBudgetLimit: null,
      isIncome: entity.isIncome,
      currency: entity.currency,
      transactions: [],
      monthlySpent: [],
    );
  }

  static CategoryEntity toEntity(Category category) {
    return CategoryEntity(
      id: category.id,
      name: category.name,
      description: category.description,
      icon: category.icon,
      budgetLimit: category.budgetLimit,
      isIncome: category.isIncome,
      currency: category.currency,
    );
  }
}
