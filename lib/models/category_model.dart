class Category {
  final int? id;
  final String name;
  final String? icon;
  final String? description;
  final double? budgetLimit;
  final bool isEssential;

  Category({
    this.id,
    required this.name,
    this.icon,
    this.description,
    this.budgetLimit,
    this.isEssential = false,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? description,
    double? budgetLimit,
    bool? isEssential,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isEssential: isEssential ?? this.isEssential,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
      budgetLimit: json['budget_limit']?.toDouble(),
      isEssential: json['is_essential'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'budget_limit': budgetLimit,
      'is_essential': isEssential ? 1 : 0,
    };
  }
}
