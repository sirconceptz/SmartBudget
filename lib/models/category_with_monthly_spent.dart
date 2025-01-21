import '../utils/enums/currency.dart';
import 'monthly_spent.dart';

class CategoryWithMonthlySpent {
  final int? id;
  final String name;
  final String description;
  final int? icon;
  final bool isIncome;
  final Currency currency;
  final List<MonthlySpent> monthlySpentList;

  CategoryWithMonthlySpent({
    this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.isIncome,
    required this.currency,
    required this.monthlySpentList,
  });
}
