import 'package:equatable/equatable.dart';
import 'package:smart_budget/models/currency_rate.dart';

abstract class CurrencyConversionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CurrencyRatesLoading extends CurrencyConversionState {}

class CurrencyRatesLoaded extends CurrencyConversionState {
  final List<CurrencyRate> rates;

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
