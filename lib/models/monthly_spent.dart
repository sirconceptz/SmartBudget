class MonthlySpent {
  final String monthKey; // example: "2025-01"
  final double spentAmount;

  MonthlySpent({
    required this.monthKey,
    required this.spentAmount,
  });

  MonthlySpent copyWith({
    String? monthKey,
    double? spentAmount,
  }) {
    return MonthlySpent(
      monthKey: monthKey ?? this.monthKey,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  factory MonthlySpent.fromJson(Map<String, dynamic> json) {
    return MonthlySpent(
      monthKey: json['monthKey'] as String,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthKey': monthKey,
      'spentAmount': spentAmount,
    };
  }
}
