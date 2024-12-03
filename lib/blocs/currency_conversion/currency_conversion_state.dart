import 'package:equatable/equatable.dart';

abstract class CurrencyConversionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CurrencyRatesLoading extends CurrencyConversionState {}

class CurrencyRatesLoaded extends CurrencyConversionState {
  final Map<String, double> rates;

  CurrencyRatesLoaded(this.rates);

  @override
  List<Object?> get props => [rates];
}

class CurrencyRatesError extends CurrencyConversionState {
  final String error;

  CurrencyRatesError(this.error);

  @override
  List<Object?> get props => [error];
}
