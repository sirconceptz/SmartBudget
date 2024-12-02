class Category {
  final int? id;
  final String name;
  final String? description;
  final String? icon;
  final double? budgetLimit;
  final bool isIncome;

  Category({
    this.id,
    required this.name,
    this.description,
    this.icon,
    this.budgetLimit,
    required this.isIncome,
  });

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    double? budgetLimit,
    bool? isIncome,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isIncome: json['is_income'] == 1,
      budgetLimit: json['budget_limit']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_income': isIncome ? 1 : 0,
      'budget_limit': budgetLimit
    };
  }
}