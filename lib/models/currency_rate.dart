import 'package:equatable/equatable.dart';

class CurrencyRate extends Equatable {
  final String code;
  final String name;
  final double rate;

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
  });

  @override
  List<Object?> get props => [code, name, rate];

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'rate': rate,
    };
  }

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
