class TransactionType {
  final int? id;
  final String name;
  final String? description;
  final bool isIncome;

  TransactionType({
    this.id,
    required this.name,
    this.description,
    required this.isIncome,
  });

  TransactionType copyWith({
    int? id,
    String? name,
    String? description,
    bool? isIncome,
  }) {
    return TransactionType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isIncome: json['is_income'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_income': isIncome ? 1 : 0,
    };
  }
}
