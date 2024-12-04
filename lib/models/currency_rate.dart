class CurrencyRate {
  final String code;
  final String name;
  final double rate;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'rate': rate,
    };
  }

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
