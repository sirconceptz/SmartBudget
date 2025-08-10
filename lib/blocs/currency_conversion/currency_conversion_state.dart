import 'package:equatable/equatable.dart';
import 'package:smart_budget/models/currency_rate.dart';

abstract class CurrencyConversionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CurrencyRatesLoading extends CurrencyConversionState {}

class CurrencyRatesLoaded extends CurrencyConversionState {
  final List<CurrencyRate> rates;
  final bool fromCache;
  final bool isStale;

  CurrencyRatesLoaded(this.rates,
      {this.fromCache = false, this.isStale = false});

  @override
  List<Object?> get props => [rates];
}

class CurrencyRatesError extends CurrencyConversionState {
  final String message;

  CurrencyRatesError(this.message);

  @override
  List<Object?> get props => [message];
}
